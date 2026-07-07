import 'package:get_it/get_it.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';


class GemmaService implements IGemmaService {
  GemmaService();

  final _statusController =
      StreamController<GemmaServiceStatus>.broadcast();

  GemmaServiceStatus _currentStatus = const GemmaNotInstalled();
  InferenceChat? _chat;
  InferenceModel? _model;
  bool _isThinkingMode = false;
  List<Tool> _tools = [];
  final Map<String, InferenceChat> _sessions = {};

  @override
  Stream<GemmaServiceStatus> get statusStream => _statusController.stream;

  @override
  GemmaServiceStatus get currentStatus => _currentStatus;

  void _emit(GemmaServiceStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  @override
  void setTools(List<Tool> tools) {
    _tools = tools;
  }

  @override
  Future<void> initialize({bool isThinkingMode = false}) async {
    _isThinkingMode = isThinkingMode;
    try {
      final modelName = GetIt.I.get<IEnvironmentService>().gemmaModelName;
      final installed = await FlutterGemma.isModelInstalled(modelName);
      if (installed) {
        await loadModel(isThinkingMode: isThinkingMode);
      } else {
        _emit(const GemmaNotInstalled());
      }
    } catch (e) {
      debugPrint('GemmaService.initialize error: $e');
      _emit(GemmaError(e));
    }
  }

  @override
  Future<void> downloadModel() async {
    final env = GetIt.I.get<IEnvironmentService>();
    try {
      _emit(const GemmaDownloading(0));
      
      final modelType = _determineModelType(env.gemmaModelName);
      final fileType = _determineModelFileType(env.gemmaModelName);

      await FlutterGemma.installModel(
        modelType: modelType,
        fileType: fileType,
      )
          .fromNetwork(
            env.gemmaModelUrl,
            token: env.huggingFaceApiKey.isNotEmpty
                ? env.huggingFaceApiKey
                : null,
          )
          .withProgress((progress) => _emit(GemmaDownloading(progress)))
          .install();
      await loadModel(isThinkingMode: _isThinkingMode);
    } catch (e) {
      debugPrint('GemmaService.downloadModel error: $e');
      _emit(GemmaError(e, isInstallError: true));
    }
  }

  ModelType _determineModelType(String modelNameOrUrl) {
    final nameLower = modelNameOrUrl.toLowerCase();
    if (nameLower.contains('deepseek')) {
      return ModelType.deepSeek;
    } else if (nameLower.contains('qwen3')) {
      return ModelType.qwen3;
    } else if (nameLower.contains('qwen')) {
      return ModelType.qwen;
    } else if (nameLower.contains('gemma4') || nameLower.contains('gemma-4')) {
      return ModelType.gemma4;
    } else if (nameLower.contains('phi')) {
      return ModelType.phi;
    } else if (nameLower.contains('llama')) {
      return ModelType.llama;
    } else if (nameLower.contains('functiongemma')) {
      return ModelType.functionGemma;
    } else if (nameLower.contains('smollm')) {
      return ModelType.general;
    }
    return ModelType.gemmaIt;
  }

  ModelFileType _determineModelFileType(String modelNameOrUrl) {
    final nameLower = modelNameOrUrl.toLowerCase();
    if (nameLower.endsWith('.task')) {
      return ModelFileType.task;
    } else if (nameLower.endsWith('.bin')) {
      return ModelFileType.binary;
    } else if (nameLower.endsWith('.tflite')) {
      return ModelFileType.binary;
    }
    return ModelFileType.litertlm;
  }


  @override
  Future<void> loadModel({bool isThinkingMode = false}) async {
    _isThinkingMode = isThinkingMode;
    try {
      _emit(const GemmaLoading());
      await _recreateChat(isThinkingMode: isThinkingMode);
      _emit(const GemmaReady());
    } catch (e) {
      debugPrint('GemmaService.loadModel error: $e');
      _emit(GemmaError(e));
    }
  }

  /// Closes the current chat/session and creates a fresh one against the
  /// active model. [loadModel] and [resetChat] both go through here so the
  /// backend/model-type selection can never drift between the two call
  /// sites — resetChat used to omit `preferredBackend: gpu`, which risked a
  /// silent fallback to CPU-only inference on every new conversation.
  Future<void> _recreateChat({required bool isThinkingMode}) async {
    final oldChat = _chat;
    _chat = null;
    await oldChat?.close();

    // Independent sessions (see sendSessionMessage) are tied to the model
    // instance being replaced below — they can't survive a reload.
    final oldSessions = _sessions.values.toList();
    _sessions.clear();
    for (final session in oldSessions) {
      await session.close();
    }

    final env = GetIt.I.get<IEnvironmentService>();
    final modelType = _determineModelType(env.gemmaModelName);

    // Gemma 4 E2B supports 128K context; use 4096 for a good balance of
    // context capacity and memory usage on mobile devices.
    final model = await FlutterGemma.getActiveModel(
      maxTokens: 4096,
      preferredBackend: PreferredBackend.gpu,
    );
    _model = model;
    _chat = await model.createChat(
      systemInstruction: _vegapunkPrompt,
      // Lower temperature = more deterministic = more reliable function calling.
      // Normal mode: 0.2 (was 0.5) — essential for JSON tool call emission.
      // Thinking mode: 0.15 (was 0.3) — structured analytical output.
      temperature: isThinkingMode ? 0.15 : 0.2,
      isThinking: isThinkingMode,
      maxOutputTokens: isThinkingMode ? 512 : 768,
      // ── Native Gemma 4 function calling ──
      // The SDK parses <|tool_call|>...</tool_call|> structured output
      // and yields FunctionCallResponse events in the stream.
      tools: _tools,
      supportsFunctionCalls: _tools.isNotEmpty,
      modelType: modelType,
      toolChoice: _tools.isNotEmpty ? ToolChoice.auto : ToolChoice.none,
    );
  }

  @override
  Stream<ModelResponse> sendMessage(
    String text, {
    String? styleInstruction,
    List<String>? ragContext,
  }) {
    final chat = _chat;
    if (chat == null) {
      return Stream.error(
        StateError('GemmaService: model not ready'),
      );
    }

    bool isCancelled = false;
    late final StreamController<ModelResponse> controller;
    
    controller = StreamController<ModelResponse>(
      onCancel: () async {
        isCancelled = true;
        await chat.stopGeneration();
      },
    );

    () async {
      try {
        final contextBlock = RagContextFraming.loreReference(ragContext);
        final promptText =
            '${RagContextFraming.styleInstruction(styleInstruction)}$contextBlock$text';

        debugPrint('GemmaService: prompt context=${ragContext?.length ?? 0} docs');
        await chat.addQueryChunk(Message(text: promptText, isUser: true));
        await for (final response in chat.generateChatResponseAsync()) {
          if (isCancelled) break;
          controller.add(response);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      } finally {
        if (!controller.isClosed) await controller.close();
      }
    }();

    return controller.stream;
  }

  /// Send a tool result back to the model for the second pass.
  ///
  /// After a [FunctionCallResponse] is received and the tool is executed,
  /// call this to inject the tool result and get the model's final answer.
  Stream<ModelResponse> sendToolResult({
    required String toolName,
    required Map<String, dynamic> result,
  }) {
    final chat = _chat;
    if (chat == null) {
      return Stream.error(StateError('GemmaService: model not ready'));
    }

    bool isCancelled = false;
    late final StreamController<ModelResponse> controller;

    controller = StreamController<ModelResponse>(
      onCancel: () async {
        isCancelled = true;
        await chat.stopGeneration();
      },
    );

    () async {
      try {
        await chat.addQueryChunk(
          Message.toolResponse(toolName: toolName, response: result),
        );
        await for (final response in chat.generateChatResponseAsync()) {
          if (isCancelled) break;
          controller.add(response);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      } finally {
        if (!controller.isClosed) await controller.close();
      }
    }();

    return controller.stream;
  }

  @override
  Stream<ModelResponse> sendSessionMessage(
    String sessionId, {
    required String systemInstruction,
    required String text,
    List<String>? ragContext,
  }) {
    final model = _model;
    if (model == null) {
      return Stream.error(StateError('GemmaService: model not ready'));
    }

    bool isCancelled = false;
    late final StreamController<ModelResponse> controller;

    controller = StreamController<ModelResponse>(
      onCancel: () async {
        isCancelled = true;
        await _sessions[sessionId]?.stopGeneration();
      },
    );

    () async {
      try {
        var session = _sessions[sessionId];
        if (session == null) {
          session = await model.openChat(
            systemInstruction: systemInstruction,
            temperature: 0.3,
            maxOutputTokens: 512,
          );
          _sessions[sessionId] = session;
        }

        // Data is meant to be read and used directly — unlike sendMessage's
        // "reference, only if relevant" framing (built for Vegapunk's lore
        // immersion), a factual assistant like this must actually cite it.
        final contextBlock = RagContextFraming.factualData(ragContext);

        await session.addQueryChunk(
          Message(text: '$contextBlock$text', isUser: true),
        );
        await for (final response in session.generateChatResponseAsync()) {
          if (isCancelled) break;
          controller.add(response);
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      } finally {
        if (!controller.isClosed) await controller.close();
      }
    }();

    return controller.stream;
  }

  @override
  Future<void> closeSession(String sessionId) async {
    final session = _sessions.remove(sessionId);
    await session?.close();
  }

  @override
  Future<void> stopGeneration() async {
    await _chat?.stopGeneration();
  }

  @override
  Future<void> resetChat({bool isThinkingMode = false}) async {
    // No guard on _currentStatus: allow reset from any non-error state.
    // The previous guard (is! GemmaReady) caused deadlocks when the status
    // changed between the time resetChat was scheduled and executed.
    try {
      _emit(const GemmaLoading());
      _isThinkingMode = isThinkingMode;
      await _recreateChat(isThinkingMode: isThinkingMode);
      _emit(const GemmaReady());
    } catch (e) {
      _emit(GemmaError(e));
    }
  }

  @override
  void dispose() {
    _statusController.close();
  }

  String get _vegapunkPrompt =>
      VegapunkPrompt.system(isPortuguese: PromptLocale.isPortuguese());
}

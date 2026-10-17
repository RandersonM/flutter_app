import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';

class GemmaService implements IGemmaService {
  GemmaService({required this._env, required this._localeService});

  final IEnvironmentService _env;
  final ILocaleService _localeService;

  final _statusController = StreamController<GemmaServiceStatus>.broadcast();

  GemmaServiceStatus _currentStatus = const GemmaNotInstalled();
  InferenceChat? _chat;
  InferenceModel? _model;
  bool _isThinkingMode = false;
  List<Tool> _tools = [];
  final Map<String, InferenceChat> _sessions = {};

  /// Bumped by [closeSession] (per session) and [_recreateChat] (all of
  /// them). An `openChat` still in flight when its session is closed finds a
  /// newer stamp and discards the chat instead of storing it.
  final Map<String, int> _sessionEpochs = {};
  int _modelReloads = 0;

  (int, int) _sessionStamp(String sessionId) =>
      (_sessionEpochs[sessionId] ?? 0, _modelReloads);

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
      final modelName = _env.gemmaModelName;
      final installed = await FlutterGemma.isModelInstalled(modelName);
      if (!installed) {
        _emit(const GemmaNotInstalled());
      } else if (_model == null) {
        await loadModel(isThinkingMode: isThinkingMode);
      } else {
        await _refreshVegapunkChat(isThinkingMode: isThinkingMode);
      }
    } catch (e) {
      debugPrint('GemmaService.initialize error: $e');
      _emit(GemmaError(e));
    }
  }

  /// Re-entering Vegapunk (or toggling thinking mode) only needs a fresh
  /// singleton chat — current locale, clean context. Reopening the model would
  /// also close every named session, Nami's included.
  Future<void> _refreshVegapunkChat({required bool isThinkingMode}) async {
    _emit(const GemmaLoading());
    try {
      await _createVegapunkChat(isThinkingMode: isThinkingMode);
    } catch (e) {
      debugPrint('GemmaService: chat refresh failed, reloading model: $e');
      await _recreateChat(isThinkingMode: isThinkingMode);
    }
    _emit(const GemmaReady());
  }

  @override
  Future<void> downloadModel() async {
    try {
      _emit(const GemmaDownloading(0));

      final modelType = _determineModelType(_env.gemmaModelName);
      final fileType = _determineModelFileType(_env.gemmaModelName);

      await FlutterGemma.installModel(modelType: modelType, fileType: fileType)
          .fromNetwork(
            _env.gemmaModelUrl,
            token: _env.huggingFaceApiKey.isNotEmpty
                ? _env.huggingFaceApiKey
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

  /// Gemma 4 E2B supports 128K context; 4096 balances context capacity against
  /// memory usage on mobile.
  static const int _maxTokens = 4096;

  /// Backends to try, in order. GPU first for throughput, CPU as the last
  /// resort so a Metal-init failure degrades performance instead of breaking
  /// the feature outright.
  static const List<PreferredBackend> _backendPreference = [
    PreferredBackend.gpu,
    PreferredBackend.cpu,
  ];

  /// Opens the active model, trying each backend in [_backendPreference].
  ///
  /// Rethrows the last error if every backend fails, so the caller still emits
  /// [GemmaError] rather than silently continuing without a model.
  Future<InferenceModel> _openModelWithFallback() async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (final backend in _backendPreference) {
      try {
        final model = await FlutterGemma.getActiveModel(
          maxTokens: _maxTokens,
          preferredBackend: backend,
        );
        if (backend != _backendPreference.first) {
          debugPrint(
            'GemmaService: opened model on ${backend.name} after '
            '${_backendPreference.first.name} failed — inference will be slower',
          );
        }
        return model;
      } catch (e, st) {
        debugPrint('GemmaService: ${backend.name} backend failed: $e');
        lastError = e;
        lastStackTrace = st;
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }

  /// Full reload: closes the chat and every named session, reopens the model
  /// through [_openModelWithFallback], then creates the Vegapunk chat. Only
  /// needed when no model is open yet or a refresh failed — routine resets use
  /// [_refreshVegapunkChat], which keeps the model and other sessions alive.
  Future<void> _recreateChat({required bool isThinkingMode}) async {
    final oldChat = _chat;
    _chat = null;
    await oldChat?.close();

    // Independent sessions (see sendSessionMessage) are tied to the model
    // instance being replaced below — they can't survive a reload.
    final oldSessions = _sessions.values.toList();
    _sessions.clear();
    _modelReloads++;
    for (final session in oldSessions) {
      await session.close();
    }

    // GPU (Metal) is preferred for speed, but its init can fail on devices
    // where the accelerator is unavailable or cannot fit the model — so fall
    // back to CPU rather than leaving the chat unusable. The plugin resets its
    // cached model instance when createModel throws, so the retry really does
    // build a fresh one instead of replaying the failed attempt.
    //
    // Note: this only recovers *reported* failures. If the OS kills the process
    // for exceeding its memory limit there is no Dart error to catch — that is
    // what the increased-memory-limit entitlement in Runner.entitlements is for.
    _model = await _openModelWithFallback();
    await _createVegapunkChat(isThinkingMode: isThinkingMode);
  }

  Future<void> _createVegapunkChat({required bool isThinkingMode}) async {
    final oldChat = _chat;
    _chat = null;
    await oldChat?.close();

    final modelType = _determineModelType(_env.gemmaModelName);
    _chat = await _model!.createChat(
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
        final contextBlock = RagContextFraming.loreReference(ragContext);
        final promptText =
            '${RagContextFraming.styleInstruction(styleInstruction)}$contextBlock$text';

        debugPrint(
          'GemmaService: prompt context=${ragContext?.length ?? 0} docs',
        );
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

  @override
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
    List<Tool>? tools,
    int maxOutputTokens = 512,
  }) {
    final model = _model;
    if (model == null) {
      return Stream.error(StateError('GemmaService: model not ready'));
    }

    bool isCancelled = false;
    InferenceChat? session;
    late final StreamController<ModelResponse> controller;

    controller = StreamController<ModelResponse>(
      onCancel: () async {
        isCancelled = true;
        await session?.stopGeneration();
      },
    );

    () async {
      try {
        final chat =
            _sessions[sessionId] ??
            await _openSession(
              sessionId,
              model,
              systemInstruction: systemInstruction,
              tools: tools,
              maxOutputTokens: maxOutputTokens,
            );
        session = chat;
        if (isCancelled) return;

        // Data is meant to be read and used directly — unlike sendMessage's
        // "reference, only if relevant" framing (built for Vegapunk's lore
        // immersion), a factual assistant like this must actually cite it.
        final contextBlock = RagContextFraming.factualData(ragContext);

        await chat.addQueryChunk(
          Message(text: '$contextBlock$text', isUser: true),
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

  Future<InferenceChat> _openSession(
    String sessionId,
    InferenceModel model, {
    required String systemInstruction,
    required List<Tool>? tools,
    required int maxOutputTokens,
  }) async {
    final stamp = _sessionStamp(sessionId);
    final hasTools = tools != null && tools.isNotEmpty;
    final session = await model.openChat(
      systemInstruction: systemInstruction,
      // Lower temperature for reliable function-call JSON emission when
      // tools are attached (matches the main chat's tuning).
      temperature: hasTools ? 0.2 : 0.3,
      maxOutputTokens: maxOutputTokens,
      tools: tools ?? const [],
      supportsFunctionCalls: hasTools,
      toolChoice: hasTools ? ToolChoice.auto : ToolChoice.none,
      modelType: _determineModelType(_env.gemmaModelName),
    );
    if (_sessionStamp(sessionId) != stamp) {
      await session.close();
      throw StateError(
        'GemmaService: session "$sessionId" closed while opening',
      );
    }
    _sessions[sessionId] = session;
    return session;
  }

  @override
  Stream<ModelResponse> sendSessionToolResult(
    String sessionId, {
    required String toolName,
    required Map<String, dynamic> result,
  }) {
    final session = _sessions[sessionId];
    if (session == null) {
      return Stream.error(
        StateError('GemmaService: session "$sessionId" not open'),
      );
    }

    bool isCancelled = false;
    late final StreamController<ModelResponse> controller;

    controller = StreamController<ModelResponse>(
      onCancel: () async {
        isCancelled = true;
        await session.stopGeneration();
      },
    );

    () async {
      try {
        await session.addQueryChunk(
          Message.toolResponse(toolName: toolName, response: result),
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
    _sessionEpochs.update(sessionId, (epoch) => epoch + 1, ifAbsent: () => 1);
    final session = _sessions.remove(sessionId);
    if (session == null) return;
    try {
      await session.stopGeneration();
    } catch (e) {
      debugPrint('GemmaService: stopping session "$sessionId" failed: $e');
    }
    await session.close();
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
    _isThinkingMode = isThinkingMode;
    try {
      await _refreshVegapunkChat(isThinkingMode: isThinkingMode);
    } catch (e) {
      _emit(GemmaError(e));
    }
  }

  @override
  void dispose() {
    _statusController.close();
  }

  String get _vegapunkPrompt => VegapunkPrompt.system(
    isPortuguese: PromptLocale.isPortuguese(_localeService),
  );
}

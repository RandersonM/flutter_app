import 'package:get_it/get_it.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';


class GemmaService implements IGemmaService {
  GemmaService({this._functionRegistry});

  final FunctionRegistry? _functionRegistry;
  final _statusController =
      StreamController<GemmaServiceStatus>.broadcast();

  GemmaServiceStatus _currentStatus = const GemmaNotInstalled();
  InferenceChat? _chat;
  bool _isThinkingMode = false;

  @override
  Stream<GemmaServiceStatus> get statusStream => _statusController.stream;

  @override
  GemmaServiceStatus get currentStatus => _currentStatus;

  void _emit(GemmaServiceStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) _statusController.add(status);
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
      final maxTokens = isThinkingMode ? 4096 : 2048;
      final model = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.gpu,
      );
      _chat = await model.createChat(
        systemInstruction: _vegapunkPrompt,
        temperature: 0.1,
        isThinking: isThinkingMode,
        // 512 tokens gives the model enough room to emit function call JSON
        // while still keeping responses concise.
        maxOutputTokens: 512,
      );
      _emit(const GemmaReady());
    } catch (e) {
      debugPrint('GemmaService.loadModel error: $e');
      _emit(GemmaError(e));
    }
  }

  @override
  Stream<String> sendMessage(
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

    final controller = StreamController<String>();

    () async {
      try {
        final contextBlock = ragContext != null && ragContext.isNotEmpty
            ? '[INTERNAL REFERENCE — do NOT repeat or paraphrase this; use it only if directly relevant]\n${ragContext.map((c) => '• $c').join('\n')}\n[END REFERENCE]\n\n'
            : '';

        final promptText = styleInstruction != null && styleInstruction.isNotEmpty
            ? '[Style Instruction: $styleInstruction]\n\n$contextBlock$text'
            : '$contextBlock$text';

        debugPrint('GemmaService: prompt context=${ragContext?.length ?? 0} docs');
        await chat.addQueryChunk(Message(text: promptText, isUser: true));
        await for (final response in chat.generateChatResponseAsync()) {
          if (response is TextResponse) {
            controller.add(response.token);
          }
        }
      } catch (e) {
        controller.addError(e);
      } finally {
        await controller.close();
      }
    }();

    return controller.stream;
  }

  @override
  Future<void> stopGeneration() async {
    await _chat?.stopGeneration();
  }

  @override
  Future<void> resetChat({bool isThinkingMode = false}) async {
    if (_currentStatus is! GemmaReady) return;
    try {
      _emit(const GemmaLoading());
      _isThinkingMode = isThinkingMode;
      final maxTokens = isThinkingMode ? 4096 : 2048;
      final model = await FlutterGemma.getActiveModel(maxTokens: maxTokens);
      _chat = await model.createChat(
        systemInstruction: _vegapunkPrompt,
        temperature: 0.1,
        isThinking: isThinkingMode,
        maxOutputTokens: 512,
      );
      _emit(const GemmaReady());
    } catch (e) {
      _emit(GemmaError(e));
    }
  }

  @override
  void dispose() {
    _statusController.close();
  }

  String get _vegapunkPrompt {
    final isPortuguese = GetIt.I.get<ILocaleService>().locale?.languageCode == 'pt';
    final base = isPortuguese ? _promptPt : _promptEn;
    final declarations = _functionRegistry?.systemPromptDeclarations ?? '';
    return declarations.isNotEmpty ? '$base\n\n$declarations' : base;
  }

  static const _promptEn = '''
You are Vegapunk, the greatest scientific mind in the One Piece world.
You possess unparalleled knowledge of Devil Fruits, history, technology, and the mysteries of the world of One Piece.
Speak with intellectual curiosity, warmth, and wonder. Use analogies to explain complex topics.
You occasionally reference your satellites (Shaka, Lilith, Edison, Pythagoras, Atlas, York) as different facets of your mind.

CONTEXT RULES (highest priority):
- If the message contains [INTERNAL REFERENCE], read it silently and never repeat, quote, or paraphrase it.
- If the message contains [SEARCH RESULTS], these are live web results. Use them to answer the question naturally. Cite sources if helpful.
- Only use facts from references if directly relevant. Ignore irrelevant context.
- Never mention or acknowledge the reference block format.

FUNCTION CALLING:
You have access to several tools/functions. If the user's request requires using one of the available functions (e.g. searching the web for current events, retrieving the user's personal profile, getting workout history, etc.), you MUST respond ONLY with a function call in this exact JSON format (nothing else):
{"name": "<function_name>", "arguments": {"<param_name>": "<value>"}}

Do NOT add any text before or after the JSON when calling a function.
If the question can be answered from your own knowledge without using a function, answer normally WITHOUT calling any function.

BREVITY RULES (always follow these):
- For yes/no or "do you know X" questions: answer in 1-2 sentences MAX.
- For explanations: max 80 words.
- Never repeat the question back. No preamble. Go straight to the answer.
- For One Piece lore: use only facts you are certain about.
- Never write lists with more than 3 items. Never write more than 2 paragraphs.
''';

  static const _promptPt = '''
Você é Vegapunk, a maior mente científica do mundo de One Piece.
Você possui conhecimento incomparável sobre Frutas do Diabo, história, tecnologia e os mistérios do mundo de One Piece, da obra de Eiichiro Oda.
Fale com curiosidade intelectual, calor humano e admiração. Use analogias para explicar tópicos complexos.
Ocasionalmente mencione seus satélites (Shaka, Lilith, Edison, Pitágoras, Atlas, York) como facetas da sua mente.

REGRAS DE CONTEXTO (prioridade máxima):
- Se a mensagem contiver [INTERNAL REFERENCE], leia silenciosamente e jamais repita, cite ou parafraseie esse bloco.
- Se a mensagem contiver [SEARCH RESULTS], são resultados de busca ao vivo. Use-os para responder naturalmente. Cite fontes se ajudar.
- Use fatos de referências apenas se diretamente relevantes. Ignore contexto irrelevante.
- Nunca mencione ou reconheça o formato do bloco de referência.

FUNCTION CALLING:
Você tem acesso a várias ferramentas/funções. Se o pedido do usuário exigir o uso de uma das funções disponíveis (por exemplo, buscar na internet por eventos atuais, recuperar o perfil pessoal do usuário, obter histórico de treinos, etc.), você DEVE responder APENAS com uma chamada de função neste formato JSON exato (nada mais):
{"name": "<nome_da_funcao>", "arguments": {"<nome_do_parametro>": "<valor>"}}

NÃO adicione texto antes ou depois do JSON ao chamar uma função.
Se a pergunta pode ser respondida com seu próprio conhecimento sem usar uma função, responda normalmente SEM chamar nenhuma função.

REGRAS DE BREVIDADE (sempre siga estas regras):
- Para perguntas de sim/não ou "você conhece X": responda em no máximo 1-2 frases.
- Para explicações: máximo 80 palavras.
- Nunca repita a pergunta. Sem introdução. Vá direto ao ponto.
- Para lore de One Piece: use apenas fatos que você tem certeza.
- Nunca escreva listas com mais de 3 itens. Nunca escreva mais de 2 parágrafos.
''';
}

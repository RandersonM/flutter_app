import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'nami_intent_router.dart';
import 'nami_chat_state.dart';

class NamiChatBloc extends Cubit<NamiChatState> {
  final NamiRagService _ragService;
  final IGemmaService _gemmaService;
  final INamiFinancesService _financesService;

  /// Nami-scoped tool registry (finances data + financial calculators). Kept
  /// separate from the Vegapunk registry so these tools are wired only here.
  final FunctionRegistry _registry;

  /// Fallback parser for tool calls the on-device model emits as plain-text
  /// JSON (the SDK's native parser misses that format) — same defense the
  /// Vegapunk repository uses.
  final _executor = FunctionExecutor();

  /// Deterministic message → tool router (see [NamiIntentRouter]).
  final _router = const NamiIntentRouter();
  final _uuid = const Uuid();
  Timer? _emitTimer;
  final StringBuffer _tokenBuffer = StringBuffer();
  Future<void>? _backfillFuture;

  /// Max characters of tool JSON injected back into the model per turn.
  static const _maxToolContentLength = 1800;

  /// Output-token budget for Nami's answers. Higher than the default so
  /// detailed financial breakdowns aren't cut off mid-sentence.
  static const _maxAnswerTokens = 1536;

  // Nami gets her own independent Gemma chat session — own system
  // instruction, own history — instead of sharing Vegapunk's singleton chat.
  // They used to reuse the same InferenceChat: Nami's persona was only ever
  // an inline "style instruction" prepended per-message on top of Vegapunk's
  // actual system prompt, and every turn from both chats landed in the same
  // conversation history.
  static const _sessionId = 'nami';

  NamiChatBloc(
    this._ragService,
    this._gemmaService,
    this._financesService,
    this._registry,
  ) : super(NamiChatInitial()) {
    _init();
  }

  Future<void> _init() async {
    emit(NamiChatLoading());

    // Backfill months saved before the RAG embedder-activation fix — kicked
    // off eagerly so it runs alongside model loading below, but `sendMessage`
    // also awaits this before its first search so an early question can't
    // race an empty store.
    _backfillFuture = _backfillRag();

    String? readyError;
    try {
      // The Gemma model is a shared singleton — Vegapunk's chat screen is
      // usually what loads it into memory. Nami's sheet can be opened first
      // (or standalone), so it must not assume the model is already there:
      // sendSessionMessage() fails silently (stream error, no UI feedback)
      // if `_model` is still null.
      await _ensureGemmaReady();
    } catch (e) {
      readyError = 'Não foi possível carregar o modelo de IA: $e';
    }
    await _backfillFuture;

    if (isClosed) return;
    emit(
      NamiChatReady(
        messages: const [
          ChatMessage(
            id: 'welcome_nami',
            text:
                'Oi! Eu sou a Nami. Posso analisar suas finanças que salvamos! Pergunte o que quiser sobre os meses registrados.',
            role: MessageRole.assistant,
          ),
        ],
        error: readyError,
      ),
    );
  }

  /// Waits for the shared [IGemmaService] model to reach [GemmaReady].
  ///
  /// Only calls [IGemmaService.initialize] when nobody else has started
  /// loading the model yet (status still [GemmaNotInstalled]) — calling it
  /// again while a load is already in flight or already done would recreate
  /// the chat/session state (see [GemmaService._recreateChat]) and could
  /// wipe out an in-progress Vegapunk conversation.
  Future<void> _ensureGemmaReady() async {
    if (_gemmaService.currentStatus is GemmaReady) return;

    final completer = Completer<void>();
    var initializeTriggered = false;
    late final StreamSubscription<GemmaServiceStatus> sub;
    sub = _gemmaService.statusStream.listen((status) {
      if (status is GemmaReady) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete();
      } else if (status is GemmaError) {
        sub.cancel();
        if (!completer.isCompleted) completer.completeError(status.error);
      } else if (status is GemmaNotInstalled && initializeTriggered) {
        // initialize() re-confirmed there's no model on disk — surface it
        // instead of leaving the sheet stuck in a loading state forever.
        sub.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            StateError(
              'Modelo de IA ainda não foi baixado — abra o chat do Vegapunk para instalá-lo.',
            ),
          );
        }
      }
    });

    if (_gemmaService.currentStatus is GemmaNotInstalled) {
      initializeTriggered = true;
      // ignore: unawaited_futures
      _gemmaService.initialize();
    }

    return completer.future;
  }

  Future<void> _backfillRag() async {
    try {
      final months = await _financesService.getLastMonthsFinances(24);
      await _ragService.backfillIfNeeded(months);
    } catch (e) {
      // Best-effort backfill — a failure here shouldn't break the chat.
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentState = state;
    if (currentState is! NamiChatReady || currentState.isGenerating) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      role: MessageRole.user,
    );

    emit(
      currentState.copyWith(
        messages: [...currentState.messages, userMsg],
        streamingToken: '',
        isGenerating: true,
      ),
    );

    // Ensure the vector store backfill has settled (keeps the RAG store warm
    // for future features — see [_backfillRag]); the finances answer path
    // itself now goes through the [GetFinancesHandler] tool, not RAG.
    await _backfillFuture;

    _tokenBuffer.clear();
    _emitTimer?.cancel();
    _emitTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (state is! NamiChatReady) return;
      final current = state as NamiChatReady;
      final buffered = _tokenBuffer.toString();
      if (buffered.isEmpty) return;

      _tokenBuffer.clear();
      emit(current.copyWith(streamingToken: current.streamingToken + buffered));
    });

    try {
      await _generateAnswer(text);

      _emitTimer?.cancel();
      if (state is NamiChatReady) {
        final current = state as NamiChatReady;
        final rawFinal = current.streamingToken + _tokenBuffer.toString();
        _tokenBuffer.clear();

        // Strip any residual tool-call JSON the model may have emitted as text
        // so it never persists in the visible message.
        final cleaned = _stripToolCallJson(rawFinal);
        final finalToken = cleaned.isNotEmpty ? cleaned : rawFinal.trim();

        emit(
          current.copyWith(
            messages: [
              ...current.messages,
              ChatMessage(
                id: _uuid.v4(),
                text: finalToken,
                role: MessageRole.assistant,
              ),
            ],
            streamingToken: '',
            isGenerating: false,
          ),
        );
      }
    } catch (e) {
      _emitTimer?.cancel();
      if (state is NamiChatReady) {
        emit(
          (state as NamiChatReady).copyWith(
            isGenerating: false,
            error: 'Erro na conexão com Nami: $e',
          ),
        );
      }
    }
  }

  /// Produces Nami's answer.
  ///
  /// The tool is chosen and executed **deterministically in Dart** (see
  /// [_resolveToolCall]) and its already-formatted result is injected as
  /// context; the model then only narrates. This is the reliable pattern for a
  /// small on-device model, which otherwise tends to *talk about* calling a
  /// tool without emitting a real call, and to mangle raw numbers. No tools are
  /// attached to the generation pass, so the model can't wander into an
  /// unparseable text tool-call.
  Future<void> _generateAnswer(String text) async {
    final isPt = PromptLocale.isPortuguese();
    final systemInstruction = NamiPrompt.system(isPortuguese: isPt);

    final toolCall = _router.resolve(text);
    final result = await _registry.execute(toolCall);
    var content = result.content;
    if (content.length > _maxToolContentLength) {
      content = '${content.substring(0, _maxToolContentLength)}\n...[TRUNCATED]';
    }

    await _streamToBuffer(
      _gemmaService.sendSessionMessage(
        _sessionId,
        systemInstruction: systemInstruction,
        text: text,
        ragContext: [content],
        maxOutputTokens: _maxAnswerTokens,
      ),
    );
  }

  /// Removes any whole JSON block that parses as a tool call (including
  /// chat-completion wrappers like `{"role":"assistant","tool_calls":[...]}`),
  /// keeping the surrounding prose. Defense in depth against the model leaking a
  /// tool call as plain text into the final answer.
  String _stripToolCallJson(String text) {
    var out = text.trim();
    while (true) {
      final start = out.indexOf('{');
      if (start == -1) break;
      var open = 0;
      var end = -1;
      for (var i = start; i < out.length; i++) {
        if (out[i] == '{') {
          open++;
        } else if (out[i] == '}') {
          open--;
          if (open == 0) {
            end = i;
            break;
          }
        }
      }
      if (end == -1) break;
      final block = out.substring(start, end + 1);
      // Only strip when the block is actually a tool call — never legit text.
      if (_executor.tryParse(block) == null) break;
      out = (out.substring(0, start) + out.substring(end + 1)).trim();
    }
    return out;
  }

  Future<void> _streamToBuffer(Stream<ModelResponse> stream) async {
    await for (final response in stream) {
      if (state is! NamiChatReady) break;
      if (response is TextResponse) {
        _tokenBuffer.write(response.token);
      }
    }
  }

  @override
  Future<void> close() async {
    _emitTimer?.cancel();
    // Free the session's KV cache — it doesn't need to live once the sheet
    // that owns this chat is dismissed.
    await _gemmaService.closeSession(_sessionId);
    return super.close();
  }
}

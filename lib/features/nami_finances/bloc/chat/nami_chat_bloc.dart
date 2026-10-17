import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'nami_intent_router.dart';
import 'nami_chat_state.dart';

class NamiChatBloc extends Cubit<NamiChatState> {
  final INamiRagService _ragService;
  final IGemmaService _gemmaService;
  final INamiFinancesService _financesService;

  /// Nami-scoped tool registry (finances data + financial calculators). Kept
  /// separate from the Vegapunk registry so these tools are wired only here.
  final FunctionRegistry _registry;
  final ILocaleService _localeService;

  /// Fallback parser for tool calls the on-device model emits as plain-text
  /// JSON (the SDK's native parser misses that format) — same defense the
  /// Vegapunk repository uses.
  final _executor = FunctionExecutor();

  /// Deterministic message → tool router (see [NamiIntentRouter]).
  final _router = const NamiIntentRouter();
  final _uuid = const Uuid();
  Timer? _emitTimer;
  final StringBuffer _tokenBuffer = StringBuffer();
  Future<void>? _backfillSettled;
  StreamSubscription<GemmaServiceStatus>? _modelStatusSub;
  StreamSubscription<ModelResponse>? _answerSub;
  Completer<void>? _answerDone;

  /// Same watchdog as Vegapunk's: native inference can stall after an OS
  /// lifecycle interruption and the stream then never emits again.
  static const _generationTimeout = Duration(seconds: 90);
  Timer? _watchdogTimer;

  /// The tool step runs before the answer stream, so the watchdog can't see
  /// it; a tool stuck on the embedder or the store gets the same budget.
  static const _toolTimeout = _generationTimeout;

  /// The chat works without the RAG backfill (`findExpenses` just finds
  /// less), and its first run after a migration may wait on the embedder
  /// download — so the chat waits this long at most and the backfill carries
  /// on in the background.
  static const _backfillWaitLimit = Duration(seconds: 5);

  /// Longest silence on the model status stream while waiting for the model.
  /// Re-armed on every status, so download progress keeps it alive.
  static const _modelLoadTimeout = Duration(minutes: 2);

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
    this._registry, {
    required this._localeService,
  }) : super(NamiChatInitial()) {
    _init();
  }

  Future<void> _init() async {
    emit(NamiChatLoading());

    // Backfill months saved before the RAG embedder-activation fix — kicked
    // off eagerly so it runs alongside model loading below, and awaited
    // (bounded) before the chat is ready so an early question doesn't race
    // an empty store.
    _backfillSettled = _backfillRag().timeout(
      _backfillWaitLimit,
      onTimeout: () =>
          debugPrint('NamiChatBloc: rag backfill still running, not waiting'),
    );

    NamiChatFailure? readyFailure;
    try {
      // The Gemma model is a shared singleton — Vegapunk's chat screen is
      // usually what loads it into memory. Nami's sheet can be opened first
      // (or standalone), so it must not assume the model is already there:
      // sendSessionMessage() fails silently (stream error, no UI feedback)
      // if `_model` is still null.
      await _ensureGemmaReady();
    } on _GemmaModelNotInstalled {
      readyFailure = NamiChatFailure.modelNotInstalled;
    } catch (e) {
      debugPrint('NamiChatBloc: model load failed: $e');
      readyFailure = NamiChatFailure.modelLoadFailed;
    }
    await _backfillSettled;

    if (isClosed) return;
    emit(NamiChatReady(failure: readyFailure));
  }

  /// Waits for the shared [IGemmaService] model to reach [GemmaReady].
  ///
  /// Only calls [IGemmaService.initialize] when nobody else has started
  /// loading the model yet (status still [GemmaNotInstalled]) — calling it
  /// again while a load is already in flight or already done would recreate
  /// the chat/session state (see [GemmaService._recreateChat]) and could
  /// wipe out an in-progress Vegapunk conversation. A model already in
  /// [GemmaError] fails right away: no new status will come on its own.
  Future<void> _ensureGemmaReady() {
    final current = _gemmaService.currentStatus;
    if (current is GemmaReady) return Future.value();
    if (current is GemmaError) return Future.error(_loadError(current));

    final initializeHere = current is GemmaNotInstalled;
    final completer = Completer<void>();
    void finish([Object? error]) {
      _modelStatusSub?.cancel();
      _modelStatusSub = null;
      if (completer.isCompleted) return;
      error == null ? completer.complete() : completer.completeError(error);
    }

    _modelStatusSub = _gemmaService.statusStream
        .timeout(_modelLoadTimeout)
        .listen((status) {
          switch (status) {
            case GemmaReady():
              finish();
            case GemmaError():
              finish(_loadError(status));
            // initialize() re-confirmed there's no model on disk.
            case GemmaNotInstalled() when initializeHere:
              finish(const _GemmaModelNotInstalled());
            default:
          }
        }, onError: finish);

    if (initializeHere) unawaited(_gemmaService.initialize());
    return completer.future;
  }

  Object _loadError(GemmaError status) =>
      status.isInstallError ? const _GemmaModelNotInstalled() : status.error;

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
      timestamp: DateTime.now(),
    );

    emit(
      currentState.copyWith(
        messages: [...currentState.messages, userMsg],
        streamingToken: '',
        isGenerating: true,
      ),
    );

    // Give the vector store backfill its bounded wait (keeps the RAG store
    // warm for future features — see [_backfillRag]); the finances answer
    // path itself now goes through the [GetFinancesHandler] tool, not RAG.
    await _backfillSettled;
    if (isClosed) return;

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

    NamiChatFailure? failure;
    try {
      await _generateAnswer(text);
    } on _GenerationTimedOut {
      failure = NamiChatFailure.generationTimedOut;
    } catch (e) {
      debugPrint('NamiChatBloc: answer generation failed: $e');
      failure = NamiChatFailure.connectionFailed;
    }
    _emitTimer?.cancel();
    if (isClosed) return;

    final current = state;
    if (current is! NamiChatReady) return;
    if (failure == NamiChatFailure.connectionFailed) {
      emit(current.copyWith(isGenerating: false, failure: failure));
      return;
    }
    final answer = _finalAnswer(current.streamingToken);
    emit(
      current.copyWith(
        messages: [
          ...current.messages,
          if (answer.isNotEmpty)
            ChatMessage(
              id: _uuid.v4(),
              text: answer,
              role: MessageRole.assistant,
              timestamp: DateTime.now(),
            ),
        ],
        streamingToken: '',
        isGenerating: false,
        failure: failure,
      ),
    );
  }

  /// Streamed text plus what the emit timer has not flushed yet, without any
  /// tool-call JSON the model leaked as text.
  String _finalAnswer(String streamed) {
    final raw = streamed + _tokenBuffer.toString();
    _tokenBuffer.clear();
    final cleaned = _stripToolCallJson(raw);
    return cleaned.isNotEmpty ? cleaned : raw.trim();
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
    final isPt = PromptLocale.isPortuguese(_localeService);
    final systemInstruction = NamiPrompt.system(isPortuguese: isPt);

    final toolCall = _router.resolve(text);
    final result = await _registry
        .execute(toolCall)
        .timeout(
          _toolTimeout,
          onTimeout: () => throw const _GenerationTimedOut(),
        );
    // The session is opened lazily by the call below; opening it after close()
    // would leave its KV cache allocated with nobody to close it.
    if (isClosed) return;
    var content = result.content;
    if (content.length > _maxToolContentLength) {
      content =
          '${content.substring(0, _maxToolContentLength)}\n...[TRUNCATED]';
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

  /// Completes when [stream] ends, or with [_GenerationTimedOut] when the
  /// watchdog cancels it.
  Future<void> _streamToBuffer(Stream<ModelResponse> stream) {
    final done = Completer<void>();
    _answerDone = done;
    _armWatchdog();
    _answerSub = stream.listen(
      (response) {
        _armWatchdog();
        if (response is TextResponse) _tokenBuffer.write(response.token);
      },
      onError: (Object e) => _settleAnswer(e),
      onDone: _settleAnswer,
      cancelOnError: true,
    );
    return done.future;
  }

  void _armWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_generationTimeout, () {
      debugPrint(
        'NamiChatBloc: generation watchdog fired — '
        'no token for ${_generationTimeout.inSeconds}s, cancelling',
      );
      unawaited(_cancelAnswer(const _GenerationTimedOut()));
    });
  }

  /// Cancelling the subscription is what stops the session's generation.
  Future<void> _cancelAnswer([Object? reason]) async {
    final sub = _answerSub;
    _settleAnswer(reason);
    await sub?.cancel();
  }

  void _settleAnswer([Object? error]) {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _answerSub = null;
    final done = _answerDone;
    _answerDone = null;
    if (done == null || done.isCompleted) return;
    error == null ? done.complete() : done.completeError(error);
  }

  @override
  Future<void> close() async {
    _emitTimer?.cancel();
    // Started before any await so isClosed is already true for handlers
    // resuming in between — they must not emit or reopen the session.
    final closing = super.close();
    // Free the session's KV cache — it doesn't need to live once the sheet
    // that owns this chat is dismissed. Started before any await: the service
    // forgets the session synchronously, so a sheet reopened while this close
    // is still stopping the generation gets a fresh session instead of one
    // this close would then kill.
    final closingSession = _gemmaService.closeSession(_sessionId);
    await _modelStatusSub?.cancel();
    await _cancelAnswer();
    await closingSession;
    return closing;
  }
}

class _GemmaModelNotInstalled implements Exception {
  const _GemmaModelNotInstalled();

  @override
  String toString() => 'GemmaModelNotInstalled';
}

class _GenerationTimedOut implements Exception {
  const _GenerationTimedOut();

  @override
  String toString() => 'GenerationTimedOut';
}

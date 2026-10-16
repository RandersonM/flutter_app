import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import '../data/knowledge/one_piece_knowledge_base.dart';
import '../data/models/chat_message.dart';
import '../data/models/vegapunk_satellite.dart';
import '../data/repository/i_vegapunk_chat_history_repository.dart';
import '../data/repository/i_vegapunk_chat_repository.dart';
import '../data/repository/vegapunk_chat_repository.dart';
import 'vegapunk_chat_state.dart';

class VegapunkChatCubit extends Cubit<VegapunkChatState> {
  VegapunkChatCubit({
    required this._repository,
    required IRAGService ragService,
    required this._historyRepository,
    required this._localeService,
  }) : _rag = ragService,
       super(const VegapunkModelNotInstalled()) {
    _modelStatusSub = _repository.modelStatusStream.listen(_onModelStatus);
    // Must be registered before any `setKnowledgeBase` call (see
    // `initialize`/`_initRag`) can trigger it.
    _rag.setOnStoreCleared(_reindexSessionFromHistory);
  }

  final IVegapunkChatRepository _repository;
  final IRAGService _rag;
  final IVegapunkChatHistoryRepository _historyRepository;
  final ILocaleService _localeService;
  late final StreamSubscription<GemmaServiceStatus> _modelStatusSub;
  StreamSubscription<String>? _streamSub;
  bool _isThinkingMode = false;
  bool _ragInitialized = false;
  List<String>? _targetCategories;
  String _lastUserMessage = '';
  // Buffer to accumulate tokens before emitting to the UI — reduces rebuild frequency.
  final StringBuffer _tokenBuffer = StringBuffer();
  Timer? _emitTimer;
  Timer? _sessionDocTimer;

  /// Watchdog: cancels generation if no token arrives within this duration.
  /// Protects against native LiteRT inference stalls after Android lifecycle
  /// interruptions (GPU/NPU suspended by OS → stream starts but never emits).
  static const _generationTimeout = Duration(seconds: 90);
  Timer? _watchdogTimer;

  static const _uuid = Uuid();

  /// Loaded once in [initialize], read by [_onModelStatus] when it constructs
  /// a fresh `VegapunkChatReady` — see that method for why this isn't emitted
  /// directly here.
  List<ChatMessage> _loadedHistory = const [];

  /// Holds the in-flight [_loadHistory] future so [_onModelStatus] can await
  /// it before emitting [VegapunkChatReady]. Running both loads in parallel
  /// (model init + Hive read) keeps the startup fast; awaiting here ensures
  /// the history is ready the moment [GemmaReady] arrives, regardless of
  /// which one finishes first.
  Future<void>? _historyFuture;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> initialize({List<String>? targetCategories}) async {
    if (targetCategories != null) {
      _targetCategories = targetCategories;
    }

    // Start the Hive read in parallel with model init — both are async and
    // independent. The Future reference is stored so _onModelStatus can await
    // it before emitting VegapunkChatReady, closing the race window where
    // GemmaReady could arrive before the history was fully loaded.
    _historyFuture = _loadHistory();

    await _repository.initializeModel(isThinkingMode: _isThinkingMode);
    // RAG init is intentionally not awaited: embedding model download (~110 MB
    // on first run) must not delay the chat becoming ready. Subsequent launches
    // are fast (model already installed). Messages sent before init completes
    // simply receive empty RAG context.
    // ignore: unawaited_futures
    _initRag();
  }

  Future<void> _loadHistory() async {
    _loadedHistory = await _historyRepository.recentMessages();
  }

  /// Persists [message] and mirrors it into [_loadedHistory] so that any
  /// later reload triggered by something other than [reset] (e.g.
  /// [toggleThinkingMode], which also lands on `_onModelStatus`'s "fresh
  /// ready state" branch) reflects the live conversation, not the stale
  /// snapshot taken at [initialize] time.
  void _persistMessage(ChatMessage message) {
    _loadedHistory = [..._loadedHistory, message];
    // Fire-and-forget, same style as the existing `_rag.addDocument` call
    // below — a slow/failed disk write must not block the chat stream.
    _historyRepository.appendMessage(message);
  }

  Future<void> _initRag() async {
    if (_ragInitialized) return;
    await _rag.initialize();
    final docs = OnePieceKnowledgeBase.getDocumentsForCategories(
      _targetCategories,
    );
    await _rag.setKnowledgeBase(docs);
    _ragInitialized = true;
    debugPrint('VegapunkChatCubit: RAG ready — ${docs.length} docs loaded');
  }

  Future<void> downloadModel() => _repository.downloadModel();

  Future<void> reset() async {
    await _cancelStream();
    _sessionDocTimer?.cancel();
    await _rag.clearSession();
    await _historyRepository.clear();
    _loadedHistory = const [];
    // Move off VegapunkChatReady before triggering the reload — same pattern
    // as toggleThinkingMode. Without this, GemmaReady below lands on
    // _onModelStatus's "preserve messages" branch (state is still Ready,
    // never transitioned away) and copyWith carries over the pre-reset
    // message list untouched, so the visible chat never actually clears.
    emit(const VegapunkModelLoading());
    await _repository.resetChat(isThinkingMode: _isThinkingMode);
    // Status stream emits GemmaLoading → GemmaReady, which transitions state.
  }

  @override
  Future<void> close() async {
    _emitTimer?.cancel();
    _sessionDocTimer?.cancel();
    await _cancelStream();
    await _modelStatusSub.cancel();
    _repository.dispose();
    return super.close();
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  void changeSatellite(VegapunkSatellite satellite) {
    if (state is VegapunkChatReady) {
      final ready = state as VegapunkChatReady;
      emit(ready.copyWith(selectedSatellite: satellite));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (state is! VegapunkChatReady) return;
    final ready = state as VegapunkChatReady;
    if (ready.isGenerating) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
      // satelliteId is who *answers*, not who asks — left null here.
    );

    emit(
      ready.copyWith(
        messages: [...ready.messages, userMsg],
        streamingToken: '',
        isGenerating: true,
      ),
    );
    _persistMessage(userMsg);

    _lastUserMessage = text.trim();

    final instruction = VegapunkSatellitePrompt.forMessage(
      ready.selectedSatellite.name,
      isPortuguese: PromptLocale.isPortuguese(_localeService),
    );

    _tokenBuffer.clear();
    _emitTimer?.cancel();

    // Batch token emits every frame to avoid rebuilding the widget tree
    // on every single token (~100ms intervals at LiteRT inference speed).
    _emitTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (state is! VegapunkChatReady) return;
      final buffered = _tokenBuffer.toString();
      if (buffered.isEmpty) return;
      _tokenBuffer.clear();
      final current = state as VegapunkChatReady;
      emit(current.copyWith(streamingToken: current.streamingToken + buffered));
    });

    // Start the watchdog — rearmed on every stream event (tokens and tool
    // sentinels alike), cancelled on done/error.
    _armWatchdog();

    _streamSub = _repository
        .sendMessage(text.trim(), styleInstruction: instruction)
        .listen(
          (token) {
            if (state is! VegapunkChatReady) return;
            final current = state as VegapunkChatReady;

            // Any event reaching here means inference is alive — including
            // tool execution, which can legitimately take longer than a
            // plain text token (e.g. a web search).
            _armWatchdog();

            // Handle sentinel tokens from the repository's function calling loop.
            final parsedTool = VegapunkChatRepository.parseToolName(token);
            if (parsedTool != null) {
              // A tool started executing — the widget layer resolves the
              // display label from this raw name.
              _emitTimer?.cancel();
              _tokenBuffer.clear();
              emit(
                current.copyWith(
                  activeToolName: parsedTool,
                  streamingToken: '',
                ),
              );
              return;
            }
            if (token == VegapunkChatRepository.toolDoneSentinel) {
              emit(current.copyWith(activeToolName: null));
              return;
            }

            // Accumulate into buffer — the timer will emit batched.
            _tokenBuffer.write(token);
          },
          onDone: () {
            _emitTimer?.cancel();
            _watchdogTimer?.cancel();
            _watchdogTimer = null;
            // Flush remaining buffered tokens before committing.
            if (_tokenBuffer.isNotEmpty && state is VegapunkChatReady) {
              final current = state as VegapunkChatReady;
              emit(
                current.copyWith(
                  streamingToken:
                      current.streamingToken + _tokenBuffer.toString(),
                ),
              );
              _tokenBuffer.clear();
            }
            _commitStreamingMessage();
          },
          onError: (Object e) {
            _emitTimer?.cancel();
            _watchdogTimer?.cancel();
            _watchdogTimer = null;
            _tokenBuffer.clear();
            debugPrint('VegapunkChatCubit stream error: $e');
            _commitStreamingMessage();
          },
          cancelOnError: true,
        );
  }

  /// (Re)arms the generation watchdog. Called once when a message is sent,
  /// then again on every stream event — token or tool sentinel — so a
  /// long-running tool call is not mistaken for a stalled inference.
  void _armWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_generationTimeout, () {
      debugPrint(
        'VegapunkChatCubit: generation watchdog fired — '
        'no token for ${_generationTimeout.inSeconds}s, cancelling',
      );
      stopGeneration();
    });
  }

  Future<void> stopGeneration() async {
    await _cancelStream();
    await _repository.stopGeneration();
    _commitStreamingMessage();
  }

  Future<void> toggleThinkingMode(bool enabled) async {
    _isThinkingMode = enabled;
    await _cancelStream();
    emit(const VegapunkModelLoading());
    await _repository.initializeModel(isThinkingMode: enabled);
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<void> _onModelStatus(GemmaServiceStatus status) async {
    switch (status) {
      case GemmaNotInstalled():
        emit(const VegapunkModelNotInstalled());
      case GemmaDownloading(:final progress):
        emit(VegapunkModelDownloading(progress));
      case GemmaLoading():
        emit(const VegapunkModelLoading());
      case GemmaReady():
        // Preserve messages if we're already in a ready state (e.g. after
        // a re-load triggered by something other than reset).
        final current = state;
        if (current is VegapunkChatReady) {
          emit(
            current.copyWith(
              isGenerating: false,
              streamingToken: '',
              isThinkingMode: _isThinkingMode,
            ),
          );
        } else {
          // Await the history load that was started in parallel with model
          // init. On a warm start the model can be ready in milliseconds while
          // Hive is still reading; awaiting here closes that race window so
          // the chat never opens with an empty history when messages exist.
          await _historyFuture;
          if (isClosed) return;
          emit(
            VegapunkChatReady(
              messages: _loadedHistory,
              isThinkingMode: _isThinkingMode,
            ),
          );
        }
      case GemmaError(:final error, :final isInstallError):
        emit(
          VegapunkChatError(
            message: error.toString(),
            isInstallError: isInstallError,
          ),
        );
    }
  }

  void _commitStreamingMessage() {
    if (state is! VegapunkChatReady) return;
    final current = state as VegapunkChatReady;
    if (!current.isGenerating) return;

    final token = current.streamingToken.trim();
    List<ChatMessage> updated = current.messages;
    if (token.isNotEmpty) {
      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        text: token,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        satelliteId: current.selectedSatellite.name,
      );
      updated = [...current.messages, assistantMsg];
      _persistMessage(assistantMsg);
    }

    emit(
      current.copyWith(
        messages: updated,
        streamingToken: '',
        isGenerating: false,
        activeToolName: null,
      ),
    );

    // Schedule the RAG document addition after a 2-second delay so it does
    // NOT compete with any in-flight LiteRT inference on the next user message.
    if (token.isNotEmpty) {
      _scheduleSessionDocument(_lastUserMessage, token);
    }
  }

  void _scheduleSessionDocument(String userText, String responseText) {
    _sessionDocTimer?.cancel();
    _sessionDocTimer = Timer(const Duration(seconds: 2), () {
      if (isClosed) return;
      // The model started generating again before the delay elapsed — retry
      // once it's idle instead of silently dropping this turn's document.
      if (state is VegapunkChatReady &&
          (state as VegapunkChatReady).isGenerating) {
        _scheduleSessionDocument(userText, responseText);
        return;
      }
      _addSessionDocument(userText, responseText);
    });
  }

  /// Rebuilds session-memory RAG documents from persisted chat history.
  ///
  /// The vector store has no scoped clear (see `IRAGService.setOnStoreCleared`
  /// docs) — whenever it's wiped, this is what makes session memory come
  /// back from a real source of truth instead of staying empty until the
  /// user says enough new things to refill it. Registered as the RAG
  /// service's `onStoreCleared` hook; not called separately at cold start,
  /// because a normal launch with an unchanged knowledge base never clears
  /// the store in the first place — the persisted vector store file already
  /// has whatever session documents survived the last actual clear, with
  /// nothing to rebuild.
  ///
  /// Per this feature's D1 decision (keep the existing cap, no added
  /// retention policy — `.specs/features/vegapunk-chat-memory/context.md`),
  /// this only ever rebuilds up to [IRAGService.maxSessionDocuments] most
  /// recent turns; anything older is not reconstructed.
  ///
  /// Fetches by raw message *count* (`cap * 2`), not by "last `cap` complete
  /// turns" — cheap and sufficient under strict user/assistant alternation,
  /// which pairs exactly `cap` turns out of `cap * 2` messages with nothing
  /// left over. The one edge case this doesn't handle: if a turn in that
  /// window has no assistant reply (generation produced no text — see
  /// `_commitStreamingMessage`), the window can end up one message short and
  /// silently drop the oldest turn in it rather than reaching further back to
  /// replace it. Accepted per D1's "zero extra work" — the fetch would need
  /// to be turn-aware (grow until enough full turns are found) to close this
  /// gap, which is exactly the kind of retention machinery D1 opted out of.
  Future<void> _reindexSessionFromHistory() async {
    final cap = _rag.maxSessionDocuments;
    final history = await _historyRepository.recentMessages(limit: cap * 2);
    // `_pairIntoTurns` can never yield more than `history.length ~/ 2` turns
    // — with at most `cap * 2` messages fetched, that's already `<= cap`, so
    // no further trim is needed here.
    final turns = _pairIntoTurns(history);

    for (final turn in turns) {
      await _rag.addDocument(_turnToRagDocument(turn));
    }
    debugPrint(
      'VegapunkChatCubit: reindexed ${turns.length} session turn(s) '
      'from history',
    );
  }

  /// Pairs adjacent (user, assistant) messages into turns. A user message
  /// with no assistant reply yet (e.g. the most recent one, or one where
  /// generation produced no text — see `_commitStreamingMessage`) is simply
  /// not turned into a turn; there is nothing to summarize yet.
  List<({ChatMessage user, ChatMessage assistant})> _pairIntoTurns(
    List<ChatMessage> messages,
  ) {
    final turns = <({ChatMessage user, ChatMessage assistant})>[];
    for (var i = 0; i < messages.length - 1; i++) {
      final current = messages[i];
      final next = messages[i + 1];
      if (current.role == MessageRole.user &&
          next.role == MessageRole.assistant) {
        turns.add((user: current, assistant: next));
      }
    }
    return turns;
  }

  RagDocument _turnToRagDocument(
    ({ChatMessage user, ChatMessage assistant}) turn,
  ) {
    final response = turn.assistant.text;
    final truncated = response.length > 512
        ? response.substring(0, 512)
        : response;
    return RagDocument(
      id: '${RagDocument.sessionIdPrefix}${turn.assistant.id}',
      content: 'User asked: ${turn.user.text}\nAnswer: $truncated',
      category: 'session',
      language: 'both',
      topic: 'session',
      isSession: true,
    );
  }

  void _addSessionDocument(String userText, String response) {
    if (userText.isEmpty || response.isEmpty) return;
    // Truncate long responses to avoid large embedding vectors (max 512 chars).
    final truncated = response.length > 512
        ? response.substring(0, 512)
        : response;
    _rag.addDocument(
      RagDocument(
        id: '${RagDocument.sessionIdPrefix}${_uuid.v4()}',
        content: 'User asked: $userText\nAnswer: $truncated',
        category: 'session',
        language: 'both',
        topic: 'session',
        isSession: true,
      ),
    );
  }

  Future<void> _cancelStream() async {
    _emitTimer?.cancel();
    _emitTimer = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _tokenBuffer.clear();
    await _streamSub?.cancel();
    _streamSub = null;
  }
}

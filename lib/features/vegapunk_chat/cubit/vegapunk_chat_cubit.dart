import 'package:get_it/get_it.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import '../data/knowledge/one_piece_knowledge_base.dart';
import '../data/models/chat_message.dart';
import '../data/models/vegapunk_satellite.dart';
import '../data/repository/i_vegapunk_chat_repository.dart';
import '../data/repository/vegapunk_chat_repository.dart';
import 'vegapunk_chat_state.dart';

class VegapunkChatCubit extends Cubit<VegapunkChatState> {
  VegapunkChatCubit({
    IVegapunkChatRepository? repository,
    IRAGService? ragService,
  })  : _repository = repository ?? VegapunkChatRepository(),
        _rag = ragService ?? getIt<IRAGService>(),
        super(const VegapunkModelNotInstalled()) {
    _modelStatusSub = _repository.modelStatusStream.listen(_onModelStatus);
  }

  final IVegapunkChatRepository _repository;
  final IRAGService _rag;
  late final StreamSubscription<GemmaServiceStatus> _modelStatusSub;
  StreamSubscription<String>? _streamSub;
  bool _isThinkingMode = false;
  bool _ragInitialized = false;
  List<String>? _targetCategories;
  String _lastUserMessage = '';
  int _turnCount = 0;
  bool _isSilentReset = false;
  // After this many complete exchanges, silently reset the model KV-cache to
  // prevent context-window overflow. UI history is untouched.
  static const int _maxTurnsBeforeReset = 5;

  static const _uuid = Uuid();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> initialize({List<String>? targetCategories}) async {
    if (targetCategories != null) {
      _targetCategories = targetCategories;
    }
    await _repository.initializeModel(isThinkingMode: _isThinkingMode);
    // RAG init is intentionally not awaited: embedding model download (~110 MB
    // on first run) must not delay the chat becoming ready. Subsequent launches
    // are fast (model already installed). Messages sent before init completes
    // simply receive empty RAG context.
    // ignore: unawaited_futures
    _initRag();
  }

  Future<void> _initRag() async {
    if (_ragInitialized) return;
    await _rag.initialize();
    final docs = OnePieceKnowledgeBase.getDocumentsForCategories(_targetCategories);
    await _rag.setKnowledgeBase(docs);
    _ragInitialized = true;
    debugPrint('VegapunkChatCubit: RAG ready — ${docs.length} docs loaded');
  }

  Future<void> downloadModel() => _repository.downloadModel();

  Future<void> reset() async {
    await _cancelStream();
    await _rag.clearSession();
    await _repository.resetChat(isThinkingMode: _isThinkingMode);
    // Status stream emits GemmaLoading → GemmaReady, which transitions state.
  }

  @override
  Future<void> close() async {
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
    if (state is! VegapunkChatReady || text.trim().isEmpty) return;
    final ready = state as VegapunkChatReady;
    if (ready.isGenerating) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      role: MessageRole.user,
    );

    emit(ready.copyWith(
      messages: [...ready.messages, userMsg],
      streamingToken: '',
      isGenerating: true,
    ));

    _lastUserMessage = text.trim();

    final isPortuguese = GetIt.I.get<ILocaleService>().locale?.languageCode == 'pt';
    final instruction = ready.selectedSatellite == VegapunkSatellite.stella
        ? null
        : (isPortuguese
            ? ready.selectedSatellite.styleInstructionPt
            : ready.selectedSatellite.styleInstructionEn);

    _streamSub = _repository.sendMessage(text.trim(), styleInstruction: instruction).listen(
      (token) {
        if (state is! VegapunkChatReady) return;
        final current = state as VegapunkChatReady;

        // Handle sentinel tokens from the repository's function calling loop.
        if (token == VegapunkChatRepository.searchingWebSentinel) {
          emit(current.copyWith(
            isSearchingWeb: true,
            streamingToken: '', // Clear any hallucinated text or raw JSON
          ));
          return;
        }
        if (token == VegapunkChatRepository.searchingDoneSentinel) {
          emit(current.copyWith(isSearchingWeb: false));
          return;
        }

        emit(current.copyWith(
          streamingToken: current.streamingToken + token,
        ));
      },
      onDone: _commitStreamingMessage,
      onError: (Object e) {
        debugPrint('VegapunkChatCubit stream error: $e');
        _commitStreamingMessage();
      },
      cancelOnError: true,
    );
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

  void _onModelStatus(GemmaServiceStatus status) {
    // During a silent KV-cache reset, suppress Loading/Ready transitions so
    // the UI never flickers or loses its message history.
    if (_isSilentReset) {
      if (status is GemmaLoading) return;
      if (status is GemmaReady) {
        _isSilentReset = false;
        return;
      }
    }

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
          emit(current.copyWith(
            isGenerating: false,
            streamingToken: '',
            isThinkingMode: _isThinkingMode,
          ));
        } else {
          emit(VegapunkChatReady(isThinkingMode: _isThinkingMode));
        }
      case GemmaError(:final error, :final isInstallError):
        emit(VegapunkChatError(
          message: error.toString(),
          isInstallError: isInstallError,
        ));
    }
  }

  void _commitStreamingMessage() {
    if (state is! VegapunkChatReady) return;
    final current = state as VegapunkChatReady;
    if (!current.isGenerating) return;

    final token = current.streamingToken.trim();
    final updated = token.isNotEmpty
        ? [
            ...current.messages,
            ChatMessage(
              id: _uuid.v4(),
              text: token,
              role: MessageRole.assistant,
            ),
          ]
        : current.messages;

    emit(current.copyWith(
      messages: updated,
      streamingToken: '',
      isGenerating: false,
    ));

    if (token.isNotEmpty) {
      _addSessionDocument(_lastUserMessage, token);
      _turnCount++;
      if (_turnCount >= _maxTurnsBeforeReset) {
        _turnCount = 0;
        _isSilentReset = true;
        // Silently reset the model's KV-cache to free context window space.
        // _onModelStatus suppresses the Loading/Ready events so the UI is unaffected.
        _repository.resetChat(isThinkingMode: _isThinkingMode).ignore();
      }
    }
  }

  void _addSessionDocument(String userText, String response) {
    if (userText.isEmpty || response.isEmpty) return;
    _rag.addDocument(RagDocument(
      id: 'sess-${_uuid.v4()}',
      content: 'User asked: $userText\nAnswer: $response',
      category: 'session',
      language: 'both',
      topic: 'session',
      isSession: true,
    ));
  }

  Future<void> _cancelStream() async {
    await _streamSub?.cancel();
    _streamSub = null;
  }
}

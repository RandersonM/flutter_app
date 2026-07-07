import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'nami_chat_state.dart';

class NamiChatBloc extends Cubit<NamiChatState> {
  final NamiRagService _ragService;
  final IGemmaService _gemmaService;
  final INamiFinancesService _financesService;
  final _uuid = const Uuid();
  StreamSubscription<ModelResponse>? _streamSub;
  Timer? _emitTimer;
  final StringBuffer _tokenBuffer = StringBuffer();
  Future<void>? _backfillFuture;

  // Nami gets her own independent Gemma chat session — own system
  // instruction, own history — instead of sharing Vegapunk's singleton chat.
  // They used to reuse the same InferenceChat: Nami's persona was only ever
  // an inline "style instruction" prepended per-message on top of Vegapunk's
  // actual system prompt, and every turn from both chats landed in the same
  // conversation history.
  static const _sessionId = 'nami';

  NamiChatBloc(this._ragService, this._gemmaService, this._financesService)
      : super(NamiChatInitial()) {
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
    emit(NamiChatReady(
      messages: const [
        ChatMessage(
          id: 'welcome_nami',
          text: 'Oi! Eu sou a Nami. Posso analisar suas finanças que salvamos! Pergunte o que quiser sobre os meses registrados.',
          role: MessageRole.assistant,
        ),
      ],
      error: readyError,
    ));
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
          completer.completeError(StateError(
            'Modelo de IA ainda não foi baixado — abra o chat do Vegapunk para instalá-lo.',
          ));
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

  /// Deterministic context for date-relative questions ("this month", "last
  /// month") merged with whatever the embedding search surfaces. Semantic
  /// similarity is unreliable for resolving "esse mês" against a document
  /// phrased as an absolute "07/2026" — so the current + previous month are
  /// always included directly instead of relying on the vector store to
  /// guess the match.
  Future<List<String>?> _buildRagContext(String query) async {
    await _backfillFuture;

    final recentMonths = await _financesService.getLastMonthsFinances(2);
    final deterministic = recentMonths.map(NamiRagService.summarize);
    final searchHits = await _ragService.searchSimilar(query, topK: 3);

    final merged = <String>{...deterministic, ...searchHits}.toList();
    return merged.isEmpty ? null : merged;
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

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMsg],
      streamingToken: '',
      isGenerating: true,
    ));

    final ragContext = await _buildRagContext(text);

    _tokenBuffer.clear();
    _emitTimer?.cancel();

    _emitTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (state is! NamiChatReady) return;
      final current = state as NamiChatReady;
      final buffered = _tokenBuffer.toString();
      if (buffered.isEmpty) return;
      
      _tokenBuffer.clear();
      emit(current.copyWith(
        streamingToken: current.streamingToken + buffered,
      ));
    });

    try {
      _streamSub = _gemmaService.sendSessionMessage(
        _sessionId,
        systemInstruction: NamiPrompt.system(
          isPortuguese: PromptLocale.isPortuguese(),
        ),
        text: text,
        ragContext: ragContext,
      ).listen(
        (response) {
          if (state is! NamiChatReady) return;
          
          if (response is TextResponse) {
            _tokenBuffer.write(response.token);
          }
        },
        onError: (error) {
          if (state is NamiChatReady) {
            emit((state as NamiChatReady).copyWith(
              isGenerating: false,
              error: 'Erro na conexão com Nami: $error',
            ));
          }
        },
        onDone: () {
          if (state is NamiChatReady) {
            final current = state as NamiChatReady;
            // Flush remaining buffer
            final finalToken = current.streamingToken + _tokenBuffer.toString();
            _tokenBuffer.clear();
            
            final modelMsg = ChatMessage(
              id: _uuid.v4(),
              text: finalToken.trim(),
              role: MessageRole.assistant,
            );
            
            emit(current.copyWith(
              messages: [...current.messages, modelMsg],
              streamingToken: '',
              isGenerating: false,
            ));
          }
        },
      );
    } catch (e) {
      emit(currentState.copyWith(
        isGenerating: false,
        error: 'Falha interna: $e',
      ));
    }
  }

  @override
  Future<void> close() async {
    _streamSub?.cancel();
    _emitTimer?.cancel();
    // Free the session's KV cache — it doesn't need to live once the sheet
    // that owns this chat is dismissed.
    await _gemmaService.closeSession(_sessionId);
    return super.close();
  }
}

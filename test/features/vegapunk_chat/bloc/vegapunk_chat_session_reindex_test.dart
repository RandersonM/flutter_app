import 'dart:async';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/gemma/gemma_service_status.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/bloc/vegapunk_chat_cubit.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_repository.dart';

/// Covers VGP-MEM-25/26: rebuilding session RAG documents from persisted
/// chat history whenever `IRAGService` reports the store was cleared.
class _FakeVegapunkChatRepository implements IVegapunkChatRepository {
  final _statusController = StreamController<GemmaServiceStatus>.broadcast();

  @override
  Stream<GemmaServiceStatus> get modelStatusStream => _statusController.stream;
  @override
  GemmaServiceStatus currentModelStatus = const GemmaNotInstalled();
  @override
  Future<void> initializeModel({bool isThinkingMode = false}) async {}
  @override
  Future<void> downloadModel() async {}
  @override
  Stream<String> sendMessage(String text, {String? styleInstruction}) =>
      const Stream.empty();
  @override
  Future<void> stopGeneration() async {}
  @override
  Future<void> resetChat({bool isThinkingMode = false}) async {}
  @override
  void dispose() {}
}

class _FakeRagService implements IRAGService {
  _FakeRagService({this.maxSessionDocuments = 20});

  @override
  int maxSessionDocuments;

  final List<RagDocument> addedDocuments = [];
  Future<void> Function()? _onStoreCleared;

  /// Simulates `RAGService` finishing a real clear+reload — the exact
  /// trigger this cubit's reindex routine is registered against.
  Future<void> simulateStoreCleared() async {
    final callback = _onStoreCleared;
    if (callback != null) await callback();
  }

  @override
  void setOnStoreCleared(Future<void> Function() callback) {
    _onStoreCleared = callback;
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> addDocument(RagDocument doc) async {
    addedDocuments.add(doc);
  }

  @override
  Future<void> addDocumentBatch(List<RagDocument> docs) async {
    addedDocuments.addAll(docs);
  }

  @override
  Future<void> clearSession() async {}
  @override
  Future<void> setKnowledgeBase(List<RagDocument> docs) async {}
  @override
  Future<List<String>> searchLore(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  }) async => const [];
  @override
  Future<List<String>> searchSession(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  }) async => const [];
}

class _FakeLocaleService implements ILocaleService {
  @override
  Locale? locale = const Locale('pt');
  @override
  String get languageCode => locale!.languageCode;
  @override
  Future<void> loadLocale() async {}
  @override
  Future<void> persistLocale(Locale locale) async {}
}

class _FakeHistoryRepository implements IVegapunkChatHistoryRepository {
  _FakeHistoryRepository([List<ChatMessage>? seed])
    : stored = List.of(seed ?? const []);

  final List<ChatMessage> stored;
  int? lastRequestedLimit;

  @override
  Future<List<ChatMessage>> recentMessages({int limit = 20}) async {
    lastRequestedLimit = limit;
    final start = stored.length > limit ? stored.length - limit : 0;
    return stored.sublist(start);
  }

  @override
  Future<void> appendMessage(ChatMessage message) async {
    stored.add(message);
  }

  @override
  Future<void> clear() async {
    stored.clear();
  }
}

ChatMessage _msg(String id, MessageRole role, String text, int minute) =>
    ChatMessage(
      id: id,
      text: text,
      role: role,
      timestamp: DateTime(2026, 1, 1, 0, minute),
    );

void main() {
  group('VegapunkChatCubit session reindex', () {
    test('rebuilds one session document per (user, assistant) turn', () async {
      final history = _FakeHistoryRepository([
        _msg('u1', MessageRole.user, 'oi vegapunk', 0),
        _msg('a1', MessageRole.assistant, 'olá!', 1),
        _msg('u2', MessageRole.user, 'quem é a stella?', 2),
        _msg('a2', MessageRole.assistant, 'meu corpo real', 3),
      ]);
      final rag = _FakeRagService();
      final cubit = VegapunkChatCubit(
        repository: _FakeVegapunkChatRepository(),
        ragService: rag,
        historyRepository: history,
        localeService: _FakeLocaleService(),
      );

      await rag.simulateStoreCleared();

      expect(rag.addedDocuments, hasLength(2));
      expect(
        rag.addedDocuments.every(
          (d) => d.id.startsWith(RagDocument.sessionIdPrefix),
        ),
        isTrue,
      );
      expect(rag.addedDocuments.every((d) => d.isSession), isTrue);
      expect(
        rag.addedDocuments[0].content,
        'User asked: oi vegapunk\nAnswer: olá!',
      );
      expect(
        rag.addedDocuments[1].content,
        'User asked: quem é a stella?\nAnswer: meu corpo real',
      );

      await cubit.close();
    });

    test(
      'does not turn a trailing unanswered user message into a document',
      () async {
        final history = _FakeHistoryRepository([
          _msg('u1', MessageRole.user, 'oi', 0),
          _msg('a1', MessageRole.assistant, 'olá', 1),
          _msg('u2', MessageRole.user, 'sem resposta ainda', 2),
        ]);
        final rag = _FakeRagService();
        final cubit = VegapunkChatCubit(
          repository: _FakeVegapunkChatRepository(),
          ragService: rag,
          historyRepository: history,
          localeService: _FakeLocaleService(),
        );

        await rag.simulateStoreCleared();

        expect(rag.addedDocuments, hasLength(1));
        expect(rag.addedDocuments.single.content, contains('oi'));

        await cubit.close();
      },
    );

    test('skips turns answered from web search results', () async {
      final history = _FakeHistoryRepository([
        _msg('u1', MessageRole.user, 'pesquise o capítulo novo', 0),
        ChatMessage(
          id: 'a1',
          text: 'o capítulo saiu',
          role: MessageRole.assistant,
          timestamp: DateTime(2026, 1, 1, 0, 1),
          usedWebContent: true,
        ),
        _msg('u2', MessageRole.user, 'quem é a stella?', 2),
        _msg('a2', MessageRole.assistant, 'meu corpo real', 3),
      ]);
      final rag = _FakeRagService();
      final cubit = VegapunkChatCubit(
        repository: _FakeVegapunkChatRepository(),
        ragService: rag,
        historyRepository: history,
        localeService: _FakeLocaleService(),
      );

      await rag.simulateStoreCleared();

      expect(rag.addedDocuments, hasLength(1));
      expect(rag.addedDocuments.single.content, contains('stella'));

      await cubit.close();
    });

    test('reindexing an empty history is a no-op, not an error', () async {
      final rag = _FakeRagService();
      final cubit = VegapunkChatCubit(
        repository: _FakeVegapunkChatRepository(),
        ragService: rag,
        historyRepository: _FakeHistoryRepository(),
        localeService: _FakeLocaleService(),
      );

      await expectLater(rag.simulateStoreCleared(), completes);

      expect(rag.addedDocuments, isEmpty);

      await cubit.close();
    });

    test('only rebuilds up to maxSessionDocuments most recent turns', () async {
      // 3 full turns persisted, cap of 2. The fetch window itself
      // (`limit: cap * 2`) is what keeps this to 2 turns under strict
      // alternation — see `_reindexSessionFromHistory`'s doc comment for why
      // that's sufficient without a separate trim step.
      final history = _FakeHistoryRepository([
        _msg('u1', MessageRole.user, 'primeira pergunta', 0),
        _msg('a1', MessageRole.assistant, 'primeira resposta', 1),
        _msg('u2', MessageRole.user, 'segunda pergunta', 2),
        _msg('a2', MessageRole.assistant, 'segunda resposta', 3),
        _msg('u3', MessageRole.user, 'terceira pergunta', 4),
        _msg('a3', MessageRole.assistant, 'terceira resposta', 5),
      ]);
      final rag = _FakeRagService(maxSessionDocuments: 2);
      final cubit = VegapunkChatCubit(
        repository: _FakeVegapunkChatRepository(),
        ragService: rag,
        historyRepository: history,
        localeService: _FakeLocaleService(),
      );

      await rag.simulateStoreCleared();

      expect(history.lastRequestedLimit, 4);
      expect(rag.addedDocuments, hasLength(2));
      expect(
        rag.addedDocuments.map((d) => d.content),
        everyElement(isNot(contains('primeira'))),
      );
      expect(
        rag.addedDocuments.any((d) => d.content.contains('segunda')),
        isTrue,
      );
      expect(
        rag.addedDocuments.any((d) => d.content.contains('terceira')),
        isTrue,
      );

      await cubit.close();
    });

    test('truncates a long assistant answer to 512 characters', () async {
      final longAnswer = 'x' * 600;
      final history = _FakeHistoryRepository([
        _msg('u1', MessageRole.user, 'conte uma história longa', 0),
        _msg('a1', MessageRole.assistant, longAnswer, 1),
      ]);
      final rag = _FakeRagService();
      final cubit = VegapunkChatCubit(
        repository: _FakeVegapunkChatRepository(),
        ragService: rag,
        historyRepository: history,
        localeService: _FakeLocaleService(),
      );

      await rag.simulateStoreCleared();

      final content = rag.addedDocuments.single.content;
      final answerPart = content.split('Answer: ').last;
      expect(answerPart.length, 512);

      await cubit.close();
    });
  });
}

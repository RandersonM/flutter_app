import 'dart:async';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/gemma/gemma_service_status.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart';
import 'package:opfan/features/vegapunk_chat/cubit/vegapunk_chat_state.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_repository.dart';

/// Hand-written fakes — same style as
/// `test/features/nami_finances/find_expenses_handler_test.dart` — no
/// mockito codegen for new tests in this project.
class _FakeVegapunkChatRepository implements IVegapunkChatRepository {
  final _statusController = StreamController<GemmaServiceStatus>.broadcast();

  @override
  Stream<GemmaServiceStatus> get modelStatusStream => _statusController.stream;

  @override
  GemmaServiceStatus currentModelStatus = const GemmaNotInstalled();

  /// Pushes [status] and waits a turn of the event loop so
  /// `VegapunkChatCubit._onModelStatus` — subscribed via a broadcast stream,
  /// which never delivers synchronously even to an already-listening
  /// subscriber — has actually run by the time this returns.
  Future<void> emitStatusAndSettle(GemmaServiceStatus status) async {
    currentModelStatus = status;
    _statusController.add(status);
    await Future<void>.delayed(Duration.zero);
  }

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
  @override
  int maxSessionDocuments = 20;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> addDocument(RagDocument doc) async {}
  @override
  Future<void> addDocumentBatch(List<RagDocument> docs) async {}
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
  @override
  void setOnStoreCleared(Future<void> Function() callback) {}
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
  bool cleared = false;

  @override
  Future<List<ChatMessage>> recentMessages({int limit = 20}) async {
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
    cleared = true;
  }
}

ChatMessage _message(String id, MessageRole role) => ChatMessage(
  id: id,
  text: 'text-$id',
  role: role,
  timestamp: DateTime(2026, 1, 1),
);

void main() {
  group('VegapunkChatCubit history', () {
    test(
      'initialize() populates VegapunkChatReady with persisted history',
      () async {
        final history = _FakeHistoryRepository([
          _message('a', MessageRole.user),
          _message('b', MessageRole.assistant),
        ]);
        final fakeRepo = _FakeVegapunkChatRepository();
        final cubit = VegapunkChatCubit(
          repository: fakeRepo,
          ragService: _FakeRagService(),
          historyRepository: history,
          localeService: _FakeLocaleService(),
        );

        await cubit.initialize();
        // Let `_loadHistory`'s awaited read (fake, but still a Future)
        // resolve before the ready state is constructed from it.
        await Future<void>.delayed(Duration.zero);
        await fakeRepo.emitStatusAndSettle(const GemmaReady());

        final state = cubit.state;
        expect(state, isA<VegapunkChatReady>());
        expect(
          (state as VegapunkChatReady).messages.map((m) => m.id).toList(),
          ['a', 'b'],
        );

        await cubit.close();
      },
    );

    test('sending a message persists it via the history repository', () async {
      final history = _FakeHistoryRepository();
      final fakeRepo = _FakeVegapunkChatRepository();
      final cubit = VegapunkChatCubit(
        repository: fakeRepo,
        ragService: _FakeRagService(),
        historyRepository: history,
        localeService: _FakeLocaleService(),
      );

      await cubit.initialize();
      await Future<void>.delayed(Duration.zero);
      await fakeRepo.emitStatusAndSettle(const GemmaReady());

      await cubit.sendMessage('hello vegapunk');
      // appendMessage is fire-and-forget from the cubit's perspective.
      await Future<void>.delayed(Duration.zero);

      expect(history.stored, hasLength(1));
      expect(history.stored.single.text, 'hello vegapunk');
      expect(history.stored.single.role, MessageRole.user);

      await cubit.close();
    });

    test(
      'reset() clears the persisted history, not just in-memory state',
      () async {
        final history = _FakeHistoryRepository([
          _message('old', MessageRole.user),
        ]);
        final fakeRepo = _FakeVegapunkChatRepository();
        final cubit = VegapunkChatCubit(
          repository: fakeRepo,
          ragService: _FakeRagService(),
          historyRepository: history,
          localeService: _FakeLocaleService(),
        );

        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        await fakeRepo.emitStatusAndSettle(const GemmaReady());
        expect((cubit.state as VegapunkChatReady).messages, hasLength(1));

        await cubit.reset();
        // reset() moves state to VegapunkModelLoading before triggering the
        // reload — regression coverage for a pre-existing bug where GemmaReady
        // firing while state was still VegapunkChatReady landed on
        // _onModelStatus's "preserve messages" branch, so the visible chat
        // never actually cleared even though the store did.
        expect(cubit.state, isA<VegapunkModelLoading>());
        await fakeRepo.emitStatusAndSettle(const GemmaReady());

        expect(history.cleared, isTrue);
        expect(history.stored, isEmpty);
        expect((cubit.state as VegapunkChatReady).messages, isEmpty);

        await cubit.close();
      },
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart';

import '../../../fakes/fake_user_storage_service.dart';

/// First test in this project to open a real Hive box (see
/// `.specs/features/vegapunk-chat-memory/tasks.md`, T6 — no prior precedent).
///
/// Uses `Hive.init(path)`, not `Hive.initFlutter()`: the latter resolves the
/// storage directory via `path_provider`, a platform channel unavailable
/// under plain `flutter_test` (no device, no `TestWidgetsFlutterBinding`
/// plugin mocks registered here). `Hive.init` takes a directory directly and
/// has no platform dependency — verified against `package:hive`'s source
/// (`HiveImpl.init`), not assumed.
void main() {
  late Directory tempDir;
  const boxName = 'vegapunk_chat_history';

  // Registered once for the whole file, not per test: adapter registration
  // is independent of which directory `Hive.init` points at, and
  // `Hive.resetAdapters()` would also wipe `Hive`'s internal DateTime/BigInt
  // adapters — those are only ever registered once, in the singleton's
  // constructor, with nothing to re-register them afterward (that
  // registration is private to the package).
  setUpAll(() {
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(MessageRoleAdapter());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'vegapunk_chat_history_test',
    );
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  ChatMessage message(String id, {DateTime? at}) => ChatMessage(
    id: id,
    text: 'text-$id',
    role: MessageRole.user,
    timestamp: at ?? DateTime(2026, 1, 1),
  );

  group('recentMessages', () {
    test('returns an empty list for a fresh box', () async {
      final repo = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      expect(await repo.recentMessages(), isEmpty);
    });

    test('returns messages in insertion order when under the limit', () async {
      final repo = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      await repo.appendMessage(message('a'));
      await repo.appendMessage(message('b'));
      await repo.appendMessage(message('c'));

      final result = await repo.recentMessages(limit: 20);

      expect(result.map((m) => m.id).toList(), ['a', 'b', 'c']);
    });

    test('returns only the last `limit` messages, still in order', () async {
      final repo = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      for (var i = 0; i < 30; i++) {
        await repo.appendMessage(message('m$i'));
      }

      final result = await repo.recentMessages(limit: 5);

      expect(result.map((m) => m.id).toList(), [
        'm25',
        'm26',
        'm27',
        'm28',
        'm29',
      ]);
    });
  });

  group('appendMessage', () {
    test('persists across reopening the box (disk round-trip)', () async {
      final writer = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      await writer.appendMessage(message('a'));
      await writer.appendMessage(message('b'));

      // Force the underlying box closed so the next repository instance
      // reads from disk rather than reusing an already-open in-memory handle
      // — otherwise this would only prove the object graph works, not that
      // anything was actually written to disk.
      await Hive.lazyBox<ChatMessage>(boxName).close();

      final reader = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      final result = await reader.recentMessages();

      expect(result.map((m) => m.id).toList(), ['a', 'b']);
    });
  });

  group('clear', () {
    test('empties the box; recentMessages returns [] afterwards', () async {
      final repo = VegapunkChatHistoryRepository(
        storage: FakeUserStorageService(),
      );
      await repo.appendMessage(message('a'));
      await repo.appendMessage(message('b'));

      await repo.clear();

      expect(await repo.recentMessages(), isEmpty);
    });
  });
}

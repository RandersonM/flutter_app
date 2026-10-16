import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/chat_message.dart';
import 'i_vegapunk_chat_history_repository.dart';

/// Hive-backed implementation of [IVegapunkChatHistoryRepository].
///
/// Uses `LazyBox`, not the eager `Box` used by every other repository in this
/// app. Hive's eager `Box.getAt` reads from an in-memory keystore populated
/// in full at `openBox` time — every message would be decoded just to open
/// the box. `LazyBox.getAt` reads one frame from the backend per call,
/// on demand. That is the only way to satisfy "never read messages beyond the
/// requested limit" once the history grows past it — a deliberate, documented
/// deviation from the rest of the codebase's Hive convention.
class VegapunkChatHistoryRepository implements IVegapunkChatHistoryRepository {
  static const String _boxName = 'vegapunk_chat_history';

  LazyBox<ChatMessage>? _box;

  /// Same recovery strategy as `FeaturedCharacterRepository._initHive`: a
  /// corrupted box falls back to an empty history instead of throwing and
  /// breaking the chat screen from opening at all.
  Future<LazyBox<ChatMessage>> _openBox() async {
    final existing = _box;
    if (existing != null) return existing;

    try {
      _box = Hive.isBoxOpen(_boxName)
          ? Hive.lazyBox<ChatMessage>(_boxName)
          : await Hive.openLazyBox<ChatMessage>(_boxName);
    } catch (e) {
      debugPrint('VegapunkChatHistoryRepository: box corrupted, resetting: $e');
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openLazyBox<ChatMessage>(_boxName);
    }
    return _box!;
  }

  @override
  Future<List<ChatMessage>> recentMessages({int limit = 20}) async {
    final box = await _openBox();
    final total = box.length;
    if (total == 0) return const [];

    final start = total > limit ? total - limit : 0;
    final result = <ChatMessage>[];
    for (var i = start; i < total; i++) {
      final message = await box.getAt(i);
      if (message != null) result.add(message);
    }
    return result;
  }

  @override
  Future<void> appendMessage(ChatMessage message) async {
    final box = await _openBox();
    await box.add(message);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}

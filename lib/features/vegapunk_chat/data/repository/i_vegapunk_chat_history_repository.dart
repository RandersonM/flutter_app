import '../models/chat_message.dart';

/// Persisted history for the Vegapunk chat.
///
/// One conversation, one history — there is no per-satellite partitioning
/// (the active `VegapunkSatellite` is a display detail on a shared thread,
/// not a separate conversation; see
/// `.specs/features/vegapunk-chat-memory/context.md`, C1).
abstract class IVegapunkChatHistoryRepository {
  /// The last [limit] messages, oldest first. Messages beyond [limit] are
  /// never read from disk.
  Future<List<ChatMessage>> recentMessages({int limit = 20});

  /// Persists one message (append). Called once per user turn and once per
  /// assistant turn, after the final text is committed — never with a
  /// partial streaming token.
  Future<void> appendMessage(ChatMessage message);

  /// Deletes the entire persisted history.
  Future<void> clear();
}

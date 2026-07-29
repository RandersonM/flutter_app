import 'dart:convert';

class RagDocument {
  /// Namespace prefix for session/conversation-memory documents, as opposed
  /// to knowledge-base/lore documents. Used at the `id` level (not a
  /// metadata field) because the vector store's filter is a no-op today —
  /// see `.specs/features/vegapunk-chat-memory/context.md`, C3 — so
  /// namespace has to be recoverable from `id` alone after a search.
  /// Knowledge-base documents keep their existing literal ids unprefixed;
  /// anything without this prefix is lore, by exclusion.
  static const String sessionIdPrefix = 'sess:';

  final String id;
  final String content;
  final String category;
  final String language;
  final String topic;
  final bool isSession;

  const RagDocument({
    required this.id,
    required this.content,
    required this.category,
    required this.language,
    required this.topic,
    this.isSession = false,
  });

  String get metadataJson => jsonEncode({
    'category': category,
    'lang': language,
    'topic': topic,
    'isSession': isSession,
  });
}

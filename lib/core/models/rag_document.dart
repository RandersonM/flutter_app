import 'dart:convert';

class RagDocument {
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

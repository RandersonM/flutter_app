import 'package:opfan/core/models/rag/rag_document.dart';

abstract class IRAGService {
  /// Cap on how many session/conversation documents this service keeps.
  /// Exposed so a caller reindexing session memory from its own persisted
  /// history (see `setOnStoreCleared`) knows how many of the most recent
  /// turns are worth rebuilding — anything beyond this is refused by
  /// [addDocument] anyway.
  int get maxSessionDocuments;

  Future<void> initialize();
  Future<void> addDocument(RagDocument doc);
  Future<void> addDocumentBatch(List<RagDocument> docs);
  Future<void> clearSession();
  Future<void> setKnowledgeBase(List<RagDocument> docs);

  /// Searches only the lore/knowledge-base documents (anything not tagged
  /// as a session document).
  Future<List<String>> searchLore(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  });

  /// Searches only the conversation-memory documents. An empty list is a
  /// valid result — "nothing relevant in the conversation history" — not
  /// an error and not padded with unrelated lore hits.
  Future<List<String>> searchSession(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  });

  /// Registers a callback invoked whenever [setKnowledgeBase] actually clears
  /// and reloads the store (its requested doc set changed since last time).
  ///
  /// The underlying vector store has no scoped clear — wiping the knowledge
  /// base also wipes session memory, with no way to avoid that. This is the
  /// hook a feature can use to restore its own session documents from
  /// whatever it persists as the source of truth, right after that happens.
  /// Never called when [setKnowledgeBase] is a no-op (unchanged doc set).
  void setOnStoreCleared(Future<void> Function() callback);
}

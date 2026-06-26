import 'package:opfan/core/models/rag_document.dart';

abstract class IRAGService {
  Future<void> initialize();
  Future<void> addDocument(RagDocument doc);
  Future<void> addDocumentBatch(List<RagDocument> docs);
  Future<List<String>> search(String query, {int topK = 3});
  Future<void> clearSession();
  Future<void> setKnowledgeBase(List<RagDocument> docs);
}

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';

class RAGService implements IRAGService {
  bool _initialized = false;
  bool _vectorStoreReady = false;
  EmbeddingModel? _embeddingModel;
  List<RagDocument> _knowledgeBaseDocs = [];
  int _sessionDocCount = 0;

  static const _owner = 'vegapunk';
  static const _dbFileName = 'opfan_rag.db';

  // Session documents accumulate for the lifetime of a chat (only cleared on
  // an explicit reset). Cap them so a very long single session doesn't keep
  // growing the vector store and slowing down `searchSimilar`.
  static const _maxSessionDocs = 20;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      _embeddingModel = await RagStoreCoordinator.ensureEmbedderInstalled();
      _vectorStoreReady = true;

      debugPrint('RAGService: ready (vector search)');
    } catch (e) {
      debugPrint('RAGService: init error: $e');
      _initialized = false;
    }
  }

  /// Re-asserts that the shared vector store points at this service's own
  /// database before every operation — another RAG feature (e.g. Nami
  /// finances) may have switched it since [initialize] ran.
  Future<bool> _ensureActiveStore() async {
    if (!_vectorStoreReady) return false;
    await RagStoreCoordinator.ensureActive(_owner, _dbFileName);
    return true;
  }

  @override
  Future<void> addDocument(RagDocument doc) async {
    if (!await _ensureActiveStore()) return;
    if (doc.isSession) {
      if (_sessionDocCount >= _maxSessionDocs) return;
      _sessionDocCount++;
    }
    final model = _embeddingModel;
    if (model == null) return;

    try {
      final embedding = await model.generateEmbedding(
        doc.content,
        taskType: TaskType.retrievalDocument,
      );
      await FlutterGemmaPlugin.instance.addDocumentWithEmbedding(
        id: doc.id,
        content: doc.content,
        embedding: embedding,
        metadata: doc.metadataJson,
      );
    } catch (e) {
      debugPrint('RAGService: addDocument error: $e');
    }
  }

  @override
  Future<void> addDocumentBatch(List<RagDocument> docs) async {
    if (docs.isEmpty || !await _ensureActiveStore()) return;
    final model = _embeddingModel;
    if (model == null) return;

    try {
      final kbDocs = docs.where((d) => !d.isSession).toList();
      if (kbDocs.isNotEmpty) _knowledgeBaseDocs = kbDocs;

      final contents = docs.map((d) => d.content).toList();
      final embeddings = await model.generateEmbeddings(
        contents,
        taskType: TaskType.retrievalDocument,
      );

      for (var i = 0; i < docs.length; i++) {
        await FlutterGemmaPlugin.instance.addDocumentWithEmbedding(
          id: docs[i].id,
          content: docs[i].content,
          embedding: embeddings[i],
          metadata: docs[i].metadataJson,
        );
      }
      debugPrint('RAGService: ${docs.length} docs added');
    } catch (e) {
      debugPrint('RAGService: addDocumentBatch error: $e');
    }
  }

  @override
  Future<List<String>> search(String query, {int topK = 3}) async {
    if (query.trim().isEmpty || !await _ensureActiveStore()) return [];

    try {
      final results = await FlutterGemmaPlugin.instance.searchSimilar(
        query: query,
        topK: topK,
      );
      final label =
          query.length > 30 ? '${query.substring(0, 30)}…' : query;
      debugPrint('RAGService: "$label" → ${results.length} docs');
      return results.map((r) => r.content).toList();
    } catch (e) {
      debugPrint('RAGService: search error: $e');
      return [];
    }
  }

  @override
  Future<void> clearSession() async {
    if (!await _ensureActiveStore()) return;

    try {
      await FlutterGemmaPlugin.instance.clearVectorStore();
      _sessionDocCount = 0;
      debugPrint('RAGService: store cleared');

      // Rebuild with KB docs so the knowledge base survives the session reset
      if (_knowledgeBaseDocs.isNotEmpty) {
        final kbSnapshot = List<RagDocument>.from(_knowledgeBaseDocs);
        _knowledgeBaseDocs = [];
        await addDocumentBatch(kbSnapshot);
        debugPrint('RAGService: KB restored (${kbSnapshot.length} docs)');
      }
    } catch (e) {
      debugPrint('RAGService: clearSession error: $e');
    }
  }

  @override
  Future<void> setKnowledgeBase(List<RagDocument> docs) async {
    if (!await _ensureActiveStore()) return;

    try {
      await FlutterGemmaPlugin.instance.clearVectorStore();
      debugPrint('RAGService: store cleared for new knowledge base');
      _knowledgeBaseDocs = [];
      _sessionDocCount = 0;
      if (docs.isNotEmpty) {
        await addDocumentBatch(docs);
      }
      debugPrint('RAGService: setKnowledgeBase loaded ${docs.length} docs');
    } catch (e) {
      debugPrint('RAGService: setKnowledgeBase error: $e');
    }
  }
}

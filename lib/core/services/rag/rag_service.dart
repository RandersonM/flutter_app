import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';

class RAGService implements IRAGService {
  bool _initialized = false;
  bool _vectorStoreReady = false;
  EmbeddingModel? _embeddingModel;
  List<RagDocument> _knowledgeBaseDocs = [];

  // Gecko-64: smallest embedding model (~110 MB), no HuggingFace auth required
  static const _modelUrl =
      'https://huggingface.co/litert-community/Gecko-110m-en/resolve/main/Gecko_64_quant.tflite';
  static const _tokenizerUrl =
      'https://huggingface.co/litert-community/Gecko-110m-en/resolve/main/sentencepiece.model';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      debugPrint('RAGService: installing embedding model…');
      await FlutterGemma.installEmbedder()
          .modelFromNetwork(_modelUrl)
          .tokenizerFromNetwork(_tokenizerUrl)
          .withModelProgress(
            (p) => debugPrint('RAGService: embedder model $p%'),
          )
          .withTokenizerProgress(
            (p) => debugPrint('RAGService: embedder tokenizer $p%'),
          )
          .install();

      _embeddingModel = await FlutterGemma.getActiveEmbedder();

      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDir.path}/opfan_rag.db';
      await FlutterGemmaPlugin.instance.initializeVectorStore(dbPath);
      _vectorStoreReady = true;

      debugPrint('RAGService: ready (vector search)');
    } catch (e) {
      debugPrint('RAGService: init error: $e');
      _initialized = false;
    }
  }

  @override
  Future<void> addDocument(RagDocument doc) async {
    if (!_vectorStoreReady) return;
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
    if (!_vectorStoreReady || docs.isEmpty) return;
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
    if (!_vectorStoreReady || query.trim().isEmpty) return [];

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
    if (!_vectorStoreReady) return;

    try {
      await FlutterGemmaPlugin.instance.clearVectorStore();
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
    if (!_vectorStoreReady) return;

    try {
      await FlutterGemmaPlugin.instance.clearVectorStore();
      debugPrint('RAGService: store cleared for new knowledge base');
      _knowledgeBaseDocs = [];
      if (docs.isNotEmpty) {
        await addDocumentBatch(docs);
      }
      debugPrint('RAGService: setKnowledgeBase loaded ${docs.length} docs');
    } catch (e) {
      debugPrint('RAGService: setKnowledgeBase error: $e');
    }
  }
}

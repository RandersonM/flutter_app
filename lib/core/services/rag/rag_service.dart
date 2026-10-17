import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:hive/hive.dart';

import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';

class RAGService implements IRAGService {
  bool _initialized = false;
  bool _vectorStoreReady = false;
  EmbeddingModel? _embeddingModel;
  List<RagDocument> _knowledgeBaseDocs = [];
  int _sessionDocCount = 0;
  Future<void> Function()? _onStoreCleared;

  static const _owner = 'vegapunk';
  static const _dbFileName = 'opfan_rag.db';

  // Session documents accumulate for the lifetime of the process (only
  // cleared on an explicit reset or a knowledge-base change — see
  // `setKnowledgeBase`). Cap them so long-running usage doesn't keep growing
  // the vector store and slowing down `searchSimilar`.
  //
  // This cap is enforced in memory, for this process's lifetime, against
  // whatever the store held the last time it was cleared. It is NOT
  // re-verified against what's actually on disk on a fresh app launch — the
  // underlying plugin has no per-document delete, only a full
  // `clearVectorStore()`, so there is no cheap way to prune older documents
  // down to the cap without wiping everything. Accepted trade-off per this
  // feature's D1 decision (`.specs/features/vegapunk-chat-memory/context.md`):
  // keep the existing cap mechanism as-is, no added retention machinery.
  static const _maxSessionDocs = 20;

  @override
  int get maxSessionDocuments => _maxSessionDocs;

  /// Over-fetch multiplier before filtering by namespace — asking the plugin
  /// for exactly `topK` and filtering afterwards can legitimately return
  /// fewer than `topK` (or zero) session hits even when enough exist, if
  /// lore documents rank higher overall in the unfiltered top-K.
  static const int _overFetchFactor = 4;

  @visibleForTesting
  static const String metaBoxNameForTesting = 'vegapunk_rag_index_meta';
  @visibleForTesting
  static const String kbFingerprintKeyForTesting = 'kb_fingerprint';

  Box<dynamic>? _metaBox;

  /// Incremented exactly when [setKnowledgeBase] takes the "unchanged
  /// fingerprint" branch. Test-only instrumentation: on an uninitialized
  /// service, both branches complete silently without throwing (neither ever
  /// reaches the plugin), so a test can't otherwise tell which branch ran
  /// from the outside.
  @visibleForTesting
  int skippedReloadCountForTesting = 0;

  /// Incremented exactly when [setKnowledgeBase] takes the "fingerprint
  /// changed" branch, before it even reaches the vector store — see
  /// [skippedReloadCountForTesting].
  @visibleForTesting
  int attemptedReloadCountForTesting = 0;

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

  /// Runs [operation] on this service's own database — another RAG feature
  /// (e.g. Nami finances) may have switched the shared store since
  /// [initialize] ran. Returns [unavailable] when the store never came up.
  Future<T> _inStore<T>(Future<T> Function() operation, T unavailable) async {
    if (!_vectorStoreReady) return unavailable;
    return RagStoreCoordinator.withStore(_owner, _dbFileName, operation);
  }

  Future<Box<dynamic>> _meta() async =>
      _metaBox ??= await Hive.openBox<dynamic>(metaBoxNameForTesting);

  /// Deterministic fingerprint of a requested doc set — a sorted join of
  /// ids. Two calls with the same set of documents (regardless of order)
  /// produce the same fingerprint. Touches no instance state, so it's a
  /// `static` pure function — exposed for T23's idempotency test to compute
  /// the exact value `setKnowledgeBase` will compare against.
  @visibleForTesting
  static String fingerprintForTesting(List<RagDocument> docs) {
    final ids = docs.map((d) => d.id).toList()..sort();
    return ids.join('|');
  }

  @override
  void setOnStoreCleared(Future<void> Function() callback) {
    _onStoreCleared = callback;
  }

  @override
  Future<void> addDocument(RagDocument doc) async {
    if (!_vectorStoreReady) return;
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
      await _inStore(
        () => FlutterGemmaPlugin.instance.addDocumentWithEmbedding(
          id: doc.id,
          content: doc.content,
          embedding: embedding,
          metadata: doc.metadataJson,
        ),
        null,
      );
    } catch (e) {
      debugPrint('RAGService: addDocument error: $e');
    }
  }

  @override
  Future<void> addDocumentBatch(List<RagDocument> docs) async {
    if (docs.isEmpty || !_vectorStoreReady) return;
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

      await _inStore(() async {
        for (var i = 0; i < docs.length; i++) {
          await FlutterGemmaPlugin.instance.addDocumentWithEmbedding(
            id: docs[i].id,
            content: docs[i].content,
            embedding: embeddings[i],
            metadata: docs[i].metadataJson,
          );
        }
      }, null);
      debugPrint('RAGService: ${docs.length} docs added');
    } catch (e) {
      debugPrint('RAGService: addDocumentBatch error: $e');
    }
  }

  @override
  Future<List<String>> searchLore(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  }) => _scopedSearch(
    query,
    topK: topK,
    threshold: threshold,
    sessionOnly: false,
  );

  @override
  Future<List<String>> searchSession(
    String query, {
    int topK = 2,
    double threshold = 0.5,
  }) =>
      _scopedSearch(query, topK: topK, threshold: threshold, sessionOnly: true);

  Future<List<String>> _scopedSearch(
    String query, {
    required int topK,
    required double threshold,
    required bool sessionOnly,
  }) async {
    if (query.trim().isEmpty || !_vectorStoreReady) return const [];

    try {
      final raw = await _inStore(
        () => FlutterGemmaPlugin.instance.searchSimilar(
          query: query,
          topK: topK * _overFetchFactor,
          threshold: threshold,
        ),
        const <RetrievalResult>[],
      );
      final scoped = filterScopedResults(
        raw,
        sessionOnly: sessionOnly,
        topK: topK,
        threshold: threshold,
      );

      final label = query.length > 30 ? '${query.substring(0, 30)}…' : query;
      debugPrint(
        'RAGService: "$label" → ${scoped.length} '
        '${sessionOnly ? "session" : "lore"} docs',
      );
      return scoped;
    } catch (e) {
      debugPrint('RAGService: scoped search error: $e');
      return const [];
    }
  }

  /// Pure namespace/threshold filter over raw plugin hits — no store, no
  /// embedding model, no I/O. Extracted so this specific logic (the part
  /// `searchLore`/`searchSession` actually need to get right) is testable
  /// without the real `flutter_gemma` plugin, which needs a network-installed
  /// embedding model and native FFI unavailable under `flutter_test`.
  ///
  /// Re-checks [threshold] defensively — the plugin's own threshold enforcement
  /// is documented as backend-dependent ("filters are a safe no-op" for an
  /// undeclared field; a similarity threshold below the store's own support
  /// could plausibly be the same kind of best-effort behavior), so a hit
  /// below the requested bar must not silently slip through.
  @visibleForTesting
  static List<String> filterScopedResults(
    List<RetrievalResult> raw, {
    required bool sessionOnly,
    required int topK,
    required double threshold,
  }) {
    return raw
        .where((r) => r.similarity >= threshold)
        .where(
          (r) => r.id.startsWith(RagDocument.sessionIdPrefix) == sessionOnly,
        )
        .take(topK)
        .map((r) => r.content)
        .toList();
  }

  @override
  Future<void> clearSession() => _inStore(() async {
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
  }, null);

  @override
  Future<void> setKnowledgeBase(List<RagDocument> docs) async {
    // Checked before touching the store on purpose: this only needs the
    // local Hive meta box, so the common case (KB unchanged — every screen
    // open with the default categories) never has to await
    // RagStoreCoordinator/the embedding model/the plugin at all, and stays
    // hermetically testable without either.
    final meta = await _meta();
    final fingerprint = fingerprintForTesting(docs);
    if (meta.get(kbFingerprintKeyForTesting) == fingerprint) {
      // Same doc set as last time — the persisted vector store already has
      // this content from whenever it was last written (same file across
      // app launches, via RagStoreCoordinator). Still record it as the
      // current KB snapshot so a later `clearSession()` call has something
      // to restore — without this, `clearSession` would wipe the store and
      // find `_knowledgeBaseDocs` empty on the very first call of a fresh
      // process, permanently losing the knowledge base.
      if (docs.isNotEmpty) _knowledgeBaseDocs = docs;
      skippedReloadCountForTesting++;
      debugPrint('RAGService: KB unchanged, skipping clear+reload');
      return;
    }

    attemptedReloadCountForTesting++;
    final reloaded = await _inStore(() async {
      try {
        debugPrint('RAGService: KB fingerprint changed, reloading…');
        await FlutterGemmaPlugin.instance.clearVectorStore();
        _knowledgeBaseDocs = [];
        _sessionDocCount = 0;
        if (docs.isNotEmpty) {
          await addDocumentBatch(docs);
        }
        await meta.put(kbFingerprintKeyForTesting, fingerprint);
        debugPrint('RAGService: setKnowledgeBase loaded ${docs.length} docs');
        return true;
      } catch (e) {
        debugPrint('RAGService: setKnowledgeBase error: $e');
        return false;
      }
    }, false);
    if (!reloaded) return;

    // clearVectorStore() has no scope — it just wiped session memory too.
    // Give the feature layer a chance to restore it from its own persisted
    // source of truth (see IRAGService.setOnStoreCleared).
    final onCleared = _onStoreCleared;
    if (onCleared != null) await onCleared();
  }
}

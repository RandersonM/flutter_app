import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart' show RetrievalResult;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/rag/rag_document.dart';
import 'package:opfan/core/services/rag/rag_service.dart';

import '../../../fakes/fake_user_storage_service.dart';

/// Covers what's hermetically testable in `RAGService` without a real
/// `flutter_gemma` plugin — every other RAG-touching test in this project
/// (Nami's, Vegapunk's) fakes at the `I*RagService` interface layer for the
/// same reason: the real plugin needs a network-installed embedding model
/// and native FFI, neither available under `flutter_test`.
///
/// NOT covered here, for that reason: the "fingerprint changed → actually
/// clears and reloads the store" transition. `setKnowledgeBase` only reaches
/// `clearVectorStore()`/`addDocumentBatch()` once the vector store is ready,
/// which requires a real, installed embedding model. What IS
/// covered and fully precise: the fingerprint comparison itself (pure), and
/// the "unchanged → skip, no clear attempted" path (observable hermetically
/// because it returns before ever needing the store).
RagDocument _doc(String id, {bool isSession = false}) => RagDocument(
  id: id,
  content: 'content-$id',
  category: isSession ? 'session' : 'lore',
  language: 'both',
  topic: 'topic',
  isSession: isSession,
);

RetrievalResult _hit(String id, double similarity) =>
    RetrievalResult(id: id, content: 'content-$id', similarity: similarity);

void main() {
  group('RAGService.filterScopedResults (pure)', () {
    test('keeps only session-prefixed hits when sessionOnly is true', () {
      final raw = [
        _hit('vgp-001', 0.9),
        _hit('${RagDocument.sessionIdPrefix}a', 0.8),
        _hit('${RagDocument.sessionIdPrefix}b', 0.7),
      ];

      final result = RAGService.filterScopedResults(
        raw,
        sessionOnly: true,
        topK: 5,
        threshold: 0.0,
      );

      expect(result, [
        'content-${RagDocument.sessionIdPrefix}a',
        'content-${RagDocument.sessionIdPrefix}b',
      ]);
    });

    test('keeps only non-session hits when sessionOnly is false', () {
      final raw = [
        _hit('vgp-001', 0.9),
        _hit('${RagDocument.sessionIdPrefix}a', 0.8),
      ];

      final result = RAGService.filterScopedResults(
        raw,
        sessionOnly: false,
        topK: 5,
        threshold: 0.0,
      );

      expect(result, ['content-vgp-001']);
    });

    test('drops hits below threshold even if the plugin returned them', () {
      // Regression guard for the exact scenario the doc comment on
      // filterScopedResults calls out: the plugin's threshold enforcement is
      // documented as backend-dependent, so this must not trust it blindly.
      final raw = [
        _hit('${RagDocument.sessionIdPrefix}a', 0.9),
        _hit('${RagDocument.sessionIdPrefix}b', 0.2),
      ];

      final result = RAGService.filterScopedResults(
        raw,
        sessionOnly: true,
        topK: 5,
        threshold: 0.5,
      );

      expect(result, ['content-${RagDocument.sessionIdPrefix}a']);
    });

    test('respects topK after filtering, not before', () {
      final raw = [
        _hit('${RagDocument.sessionIdPrefix}a', 0.9),
        _hit('vgp-001', 0.85),
        _hit('${RagDocument.sessionIdPrefix}b', 0.8),
        _hit('${RagDocument.sessionIdPrefix}c', 0.7),
      ];

      final result = RAGService.filterScopedResults(
        raw,
        sessionOnly: true,
        topK: 2,
        threshold: 0.0,
      );

      // 3 session hits exist; topK=2 must cap the FILTERED list, not the raw
      // 4-item input (which would already satisfy a naive `take(2)` before
      // filtering by accident, so this specifically checks filter-then-take
      // ordering).
      expect(result, [
        'content-${RagDocument.sessionIdPrefix}a',
        'content-${RagDocument.sessionIdPrefix}b',
      ]);
    });

    test('returns empty when nothing matches the namespace', () {
      final raw = [_hit('vgp-001', 0.9), _hit('vgp-002', 0.8)];

      final result = RAGService.filterScopedResults(
        raw,
        sessionOnly: true,
        topK: 5,
        threshold: 0.0,
      );

      expect(result, isEmpty);
    });
  });

  group('RAGService.fingerprintForTesting (pure)', () {
    test('is identical for the same doc set regardless of order', () {
      final a = [_doc('x'), _doc('y'), _doc('z')];
      final b = [_doc('z'), _doc('x'), _doc('y')];

      expect(
        RAGService.fingerprintForTesting(a),
        RAGService.fingerprintForTesting(b),
      );
    });

    test('differs when the doc set actually changes', () {
      final a = [_doc('x'), _doc('y')];
      final b = [_doc('x'), _doc('y'), _doc('z')];

      expect(
        RAGService.fingerprintForTesting(a),
        isNot(RAGService.fingerprintForTesting(b)),
      );
    });
  });

  group('RAGService.setKnowledgeBase idempotency', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rag_service_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test(
      'skips clearing when the requested doc set matches the stored fingerprint',
      () async {
        final docs = [_doc('vgp-001'), _doc('vgp-002')];
        final box = await Hive.openBox<dynamic>(
          RAGService.metaBoxNameForTesting,
        );
        await box.put(
          RAGService.kbFingerprintKeyForTesting,
          RAGService.fingerprintForTesting(docs),
        );

        final service = RAGService(storage: FakeUserStorageService());
        await service.setKnowledgeBase(docs);

        // The service is never initialized, so on its own that would ALSO
        // make the "fingerprint changed" branch bail out silently (it never
        // reaches the plugin either) — without these counters, this test
        // would pass even if the fingerprint check were deleted entirely.
        expect(service.skippedReloadCountForTesting, 1);
        expect(service.attemptedReloadCountForTesting, 0);
      },
    );

    test(
      'attempts a reload when the doc set does not match the stored fingerprint',
      () async {
        final docs = [_doc('vgp-001'), _doc('vgp-002')];
        final box = await Hive.openBox<dynamic>(
          RAGService.metaBoxNameForTesting,
        );
        await box.put(RAGService.kbFingerprintKeyForTesting, 'stale-value');

        final service = RAGService(storage: FakeUserStorageService());
        await service.setKnowledgeBase(docs);

        expect(service.attemptedReloadCountForTesting, 1);
        expect(service.skippedReloadCountForTesting, 0);
      },
    );

    test(
      'attempts a reload on the very first call (no fingerprint yet)',
      () async {
        final docs = [_doc('vgp-001')];
        final service = RAGService(storage: FakeUserStorageService());

        await service.setKnowledgeBase(docs);

        expect(service.attemptedReloadCountForTesting, 1);
        expect(service.skippedReloadCountForTesting, 0);
      },
    );
  });
}

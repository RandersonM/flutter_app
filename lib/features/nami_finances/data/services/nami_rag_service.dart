import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';
import 'package:opfan/features/nami_finances/data/models/expense_match.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';

class NamiRagService implements INamiRagService {
  static const _owner = 'nami_finances';
  static const _dbFileName = 'nami_finances_store.db';

  /// Bump to force a full re-index on the next launch.
  ///
  /// v1 stored one document per *month*, containing a numeric summary
  /// ("Receita total: R$ 8.400,00 …"). That was the wrong unit twice over:
  /// numbers do not embed usefully, and the per-expense descriptions the user
  /// actually typed were never indexed at all. v2 stores one document per
  /// expense description. The old documents cannot be deleted individually —
  /// flutter_gemma exposes no `removeDocument` on its public API — so a version
  /// change clears the whole store and rebuilds it.
  static const int _schemaVersion = 2;

  /// `id` prefix marking a document as an indexed expense, so a hit from any
  /// other document kind can be filtered out even if the store is shared later.
  static const String _expenseIdPrefix = 'exp:';

  static const String _metaBoxName = 'nami_rag_index_meta';
  static const String _schemaVersionKey = '__schema_version';

  /// Similarity floor for [findExpenses].
  ///
  /// Starting point, not a calibrated value — tune it against real user data.
  /// Too low and unrelated questions retrieve arbitrary expenses; too high and
  /// paraphrases stop matching.
  static const double defaultThreshold = 0.55;

  bool _isInitialized = false;
  bool _backfilled = false;
  Box<dynamic>? _metaBox;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await RagStoreCoordinator.ensureEmbedderInstalled();
      _isInitialized = true;
      debugPrint('NamiRagService initialized (schema v$_schemaVersion).');
    } catch (e) {
      debugPrint('Failed to initialize NamiRagService: $e');
    }
  }

  /// Runs [operation] on this feature's own database — the Vegapunk chat RAG
  /// may have switched the shared store since the last call (see
  /// [RagStoreCoordinator]).
  Future<T> _inStore<T>(Future<T> Function() operation) =>
      RagStoreCoordinator.withStore(_owner, _dbFileName, operation);

  Future<Box<dynamic>> _meta() async =>
      _metaBox ??= await Hive.openBox<dynamic>(_metaBoxName);

  /// Fingerprint of a month's indexed state. Changes whenever the month is
  /// edited, so [syncMonth] can skip re-embedding an unchanged month.
  static String _fingerprint(NamiFinancesModel model) =>
      'v$_schemaVersion:${model.updatedAt.toIso8601String()}';

  /// Drops the whole store when the on-disk index predates [_schemaVersion].
  /// No-op once migrated.
  Future<void> _migrateIfNeeded() async {
    final meta = await _meta();
    if (meta.get(_schemaVersionKey) == _schemaVersion) return;

    debugPrint('NamiRagService: re-indexing for schema v$_schemaVersion…');
    await _inStore(() async {
      try {
        await FlutterGemmaPlugin.instance.clearVectorStore();
      } catch (e) {
        debugPrint('NamiRagService: clearVectorStore failed: $e');
      }
    });
    await meta.clear();
    await meta.put(_schemaVersionKey, _schemaVersion);
  }

  @override
  Future<void> syncMonth(NamiFinancesModel model) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    await _migrateIfNeeded();

    final meta = await _meta();
    final monthKey = _monthKey(model);
    if (meta.get(monthKey) == _fingerprint(model)) return;

    // Only descriptions carry meaning worth embedding. An expense the user
    // never described has nothing to match on, so indexing it would only add
    // noise to the nearest-neighbour set.
    final described = model.expenses.where(
      (e) => e.description.trim().isNotEmpty,
    );

    final indexed = await _inStore(() async {
      var count = 0;
      for (final expense in described) {
        if (await _indexExpense(expense, monthKey)) count++;
      }
      return count;
    });

    await meta.put(monthKey, _fingerprint(model));
    debugPrint('NamiRagService: indexed $indexed expense(s) for $monthKey');
  }

  Future<bool> _indexExpense(ExpenseModel expense, String monthKey) async {
    try {
      await FlutterGemmaPlugin.instance.addDocument(
        // Category and month go in the content as words, not numbers: they are
        // part of how the user refers to a purchase ("comida de julho").
        id: '$_expenseIdPrefix${expense.id}',
        content:
            '${expense.description.trim()} '
            '(${expense.category.name}, $monthKey)',
        metadata: jsonEncode({
          'module': 'nami_finances',
          'kind': 'expense',
          'expenseId': expense.id,
          'month': monthKey,
          'category': expense.category.name,
        }),
      );
      return true;
    } catch (e) {
      debugPrint('NamiRagService: failed to index expense ${expense.id}: $e');
      return false;
    }
  }

  @override
  Future<void> backfillIfNeeded(List<NamiFinancesModel> months) async {
    if (_backfilled || months.isEmpty) return;
    _backfilled = true;
    for (final month in months) {
      await syncMonth(month);
    }
  }

  @override
  Future<List<ExpenseMatch>> findExpenses(
    String query, {
    int topK = 8,
    double threshold = defaultThreshold,
  }) async {
    if (query.trim().isEmpty) return const [];
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return const [];

    try {
      final results = await _inStore(
        () => FlutterGemmaPlugin.instance.searchSimilar(
          query: query,
          topK: topK,
          threshold: threshold,
        ),
      );

      final matches = <ExpenseMatch>[];
      for (final result in results) {
        if (!result.id.startsWith(_expenseIdPrefix)) continue;
        // `threshold` is honoured by the store, but re-check: a backend that
        // ignores it would otherwise silently return low-relevance rows.
        if (result.similarity < threshold) continue;

        final monthKey = _monthKeyFromMetadata(result.metadata);
        if (monthKey == null) continue;

        matches.add(
          ExpenseMatch(
            expenseId: result.id.substring(_expenseIdPrefix.length),
            monthKey: monthKey,
            similarity: result.similarity,
          ),
        );
      }

      matches.sort((a, b) => b.similarity.compareTo(a.similarity));
      return matches;
    } catch (e) {
      debugPrint('NamiRagService: findExpenses failed: $e');
      return const [];
    }
  }

  static String? _monthKeyFromMetadata(String? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map && decoded['month'] is String) {
        return decoded['month'] as String;
      }
    } catch (_) {
      // Malformed metadata — treat as a non-match rather than throwing.
    }
    return null;
  }

  static String _monthKey(NamiFinancesModel model) =>
      '${model.month.year}-${model.month.month.toString().padLeft(2, '0')}';
}

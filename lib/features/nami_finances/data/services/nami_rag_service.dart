import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/storage/user_data_names.dart';
import 'package:opfan/features/nami_finances/data/models/expense_match.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';

class NamiRagService implements INamiRagService {
  NamiRagService({required this._storage, required this._installEmbedder});

  final IUserStorageService _storage;
  final Future<void> Function() _installEmbedder;

  /// Bump to force a full re-index on the next launch.
  ///
  /// v1 stored one document per *month*, containing a numeric summary
  /// ("Receita total: R$ 8.400,00 …"). That was the wrong unit twice over:
  /// numbers do not embed usefully, and the per-expense descriptions the user
  /// actually typed were never indexed at all. v2 stored one document per
  /// expense description, but every edit gave each expense a new id, so the
  /// store piled up duplicates. v3 records which documents each month indexed
  /// and removes the ones an edit dropped. A version change clears the whole
  /// store and rebuilds it.
  static const int _schemaVersion = 3;

  /// `id` prefix marking a document as an indexed expense, so a hit from any
  /// other document kind can be filtered out even if the store is shared later.
  static const String _expenseIdPrefix = 'exp:';

  static const String _schemaVersionKey = '__schema_version';

  /// Similarity floor for [findExpenses].
  ///
  /// Starting point, not a calibrated value — tune it against real user data.
  /// Too low and unrelated questions retrieve arbitrary expenses; too high and
  /// paraphrases stop matching.
  static const double defaultThreshold = 0.55;

  bool _isInitialized = false;
  final Set<String> _backfilledStores = {};

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _installEmbedder();
      _isInitialized = true;
      debugPrint('NamiRagService initialized (schema v$_schemaVersion).');
    } catch (e) {
      debugPrint('Failed to initialize NamiRagService: $e');
    }
  }

  /// Runs [operation] on this feature's own database — the Vegapunk chat RAG
  /// may have switched the shared store since the last call (see
  /// [RagStoreCoordinator]).
  Future<T> _inStore<T>(String store, Future<T> Function() operation) =>
      RagStoreCoordinator.withStore(store, store, operation);

  /// Each signed-in user indexes their own expenses in their own database.
  Future<String> _storeFile() =>
      _storage.userDatabaseFileName(UserDataNames.namiRagDatabase);

  /// The index record of [store]'s user, or null when someone else signed in
  /// (or out) since [store] was resolved.
  Future<Box<dynamic>?> _metaOf(String store) async {
    final meta = await _storage.openUserBox<dynamic>(
      UserDataNames.namiRagIndexMetaBox,
    );
    return await _storeFile() == store ? meta : null;
  }

  Future<bool> _ensureInitialized() async {
    if (!_isInitialized) await initialize();
    return _isInitialized;
  }

  /// Drops the whole store when the on-disk index predates [_schemaVersion].
  /// No-op once migrated. Call it inside the store operation.
  Future<void> _migrateIfNeeded(Box<dynamic> meta) async {
    if (meta.get(_schemaVersionKey) == _schemaVersion) return;

    debugPrint('NamiRagService: re-indexing for schema v$_schemaVersion…');
    try {
      await FlutterGemmaPlugin.instance.clearVectorStore();
    } catch (e) {
      debugPrint('NamiRagService: clearVectorStore failed: $e');
    }
    await meta.clear();
    await meta.put(_schemaVersionKey, _schemaVersion);
  }

  @override
  Future<void> syncMonth(NamiFinancesModel model) async {
    // Resolved before the embedder download, which can outlast a sign-out:
    // the month belongs to whoever was signed in when it was saved.
    final store = await _storeFile();
    if (!await _ensureInitialized()) return;
    await _syncMonthInto(store, model);
  }

  Future<void> _syncMonthInto(String store, NamiFinancesModel model) async {
    final monthKey = _monthKey(model);
    final wanted = documentsFor(model);
    final expensesByDocument = {
      for (final expense in model.expenses) _documentId(expense.id): expense,
    };

    // The month's record is read and written inside the store operation, so
    // two syncs of the same month cannot lose track of each other's documents.
    await _inStore(store, () async {
      final meta = await _metaOf(store);
      if (meta == null) {
        debugPrint('NamiRagService: user changed, $monthKey not indexed');
        return;
      }
      await _migrateIfNeeded(meta);

      final indexed = _indexedDocuments(meta.get(monthKey));
      final plan = planSync(indexed: indexed, wanted: wanted);
      if (plan.toIndex.isEmpty && plan.toRemove.isEmpty) return;

      for (final id in plan.toRemove) {
        if (await _removeDocument(id)) indexed.remove(id);
      }
      for (final id in plan.toIndex) {
        if (await _indexExpense(expensesByDocument[id]!, monthKey)) {
          indexed[id] = wanted[id]!;
        }
      }

      await meta.put(monthKey, indexed);
      debugPrint(
        'NamiRagService: $monthKey indexed ${plan.toIndex.length}, '
        'removed ${plan.toRemove.length} document(s)',
      );
    });
  }

  /// The documents [model] should have in the store, keyed by document id and
  /// valued by their text.
  ///
  /// Only descriptions carry meaning worth embedding. An expense the user
  /// never described has nothing to match on, so indexing it would only add
  /// noise to the nearest-neighbour set.
  static Map<String, String> documentsFor(NamiFinancesModel model) {
    final monthKey = _monthKey(model);
    return {
      for (final expense in model.expenses)
        if (expense.description.trim().isNotEmpty)
          _documentId(expense.id): _documentContent(expense, monthKey),
    };
  }

  /// What a month must change to go from the documents it [indexed] to the
  /// ones it [wanted]: index the new or reworded ones, remove the dropped ones.
  static ({List<String> toIndex, List<String> toRemove}) planSync({
    required Map<String, String> indexed,
    required Map<String, String> wanted,
  }) => (
    toIndex: [
      for (final entry in wanted.entries)
        if (indexed[entry.key] != entry.value) entry.key,
    ],
    toRemove: [
      for (final id in indexed.keys)
        if (!wanted.containsKey(id)) id,
    ],
  );

  static Map<String, String> _indexedDocuments(Object? stored) => {
    if (stored is Map)
      for (final entry in stored.entries)
        entry.key.toString(): entry.value.toString(),
  };

  static String _documentId(String expenseId) => '$_expenseIdPrefix$expenseId';

  // Category and month go in the content as words, not numbers: they are
  // part of how the user refers to a purchase ("comida de julho").
  static String _documentContent(ExpenseModel expense, String monthKey) =>
      '${expense.description.trim()} (${expense.category.name}, $monthKey)';

  Future<bool> _removeDocument(String id) async {
    try {
      await RagStoreCoordinator.removeDocument(id);
      return true;
    } catch (e) {
      debugPrint('NamiRagService: failed to remove $id: $e');
      return false;
    }
  }

  Future<bool> _indexExpense(ExpenseModel expense, String monthKey) async {
    try {
      await FlutterGemmaPlugin.instance.addDocument(
        id: _documentId(expense.id),
        content: _documentContent(expense, monthKey),
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
    if (months.isEmpty) return;
    final store = await _storeFile();
    if (!_backfilledStores.add(store)) return;
    if (!await _ensureInitialized()) return;
    for (final month in months) {
      await _syncMonthInto(store, month);
    }
  }

  @override
  Future<List<ExpenseMatch>> findExpenses(
    String query, {
    int topK = 8,
    double threshold = defaultThreshold,
  }) async {
    if (query.trim().isEmpty) return const [];
    if (!await _ensureInitialized()) return const [];

    try {
      final store = await _storeFile();
      final results = await _inStore(
        store,
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

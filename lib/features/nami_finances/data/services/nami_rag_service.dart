import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'dart:convert';

class NamiRagService {
  static const _owner = 'nami_finances';
  static const _dbFileName = 'nami_finances_store.db';
  bool _isInitialized = false;
  bool _backfilled = false;

  /// Installs the shared embedding model (see [RagStoreCoordinator]).
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await RagStoreCoordinator.ensureEmbedderInstalled();
      _isInitialized = true;
      debugPrint('NamiRagService initialized.');
    } catch (e) {
      debugPrint('Failed to initialize NamiRagService: $e');
    }
  }

  /// Re-asserts that the shared vector store points at this feature's own
  /// database — the Vegapunk chat RAG may have switched it since the last
  /// call (see [RagStoreCoordinator]).
  Future<void> _ensureActiveStore() =>
      RagStoreCoordinator.ensureActive(_owner, _dbFileName);

  /// Re-syncs previously saved months that predate the fix for the embedder
  /// never being activated (see [RagStoreCoordinator.ensureEmbedderInstalled]).
  /// Before that fix, `syncMonth` silently failed on save — the finances
  /// were persisted to Hive/Firestore, but never made it into the vector
  /// store, so the chat had no context for them. Runs once per app session
  /// (this service is a singleton); safe to call every time the chat opens.
  Future<void> backfillIfNeeded(List<NamiFinancesModel> months) async {
    if (_backfilled || months.isEmpty) return;
    _backfilled = true;
    for (final month in months) {
      await syncMonth(month);
    }
  }

  /// Natural-language summary of a month's finances — the single source of
  /// truth for both what gets embedded into the vector store ([syncMonth])
  /// and what gets injected as deterministic context for "this month" /
  /// "last month" style questions (see `NamiChatBloc`).
  static String summarize(NamiFinancesModel model) {
    final monthStr = model.month.month.toString().padLeft(2, '0');
    final yearStr = model.month.year.toString();

    // NOTE: previously this used a nested single-quoted string with escaped
    // `\$` markers, which suppressed interpolation entirely — every synced
    // document had the literal text "${e.key.name}: R$ ${e.value...}" for
    // its category breakdown instead of real numbers.
    final categoryBreakdown = model.expensesByCategory.entries
        .map((e) => '${e.key.name}: R\$ ${e.value.toStringAsFixed(2)}')
        .join(', ');

    final reserveBreakdown = model.reserves.isEmpty
        ? ''
        : model.reserves
              .map(
                (r) =>
                    '${r.purpose.name}: R\$ ${r.amount.toStringAsFixed(2)}'
                    '${r.note.isNotEmpty ? ' (${r.note})' : ''}',
              )
              .join(', ');

    final goalPart = model.reserveGoal != null && model.reserveGoal! > 0
        ? "Meta de reserva: R\$ ${model.reserveGoal!.toStringAsFixed(2)}. "
        : '';

    return "Resumo financeiro de $monthStr/$yearStr. "
        "Receita total: R\$ ${model.totalIncome.toStringAsFixed(2)}. "
        "Despesas totais: R\$ ${model.totalExpenses.toStringAsFixed(2)}. "
        "Despesas por categoria: $categoryBreakdown. "
        "Total reservado no mês: R\$ ${model.totalReserves.toStringAsFixed(2)}. "
        "${reserveBreakdown.isNotEmpty ? 'Reservas por finalidade: $reserveBreakdown. ' : ''}"
        "$goalPart"
        "Saldo disponível: R\$ ${model.availableAmount.toStringAsFixed(2)}.";
  }

  /// Syncs a monthly finances model into the vector store as a RAG document
  Future<void> syncMonth(NamiFinancesModel model) async {
    if (!_isInitialized) await initialize();
    await _ensureActiveStore();

    final monthStr = model.month.month.toString().padLeft(2, '0');
    final yearStr = model.month.year.toString();
    final content = summarize(model);

    final metadata = jsonEncode({
      "module": "nami_finances",
      "year": yearStr,
      "month": monthStr,
    });

    try {
      await FlutterGemmaPlugin.instance.addDocument(
        id: model.id,
        content: content,
        metadata: metadata,
      );
      debugPrint('Synced Nami finances document for $monthStr/$yearStr');
    } catch (e) {
      debugPrint('Failed to sync document to NamiRagService: $e');
    }
  }

  /// Performs a semantic search against the finances store
  Future<List<String>> searchSimilar(String query, {int topK = 3}) async {
    if (!_isInitialized) await initialize();
    await _ensureActiveStore();

    try {
      // NOTE: flutter_gemma searchSimilar handles the embeddings mapping automatically
      // when addDocument was used.
      final results = await FlutterGemmaPlugin.instance.searchSimilar(
        query: query,
        topK: topK,
      );
      return results.map((r) => r.content).toList();
    } catch (e) {
      debugPrint('Failed semantic search in NamiRagService: $e');
      return [];
    }
  }
}

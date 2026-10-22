import 'package:opfan/features/nami_finances/data/models/expense_match.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

/// Semantic index over the free text the user typed into their finances.
///
/// Scope is deliberately narrow: this indexes **expense descriptions**, which
/// are the only part of the finances data that structured queries cannot reach
/// ("aquela viagem pra praia" spans several categories and months, and matches
/// no enum). Totals, per-category breakdowns and month lookups are served
/// exactly by `INamiFinancesService` + the `getFinances` tool — embedding those
/// would be both redundant and lossy, since numbers have no useful semantic
/// neighbourhood.
abstract class INamiRagService {
  /// Installs the shared embedding model. Safe to call repeatedly.
  Future<void> initialize();

  /// Indexes one month's expense descriptions. Skips work when the month has
  /// not changed since it was last indexed.
  Future<void> syncMonth(NamiFinancesModel model);

  /// Indexes any month not yet covered by the current index schema. Once it
  /// has indexed every month it is a no-op for the rest of the app session;
  /// a run that could not finish (embedder not loaded, user switched) is
  /// retried on the next call.
  Future<void> backfillIfNeeded(List<NamiFinancesModel> months);

  /// Whether the signed-in user's backfill finished this session. Until then
  /// [findExpenses] may miss expenses of months not indexed yet.
  Future<bool> isIndexComplete();

  /// Loads the embedder, waiting only a few seconds: false while it is still
  /// downloading or could not be loaded. The load carries on in the background.
  Future<bool> isSearchReady();

  /// Finds expenses whose description is semantically close to [query].
  ///
  /// Returns matches ordered by descending similarity, dropping anything below
  /// [threshold] so "no relevant expense" is a real answer instead of the
  /// [topK] least-bad rows. Throws [ExpenseSearchNotReady] when the embedder
  /// is not loaded yet.
  Future<List<ExpenseMatch>> findExpenses(
    String query, {
    int topK,
    double threshold,
  });
}

/// The embedding model is still downloading (or could not be loaded), so
/// expenses cannot be searched yet.
class ExpenseSearchNotReady implements Exception {
  const ExpenseSearchNotReady();

  @override
  String toString() => 'ExpenseSearchNotReady';
}

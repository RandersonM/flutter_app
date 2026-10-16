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

  /// Indexes any month not yet covered by the current index schema. Runs at
  /// most once per app session.
  Future<void> backfillIfNeeded(List<NamiFinancesModel> months);

  /// Finds expenses whose description is semantically close to [query].
  ///
  /// Returns matches ordered by descending similarity, dropping anything below
  /// [threshold] so "no relevant expense" is a real answer instead of the
  /// [topK] least-bad rows.
  Future<List<ExpenseMatch>> findExpenses(
    String query, {
    int topK,
    double threshold,
  });
}

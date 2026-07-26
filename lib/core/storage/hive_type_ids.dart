/// Single source of truth for every Hive `TypeAdapter.typeId` in the app.
///
/// Hive identifies persisted objects by this integer alone. If two adapters
/// ever claim the same id, Hive will happily decode one model's bytes as the
/// other — silent local-data corruption that only shows up after an upgrade,
/// on users' devices. So the ids live here, and nowhere else: adapters must
/// reference these constants instead of writing a literal.
///
/// Rules when adding a model:
///  1. Add a constant here using the next free id in the feature's block.
///  2. Never change or reuse an id that has shipped — old bytes on disk still
///     carry it. Retire it in [retired] instead and take a fresh one.
///  3. Reference the constant from the adapter: `final int typeId = HiveTypeIds.x;`
///  4. Register the adapter in `HiveStorageService.initialize()`.
///
/// Blocks are spaced so a feature can grow without colliding with its
/// neighbour:
///   0–9    core (auth, theme, shared models)
///   10–19  nami_finances
///   20–29  zoro_workout
///   30–39  sanji_cooking
///   40–49  robin_knowledge
///   50+    unassigned — claim the next block and document it here
abstract final class HiveTypeIds {
  // ── core (0–9) ──────────────────────────────────────────────────────────
  /// Daily featured character model.
  static const int todayCharacter = 0;

  /// User authentication details.
  static const int userModel = 1;

  /// Custom application theme settings.
  static const int themeSettings = 2;

  // ── nami_finances (10–19) ───────────────────────────────────────────────
  /// Financial tracker overall model.
  static const int namiFinancesModel = 10;

  /// Monthly income list entry.
  static const int monthlyIncomeModel = 11;

  /// Individual expense item.
  static const int expenseModel = 12;

  /// Enum-like categories for expenses.
  static const int expenseCategory = 13;

  /// Individual reserve item.
  static const int reserveModel = 14;

  /// Enum-like purposes for reserves.
  static const int reservePurpose = 15;

  /// Ids that have shipped and must never be reused, even though no adapter
  /// claims them today. Empty for now — add here when a model is deleted.
  static const Set<int> retired = <int>{};

  /// Every id currently claimed by an adapter. Kept in sync by
  /// `hive_type_ids_test.dart`, which fails if this list disagrees with the
  /// adapters registered in [HiveStorageService] or contains a duplicate.
  static const List<int> all = <int>[
    todayCharacter,
    userModel,
    themeSettings,
    namiFinancesModel,
    monthlyIncomeModel,
    expenseModel,
    expenseCategory,
    reserveModel,
    reservePurpose,
  ];
}

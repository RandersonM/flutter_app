import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/one_piece/data/models/today_character.dart';

import 'i_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opfan/core/storage/hive_type_ids.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/models/theme/theme_model.dart';

/// One adapter plus the model type it decodes, bound together.
///
/// `Hive.registerAdapter<T>` resolves the adapter against `T`, and its match
/// test is `value is T`. Passing a `TypeAdapter<dynamic>` therefore infers
/// `T == dynamic`, making that adapter match *every* value — Hive then routes
/// all writes to whichever adapter was registered first. (Hive prints a warning
/// about this, but it is not an error.)
///
/// Capturing `T` at construction and registering from [register] keeps the
/// concrete type, so a list of these can be looped over safely.
abstract interface class HiveAdapterRegistration {
  /// The id the bound adapter reports — read by the type-id guard test.
  int get typeId;

  /// The model type this adapter is registered under. Exposed so a test can
  /// assert it is never `dynamic`, which is the failure this class prevents.
  Type get modelType;

  /// Registers the adapter under its concrete model type.
  void register();
}

class _Registration<T> implements HiveAdapterRegistration {
  const _Registration(this._adapter);

  final TypeAdapter<T> _adapter;

  @override
  int get typeId => _adapter.typeId;

  @override
  Type get modelType => T;

  @override
  void register() => Hive.registerAdapter<T>(_adapter);
}

class HiveStorageService implements IStorageService {
  /// Every adapter the app persists with. Type ids are owned by
  /// [HiveTypeIds] — see that file before adding a model here.
  ///
  /// The explicit type argument on each entry is what keeps Hive's dispatch
  /// correct; do not let it be inferred. Exposed (rather than inlined into
  /// [initialize]) so `test/core/storage/hive_type_ids_test.dart` can assert
  /// the reported ids match the registry, catching a collision at test time
  /// instead of on a user's device.
  static List<HiveAdapterRegistration> get adapters =>
      <HiveAdapterRegistration>[
        _Registration<TodayCharacter>(TodayCharacterAdapter()),
        _Registration<UserModel>(UserModelAdapter()),
        _Registration<ThemeSettings>(ThemeSettingsAdapter()),
        _Registration<NamiFinancesModel>(NamiFinancesModelAdapter()),
        _Registration<MonthlyIncomeModel>(MonthlyIncomeModelAdapter()),
        _Registration<ExpenseModel>(ExpenseModelAdapter()),
        _Registration<ExpenseCategory>(ExpenseCategoryAdapter()),
        _Registration<ReserveModel>(ReserveModelAdapter()),
        _Registration<ReservePurpose>(ReservePurposeAdapter()),
      ];

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();

    for (final registration in adapters) {
      registration.register();
    }
  }
}

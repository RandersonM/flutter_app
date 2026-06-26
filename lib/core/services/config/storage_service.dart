import 'i_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/models/theme_model.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/core/models/one_piece/today_character.dart';


class HiveStorageService implements IStorageService {
  /// Central Registry of Hive Type IDs to prevent collisions.
  ///
  /// | Type ID | Model Class          | Description                      |
  /// |---------|----------------------|----------------------------------|
  /// | 0       | TodayCharacter       | Daily featured character model   |
  /// | 1       | UserModel            | User authentication details      |
  /// | 2       | ThemeSettings        | Custom application theme settings|
  /// | 10      | NamiFinancesModel    | Financial tracker overall model  |
  /// | 11      | MonthlyIncomeModel   | Monthly income list entry        |
  /// | 12      | ExpenseModel         | Individual expense item          |
  /// | 13      | ExpenseCategory      | Enum-like categories for expenses|
  static const int todayCharacterTypeId = 0;
  static const int userModelTypeId = 1;
  static const int themeSettingsTypeId = 2;
  static const int namiFinancesModelTypeId = 10;
  static const int monthlyIncomeModelTypeId = 11;
  static const int expenseModelTypeId = 12;
  static const int expenseCategoryTypeId = 13;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register all Adapters
    Hive.registerAdapter(TodayCharacterAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ThemeSettingsAdapter());

    Hive.registerAdapter(NamiFinancesModelAdapter());
    Hive.registerAdapter(MonthlyIncomeModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
  }
}

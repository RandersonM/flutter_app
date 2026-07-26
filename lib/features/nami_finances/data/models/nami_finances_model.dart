import 'package:hive/hive.dart';

class NamiFinancesModel extends HiveObject {
  final String id;

  final DateTime month;

  final List<MonthlyIncomeModel> monthlyIncomes;

  final List<ExpenseModel> expenses;

  /// Legacy single-value reserves total. Kept for backward compatibility and
  /// denormalized on every save to equal [totalReserves] so the aggregation in
  /// `NamiFinancesService.getTotalSavings` / `getAccumulatedSavingsInfo`
  /// keeps working unchanged. New code should read [totalReserves].
  final double savings;

  /// Itemized reserves for the month (each with a purpose + optional note).
  /// Empty for records saved before this feature — see [totalReserves].
  final List<ReserveModel> reserves;

  /// Optional monthly reserve target. Null when the user has not set a goal.
  final double? reserveGoal;

  final DateTime createdAt;

  final DateTime updatedAt;

  NamiFinancesModel({
    required this.id,
    required this.month,
    required this.monthlyIncomes,
    required this.expenses,
    this.savings = 0.0,
    this.reserves = const [],
    this.reserveGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalIncome {
    return monthlyIncomes.fold(0.0, (sum, income) => sum + income.amount);
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Total reserved this month. Falls back to the legacy [savings] value for
  /// records saved before reserves became a list.
  double get totalReserves {
    if (reserves.isEmpty) return savings;
    return reserves.fold(0.0, (sum, reserve) => sum + reserve.amount);
  }

  double get availableAmount => totalIncome - totalExpenses - totalReserves;

  double get dailyAmount {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return availableAmount > 0 ? availableAmount / daysInMonth : 0;
  }

  double get savingsPercentage {
    if (totalIncome == 0) return 0;
    return (totalReserves / totalIncome) * 100;
  }

  double get yearlySavings {
    return totalReserves * 12;
  }

  /// Progress toward [reserveGoal] as a 0..1+ ratio, or null when no goal set.
  double? get reserveGoalProgress {
    final goal = reserveGoal;
    if (goal == null || goal <= 0) return null;
    return totalReserves / goal;
  }

  /// Reserve amounts aggregated by purpose.
  Map<ReservePurpose, double> get reservesByPurpose {
    final Map<ReservePurpose, double> totals = {};
    for (final reserve in reserves) {
      totals[reserve.purpose] = (totals[reserve.purpose] ?? 0) + reserve.amount;
    }
    return totals;
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  bool isSameMonth(DateTime other) {
    return month.year == other.year && month.month == other.month;
  }

  String get monthKey {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  Map<ExpenseCategory, double> get expensesByCategory {
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }
}

class MonthlyIncomeModel {
  final String id;

  final double amount;

  final String description;

  MonthlyIncomeModel({
    required this.id,
    required this.amount,
    required this.description,
  });
}

class ExpenseModel {
  final String id;

  final double amount;

  final ExpenseCategory category;

  final String description;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
  });
}

enum ExpenseCategory { fixed, food, transport, entertainment, health, other }

/// What a reserve is being set aside for.
enum ReservePurpose { emergency, travel, goal, investment, other }

class ReserveModel {
  final String id;

  final double amount;

  final ReservePurpose purpose;

  /// Optional free-text note describing the reserve. May be ''.
  final String note;

  ReserveModel({
    required this.id,
    required this.amount,
    required this.purpose,
    this.note = '',
  });
}

class NamiFinancesModelAdapter extends TypeAdapter<NamiFinancesModel> {
  @override
  final int typeId = 10;

  @override
  NamiFinancesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NamiFinancesModel(
      id: fields[0] as String,
      month: fields[1] as DateTime,
      monthlyIncomes: (fields[2] as List).cast<MonthlyIncomeModel>(),
      expenses: (fields[3] as List).cast<ExpenseModel>(),
      savings: fields[4] as double,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      // Fields 7 & 8 are absent in records saved before the reserves feature —
      // default to an empty list / null so legacy data loads unchanged.
      reserves: (fields[7] as List?)?.cast<ReserveModel>() ?? const [],
      reserveGoal: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, NamiFinancesModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.monthlyIncomes)
      ..writeByte(3)
      ..write(obj.expenses)
      ..writeByte(4)
      ..write(obj.savings)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.reserves)
      ..writeByte(8)
      ..write(obj.reserveGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamiFinancesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MonthlyIncomeModelAdapter extends TypeAdapter<MonthlyIncomeModel> {
  @override
  final int typeId = 11;

  @override
  MonthlyIncomeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyIncomeModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyIncomeModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyIncomeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 12;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as ExpenseCategory,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReserveModelAdapter extends TypeAdapter<ReserveModel> {
  @override
  final int typeId = 14;

  @override
  ReserveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReserveModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      purpose: fields[2] as ReservePurpose,
      note: fields[3] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, ReserveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.purpose)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReserveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReservePurposeAdapter extends TypeAdapter<ReservePurpose> {
  @override
  final int typeId = 15;

  @override
  ReservePurpose read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReservePurpose.emergency;
      case 1:
        return ReservePurpose.travel;
      case 2:
        return ReservePurpose.goal;
      case 3:
        return ReservePurpose.investment;
      case 4:
        return ReservePurpose.other;
      default:
        return ReservePurpose.other;
    }
  }

  @override
  void write(BinaryWriter writer, ReservePurpose obj) {
    switch (obj) {
      case ReservePurpose.emergency:
        writer.writeByte(0);
        break;
      case ReservePurpose.travel:
        writer.writeByte(1);
        break;
      case ReservePurpose.goal:
        writer.writeByte(2);
        break;
      case ReservePurpose.investment:
        writer.writeByte(3);
        break;
      case ReservePurpose.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservePurposeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 13;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.fixed;
      case 1:
        return ExpenseCategory.food;
      case 2:
        return ExpenseCategory.transport;
      case 3:
        return ExpenseCategory.entertainment;
      case 4:
        return ExpenseCategory.health;
      case 5:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.fixed:
        writer.writeByte(0);
        break;
      case ExpenseCategory.food:
        writer.writeByte(1);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(2);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(3);
        break;
      case ExpenseCategory.health:
        writer.writeByte(4);
        break;
      case ExpenseCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

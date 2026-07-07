import 'package:hive/hive.dart';

class NamiFinancesModel extends HiveObject {
  final String id;

  final DateTime month;

  final List<MonthlyIncomeModel> monthlyIncomes;

  final List<ExpenseModel> expenses;

  final double savings;

  final DateTime createdAt;

  final DateTime updatedAt;

  NamiFinancesModel({
    required this.id,
    required this.month,
    required this.monthlyIncomes,
    required this.expenses,
    this.savings = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalIncome {
    return monthlyIncomes.fold(0.0, (sum, income) => sum + income.amount);
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get availableAmount => totalIncome - totalExpenses - savings;

  double get dailyAmount {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return availableAmount > 0 ? availableAmount / daysInMonth : 0;
  }

  double get savingsPercentage {
    if (totalIncome == 0) return 0;
    return (savings / totalIncome) * 100;
  }

  double get yearlySavings {
    return savings * 12;
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
    );
  }

  @override
  void write(BinaryWriter writer, NamiFinancesModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.updatedAt);
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

import 'package:hive/hive.dart';

part 'nami_finances_model.g.dart';

@HiveType(typeId: 10)
class NamiFinancesModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime month;

  @HiveField(2)
  final List<MonthlyIncomeModel> monthlyIncomes;

  @HiveField(3)
  final List<ExpenseModel> expenses;

  @HiveField(4)
  final double savings;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
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

@HiveType(typeId: 11)
class MonthlyIncomeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  MonthlyIncomeModel({
    required this.id,
    required this.amount,
    required this.description,
  });
}

@HiveType(typeId: 12)
class ExpenseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final ExpenseCategory category;

  @HiveField(3)
  final String description;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
  });
}

@HiveType(typeId: 13)
enum ExpenseCategory {
  @HiveField(0)
  fixed,
  @HiveField(1)
  food,
  @HiveField(2)
  transport,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  health,
  @HiveField(5)
  other,
}

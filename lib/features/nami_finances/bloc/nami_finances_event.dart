import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

abstract class NamiFinancesEvent {}

class LoadFinances extends NamiFinancesEvent {
  final DateTime month;
  LoadFinances(this.month);
}

class LoadCurrentMonthFinances extends NamiFinancesEvent {}

class LoadFinancesHistory extends NamiFinancesEvent {
  final int months;
  LoadFinancesHistory({this.months = 6});
}

class SaveFinances extends NamiFinancesEvent {
  final List<MonthlyIncomeModel> incomes;
  final List<ExpenseModel> expenses;
  final List<ReserveModel> reserves;
  final double? reserveGoal;
  final DateTime month;

  SaveFinances({
    required this.incomes,
    required this.expenses,
    required this.reserves,
    this.reserveGoal,
    required this.month,
  });
}

class DeleteFinances extends NamiFinancesEvent {
  final String id;
  DeleteFinances(this.id);
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/finances_setup_form.dart';

import '../../../testable_widget.dart';

final _existing = NamiFinancesModel(
  id: 'month-id',
  month: DateTime(2026, 7),
  monthlyIncomes: [
    MonthlyIncomeModel(id: 'income-1', amount: 5000, description: 'Salary'),
  ],
  expenses: [
    ExpenseModel(
      id: 'expense-1',
      amount: 1200,
      category: ExpenseCategory.fixed,
      description: 'Rent',
    ),
    ExpenseModel(
      id: 'expense-2',
      amount: 300,
      category: ExpenseCategory.food,
      description: 'Beach trip',
    ),
  ],
  reserves: [
    ReserveModel(id: 'reserve-1', amount: 200, purpose: ReservePurpose.travel),
  ],
  createdAt: DateTime(2026, 7),
  updatedAt: DateTime(2026, 7),
);

void main() {
  group('FinancesSetupForm behaviour', () {
    testWidgets('keeps the saved ids when an existing month is saved again', (
      tester,
    ) async {
      List<MonthlyIncomeModel>? incomes;
      List<ExpenseModel>? expenses;
      List<ReserveModel>? reserves;

      await tester.pumpWidget(
        getTestableWidget(
          Scaffold(
            body: SingleChildScrollView(
              child: FinancesSetupForm(
                existingFinances: _existing,
                onSave: (i, e, r, _) {
                  incomes = i;
                  expenses = e;
                  reserves = r;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(incomes!.map((i) => i.id), ['income-1']);
      expect(expenses!.map((e) => e.id), ['expense-1', 'expense-2']);
      expect(reserves!.map((r) => r.id), ['reserve-1']);
    });
  });
}

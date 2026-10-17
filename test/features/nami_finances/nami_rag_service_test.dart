import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';

ExpenseModel _expense(String id, String description) => ExpenseModel(
  id: id,
  amount: 100,
  category: ExpenseCategory.food,
  description: description,
);

NamiFinancesModel _month(List<ExpenseModel> expenses) => NamiFinancesModel(
  id: 'month-id',
  month: DateTime(2026, 7),
  monthlyIncomes: const [],
  expenses: expenses,
  createdAt: DateTime(2026, 7),
  updatedAt: DateTime(2026, 7),
);

void main() {
  group('NamiRagService.documentsFor', () {
    test('keys each described expense by its own id', () {
      final docs = NamiRagService.documentsFor(
        _month([_expense('a', 'praia'), _expense('b', '  ')]),
      );

      expect(docs, {'exp:a': 'praia (food, 2026-07)'});
    });

    test('gives the same documents when an unchanged month is saved again', () {
      final expenses = [_expense('a', 'praia'), _expense('b', 'mercado')];

      expect(
        NamiRagService.documentsFor(_month(expenses)),
        NamiRagService.documentsFor(_month(List.of(expenses))),
      );
    });
  });

  group('NamiRagService.planSync', () {
    const indexed = {
      'exp:a': 'praia (food, 2026-07)',
      'exp:b': 'mercado (food, 2026-07)',
    };

    test('does nothing when the month did not change', () {
      final plan = NamiRagService.planSync(indexed: indexed, wanted: indexed);

      expect(plan.toIndex, isEmpty);
      expect(plan.toRemove, isEmpty);
    });

    test('indexes only new or reworded expenses', () {
      final plan = NamiRagService.planSync(
        indexed: indexed,
        wanted: {
          'exp:a': 'praia (food, 2026-07)',
          'exp:b': 'feira (food, 2026-07)',
          'exp:c': 'cinema (food, 2026-07)',
        },
      );

      expect(plan.toIndex, ['exp:b', 'exp:c']);
      expect(plan.toRemove, isEmpty);
    });

    test('removes the documents of expenses the edit dropped', () {
      final plan = NamiRagService.planSync(
        indexed: indexed,
        wanted: {'exp:a': 'praia (food, 2026-07)'},
      );

      expect(plan.toIndex, isEmpty);
      expect(plan.toRemove, ['exp:b']);
    });
  });
}

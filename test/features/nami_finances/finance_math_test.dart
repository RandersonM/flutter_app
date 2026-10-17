import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

void main() {
  group('formatBrl', () {
    test('formats thousands and cents in pt-BR', () {
      expect(FinanceMath.formatBrl(60000), 'R\$ 60.000,00');
      expect(FinanceMath.formatBrl(6130), 'R\$ 6.130,00');
      expect(FinanceMath.formatBrl(1234567.8), 'R\$ 1.234.567,80');
      expect(FinanceMath.formatBrl(0), 'R\$ 0,00');
      expect(FinanceMath.formatBrl(5), 'R\$ 5,00');
    });

    test('handles negatives', () {
      expect(FinanceMath.formatBrl(-250.5), '-R\$ 250,50');
    });

    test('rounds to whole reais without cents', () {
      expect(FinanceMath.formatBrl(8400.4, withCents: false), 'R\$ 8.400');
      expect(FinanceMath.formatBrl(999.5, withCents: false), 'R\$ 1.000');
      expect(FinanceMath.formatBrl(-1250, withCents: false), '-R\$ 1.250');
    });
  });

  group('parseAmount', () {
    test('parses plain, pt-BR and shorthand forms to the same value', () {
      expect(FinanceMath.parseAmount('80000'), 80000);
      expect(FinanceMath.parseAmount('80.000'), 80000);
      expect(FinanceMath.parseAmount('80.000,00'), 80000);
      expect(FinanceMath.parseAmount('R\$ 80.000'), 80000);
      expect(FinanceMath.parseAmount('80mil'), 80000);
      expect(FinanceMath.parseAmount('80 mil'), 80000);
      expect(FinanceMath.parseAmount('80k'), 80000);
    });

    test('parses decimals and millions', () {
      expect(FinanceMath.parseAmount('1,5'), 1.5);
      expect(FinanceMath.parseAmount('1.5'), 1.5);
      expect(FinanceMath.parseAmount('1,5 mi'), 1500000);
    });

    test('returns null for non-numeric input', () {
      expect(FinanceMath.parseAmount('abc'), isNull);
      expect(FinanceMath.parseAmount(null), isNull);
      expect(FinanceMath.parseAmount(''), isNull);
    });

    test('does not scale by "mil" or "mi" inside other words', () {
      expect(FinanceMath.parseAmount('algo similar por 500'), 500);
      expect(FinanceMath.parseAmount('gasto militar de 300'), 300);
      expect(FinanceMath.parseAmount('comprei milho por 20'), 20);
      expect(FinanceMath.parseAmount('minha conta de 150'), 150);
    });

    test('still scales the standalone words', () {
      expect(FinanceMath.parseAmount('2 milhões'), 2000000);
      expect(FinanceMath.parseAmount('1 milhao'), 1000000);
      expect(FinanceMath.parseAmount('20 mil reais'), 20000);
    });

    test('keeps a leading minus sign', () {
      expect(FinanceMath.parseAmount('-500'), -500);
      expect(FinanceMath.parseAmount('R\$ -1.234,56'), -1234.56);
      expect(FinanceMath.parseAmount('- 2 mil'), -2000);
    });

    test('ignores a hyphen that is not a sign', () {
      expect(FinanceMath.parseAmount('covid-19'), 19);
      expect(FinanceMath.parseAmount('10-20'), 10);
    });

    test('skips punctuation before the number', () {
      expect(FinanceMath.parseAmount('ok... 500'), 500);
    });
  });

  group('amountScale', () {
    test('reads the scale word of a sentence', () {
      expect(FinanceMath.amountScale('carro de 80 mil'), 1000);
      expect(FinanceMath.amountScale('80k'), 1000);
      expect(FinanceMath.amountScale('1,5 mi'), 1000000);
      expect(FinanceMath.amountScale('algo similar por 500'), 1);
    });
  });

  group('monthsTracked', () {
    test('counts both the first and the current month', () {
      expect(
        FinanceMath.monthsTracked(DateTime(2026, 1), DateTime(2026, 3)),
        3,
      );
      expect(
        FinanceMath.monthsTracked(DateTime(2025, 3), DateTime(2026, 3, 15)),
        13,
      );
    });

    test('is one month when tracking started this month or later', () {
      expect(
        FinanceMath.monthsTracked(DateTime(2026, 3), DateTime(2026, 3, 31)),
        1,
      );
      expect(
        FinanceMath.monthsTracked(DateTime(2026, 5), DateTime(2026, 3)),
        1,
      );
    });
  });

  group('historyChartMaxY', () {
    NamiFinancesModel month({required double income, required double spent}) =>
        NamiFinancesModel(
          id: 'm',
          month: DateTime(2026, 1),
          monthlyIncomes: [
            MonthlyIncomeModel(id: 'i', amount: income, description: ''),
          ],
          expenses: [
            ExpenseModel(
              id: 'e',
              amount: spent,
              category: ExpenseCategory.other,
              description: '',
            ),
          ],
          createdAt: DateTime(2026, 1),
          updatedAt: DateTime(2026, 1),
        );

    test('fits expenses larger than any income', () {
      expect(
        FinanceMath.historyChartMaxY([
          month(income: 3000, spent: 4500),
          month(income: 4000, spent: 1000),
        ]),
        4500,
      );
    });

    test('fits the largest income', () {
      expect(
        FinanceMath.historyChartMaxY([month(income: 5000, spent: 1000)]),
        5000,
      );
    });

    test('never returns 0, which the chart cannot divide into lines', () {
      expect(FinanceMath.historyChartMaxY(const []), 1);
      expect(FinanceMath.historyChartMaxY([month(income: 0, spent: 0)]), 1);
    });
  });

  group('affordableInstallment', () {
    test(
      'caps the installment by the more conservative of income/cash-flow',
      () {
        // Income 10k, expenses 6k → disposable 4k. 30% of income = 3k (tighter).
        final plan = FinanceMath.affordableInstallment(
          price: 80000,
          downPayment: 60000,
          monthlyIncome: 10000,
          monthlyDisposable: 4000,
        );
        expect(plan.financed, 20000);
        expect(plan.safeByIncome, 3000);
        expect(plan.safeByDisposable, 4000);
        expect(plan.recommendedMaxInstallment, 3000);
        // 20000 / 3000 = 6.67 → ceil 7 months.
        expect(plan.monthsAtRecommendedMax, 7);
        // A 12-month term (1666.67) is within the 3000 budget.
        final term12 = plan.scenarios.firstWhere((s) => s.termMonths == 12);
        expect(term12.withinBudget, isTrue);
      },
    );
  });

  group('goalPlan', () {
    test('computes months to reach at a given pace', () {
      final plan = FinanceMath.goalPlan(
        targetAmount: 20000,
        currentReserves: 5000,
        monthlyContribution: 1500,
      );
      expect(plan.remaining, 15000);
      expect(plan.monthsToReach, 10); // 15000 / 1500
    });

    test('computes required contribution for a target term', () {
      final plan = FinanceMath.goalPlan(
        targetAmount: 12000,
        currentReserves: 0,
        monthlyContribution: 0,
        targetMonths: 12,
      );
      expect(plan.requiredMonthlyContribution, 1000);
      expect(plan.monthsToReach, 12);
    });
  });
}

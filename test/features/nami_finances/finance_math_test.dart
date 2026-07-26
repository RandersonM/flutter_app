import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';

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
  });

  group('affordableInstallment', () {
    test('caps the installment by the more conservative of income/cash-flow', () {
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
    });
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

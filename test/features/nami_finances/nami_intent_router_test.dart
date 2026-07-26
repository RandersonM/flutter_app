import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_intent_router.dart';

void main() {
  const router = NamiIntentRouter();

  group('installment intent', () {
    test('routes the "60 a 80 mil em 100 vezes" case correctly', () {
      final call = router.resolve(
        'até quanto de parcela consigo pagar para comprar um carro de 60 a 80 '
        'mil parcelado em 100 vezes',
      );
      expect(call.name, 'affordableInstallment');
      // Higher end of the range, "mil" applied to both bare numbers.
      expect(call.arguments['price'], '80000');
      // The "100 vezes" term is captured, not read as an amount.
      expect(call.arguments['term'], '100');
    });

    test('captures a down payment / consórcio as the lower amount', () {
      final call = router.resolve(
        'quero um carro de 80 mil com consórcio de 60 mil, cabe no bolso?',
      );
      expect(call.name, 'affordableInstallment');
      expect(call.arguments['price'], '80000');
      expect(call.arguments['downPayment'], '60000');
    });
  });

  test('savings goal intent routes to simulateGoalPlan', () {
    final call = router.resolve('quero juntar uma meta de 20 mil, dá?');
    expect(call.name, 'simulateGoalPlan');
    expect(call.arguments['targetAmount'], '20000');
  });

  test('budget intent routes to budgetBreakdown', () {
    final call = router.resolve('meu orçamento está saudável?');
    expect(call.name, 'budgetBreakdown');
  });

  test('generic question falls back to getFinances', () {
    final call = router.resolve('como foram minhas finanças esse mês?');
    expect(call.name, 'getFinances');
    expect(call.arguments['monthsBack'], '6');
  });

  test('a specific month routes getFinances with that month', () {
    final call = router.resolve('quanto gastei em 2026-05?');
    expect(call.name, 'getFinances');
    expect(call.arguments['month'], '2026-05');
  });

  group('extractAmounts', () {
    test('applies trailing "mil" to bare numbers and skips the term', () {
      final amounts = router.extractAmounts(
        'carro de 60 a 80 mil em 100 vezes',
        excludeTermMonths: 100,
      );
      expect(amounts, containsAll(<double>[60000, 80000]));
      expect(amounts, isNot(contains(100.0)));
      expect(amounts, isNot(contains(100000.0)));
    });
  });
}

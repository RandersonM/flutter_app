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

  group('findExpenses intent', () {
    test(
      'routes a described thing to findExpenses with the object as query',
      () {
        final call = router.resolve('quanto gastei com a viagem pra praia?');
        expect(call.name, 'findExpenses');
        expect(call.arguments['query'], 'a viagem pra praia');
      },
    );

    test('handles "paguei" and "comprei" as spending verbs', () {
      expect(
        router.resolve('quanto paguei no conserto da geladeira').name,
        'findExpenses',
      );
      expect(
        router.resolve('comprei o presente da minha mãe, quanto foi?').name,
        'findExpenses',
      );
    });

    // The whole risk of this intent is stealing questions getFinances answers
    // exactly. Each case below must stay on getFinances.
    group('defers to getFinances when the question is an aggregate', () {
      test('a relative period', () {
        expect(router.resolve('quanto gastei esse mês?').name, 'getFinances');
        expect(
          router.resolve('quanto gastei no mês passado?').name,
          'getFinances',
        );
        expect(
          router.resolve('quanto gastei nos últimos 3 meses?').name,
          'getFinances',
        );
      });

      test('an explicit month — the pre-existing routing still holds', () {
        final call = router.resolve('quanto gastei em 2026-05?');
        expect(call.name, 'getFinances');
        expect(call.arguments['month'], '2026-05');
      });

      test('a named month', () {
        expect(router.resolve('quanto gastei com julho?').name, 'getFinances');
      });

      test('a category, which getFinances already breaks down', () {
        expect(router.resolve('quanto gastei com comida?').name, 'getFinances');
        expect(
          router.resolve('quanto gastei com transporte?').name,
          'getFinances',
        );
        expect(router.resolve('quanto gastei com saúde?').name, 'getFinances');
      });

      test('a spending question with no object at all', () {
        expect(router.resolve('quanto eu gastei?').name, 'getFinances');
      });
    });

    test('does not hijack the priced/goal/budget intents', () {
      expect(
        router
            .resolve('quanto gastei comprando um carro de 80 mil parcelado')
            .name,
        'affordableInstallment',
      );
      expect(
        router.resolve('quero juntar uma meta de 20 mil pra viagem').name,
        'simulateGoalPlan',
      );
      expect(
        router.resolve('como está meu orçamento?').name,
        'budgetBreakdown',
      );
    });

    group('extractExpenseQuery', () {
      test('strips trailing punctuation and collapses whitespace', () {
        expect(
          router.extractExpenseQuery('quanto gastei com o   hotel da praia ?'),
          'o hotel da praia',
        );
      });

      test('rejects an object containing digits', () {
        expect(
          router.extractExpenseQuery('gastei com 500 reais de coisa'),
          isNull,
        );
      });

      test('rejects an object too short to be meaningful', () {
        expect(router.extractExpenseQuery('gastei com ab'), isNull);
      });
    });
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

    test('does not read "mil" inside another word as thousands', () {
      expect(router.extractAmounts('algo similar por 500'), [500]);
    });
  });
}

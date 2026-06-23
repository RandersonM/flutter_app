import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/calculator/calculator_cubit.dart';

void main() {
  group('CalculatorCubit', () {
    late CalculatorCubit cubit;

    setUp(() {
      cubit = CalculatorCubit();
    });

    tearDown(() => cubit.close());

    test('Should do the multiplier', () {
      cubit.appendInput('4x4');
      cubit.evaluate();
      expect(cubit.state.result, '16.0');

      cubit.clear();
      cubit.appendInput('800x0');
      cubit.evaluate();
      expect(cubit.state.result, '0.0');

      cubit.clear();
      cubit.appendInput('-5x5');
      cubit.evaluate();
      expect(cubit.state.result, '-25.0');
    });

    test('Should do the division', () {
      cubit.appendInput('50/5');
      cubit.evaluate();
      expect(cubit.state.result, '10.0');

      cubit.clear();
      cubit.appendInput('50/-50');
      cubit.evaluate();
      expect(cubit.state.result, '-1.0');
    });

    test('Should add and subtract', () {
      cubit.appendInput('48-50+2-3');
      cubit.evaluate();
      expect(cubit.state.result, '-3.0');

      cubit.clear();
      cubit.appendInput('100-50-40+10-15');
      cubit.evaluate();
      expect(cubit.state.result, '5.0');
    });

    test('Should clear input', () {
      cubit.appendInput('4861234894213x8465132464');
      cubit.clear();
      expect(cubit.state.input, '');
    });
  });
}

// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'calculator_bloc.dart';

abstract class CalculatorEvent {
  CalculatorEvent();
}

class CalculatorInput extends CalculatorEvent {
  final String input;
  CalculatorInput(this.input) : super();
}

class CalculatorClear extends CalculatorEvent {
  CalculatorClear() : super();
}

class CalculatorDelete extends CalculatorEvent {
  CalculatorDelete() : super();
}

class CalculatorResult extends CalculatorEvent {
  CalculatorResult() : super();
}

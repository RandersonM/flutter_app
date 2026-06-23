import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:opfan/core/calculator/calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorState.initial());

  void appendInput(String value) =>
      emit(state.copyWith(input: state.input + value));

  void deleteLastChar() {
    if (state.input.isNotEmpty) {
      emit(state.copyWith(
          input: state.input.substring(0, state.input.length - 1)));
    }
  }

  void clear() => emit(CalculatorState.initial());

  void evaluate() {
    try {
      final expression = state.input.replaceAll('x', '*');
      final p = GrammarParser();
      final exp = p.parse(expression);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm);
      emit(state.copyWith(result: result.toString()));
    } catch (_) {
      emit(state.copyWith(result: 'Error'));
    }
  }

  bool isOperator(String button) =>
      ['/', 'x', '-', '+', '='].contains(button);

  Color getButtonTextColor(String button) =>
      isOperator(button) ? Colors.white : Colors.black;
}

// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:math_expressions/math_expressions.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  String input;
  CalculatorBloc({this.input = ''}) : super(const CalculatorInitial()) {
    on<CalculatorResult>(_result);
    on<CalculatorInput>(_input);
    on<CalculatorClear>(_clear);
    on<CalculatorDelete>(_delete);
  }
  void _clear(CalculatorClear event, Emitter<CalculatorState> emit) async {
    emit(const CalculatorLoading());
    input = '';
    emit(const CalculatorInitial());
  }

  void _input(CalculatorInput event, Emitter<CalculatorState> emit) async {
    emit(const CalculatorLoading());
    input += event.input;
    emit(CalculatorInputed(input));
  }

  void _delete(CalculatorDelete event, Emitter<CalculatorState> emit) async {
    emit(const CalculatorLoading());
    input = input.substring(0, input.length - 1);
    emit(CalculatorInputed(input));
  }

  void _result(CalculatorResult event, Emitter<CalculatorState> emit) async {
    emit(const CalculatorLoading());
    try {
      input = input.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      input = eval.toString();
      emit(CalculatorSuccess(eval.toString()));
    } catch (e) {
      emit(CalculatorFailed('Unknown operation: ${e.toString()}'));
    }
  }
}

// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'calculator_bloc.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object> get props => [];
}

class CalculatorInitial extends CalculatorState {
  const CalculatorInitial() : super();
}

class CalculatorLoading extends CalculatorState {
  const CalculatorLoading() : super();
}

class CalculatorInputed extends CalculatorState {
  final String input;
  const CalculatorInputed(this.input) : super();
}

class CalculatorSuccess extends CalculatorState {
  final String result;

  const CalculatorSuccess(this.result) : super();
}

class CalculatorFailed extends CalculatorState {
  final String error;

  const CalculatorFailed(this.error) : super();
}

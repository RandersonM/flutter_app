import 'package:equatable/equatable.dart';

class CalculatorState extends Equatable {
  final String result;
  final String input;

  const CalculatorState({required this.result, required this.input});

  factory CalculatorState.initial() =>
      const CalculatorState(result: '0', input: '');

  CalculatorState copyWith({String? result, String? input}) => CalculatorState(
    result: result ?? this.result,
    input: input ?? this.input,
  );

  @override
  List<Object?> get props => [result, input];
}

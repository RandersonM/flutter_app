import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opfan/features/calculator/bloc/calculator_cubit.dart';
import 'package:opfan/features/calculator/bloc/calculator_state.dart';
import 'package:opfan/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:opfan/features/calculator/presentation/widgets/calculator_header.dart';
import 'package:opfan/shared/utils/constants.dart';

class CalculatorContent extends StatelessWidget {
  const CalculatorContent({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final cubit = context.read<CalculatorCubit>();
          return Column(
            children: <Widget>[
              CalculatorHeader(result: state.result, input: state.input),
              Expanded(
                flex: 3,
                child: GridView.builder(
                  itemCount: Constants.calculatorButtons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final button = Constants.calculatorButtons[index];
                    switch (index) {
                      // Clear Button
                      case 0:
                        return CalculatorButton(
                          buttontapped: cubit.clear,
                          buttonText: button,
                          color: Theme.of(context).colorScheme.primary,
                          textColor: _textColor(cubit, button),
                        );

                      // x^2 Button
                      case 1:
                        return CalculatorButton(
                          buttonText: button,
                          color: Theme.of(context).colorScheme.primary,
                          textColor: _textColor(cubit, button),
                          buttontapped: () => cubit.appendInput('^2'),
                        );

                      // % Button
                      case 2:
                        return CalculatorButton(
                          buttontapped: () => cubit.appendInput(button),
                          buttonText: button,
                          color: Theme.of(context).colorScheme.primary,
                          textColor: _textColor(cubit, button),
                        );

                      // Delete Button
                      case 3:
                        return CalculatorButton(
                          buttontapped: cubit.deleteLastChar,
                          buttonText: button,
                          color: Theme.of(context).colorScheme.primary,
                          textColor: _textColor(cubit, button),
                        );

                      // Result Button
                      case 18:
                        return CalculatorButton(
                          buttontapped: cubit.evaluate,
                          buttonText: button,
                          color: Theme.of(context).colorScheme.onSecondary,
                          textColor: _textColor(cubit, button),
                        );

                      // Other Buttons
                      default:
                        return CalculatorButton(
                          buttontapped: () => cubit.appendInput(button),
                          buttonText: button,
                          color: cubit.isOperator(button)
                              ? Theme.of(context).colorScheme.onSecondary
                              : Colors.white,
                          textColor: _textColor(cubit, button),
                        );
                    }
                  },
                ),
              ),
            ],
          );
        },
      );

  // Keys have fixed fills (white / onSecondary), so labels need fixed contrast.
  Color _textColor(CalculatorCubit cubit, String button) {
    const operatorLabel = Colors.white; // harness:allow fixed contrast
    const digitLabel = Colors.black; // harness:allow fixed contrast
    return cubit.isOperator(button) ? operatorLabel : digitLabel;
  }
}

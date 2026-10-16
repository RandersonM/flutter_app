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
                    final colors = Theme.of(context).colorScheme;
                    switch (index) {
                      // Clear Button
                      case 0:
                        return CalculatorButton(
                          buttontapped: cubit.clear,
                          buttonText: button,
                          color: colors.primary,
                          textColor: colors.onPrimary,
                        );

                      // x^2 Button
                      case 1:
                        return CalculatorButton(
                          buttonText: button,
                          color: colors.primary,
                          textColor: colors.onPrimary,
                          buttontapped: () => cubit.appendInput('^2'),
                        );

                      // % Button
                      case 2:
                        return CalculatorButton(
                          buttontapped: () => cubit.appendInput(button),
                          buttonText: button,
                          color: colors.primary,
                          textColor: colors.onPrimary,
                        );

                      // Delete Button
                      case 3:
                        return CalculatorButton(
                          buttontapped: cubit.deleteLastChar,
                          buttonText: button,
                          color: colors.primary,
                          textColor: colors.onPrimary,
                        );

                      // Result Button
                      case 18:
                        return CalculatorButton(
                          buttontapped: cubit.evaluate,
                          buttonText: button,
                          color: colors.primaryContainer,
                          textColor: colors.onPrimaryContainer,
                        );

                      // Other Buttons
                      default:
                        return CalculatorButton(
                          buttontapped: () => cubit.appendInput(button),
                          buttonText: button,
                          color: cubit.isOperator(button)
                              ? colors.primaryContainer
                              : colors.surfaceContainer,
                          textColor: cubit.isOperator(button)
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        );
                    }
                  },
                ),
              ),
            ],
          );
        },
      );
}

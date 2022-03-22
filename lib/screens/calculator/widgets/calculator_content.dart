// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_app/core/calculator/calculator_provider.dart';
import 'package:simple_app/screens/calculator/widgets/calculator_button.dart';
import 'package:simple_app/screens/calculator/widgets/calculator_header.dart.dart';
import 'package:simple_app/shared/constants.dart';

class CalculatorContent extends StatelessWidget {
  const CalculatorContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<CalculatorProvider>(
        builder: (BuildContext context, CalculatorProvider provider, _) =>
            Column(
          children: <Widget>[
            CalculatorHeader(result: provider.result, input: provider.input),
            Expanded(
              flex: 3,
              child: GridView.builder(
                  itemCount: Constants.calculatorButtons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      // Clear Button
                      case 0:
                        return CalculatorButton(
                          buttontapped: () => provider.clean(),
                          buttonText: Constants.calculatorButtons[index],
                          color: Theme.of(context).colorScheme.primary,
                          textColor: provider.getButtonTextColor(
                              Constants.calculatorButtons[index]),
                        );

                      // x^2 button
                      case 1:
                        return CalculatorButton(
                          buttonText: Constants.calculatorButtons[index],
                          color: Theme.of(context).colorScheme.primary,
                          textColor: provider.getButtonTextColor(
                              Constants.calculatorButtons[index]),
                          buttontapped: () {
                            provider.input += '^2';
                          },
                        );

                      // % Button
                      case 2:
                        return CalculatorButton(
                          buttontapped: () => provider.input +=
                              Constants.calculatorButtons[index],
                          buttonText: Constants.calculatorButtons[index],
                          color: Theme.of(context).colorScheme.primary,
                          textColor: provider.getButtonTextColor(
                              Constants.calculatorButtons[index]),
                        );

                      // Delete Button
                      case 3:
                        return CalculatorButton(
                          buttontapped: () => provider.input = provider.input
                              .substring(0, provider.input.length - 1),
                          buttonText: Constants.calculatorButtons[index],
                          color: Theme.of(context).colorScheme.primary,
                          textColor: provider.getButtonTextColor(
                              Constants.calculatorButtons[index]),
                        );

                      // Result Button
                      case 18:
                        return CalculatorButton(
                          buttontapped: () => provider.equalPressed(),
                          buttonText: Constants.calculatorButtons[index],
                          color: Theme.of(context).colorScheme.onSecondary,
                          textColor: provider.getButtonTextColor(
                              Constants.calculatorButtons[index]),
                        );

                      //  Other Buttons
                      default:
                        return CalculatorButton(
                            buttontapped: () => provider.input +=
                                Constants.calculatorButtons[index],
                            buttonText: Constants.calculatorButtons[index],
                            color: provider.isOperator(
                                    Constants.calculatorButtons[index])
                                ? Theme.of(context).colorScheme.onSecondary
                                : Colors.white,
                            textColor: provider.getButtonTextColor(
                                Constants.calculatorButtons[index]));
                    }
                  }),
            ),
          ],
        ),
      );
}

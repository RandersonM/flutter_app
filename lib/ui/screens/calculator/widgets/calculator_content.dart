// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/blocs/calculator/calculator_bloc.dart';

import 'package:simple_app/shared/constants.dart';

import 'calculator_button.dart';
import 'calculator_header.dart.dart';

class CalculatorContent extends StatelessWidget {
  const CalculatorContent({Key? key}) : super(key: key);

  bool isOperator(String button) {
    if (button == '/' ||
        button == 'x' ||
        button == '-' ||
        button == '+' ||
        button == '=') {
      return true;
    }
    return false;
  }

  Color getButtonTextColor(String button) =>
      isOperator(button) ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    final CalculatorBloc calBloc = BlocProvider.of<CalculatorBloc>(context);
    return Column(
      children: <Widget>[
        const CalculatorHeader(),
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
                      buttontapped: () => calBloc.add(CalculatorClear()),
                      buttonText: Constants.calculatorButtons[index],
                      color: Theme.of(context).colorScheme.primary,
                      textColor: getButtonTextColor(
                          Constants.calculatorButtons[index]),
                    );

                  // x^2 button
                  case 1:
                    return CalculatorButton(
                      buttonText: Constants.calculatorButtons[index],
                      color: Theme.of(context).colorScheme.primary,
                      textColor: getButtonTextColor(
                          Constants.calculatorButtons[index]),
                      buttontapped: () {
                        calBloc.add(CalculatorInput('^2'));
                      },
                    );

                  // % Button
                  case 2:
                    return CalculatorButton(
                      buttontapped: () => calBloc.add(
                          CalculatorInput(Constants.calculatorButtons[index])),
                      buttonText: Constants.calculatorButtons[index],
                      color: Theme.of(context).colorScheme.primary,
                      textColor: getButtonTextColor(
                          Constants.calculatorButtons[index]),
                    );

                  // Delete Button
                  case 3:
                    return CalculatorButton(
                      buttontapped: () => calBloc.add(CalculatorDelete()),
                      buttonText: Constants.calculatorButtons[index],
                      color: Theme.of(context).colorScheme.primary,
                      textColor: getButtonTextColor(
                          Constants.calculatorButtons[index]),
                    );

                  // Result Button
                  case 18:
                    return CalculatorButton(
                      buttontapped: () =>
                          BlocProvider.of<CalculatorBloc>(context)
                              .add(CalculatorResult()),
                      buttonText: Constants.calculatorButtons[index],
                      color: Theme.of(context).colorScheme.onSecondary,
                      textColor: getButtonTextColor(
                          Constants.calculatorButtons[index]),
                    );

                  //  Other Buttons
                  default:
                    return CalculatorButton(
                        buttontapped: () => calBloc.add(CalculatorInput(
                            Constants.calculatorButtons[index])),
                        buttonText: Constants.calculatorButtons[index],
                        color: isOperator(Constants.calculatorButtons[index])
                            ? Theme.of(context).colorScheme.onSecondary
                            : Colors.white,
                        textColor: getButtonTextColor(
                            Constants.calculatorButtons[index]));
                }
              }),
        ),
      ],
    );
  }
}

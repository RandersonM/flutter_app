// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorProvider extends ChangeNotifier {
  String _result = '0';
  String _input = '';

  String get result => _result;

  String get input => _input;

  set result(String newResult) {
    _result = newResult;
    notifyListeners();
  }

  set input(String newInput) {
    _input = newInput;
    notifyListeners();
  }

  void clean() {
    input = '';
    result = '0';
    notifyListeners();
  }

  Color getButtonTextColor(String button) =>
      isOperator(button) ? Colors.white : Colors.black;

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

  void equalPressed() {
    String finaluserinput = input;
    finaluserinput = input.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    result = eval.toString();
  }
}

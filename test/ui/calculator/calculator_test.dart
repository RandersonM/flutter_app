// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opfan/screens/calculator/calculator_screen.dart';
import 'package:opfan/screens/calculator/widgets/calculator_button.dart';
import 'package:opfan/screens/calculator/widgets/calculator_header.dart.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart'
    show DefaultAppBar;


import '../../testable_widget.dart';

void main() {
  group('Calculator screen tests', () {
    testWidgets('Should render all calculator buttons and header',
        (WidgetTester tester) async {
      Widget calculatorScreen = const CalculatorScreen();

      await tester.pumpWidget(getTestableWidget(calculatorScreen));

      expect(find.byType(DefaultAppBar), findsOneWidget);

      expect(find.byType(CalculatorButton), findsNWidgets(8));

      expect(find.byType(CalculatorHeader), findsOneWidget);
    });
  });
}

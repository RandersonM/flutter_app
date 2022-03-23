// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app/core/calculator/calculator_provider.dart';

void main() {
  group(' Calculator provider', () {
    CalculatorProvider provider = CalculatorProvider();
    testWidgets('Should do the multiplier', (WidgetTester tester) async {
      provider.input = "4x4";
      provider.equalPressed();
      expect(provider.result, "16.0");

      provider.input = "800x0";
      provider.equalPressed();
      expect(provider.result, "0.0");

      provider.input = "-5x5";
      provider.equalPressed();
      expect(provider.result, "-25.0");
    });

    testWidgets('Should do the division', (WidgetTester tester) async {
      provider.input = "50/5";
      provider.equalPressed();
      expect(provider.result, "10.0");

      provider.input = "1000/0";
      provider.equalPressed();
      expect(provider.result, "Infinity");

      provider.input = "50/-50";
      provider.equalPressed();
      expect(provider.result, "-1.0");
    });

    testWidgets('Should add and subtract', (WidgetTester tester) async {
      provider.input = "48-50+2-3";
      provider.equalPressed();
      expect(provider.result, "-3.0");

      provider.input = "100-50-40+10-15";
      provider.equalPressed();
      expect(provider.result, "5.0");
    });

    testWidgets('Should clear input', (WidgetTester tester) async {
      provider.input = "4861234894213x8465132464";

      provider.clean();

      expect(provider.input, "");
    });
  });
}

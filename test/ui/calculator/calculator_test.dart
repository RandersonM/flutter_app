import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opfan/features/calculator/presentation/calculator_screen.dart';
import 'package:opfan/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:opfan/features/calculator/presentation/widgets/calculator_header.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart'
    show DefaultAppBar;

import 'package:get_it/get_it.dart';
import 'package:opfan/features/calculator/bloc/calculator_cubit.dart';
import '../../testable_widget.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.registerFactory<CalculatorCubit>(() => CalculatorCubit());
  });

  tearDown(() {
    getIt.reset();
  });

  group('Calculator screen tests', () {
    testWidgets('Should render all calculator buttons and header', (
      WidgetTester tester,
    ) async {
      Widget calculatorScreen = const CalculatorScreen();

      await tester.pumpWidget(getTestableWidget(calculatorScreen));

      expect(find.byType(DefaultAppBar), findsOneWidget);

      expect(find.byType(CalculatorButton), findsAtLeastNWidgets(8));

      expect(find.byType(CalculatorHeader), findsOneWidget);
    });

    testWidgets('colours keys with theme roles', (WidgetTester tester) async {
      await tester.pumpWidget(getTestableWidget(const CalculatorScreen()));

      final colors = Theme.of(
        tester.element(find.byType(CalculatorHeader)),
      ).colorScheme;
      CalculatorButton key(String label) => tester.widget<CalculatorButton>(
        find.widgetWithText(CalculatorButton, label),
      );

      expect(key('C').color, colors.primary);
      expect(key('C').textColor, colors.onPrimary);
      expect(key('/').color, colors.primaryContainer);
      expect(key('/').textColor, colors.onPrimaryContainer);
      expect(key('7').color, colors.surfaceContainer);
      expect(key('7').textColor, colors.onSurface);
    });
  });
}

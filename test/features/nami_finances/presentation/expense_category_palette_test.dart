import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/presentation/expense_category_palette.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/add_expense_dialog.dart'
    as dialog;
import 'package:opfan/shared/utils/theme.dart';

Future<BuildContext> _contextFor(WidgetTester tester, ThemeData theme) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  group('ExpenseCategoryPalette behaviour', () {
    testWidgets('gives every category a distinct colour in each theme', (
      tester,
    ) async {
      for (final theme in [getLightTheme(), getDarkTheme()]) {
        final context = await _contextFor(tester, theme);
        final colors = ExpenseCategory.values
            .map((category) => ExpenseCategoryPalette.of(context, category))
            .toSet();
        expect(colors, hasLength(ExpenseCategory.values.length));
      }
    });

    testWidgets('uses different tones for light and dark themes', (
      tester,
    ) async {
      final light = await _contextFor(tester, getLightTheme());
      final lightFood = ExpenseCategoryPalette.of(light, ExpenseCategory.food);
      final dark = await _contextFor(tester, getDarkTheme());
      final darkFood = ExpenseCategoryPalette.of(dark, ExpenseCategory.food);

      expect(lightFood, isNot(darkFood));
    });

    testWidgets('matches the setup form enum by category name', (tester) async {
      final context = await _contextFor(tester, getLightTheme());

      for (final category in dialog.ExpenseCategory.values) {
        expect(
          ExpenseCategoryPalette.of(context, category),
          ExpenseCategoryPalette.of(
            context,
            ExpenseCategory.values.byName(category.name),
          ),
        );
      }
    });
  });
}

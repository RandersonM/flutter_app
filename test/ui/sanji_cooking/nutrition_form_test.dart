import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/nutrition_form.dart';

import '../../testable_widget.dart';

class _MockSanjiCookingBloc extends Mock implements SanjiCookingBloc {}

void main() {
  late _MockSanjiCookingBloc bloc;
  late List<Map<String, dynamic>> calculated;

  setUp(() {
    bloc = _MockSanjiCookingBloc();
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    calculated = [];
  });

  Future<void> submit(
    WidgetTester tester, {
    required String weight,
    required String height,
  }) async {
    await tester.pumpWidget(
      getTestableWidget(
        BlocProvider<SanjiCookingBloc>.value(
          value: bloc,
          child: Scaffold(
            body: SingleChildScrollView(
              child: NutritionForm(
                onCalculate: calculated.add,
                existingData: const {
                  'age': 30,
                  'gender': 'male',
                  'waist': 80,
                  'activityLevel': 'moderate',
                  'goal': 'maintenance',
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight (kg)'),
      weight,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Height (cm)'),
      height,
    );
    final button = find.text('Calculate Nutrition');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  group('NutritionForm behaviour', () {
    testWidgets('accepts a weight typed with a decimal comma', (tester) async {
      await submit(tester, weight: '72,5', height: '175');

      expect(calculated.single['weight'], 72.5);
      expect(calculated.single['height'], 175);
    });

    testWidgets('refuses a zero height instead of saving it', (tester) async {
      await submit(tester, weight: '72', height: '0');

      expect(calculated, isEmpty);
      expect(find.text('Enter a value between 50 and 260'), findsOneWidget);
    });

    testWidgets('refuses a negative weight instead of saving it', (
      tester,
    ) async {
      await submit(tester, weight: '-3', height: '175');

      expect(calculated, isEmpty);
      expect(find.text('Enter a value between 20 and 400'), findsOneWidget);
    });

    testWidgets('offers a keyboard with a decimal key', (tester) async {
      await submit(tester, weight: '72', height: '175');

      final weightField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Weight (kg)'),
          matching: find.byType(TextField),
        ),
      );
      expect(
        weightField.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });
  });
}

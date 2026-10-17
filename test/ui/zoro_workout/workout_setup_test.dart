import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/features/zoro_workout/bloc/index.dart';
import 'package:opfan/features/zoro_workout/presentation/widgets/workout_setup.dart';

import '../../testable_widget.dart';

class _MockZoroWorkoutBloc extends Mock implements ZoroWorkoutBloc {}

void main() {
  late _MockZoroWorkoutBloc bloc;
  late List<Map<String, dynamic>> calculated;

  setUp(() {
    bloc = _MockZoroWorkoutBloc();
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
        BlocProvider<ZoroWorkoutBloc>.value(
          value: bloc,
          child: Scaffold(
            body: SingleChildScrollView(
              child: WorkoutSetup(
                onCalculate: calculated.add,
                existingData: const {
                  'age': 30,
                  'gender': 'male',
                  'waist': 80,
                  'workoutDaysGoal': 3,
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
    final button = find.text('Calculate Health Metrics');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  group('WorkoutSetup behaviour', () {
    testWidgets('accepts a weight typed with a decimal comma', (tester) async {
      await submit(tester, weight: '72,5', height: '175');

      expect(calculated.single['weight'], 72.5);
      expect(calculated.single['bmi'], closeTo(23.67, 0.01));
    });

    testWidgets('refuses a zero height instead of saving an infinite bmi', (
      tester,
    ) async {
      await submit(tester, weight: '72', height: '0');

      expect(calculated, isEmpty);
      expect(find.text('Enter a value between 50 and 260'), findsOneWidget);
    });

    testWidgets('refuses a negative weight', (tester) async {
      await submit(tester, weight: '-3', height: '175');

      expect(calculated, isEmpty);
      expect(find.text('Enter a value between 20 and 400'), findsOneWidget);
    });
  });
}

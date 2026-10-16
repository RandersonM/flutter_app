import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/workout/i_workout_assessment_service.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/get_workout_history_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';

class _MockWorkoutAssessmentService extends Mock
    implements IWorkoutAssessmentService {}

class _FixedLocaleService implements ILocaleService {
  _FixedLocaleService(this.languageCode);

  @override
  final String languageCode;
  @override
  Locale? get locale => Locale(languageCode);
  @override
  Future<void> loadLocale() async {}
  @override
  Future<void> persistLocale(Locale locale) async {}
}

WorkoutAssessmentModel _assessment() => WorkoutAssessmentModel(
  userId: 'alice',
  monthYear: '2026-09',
  gender: 'female',
  age: 30,
  height: 165,
  weight: 60,
  waist: 70,
  createdAt: DateTime(2026, 9),
  updatedAt: DateTime(2026, 9),
);

void main() {
  late _MockWorkoutAssessmentService workouts;

  setUp(() {
    workouts = _MockWorkoutAssessmentService();
    when(
      () => workouts.getUserAssessmentHistory(),
    ).thenAnswer((_) async => [_assessment()]);
  });

  Future<String> tableFor(String languageCode) async {
    final handler = GetWorkoutHistoryHandler(
      workoutService: workouts,
      localeService: _FixedLocaleService(languageCode),
    );
    final result = await handler.execute(
      const ToolCall(name: 'getWorkoutHistory', arguments: {}),
    );
    return (jsonDecode(result.content) as Map<String, dynamic>)['table']
        as String;
  }

  group('GetWorkoutHistoryHandler behaviour', () {
    test('writes the table headers in the app language', () async {
      expect(await tableFor('pt'), contains('Mês'));
      expect(await tableFor('en'), isNot(contains('Mês')));
    });
  });
}

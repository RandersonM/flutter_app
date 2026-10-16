import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/core/services/workout/i_workout_assessment_service.dart';
import 'package:opfan/features/zoro_workout/bloc/index.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';

class _MockWorkoutAssessmentService extends Mock
    implements IWorkoutAssessmentService {}

class _MockAuthService extends Mock implements IAuthService {}

class _FakeAssessment extends Fake implements WorkoutAssessmentModel {}

void main() {
  late _MockWorkoutAssessmentService workouts;
  late _MockAuthService auth;

  final user = UserModel(
    uid: 'alice',
    email: 'alice@example.com',
    displayName: 'Alice',
    emailVerified: true,
    providerId: 'google.com',
    createdAt: DateTime(2024),
    lastSignIn: DateTime(2024),
    activityLevel: 'moderate',
  );
  const healthResults = <String, dynamic>{
    'gender': 'female',
    'age': 30,
    'height': 165.0,
    'weight': 60.0,
    'waist': 70.0,
    'goal': 'lose_weight',
  };

  setUpAll(() => registerFallbackValue(user));

  setUp(() {
    workouts = _MockWorkoutAssessmentService();
    auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(user);
    when(
      () => workouts.saveWorkoutAssessment(
        gender: any(named: 'gender'),
        age: any(named: 'age'),
        height: any(named: 'height'),
        weight: any(named: 'weight'),
        waist: any(named: 'waist'),
        bmi: any(named: 'bmi'),
        waistToHeightRatio: any(named: 'waistToHeightRatio'),
        bodyFatPercentage: any(named: 'bodyFatPercentage'),
        healthScore: any(named: 'healthScore'),
        workoutDaysGoal: any(named: 'workoutDaysGoal'),
        workoutDays: any(named: 'workoutDays'),
        activityLevel: any(named: 'activityLevel'),
        goal: any(named: 'goal'),
      ),
    ).thenAnswer((_) async => _FakeAssessment());
    when(
      () => workouts.getCurrentUserAssessment(),
    ).thenAnswer((_) async => null);
    when(() => workouts.getUserAssessmentHistory()).thenAnswer((_) async => []);
  });

  ZoroWorkoutBloc build() =>
      ZoroWorkoutBloc(service: workouts, authService: auth);

  group('ZoroWorkoutBloc body profile', () {
    blocTest<ZoroWorkoutBloc, ZoroWorkoutState>(
      'saves the assessment body data to the user profile',
      setUp: () =>
          when(() => auth.updateBodyProfile(any())).thenAnswer((_) async {}),
      build: build,
      act: (bloc) =>
          bloc.add(const SaveNewAssessment(healthResults: healthResults)),
      expect: () => [isA<ZoroWorkoutLoaded>()],
      verify: (_) {
        final saved =
            verify(() => auth.updateBodyProfile(captureAny())).captured.single
                as UserModel;
        expect(saved.weightKg, 60.0);
        expect(saved.goal, 'lose_weight');
        expect(saved.activityLevel, 'moderate');
      },
    );

    blocTest<ZoroWorkoutBloc, ZoroWorkoutState>(
      'still saves the assessment when saving the profile fails',
      setUp: () => when(
        () => auth.updateBodyProfile(any()),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) =>
          bloc.add(const SaveNewAssessment(healthResults: healthResults)),
      expect: () => [isA<ZoroWorkoutLoaded>()],
    );
  });
}

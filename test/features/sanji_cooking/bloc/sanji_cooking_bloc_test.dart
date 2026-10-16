import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/core/services/nutrition/i_nutrition_calculation_service.dart';
import 'package:opfan/core/services/workout/i_workout_assessment_service.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/data/models/nutrition_calculation_model.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';

class _MockWorkoutAssessmentService extends Mock
    implements IWorkoutAssessmentService {}

class _MockCookingRepository extends Mock implements ICookingRepository {}

class _MockNutritionCalculationService extends Mock
    implements INutritionCalculationService {}

class _MockAuthService extends Mock implements IAuthService {}

class _FakeNutrition extends Fake implements NutritionCalculationModel {}

void main() {
  late _MockNutritionCalculationService nutrition;
  late _MockCookingRepository cooking;
  late _MockAuthService auth;

  final user = UserModel(
    uid: 'alice',
    email: 'alice@example.com',
    displayName: 'Alice',
    emailVerified: true,
    providerId: 'google.com',
    createdAt: DateTime(2024),
    lastSignIn: DateTime(2024),
  );
  final results = _FakeNutrition();
  const nutritionData = {
    'age': 30,
    'gender': 'female',
    'weight': 60.0,
    'height': 165.0,
    'waist': 70.0,
    'activityLevel': 'moderate',
    'goal': 'maintain',
  };

  setUpAll(() => registerFallbackValue(user));

  setUp(() {
    nutrition = _MockNutritionCalculationService();
    cooking = _MockCookingRepository();
    auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(user);
    when(
      () => nutrition.calculateNutrition(
        age: any(named: 'age'),
        gender: any(named: 'gender'),
        weight: any(named: 'weight'),
        height: any(named: 'height'),
        waist: any(named: 'waist'),
        activityLevel: any(named: 'activityLevel'),
        goal: any(named: 'goal'),
      ),
    ).thenReturn(results);
  });

  SanjiCookingBloc build() => SanjiCookingBloc(
    workoutService: _MockWorkoutAssessmentService(),
    cookingRepository: cooking,
    nutritionService: nutrition,
    authService: auth,
  );

  group('SanjiCookingBloc body profile', () {
    blocTest<SanjiCookingBloc, SanjiCookingState>(
      'saves the calculated body data to the user profile',
      setUp: () =>
          when(() => auth.updateBodyProfile(any())).thenAnswer((_) async {}),
      build: build,
      act: (bloc) =>
          bloc.add(const CalculateNutrition(nutritionData: nutritionData)),
      expect: () => [
        const SanjiCookingLoading(),
        SanjiCookingLoaded(nutritionResults: results, showForm: false),
      ],
      verify: (_) {
        final saved =
            verify(() => auth.updateBodyProfile(captureAny())).captured.single
                as UserModel;
        expect(saved.weightKg, 60.0);
        expect(saved.goal, 'maintain');
      },
    );

    blocTest<SanjiCookingBloc, SanjiCookingState>(
      'still shows the results when saving the profile fails',
      setUp: () => when(
        () => auth.updateBodyProfile(any()),
      ).thenThrow(Exception('offline')),
      build: build,
      act: (bloc) =>
          bloc.add(const CalculateNutrition(nutritionData: nutritionData)),
      expect: () => [
        const SanjiCookingLoading(),
        SanjiCookingLoaded(nutritionResults: results, showForm: false),
      ],
    );
  });

  group('SanjiCookingBloc failures', () {
    const mealEvent = GeneratePersonalizedMeal(
      ingredients: ['rice'],
      mealType: 'lunch',
      targetCalories: 600,
      goal: 'maintenance',
    );

    blocTest<SanjiCookingBloc, SanjiCookingState>(
      'emits calculationFailed when the nutrition calculation throws',
      setUp: () => when(
        () => nutrition.calculateNutrition(
          age: any(named: 'age'),
          gender: any(named: 'gender'),
          weight: any(named: 'weight'),
          height: any(named: 'height'),
          waist: any(named: 'waist'),
          activityLevel: any(named: 'activityLevel'),
          goal: any(named: 'goal'),
        ),
      ).thenThrow(Exception('bad input')),
      build: build,
      act: (bloc) =>
          bloc.add(const CalculateNutrition(nutritionData: nutritionData)),
      expect: () => [
        const SanjiCookingLoading(),
        const SanjiCookingError(SanjiCookingFailure.calculationFailed),
      ],
    );

    blocTest<SanjiCookingBloc, SanjiCookingState>(
      'emits noIngredients when generating a meal without ingredients',
      build: build,
      act: (bloc) => bloc.add(
        const GeneratePersonalizedMeal(
          ingredients: [],
          mealType: 'lunch',
          targetCalories: 600,
          goal: 'maintenance',
        ),
      ),
      expect: () => [
        const SanjiCookingPersonalizedMealLoaded(
          ingredients: [],
          mealType: 'lunch',
          targetCalories: 600,
          goal: 'maintenance',
          failure: SanjiCookingFailure.noIngredients,
        ),
      ],
    );

    blocTest<SanjiCookingBloc, SanjiCookingState>(
      'emits mealFailed when the meal request throws',
      setUp: () => when(
        () => cooking.generatePersonalizedMeal(
          ingredients: any(named: 'ingredients'),
          mealType: any(named: 'mealType'),
          targetCalories: any(named: 'targetCalories'),
          goal: any(named: 'goal'),
          dietaryRestrictions: any(named: 'dietaryRestrictions'),
        ),
      ).thenThrow(Exception('quota')),
      build: build,
      act: (bloc) => bloc.add(mealEvent),
      expect: () => [
        isA<SanjiCookingPersonalizedMealGenerating>(),
        const SanjiCookingPersonalizedMealLoaded(
          ingredients: ['rice'],
          mealType: 'lunch',
          targetCalories: 600,
          goal: 'maintenance',
          failure: SanjiCookingFailure.mealFailed,
        ),
      ],
    );
  });
}

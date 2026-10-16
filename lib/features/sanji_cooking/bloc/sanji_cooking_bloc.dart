import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/features/sanji_cooking/data/repository/i_cooking_repository.dart';
import 'package:opfan/core/services/index.dart';
import 'sanji_cooking_event.dart';
import 'sanji_cooking_state.dart';

class SanjiCookingBloc extends Bloc<SanjiCookingEvent, SanjiCookingState> {
  final IWorkoutAssessmentService _workoutService;
  final ICookingRepository _cookingRepository;
  final INutritionCalculationService _nutritionService;
  final IAuthService _authService;

  SanjiCookingBloc({
    required this._workoutService,
    required this._cookingRepository,
    required this._nutritionService,
    required this._authService,
  }) : super(const SanjiCookingInitial()) {
    on<InitializeSanjiCooking>(_onInitializeSanjiCooking);
    on<CalculateNutrition>(_onCalculateNutrition);
    on<SaveNutritionData>(_onSaveNutritionData);
    on<NewCalculation>(_onNewCalculation);
    on<ClearError>(_onClearError);
    on<GenerateCookingTips>(_onGenerateCookingTips);
    on<ClearCookingTips>(_onClearCookingTips);
    on<AddIngredient>(_onAddIngredient);
    on<RemoveIngredient>(_onRemoveIngredient);
    on<GeneratePersonalizedMeal>(_onGeneratePersonalizedMeal);
  }

  Future<void> _onInitializeSanjiCooking(
    InitializeSanjiCooking event,
    Emitter<SanjiCookingState> emit,
  ) async {
    emit(const SanjiCookingLoading());

    try {
      final user = _authService.currentUser;

      if (user != null && user.isProfileComplete) {
        final nutritionResults = _nutritionService.calculateNutrition(
          age: user.age!,
          gender: user.gender!,
          weight: user.weightKg!,
          height: user.heightCm!,
          waist: user.waistCm ?? 0.0,
          activityLevel: user.activityLevel!,
          goal: user.goal!,
        );

        emit(
          SanjiCookingLoaded(
            nutritionResults: nutritionResults,
            hasExistingData: true,
            showForm: false,
          ),
        );
      } else {
        final existingData = user != null
            ? {
                'age': user.age,
                'gender': user.gender,
                'weight': user.weightKg,
                'height': user.heightCm,
                'waist': user.waistCm,
                'activityLevel': user.activityLevel,
                'goal': user.goal,
              }
            : <String, dynamic>{};

        emit(SanjiCookingFormWithData(existingData: existingData));
      }
    } catch (e) {
      debugPrint('SanjiCookingBloc: initializing failed: $e');
      emit(const SanjiCookingError(SanjiCookingFailure.loadFailed));
    }
  }

  Future<void> _onCalculateNutrition(
    CalculateNutrition event,
    Emitter<SanjiCookingState> emit,
  ) async {
    emit(const SanjiCookingLoading());

    try {
      final nutritionResults = _nutritionService.calculateNutrition(
        age: event.nutritionData['age'],
        gender: event.nutritionData['gender'],
        weight: event.nutritionData['weight'],
        height: event.nutritionData['height'],
        waist: event.nutritionData['waist'],
        activityLevel: event.nutritionData['activityLevel'],
        goal: event.nutritionData['goal'],
      );

      // Auto-save global profile when calculating
      final user = _authService.currentUser;
      if (user != null) {
        final updatedUser = user.copyWith(
          gender: event.nutritionData['gender'],
          age: event.nutritionData['age'],
          heightCm: event.nutritionData['height'],
          weightKg: event.nutritionData['weight'],
          waistCm: event.nutritionData['waist'],
          activityLevel: event.nutritionData['activityLevel'],
          goal: event.nutritionData['goal'],
        );
        unawaited(_saveBodyProfile(updatedUser));
      }

      emit(
        SanjiCookingLoaded(
          nutritionResults: nutritionResults,
          hasExistingData: false,
          showForm: false,
        ),
      );
    } catch (e) {
      debugPrint('SanjiCookingBloc: calculating nutrition failed: $e');
      emit(const SanjiCookingError(SanjiCookingFailure.calculationFailed));
    }
  }

  Future<void> _onSaveNutritionData(
    SaveNutritionData event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      debugPrint('SanjiCookingBloc: Starting _onSaveNutritionData');

      final user = _authService.currentUser;
      if (user != null) {
        final updatedUser = user.copyWith(
          gender: event.nutritionData['gender'],
          age: event.nutritionData['age'],
          heightCm: event.nutritionData['height'],
          weightKg: event.nutritionData['weight'],
          waistCm: event.nutritionData['waist'],
          activityLevel: event.nutritionData['activityLevel'],
          goal: event.nutritionData['goal'],
        );
        unawaited(_saveBodyProfile(updatedUser));
      }

      await _workoutService.updateNutritionData(
        gender: event.nutritionData['gender'],
        age: event.nutritionData['age'],
        height: event.nutritionData['height'],
        weight: event.nutritionData['weight'],
        waist: event.nutritionData['waist'],
        activityLevel: event.nutritionData['activityLevel'],
        goal: event.nutritionData['goal'],
      );

      debugPrint('SanjiCookingBloc: Successfully saved nutrition data');

      emit(const SanjiCookingLoaded(hasExistingData: false, showForm: true));
    } catch (e, stackTrace) {
      debugPrint('SanjiCookingBloc: Error in _onSaveNutritionData: $e');
      debugPrint('SanjiCookingBloc: Stack trace: $stackTrace');
      emit(const SanjiCookingError(SanjiCookingFailure.saveFailed));
    }
  }

  Future<void> _onNewCalculation(
    NewCalculation event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      final user = _authService.currentUser;

      if (user != null && user.isProfileComplete) {
        final existingData = {
          'age': user.age,
          'gender': user.gender,
          'weight': user.weightKg,
          'height': user.heightCm,
          'waist': user.waistCm,
          'activityLevel': user.activityLevel,
          'goal': user.goal,
        };

        emit(SanjiCookingFormWithData(existingData: existingData));
      } else {
        emit(const SanjiCookingLoaded(hasExistingData: false, showForm: true));
      }
    } catch (e) {
      debugPrint('SanjiCookingBloc: loading existing data failed: $e');
      emit(const SanjiCookingError(SanjiCookingFailure.loadFailed));
    }
  }

  void _onClearError(ClearError event, Emitter<SanjiCookingState> emit) {
    emit(const SanjiCookingInitial());
  }

  Future<void> _onGenerateCookingTips(
    GenerateCookingTips event,
    Emitter<SanjiCookingState> emit,
  ) async {
    if (event.ingredients.isEmpty) {
      emit(
        SanjiCookingTipsLoaded(
          ingredients: event.ingredients,
          cookingMethod: event.cookingMethod,
          difficulty: event.difficulty,
          failure: SanjiCookingFailure.noIngredients,
        ),
      );
      return;
    }

    emit(
      SanjiCookingTipsLoaded(
        ingredients: event.ingredients,
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
      ),
    );

    try {
      final response = await _cookingRepository.generateCookingTips(
        ingredient: event.ingredients.join(', '),
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
      );

      emit(
        SanjiCookingTipsLoaded(
          ingredients: event.ingredients,
          cookingMethod: event.cookingMethod,
          difficulty: event.difficulty,
          cookingTips: response,
        ),
      );
    } catch (e) {
      debugPrint('SanjiCookingBloc: generating cooking tips failed: $e');
      emit(
        SanjiCookingTipsLoaded(
          ingredients: event.ingredients,
          cookingMethod: event.cookingMethod,
          difficulty: event.difficulty,
          failure: SanjiCookingFailure.tipsFailed,
        ),
      );
    }
  }

  void _onClearCookingTips(
    ClearCookingTips event,
    Emitter<SanjiCookingState> emit,
  ) {
    emit(const SanjiCookingTipsLoaded(ingredients: []));
  }

  void _onAddIngredient(AddIngredient event, Emitter<SanjiCookingState> emit) {
    final currentState = state;
    if (currentState is SanjiCookingTipsLoaded) {
      final ingredients = List<String>.from(currentState.ingredients);
      if (!ingredients.contains(event.ingredient)) {
        ingredients.add(event.ingredient);
        emit(currentState.copyWith(ingredients: ingredients));
      }
    } else {
      emit(SanjiCookingTipsLoaded(ingredients: [event.ingredient]));
    }
  }

  void _onRemoveIngredient(
    RemoveIngredient event,
    Emitter<SanjiCookingState> emit,
  ) {
    final currentState = state;
    if (currentState is SanjiCookingTipsLoaded) {
      final ingredients = List<String>.from(currentState.ingredients);
      ingredients.remove(event.ingredient);
      emit(currentState.copyWith(ingredients: ingredients));
    }
  }

  Future<void> _onGeneratePersonalizedMeal(
    GeneratePersonalizedMeal event,
    Emitter<SanjiCookingState> emit,
  ) async {
    if (event.ingredients.isEmpty) {
      emit(
        SanjiCookingPersonalizedMealLoaded(
          ingredients: event.ingredients,
          mealType: event.mealType,
          targetCalories: event.targetCalories,
          goal: event.goal,
          dietaryRestrictions: event.dietaryRestrictions,
          failure: SanjiCookingFailure.noIngredients,
        ),
      );
      return;
    }

    emit(
      SanjiCookingPersonalizedMealGenerating(
        ingredients: event.ingredients,
        mealType: event.mealType,
        targetCalories: event.targetCalories,
        goal: event.goal,
        dietaryRestrictions: event.dietaryRestrictions,
      ),
    );

    try {
      final meal = await _cookingRepository.generatePersonalizedMeal(
        ingredients: event.ingredients,
        mealType: event.mealType,
        targetCalories: event.targetCalories,
        goal: event.goal,
        dietaryRestrictions: event.dietaryRestrictions,
      );

      emit(
        SanjiCookingPersonalizedMealLoaded(
          ingredients: event.ingredients,
          mealType: event.mealType,
          targetCalories: event.targetCalories,
          goal: event.goal,
          dietaryRestrictions: event.dietaryRestrictions,
          personalizedMeal: meal,
          failure: meal == null ? SanjiCookingFailure.mealFailed : null,
        ),
      );
    } catch (e) {
      debugPrint('SanjiCookingBloc: generating the meal failed: $e');
      emit(
        SanjiCookingPersonalizedMealLoaded(
          ingredients: event.ingredients,
          mealType: event.mealType,
          targetCalories: event.targetCalories,
          goal: event.goal,
          dietaryRestrictions: event.dietaryRestrictions,
          failure: SanjiCookingFailure.mealFailed,
        ),
      );
    }
  }

  /// Not awaited: the user's flow must not wait on, or fail with, the profile
  /// sync.
  Future<void> _saveBodyProfile(UserModel user) async {
    try {
      await _authService.updateBodyProfile(user);
    } catch (e) {
      debugPrint('SanjiCookingBloc: saving the body profile failed: $e');
    }
  }
}

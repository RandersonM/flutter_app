import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';
import 'package:opfan/core/services/nutrition_calculation_service.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/workout_assessment_service.dart';
import 'sanji_cooking_event.dart';
import 'sanji_cooking_state.dart';

class SanjiCookingBloc extends Bloc<SanjiCookingEvent, SanjiCookingState> {
  final WorkoutAssessmentService _workoutService = WorkoutAssessmentService();
  final ICookingRepository _cookingRepository = getIt<ICookingRepository>();

  SanjiCookingBloc() : super(const SanjiCookingInitial()) {
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
      final currentAssessment = await _workoutService.getCurrentUserAssessment();
      
      if (currentAssessment != null) {
        final hasRequiredData = currentAssessment.gender.isNotEmpty &&
            currentAssessment.age > 0 &&
            currentAssessment.height > 0 &&
            currentAssessment.weight > 0 &&
            currentAssessment.activityLevel != null &&
            currentAssessment.goal != null &&
            currentAssessment.waist > 0;
        
        if (hasRequiredData) {
          final nutritionResults = NutritionCalculationService.calculateNutrition(
            age: currentAssessment.age,
            gender: currentAssessment.gender,
            weight: currentAssessment.weight,
            height: currentAssessment.height,
            waist: currentAssessment.waist,
            activityLevel: currentAssessment.activityLevel!,
            goal: currentAssessment.goal!,
          );
          
          emit(SanjiCookingLoaded(
            nutritionResults: nutritionResults,
            hasExistingData: true,
            showForm: false,
          ));
        } else {
          // Preparar dados existentes para o formulário
          final existingData = {
            'age': currentAssessment.age,
            'gender': currentAssessment.gender,
            'weight': currentAssessment.weight,
            'height': currentAssessment.height,
            'waist': currentAssessment.waist,
            'activityLevel': currentAssessment.activityLevel,
            'goal': currentAssessment.goal,
          };
          
          emit(SanjiCookingFormWithData(existingData: existingData));
        }
      } else {
        emit(const SanjiCookingLoaded(
          hasExistingData: false,
          showForm: true,
        ));
      }
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao inicializar: $e'));
    }
  }

  Future<void> _onCalculateNutrition(
    CalculateNutrition event,
    Emitter<SanjiCookingState> emit,
  ) async {
    emit(const SanjiCookingLoading());
    
    try {
      final nutritionResults = NutritionCalculationService.calculateNutrition(
        age: event.nutritionData['age'],
        gender: event.nutritionData['gender'],
        weight: event.nutritionData['weight'],
        height: event.nutritionData['height'],
        waist: event.nutritionData['waist'],
        activityLevel: event.nutritionData['activityLevel'],
        goal: event.nutritionData['goal'],
      );
      
      emit(SanjiCookingLoaded(
        nutritionResults: nutritionResults,
        hasExistingData: false,
        showForm: false,
      ));
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao calcular nutrição: $e'));
    }
  }

  Future<void> _onSaveNutritionData(
    SaveNutritionData event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      debugPrint('SanjiCookingBloc: Starting _onSaveNutritionData');
      debugPrint('SanjiCookingBloc: nutritionData: ${event.nutritionData}');
      
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
      
      emit(const SanjiCookingLoaded(
        hasExistingData: false,
        showForm: true,
      ));
    } catch (e, stackTrace) {
      debugPrint('SanjiCookingBloc: Error in _onSaveNutritionData: $e');
      debugPrint('SanjiCookingBloc: Stack trace: $stackTrace');
      emit(SanjiCookingError(message: 'Error saving nutrition data: $e'));
    }
  }

  void _onNewCalculation(
    NewCalculation event,
    Emitter<SanjiCookingState> emit,
  ) async {
    try {
      final currentAssessment = await _workoutService.getCurrentUserAssessment();
      
      if (currentAssessment != null) {
        final existingData = {
          'age': currentAssessment.age,
          'gender': currentAssessment.gender,
          'weight': currentAssessment.weight,
          'height': currentAssessment.height,
          'waist': currentAssessment.waist,
          'activityLevel': currentAssessment.activityLevel,
          'goal': currentAssessment.goal,
        };
        
        emit(SanjiCookingFormWithData(existingData: existingData));
      } else {
        emit(const SanjiCookingLoaded(
          hasExistingData: false,
          showForm: true,
        ));
      }
    } catch (e) {
      emit(SanjiCookingError(message: 'Erro ao carregar dados existentes: $e'));
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<SanjiCookingState> emit,
  ) {
    emit(const SanjiCookingInitial());
  }

  Future<void> _onGenerateCookingTips(
    GenerateCookingTips event,
    Emitter<SanjiCookingState> emit,
  ) async {
    if (event.ingredients.isEmpty) {
      emit(SanjiCookingTipsLoaded(
        ingredients: event.ingredients,
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
        errorMessage: 'Adicione pelo menos um ingrediente',
      ));
      return;
    }

    emit(SanjiCookingTipsLoaded(
      ingredients: event.ingredients,
      cookingMethod: event.cookingMethod,
      difficulty: event.difficulty,
      isLoading: true,
    ));

    try {
      final response = await _cookingRepository.generateCookingTips(
        ingredient: event.ingredients.join(', '),
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
      );

      emit(SanjiCookingTipsLoaded(
        ingredients: event.ingredients,
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
        cookingTips: response,
        isLoading: false,
      ));
    } catch (e) {
      emit(SanjiCookingTipsLoaded(
        ingredients: event.ingredients,
        cookingMethod: event.cookingMethod,
        difficulty: event.difficulty,
        errorMessage: 'Erro ao gerar dicas: $e',
        isLoading: false,
      ));
    }
  }

  void _onClearCookingTips(
    ClearCookingTips event,
    Emitter<SanjiCookingState> emit,
  ) {
    emit(const SanjiCookingTipsLoaded(ingredients: []));
  }

  void _onAddIngredient(
    AddIngredient event,
    Emitter<SanjiCookingState> emit,
  ) {
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
      emit(SanjiCookingPersonalizedMealLoaded(
        ingredients: event.ingredients,
        mealType: event.mealType,
        targetCalories: event.targetCalories,
        goal: event.goal,
        dietaryRestrictions: event.dietaryRestrictions,
        errorMessage: 'Por favor, adicione pelo menos um ingrediente.',
      ));
      return;
    }

    emit(SanjiCookingPersonalizedMealLoaded(
      ingredients: event.ingredients,
      mealType: event.mealType,
      targetCalories: event.targetCalories,
      goal: event.goal,
      dietaryRestrictions: event.dietaryRestrictions,
      isLoading: true,
    ));

    try {
      final meal = await _cookingRepository.generatePersonalizedMeal(
        ingredients: event.ingredients,
        mealType: event.mealType,
        targetCalories: event.targetCalories,
        goal: event.goal,
        dietaryRestrictions: event.dietaryRestrictions,
      );

      if (meal != null) {
        emit(SanjiCookingPersonalizedMealLoaded(
          ingredients: event.ingredients,
          mealType: event.mealType,
          targetCalories: event.targetCalories,
          goal: event.goal,
          dietaryRestrictions: event.dietaryRestrictions,
          personalizedMeal: meal,
        ));
      } else {
        emit(SanjiCookingPersonalizedMealLoaded(
          ingredients: event.ingredients,
          mealType: event.mealType,
          targetCalories: event.targetCalories,
          goal: event.goal,
          dietaryRestrictions: event.dietaryRestrictions,
          errorMessage: 'Não foi possível gerar a refeição. Tente novamente.',
        ));
      }
    } catch (e) {
      emit(SanjiCookingPersonalizedMealLoaded(
        ingredients: event.ingredients,
        mealType: event.mealType,
        targetCalories: event.targetCalories,
        goal: event.goal,
        dietaryRestrictions: event.dietaryRestrictions,
        errorMessage: 'Erro ao gerar refeição: $e',
      ));
    }
  }
}

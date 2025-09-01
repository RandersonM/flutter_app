import 'package:equatable/equatable.dart';
import '../../../core/models/nutrition_calculation_model.dart';

abstract class SanjiCookingState extends Equatable {
  const SanjiCookingState();

  @override
  List<Object?> get props => [];
}

class SanjiCookingInitial extends SanjiCookingState {
  const SanjiCookingInitial();
}

class SanjiCookingLoading extends SanjiCookingState {
  const SanjiCookingLoading();
}

class SanjiCookingLoaded extends SanjiCookingState {
  final NutritionCalculationModel? nutritionResults;
  final bool hasExistingData;
  final bool showForm;

  const SanjiCookingLoaded({
    this.nutritionResults,
    this.hasExistingData = false,
    this.showForm = true,
  });

  @override
  List<Object?> get props => [nutritionResults, hasExistingData, showForm];

  SanjiCookingLoaded copyWith({
    NutritionCalculationModel? nutritionResults,
    bool? hasExistingData,
    bool? showForm,
  }) {
    return SanjiCookingLoaded(
      nutritionResults: nutritionResults ?? this.nutritionResults,
      hasExistingData: hasExistingData ?? this.hasExistingData,
      showForm: showForm ?? this.showForm,
    );
  }
}

class SanjiCookingFormWithData extends SanjiCookingState {
  final Map<String, dynamic> existingData;

  const SanjiCookingFormWithData({
    required this.existingData,
  });

  @override
  List<Object?> get props => [existingData];
}

class SanjiCookingError extends SanjiCookingState {
  final String message;

  const SanjiCookingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SanjiCookingTipsLoaded extends SanjiCookingState {
  final List<String> ingredients;
  final String? cookingMethod;
  final String? difficulty;
  final String? cookingTips;
  final bool isLoading;
  final String? errorMessage;

  const SanjiCookingTipsLoaded({
    required this.ingredients,
    this.cookingMethod,
    this.difficulty,
    this.cookingTips,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        ingredients,
        cookingMethod,
        difficulty,
        cookingTips,
        isLoading,
        errorMessage,
      ];

  SanjiCookingTipsLoaded copyWith({
    List<String>? ingredients,
    String? cookingMethod,
    String? difficulty,
    String? cookingTips,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SanjiCookingTipsLoaded(
      ingredients: ingredients ?? this.ingredients,
      cookingMethod: cookingMethod ?? this.cookingMethod,
      difficulty: difficulty ?? this.difficulty,
      cookingTips: cookingTips ?? this.cookingTips,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SanjiCookingPersonalizedMealLoaded extends SanjiCookingState {
  final List<String> ingredients;
  final String mealType;
  final double targetCalories;
  final String goal;
  final String? dietaryRestrictions;
  final String? personalizedMeal;
  final bool isLoading;
  final String? errorMessage;

  const SanjiCookingPersonalizedMealLoaded({
    required this.ingredients,
    required this.mealType,
    required this.targetCalories,
    required this.goal,
    this.dietaryRestrictions,
    this.personalizedMeal,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        ingredients,
        mealType,
        targetCalories,
        goal,
        dietaryRestrictions,
        personalizedMeal,
        isLoading,
        errorMessage,
      ];

  SanjiCookingPersonalizedMealLoaded copyWith({
    List<String>? ingredients,
    String? mealType,
    double? targetCalories,
    String? goal,
    String? dietaryRestrictions,
    String? personalizedMeal,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SanjiCookingPersonalizedMealLoaded(
      ingredients: ingredients ?? this.ingredients,
      mealType: mealType ?? this.mealType,
      targetCalories: targetCalories ?? this.targetCalories,
      goal: goal ?? this.goal,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      personalizedMeal: personalizedMeal ?? this.personalizedMeal,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

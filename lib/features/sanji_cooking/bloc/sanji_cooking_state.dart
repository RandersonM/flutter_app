import 'package:equatable/equatable.dart';
import 'package:opfan/features/sanji_cooking/data/models/nutrition_calculation_model.dart';

enum SanjiCookingFailure {
  loadFailed,
  calculationFailed,
  saveFailed,
  noIngredients,
  tipsFailed,
  mealFailed,
}

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

  const SanjiCookingFormWithData({required this.existingData});

  @override
  List<Object?> get props => [existingData];
}

class SanjiCookingError extends SanjiCookingState {
  final SanjiCookingFailure failure;

  const SanjiCookingError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class SanjiCookingTipsLoaded extends SanjiCookingState {
  final List<String> ingredients;
  final String? cookingMethod;
  final String? difficulty;
  final String? cookingTips;
  final SanjiCookingFailure? failure;

  const SanjiCookingTipsLoaded({
    required this.ingredients,
    this.cookingMethod,
    this.difficulty,
    this.cookingTips,
    this.failure,
  });

  @override
  List<Object?> get props => [
    ingredients,
    cookingMethod,
    difficulty,
    cookingTips,
    failure,
  ];

  SanjiCookingTipsLoaded copyWith({
    List<String>? ingredients,
    String? cookingMethod,
    String? difficulty,
    String? cookingTips,
    SanjiCookingFailure? failure,
  }) {
    return SanjiCookingTipsLoaded(
      ingredients: ingredients ?? this.ingredients,
      cookingMethod: cookingMethod ?? this.cookingMethod,
      difficulty: difficulty ?? this.difficulty,
      cookingTips: cookingTips ?? this.cookingTips,
      failure: failure ?? this.failure,
    );
  }
}

/// Emitted while the AI is generating a personalized meal (replaces the old
/// isLoading flag that was incorrectly embedded inside the loaded state).
class SanjiCookingPersonalizedMealGenerating extends SanjiCookingState {
  final List<String> ingredients;
  final String mealType;
  final double targetCalories;
  final String goal;
  final String? dietaryRestrictions;

  const SanjiCookingPersonalizedMealGenerating({
    required this.ingredients,
    required this.mealType,
    required this.targetCalories,
    required this.goal,
    this.dietaryRestrictions,
  });

  @override
  List<Object?> get props => [
    ingredients,
    mealType,
    targetCalories,
    goal,
    dietaryRestrictions,
  ];
}

class SanjiCookingPersonalizedMealLoaded extends SanjiCookingState {
  final List<String> ingredients;
  final String mealType;
  final double targetCalories;
  final String goal;
  final String? dietaryRestrictions;
  final String? personalizedMeal;
  final SanjiCookingFailure? failure;

  const SanjiCookingPersonalizedMealLoaded({
    required this.ingredients,
    required this.mealType,
    required this.targetCalories,
    required this.goal,
    this.dietaryRestrictions,
    this.personalizedMeal,
    this.failure,
  });

  @override
  List<Object?> get props => [
    ingredients,
    mealType,
    targetCalories,
    goal,
    dietaryRestrictions,
    personalizedMeal,
    failure,
  ];

  SanjiCookingPersonalizedMealLoaded copyWith({
    List<String>? ingredients,
    String? mealType,
    double? targetCalories,
    String? goal,
    String? dietaryRestrictions,
    String? personalizedMeal,
    SanjiCookingFailure? failure,
  }) {
    return SanjiCookingPersonalizedMealLoaded(
      ingredients: ingredients ?? this.ingredients,
      mealType: mealType ?? this.mealType,
      targetCalories: targetCalories ?? this.targetCalories,
      goal: goal ?? this.goal,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      personalizedMeal: personalizedMeal ?? this.personalizedMeal,
      failure: failure ?? this.failure,
    );
  }
}

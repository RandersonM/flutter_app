import 'package:equatable/equatable.dart';

abstract class SanjiCookingEvent extends Equatable {
  const SanjiCookingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSanjiCooking extends SanjiCookingEvent {
  const InitializeSanjiCooking();
}

class CalculateNutrition extends SanjiCookingEvent {
  final Map<String, dynamic> nutritionData;

  const CalculateNutrition({required this.nutritionData});

  @override
  List<Object?> get props => [nutritionData];
}

class SaveNutritionData extends SanjiCookingEvent {
  final Map<String, dynamic> nutritionData;

  const SaveNutritionData({required this.nutritionData});

  @override
  List<Object?> get props => [nutritionData];
}

class NewCalculation extends SanjiCookingEvent {
  const NewCalculation();
}

class ClearError extends SanjiCookingEvent {
  const ClearError();
}

class GenerateCookingTips extends SanjiCookingEvent {
  final List<String> ingredients;
  final String? cookingMethod;
  final String? difficulty;

  const GenerateCookingTips({
    required this.ingredients,
    this.cookingMethod,
    this.difficulty,
  });

  @override
  List<Object?> get props => [ingredients, cookingMethod, difficulty];
}

class GeneratePersonalizedMeal extends SanjiCookingEvent {
  final List<String> ingredients;
  final String mealType;
  final double targetCalories;
  final String goal;
  final String? dietaryRestrictions;

  const GeneratePersonalizedMeal({
    required this.ingredients,
    required this.mealType,
    required this.targetCalories,
    required this.goal,
    this.dietaryRestrictions,
  });

  @override
  List<Object?> get props =>
      [ingredients, mealType, targetCalories, goal, dietaryRestrictions];
}

class ClearCookingTips extends SanjiCookingEvent {
  const ClearCookingTips();
}

class AddIngredient extends SanjiCookingEvent {
  final String ingredient;

  const AddIngredient({required this.ingredient});

  @override
  List<Object?> get props => [ingredient];
}

class RemoveIngredient extends SanjiCookingEvent {
  final String ingredient;

  const RemoveIngredient({required this.ingredient});

  @override
  List<Object?> get props => [ingredient];
}

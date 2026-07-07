abstract class ICookingRepository {
  /// Generate cooking tips and advice
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  });


  /// Generate personalized meal based on nutrition data
  Future<String?> generatePersonalizedMeal({
    required List<String> ingredients,
    required String mealType,
    required double targetCalories,
    required String goal,
    String? dietaryRestrictions,
  });
}

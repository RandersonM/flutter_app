abstract class ICookingRepository {
  /// Generate cooking tips and advice
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  });

  /// Generate recipe suggestions
  Future<String?> generateRecipeSuggestions({
    required List<String> ingredients,
    String? cuisine,
    String? mealType,
    int? servings,
  });

  /// Generate nutritional information
  Future<String?> generateNutritionalInfo({
    required String foodItem,
    String? portion,
    String? cookingMethod,
  });

  /// Generate cooking techniques explanation
  Future<String?> generateCookingTechnique({
    required String technique,
    String? ingredient,
    String? difficulty,
  });

  /// Generate meal planning suggestions
  Future<String?> generateMealPlanning({
    required int days,
    String? dietaryRestrictions,
    String? budget,
    String? timeAvailable,
  });

  /// Generate food pairing suggestions
  Future<String?> generateFoodPairings({
    required String mainIngredient,
    String? cuisine,
    String? occasion,
  });

  /// Generate cooking troubleshooting
  Future<String?> generateCookingTroubleshooting({
    required String problem,
    String? dish,
    String? cookingMethod,
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

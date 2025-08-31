import 'package:opfan/core/services/gemini_service.dart';
import 'package:opfan/core/services/service_locator.dart';

class CookingRepository {
  final GeminiService _geminiService = getIt<GeminiService>();

  /// Generate cooking tips and advice
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  }) async {
    final prompt = '''
Generate helpful cooking tips for $ingredient.
${cookingMethod != null ? 'Cooking method: $cookingMethod' : ''}
${difficulty != null ? 'Difficulty level: $difficulty' : ''}

Please provide:
1. Preparation tips
2. Cooking techniques
3. Common mistakes to avoid
4. Serving suggestions
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Cooking tips and advice for ingredients',
      parameters: {
        'ingredient': ingredient,
        'cooking_method': cookingMethod,
        'difficulty': difficulty,
      },
    );
  }

  /// Generate recipe suggestions
  Future<String?> generateRecipeSuggestions({
    required List<String> ingredients,
    String? cuisine,
    String? mealType,
    int? servings,
  }) async {
    final ingredientsList = ingredients.join(', ');
    
    final prompt = '''
Suggest recipes using these ingredients: $ingredientsList
${cuisine != null ? 'Cuisine: $cuisine' : ''}
${mealType != null ? 'Meal type: $mealType' : ''}
${servings != null ? 'Servings: $servings' : ''}

Please provide:
1. Recipe name
2. Ingredients list with quantities
3. Step-by-step instructions
4. Cooking time and difficulty
5. Tips for best results
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Recipe suggestions based on available ingredients',
      parameters: {
        'ingredients': ingredients,
        'cuisine': cuisine,
        'meal_type': mealType,
        'servings': servings,
      },
    );
  }

  /// Generate nutritional information
  Future<String?> generateNutritionalInfo({
    required String foodItem,
    String? portion,
    String? cookingMethod,
  }) async {
    final prompt = '''
Provide nutritional information for $foodItem.
${portion != null ? 'Portion size: $portion' : ''}
${cookingMethod != null ? 'Cooking method: $cookingMethod' : ''}

Please include:
1. Calories per serving
2. Macronutrients (protein, carbs, fat)
3. Key vitamins and minerals
4. Health benefits
5. Dietary considerations
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Nutritional information and health benefits',
      parameters: {
        'food_item': foodItem,
        'portion': portion,
        'cooking_method': cookingMethod,
      },
    );
  }

  /// Generate cooking techniques explanation
  Future<String?> generateCookingTechnique({
    required String technique,
    String? ingredient,
    String? difficulty,
  }) async {
    final prompt = '''
Explain the cooking technique: $technique
${ingredient != null ? 'For ingredient: $ingredient' : ''}
${difficulty != null ? 'Difficulty level: $difficulty' : ''}

Please provide:
1. What this technique involves
2. Step-by-step instructions
3. Tips for success
4. Common mistakes to avoid
5. When to use this technique
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Cooking techniques and methods explanation',
      parameters: {
        'technique': technique,
        'ingredient': ingredient,
        'difficulty': difficulty,
      },
    );
  }

  /// Generate meal planning suggestions
  Future<String?> generateMealPlanning({
    required int days,
    String? dietaryRestrictions,
    String? budget,
    String? timeAvailable,
  }) async {
    final prompt = '''
Create a $days-day meal plan.
${dietaryRestrictions != null ? 'Dietary restrictions: $dietaryRestrictions' : ''}
${budget != null ? 'Budget: $budget' : ''}
${timeAvailable != null ? 'Time available: $timeAvailable' : ''}

Please provide:
1. Daily meal suggestions
2. Shopping list
3. Preparation tips
4. Time-saving strategies
5. Budget-friendly alternatives
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Meal planning and preparation strategies',
      parameters: {
        'days': days,
        'dietary_restrictions': dietaryRestrictions,
        'budget': budget,
        'time_available': timeAvailable,
      },
    );
  }

  /// Generate food pairing suggestions
  Future<String?> generateFoodPairings({
    required String mainIngredient,
    String? cuisine,
    String? occasion,
  }) async {
    final prompt = '''
Suggest food pairings for $mainIngredient.
${cuisine != null ? 'Cuisine: $cuisine' : ''}
${occasion != null ? 'Occasion: $occasion' : ''}

Please provide:
1. Complementary ingredients
2. Side dish suggestions
3. Beverage pairings
4. Flavor combinations
5. Presentation ideas
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Food pairing and flavor combination suggestions',
      parameters: {
        'main_ingredient': mainIngredient,
        'cuisine': cuisine,
        'occasion': occasion,
      },
    );
  }

  /// Generate cooking troubleshooting
  Future<String?> generateCookingTroubleshooting({
    required String problem,
    String? dish,
    String? cookingMethod,
  }) async {
    final prompt = '''
Help solve this cooking problem: $problem
${dish != null ? 'Dish: $dish' : ''}
${cookingMethod != null ? 'Cooking method: $cookingMethod' : ''}

Please provide:
1. Possible causes
2. Solutions to try
3. Prevention tips
4. Alternative approaches
5. When to start over
''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: 'Cooking problem troubleshooting and solutions',
      parameters: {
        'problem': problem,
        'dish': dish,
        'cooking_method': cookingMethod,
      },
    );
  }
}

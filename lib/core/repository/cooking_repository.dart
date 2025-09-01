import 'package:opfan/core/services/gemini_service.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/core/services/locale_service.dart';
import 'package:opfan/core/repository/interfaces/cooking_repository_interface.dart';

class CookingRepository implements ICookingRepository {
  final GeminiService _geminiService = getIt<GeminiService>();

  String get _currentLanguage {
    final locale = LocaleService.locale;
    return locale?.languageCode ?? 'en';
  }

  bool get _isPortuguese => _currentLanguage == 'pt';

  @override
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  }) async {
    final prompt = _isPortuguese
        ? '''
Gere dicas úteis de culinária para $ingredient.
${cookingMethod != null ? 'Método de cozimento: $cookingMethod' : ''}
${difficulty != null ? 'Nível de dificuldade: $difficulty' : ''}

Por favor, forneça:
1. Dicas de preparação
2. Técnicas de cozimento
3. Erros comuns a evitar
4. Sugestões de servir
'''
        : '''
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
      context: _isPortuguese
          ? 'Dicas de culinária e conselhos para ingredientes'
          : 'Cooking tips and advice for ingredients',
      parameters: {
        'ingredient': ingredient,
        'cooking_method': cookingMethod,
        'difficulty': difficulty,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateRecipeSuggestions({
    required List<String> ingredients,
    String? cuisine,
    String? mealType,
    int? servings,
  }) async {
    final ingredientsList = ingredients.join(', ');
    
    final prompt = _isPortuguese
        ? '''
Sugira receitas usando estes ingredientes: $ingredientsList
${cuisine != null ? 'Culinária: $cuisine' : ''}
${mealType != null ? 'Tipo de refeição: $mealType' : ''}
${servings != null ? 'Porções: $servings' : ''}

Por favor, forneça:
1. Nome da receita
2. Lista de ingredientes com quantidades
3. Instruções passo a passo
4. Tempo de cozimento e dificuldade
5. Dicas para melhores resultados
'''
        : '''
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
      context: _isPortuguese
          ? 'Sugestões de receitas baseadas em ingredientes disponíveis'
          : 'Recipe suggestions based on available ingredients',
      parameters: {
        'ingredients': ingredients,
        'cuisine': cuisine,
        'meal_type': mealType,
        'servings': servings,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateNutritionalInfo({
    required String foodItem,
    String? portion,
    String? cookingMethod,
  }) async {
    final prompt = _isPortuguese
        ? '''
Forneça informações nutricionais para $foodItem.
${portion != null ? 'Tamanho da porção: $portion' : ''}
${cookingMethod != null ? 'Método de cozimento: $cookingMethod' : ''}

Por favor, inclua:
1. Calorias por porção
2. Macronutrientes (proteína, carboidratos, gordura)
3. Vitaminas e minerais principais
4. Benefícios para a saúde
5. Considerações dietéticas
'''
        : '''
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
      context: _isPortuguese
          ? 'Informações nutricionais e benefícios para a saúde'
          : 'Nutritional information and health benefits',
      parameters: {
        'food_item': foodItem,
        'portion': portion,
        'cooking_method': cookingMethod,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateCookingTechnique({
    required String technique,
    String? ingredient,
    String? difficulty,
  }) async {
    final prompt = _isPortuguese
        ? '''
Explique a técnica de cozimento: $technique
${ingredient != null ? 'Para ingrediente: $ingredient' : ''}
${difficulty != null ? 'Nível de dificuldade: $difficulty' : ''}

Por favor, forneça:
1. O que esta técnica envolve
2. Instruções passo a passo
3. Dicas para o sucesso
4. Erros comuns a evitar
5. Quando usar esta técnica
'''
        : '''
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
      context: _isPortuguese
          ? 'Explicação de técnicas e métodos de cozimento'
          : 'Cooking techniques and methods explanation',
      parameters: {
        'technique': technique,
        'ingredient': ingredient,
        'difficulty': difficulty,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateMealPlanning({
    required int days,
    String? dietaryRestrictions,
    String? budget,
    String? timeAvailable,
  }) async {
    final prompt = _isPortuguese
        ? '''
Crie um plano de refeições de $days dias.
${dietaryRestrictions != null ? 'Restrições dietéticas: $dietaryRestrictions' : ''}
${budget != null ? 'Orçamento: $budget' : ''}
${timeAvailable != null ? 'Tempo disponível: $timeAvailable' : ''}

Por favor, forneça:
1. Sugestões de refeições diárias
2. Lista de compras
3. Dicas de preparação
4. Estratégias para economizar tempo
5. Alternativas econômicas
'''
        : '''
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
      context: _isPortuguese
          ? 'Estratégias de planejamento e preparação de refeições'
          : 'Meal planning and preparation strategies',
      parameters: {
        'days': days,
        'dietary_restrictions': dietaryRestrictions,
        'budget': budget,
        'time_available': timeAvailable,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateFoodPairings({
    required String mainIngredient,
    String? cuisine,
    String? occasion,
  }) async {
    final prompt = _isPortuguese
        ? '''
Sugira combinações de alimentos para $mainIngredient.
${cuisine != null ? 'Culinária: $cuisine' : ''}
${occasion != null ? 'Ocasião: $occasion' : ''}

Por favor, forneça:
1. Ingredientes complementares
2. Sugestões de acompanhamentos
3. Combinações de bebidas
4. Combinações de sabores
5. Ideias de apresentação
'''
        : '''
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
      context: _isPortuguese
          ? 'Sugestões de combinações de alimentos e sabores'
          : 'Food pairing and flavor combination suggestions',
      parameters: {
        'main_ingredient': mainIngredient,
        'cuisine': cuisine,
        'occasion': occasion,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generateCookingTroubleshooting({
    required String problem,
    String? dish,
    String? cookingMethod,
  }) async {
    final prompt = _isPortuguese
        ? '''
Ajude a resolver este problema de culinária: $problem
${dish != null ? 'Prato: $dish' : ''}
${cookingMethod != null ? 'Método de cozimento: $cookingMethod' : ''}

Por favor, forneça:
1. Possíveis causas
2. Soluções para tentar
3. Dicas de prevenção
4. Abordagens alternativas
5. Quando recomeçar
'''
        : '''
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
      context: _isPortuguese
          ? 'Solução de problemas de culinária e soluções'
          : 'Cooking problem troubleshooting and solutions',
      parameters: {
        'problem': problem,
        'dish': dish,
        'cooking_method': cookingMethod,
        'language': _currentLanguage,
      },
    );
  }

  @override
  Future<String?> generatePersonalizedMeal({
    required List<String> ingredients,
    required String mealType,
    required double targetCalories,
    required String goal,
    String? dietaryRestrictions,
  }) async {
    final ingredientsText = ingredients.join(', ');
    final goalText = _getLocalizedGoal(goal);

    final prompt = _isPortuguese
        ? '''
    Crie uma refeição personalizada para $mealType usando os ingredientes disponíveis: $ingredientsText

    Informações nutricionais:
    - Calorias alvo: ${targetCalories.toStringAsFixed(0)} kcal
    - Objetivo: $goalText
    ${dietaryRestrictions != null ? '- Restrições alimentares: $dietaryRestrictions' : ''}

    Por favor, forneça:
    1. **Nome da Receita**
    2. **Ingredientes** (quantidades específicas)
    3. **Informações Nutricionais** (calorias, proteínas, carboidratos, gorduras)
    4. **Passo a Passo** detalhado
    5. **Dicas do Chef Sanji** para melhor resultado
    6. **Tempo de Preparo** e **Dificuldade**
    7. **Substituições** possíveis se necessário

    Formate a resposta em markdown com títulos, listas e destaques.
    '''
        : '''
    Create a personalized meal for $mealType using available ingredients: $ingredientsText

    Nutritional information:
    - Target calories: ${targetCalories.toStringAsFixed(0)} kcal
    - Goal: $goalText
    ${dietaryRestrictions != null ? '- Dietary restrictions: $dietaryRestrictions' : ''}

    Please provide:
    1. **Recipe Name**
    2. **Ingredients** (specific quantities)
    3. **Nutritional Information** (calories, proteins, carbs, fats)
    4. **Step-by-Step** detailed instructions
    5. **Chef Sanji's Tips** for best results
    6. **Prep Time** and **Difficulty**
    7. **Possible Substitutions** if needed

    Format the response in markdown with titles, lists, and highlights.
    ''';

    return await _geminiService.generateText(
      prompt: prompt,
      context: _isPortuguese
          ? 'Receita personalizada baseada em dados nutricionais'
          : 'Personalized recipe based on nutritional data',
      parameters: {
        'ingredients': ingredientsText,
        'meal_type': mealType,
        'target_calories': targetCalories,
        'goal': goal,
        'dietary_restrictions': dietaryRestrictions,
        'language': _currentLanguage,
      },
    );
  }

  String _getLocalizedGoal(String goal) {
    if (_isPortuguese) {
      switch (goal) {
        case 'maintenance':
          return 'Manter peso';
        case 'weight_loss':
          return 'Perder peso';
        case 'muscle_gain':
          return 'Ganhar massa muscular';
        default:
          return goal;
      }
    } else {
      switch (goal) {
        case 'maintenance':
          return 'Maintain weight';
        case 'weight_loss':
          return 'Lose weight';
        case 'muscle_gain':
          return 'Gain muscle';
        default:
          return goal;
      }
    }
  }
}

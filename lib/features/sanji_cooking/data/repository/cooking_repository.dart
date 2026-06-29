import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';

class CookingRepository implements ICookingRepository {
  final IGeminiService _geminiService = getIt<IGeminiService>();

  /// Removes control characters and caps length to prevent prompt injection.
  static String _sanitize(String input, {int maxLength = 200}) {
    final clean = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    return clean.length > maxLength ? clean.substring(0, maxLength) : clean;
  }

  String get _currentLanguage {
    final locale = GetIt.I.get<ILocaleService>().locale;
    return locale?.languageCode ?? 'en';
  }

  bool get _isPortuguese => _currentLanguage == 'pt';

  String get _sanjiSystemInstruction {
    return _isPortuguese
        ? "Você é o Sanji, o lendário cozinheiro dos Piratas do Chapéu de Palha de One Piece. Você é apaixonado por culinária, odeia desperdiçar comida e sempre oferece conselhos e técnicas gastronômicas profissionais. Fale com a paixão e o estilo característico de Sanji (confiante, focado em ingredientes frescos, respeitoso e levemente dramático sobre comida), mas sempre com informações culinárias reais e precisas."
        : "You are Sanji, the legendary chef of the Straw Hat Pirates from One Piece. You are passionate about cooking, despise wasting food, and always offer professional culinary advice and techniques. Speak with Sanji's characteristic passion and style (confident, ingredient-focused, respectful and slightly dramatic about food), but always provide real, accurate culinary information.";
  }

  @override
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  }) async {
    final safeIngredient = _sanitize(ingredient);
    final safeCookingMethod = cookingMethod != null ? _sanitize(cookingMethod) : null;
    final safeDifficulty = difficulty != null ? _sanitize(difficulty) : null;
    final prompt = _isPortuguese
        ? '''
Gere dicas úteis de culinária para $safeIngredient.
${safeCookingMethod != null ? 'Método de cozimento: $safeCookingMethod' : ''}
${safeDifficulty != null ? 'Nível de dificuldade: $safeDifficulty' : ''}

Por favor, forneça:
1. Dicas de preparação
2. Técnicas de cozimento
3. Erros comuns a evitar
4. Sugestões de servir
'''
        : '''
Generate helpful cooking tips for $safeIngredient.
${safeCookingMethod != null ? 'Cooking method: $safeCookingMethod' : ''}
${safeDifficulty != null ? 'Difficulty level: $safeDifficulty' : ''}

Please provide:
1. Preparation tips
2. Cooking techniques
3. Common mistakes to avoid
4. Serving suggestions
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
    final ingredientsList = ingredients.map((i) => _sanitize(i)).join(', ');

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
      systemInstruction: _sanjiSystemInstruction,
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
    final safeFoodItem = _sanitize(foodItem);
    final prompt = _isPortuguese
        ? '''
Forneça informações nutricionais para $safeFoodItem.
${portion != null ? 'Tamanho da porção: ${_sanitize(portion)}' : ''}
${cookingMethod != null ? 'Método de cozimento: ${_sanitize(cookingMethod)}' : ''}

Por favor, inclua:
1. Calorias por porção
2. Macronutrientes (proteína, carboidratos, gordura)
3. Vitaminas e minerais principais
4. Benefícios para a saúde
5. Considerações dietéticas
'''
        : '''
Provide nutritional information for $safeFoodItem.
${portion != null ? 'Portion size: ${_sanitize(portion)}' : ''}
${cookingMethod != null ? 'Cooking method: ${_sanitize(cookingMethod)}' : ''}

Please include:
1. Calories per serving
2. Macronutrients (protein, carbs, fat)
3. Key vitamins and minerals
4. Health benefits
5. Dietary considerations
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
    final safeTechnique = _sanitize(technique);
    final prompt = _isPortuguese
        ? '''
Explique a técnica de cozimento: $safeTechnique
${ingredient != null ? 'Para ingrediente: ${_sanitize(ingredient)}' : ''}
${difficulty != null ? 'Nível de dificuldade: ${_sanitize(difficulty)}' : ''}

Por favor, forneça:
1. O que esta técnica envolve
2. Instruções passo a passo
3. Dicas para o sucesso
4. Erros comuns a evitar
5. Quando usar esta técnica
'''
        : '''
Explain the cooking technique: $safeTechnique
${ingredient != null ? 'For ingredient: ${_sanitize(ingredient)}' : ''}
${difficulty != null ? 'Difficulty level: ${_sanitize(difficulty)}' : ''}

Please provide:
1. What this technique involves
2. Step-by-step instructions
3. Tips for success
4. Common mistakes to avoid
5. When to use this technique
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
${dietaryRestrictions != null ? 'Restrições dietéticas: ${_sanitize(dietaryRestrictions)}' : ''}
${budget != null ? 'Orçamento: ${_sanitize(budget)}' : ''}
${timeAvailable != null ? 'Tempo disponível: ${_sanitize(timeAvailable)}' : ''}

Por favor, forneça:
1. Sugestões de refeições diárias
2. Lista de compras
3. Dicas de preparação
4. Estratégias para economizar tempo
5. Alternativas econômicas
'''
        : '''
Create a $days-day meal plan.
${dietaryRestrictions != null ? 'Dietary restrictions: ${_sanitize(dietaryRestrictions)}' : ''}
${budget != null ? 'Budget: ${_sanitize(budget)}' : ''}
${timeAvailable != null ? 'Time available: ${_sanitize(timeAvailable)}' : ''}

Please provide:
1. Daily meal suggestions
2. Shopping list
3. Preparation tips
4. Time-saving strategies
5. Budget-friendly alternatives
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
    final safeMain = _sanitize(mainIngredient);
    final prompt = _isPortuguese
        ? '''
Sugira combinações de alimentos para $safeMain.
${cuisine != null ? 'Culinária: ${_sanitize(cuisine)}' : ''}
${occasion != null ? 'Ocasião: ${_sanitize(occasion)}' : ''}

Por favor, forneça:
1. Ingredientes complementares
2. Sugestões de acompanhamentos
3. Combinações de bebidas
4. Combinações de sabores
5. Ideias de apresentação
'''
        : '''
Suggest food pairings for $safeMain.
${cuisine != null ? 'Cuisine: ${_sanitize(cuisine)}' : ''}
${occasion != null ? 'Occasion: ${_sanitize(occasion)}' : ''}

Please provide:
1. Complementary ingredients
2. Side dish suggestions
3. Beverage pairings
4. Flavor combinations
5. Presentation ideas
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
    final safeProblem = _sanitize(problem);
    final prompt = _isPortuguese
        ? '''
Ajude a resolver este problema de culinária: $safeProblem
${dish != null ? 'Prato: ${_sanitize(dish)}' : ''}
${cookingMethod != null ? 'Método de cozimento: ${_sanitize(cookingMethod)}' : ''}

Por favor, forneça:
1. Possíveis causas
2. Soluções para tentar
3. Dicas de prevenção
4. Abordagens alternativas
5. Quando recomeçar
'''
        : '''
Help solve this cooking problem: $safeProblem
${dish != null ? 'Dish: ${_sanitize(dish)}' : ''}
${cookingMethod != null ? 'Cooking method: ${_sanitize(cookingMethod)}' : ''}

Please provide:
1. Possible causes
2. Solutions to try
3. Prevention tips
4. Alternative approaches
5. When to start over
''';

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: _sanjiSystemInstruction,
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
    final ingredientsText = ingredients.map((i) => _sanitize(i)).join(', ');
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
      systemInstruction: _sanjiSystemInstruction,
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

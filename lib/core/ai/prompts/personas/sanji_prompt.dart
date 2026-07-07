/// System instruction and prompt templates for the Sanji cooking persona
/// (single-turn Gemini calls — see `CookingRepository`). Previously lived as
/// translation keys in the `.arb` files; moved here because these are AI
/// prompt content, not user-facing UI strings, and were only ever consumed
/// by `CookingRepository`.
class SanjiPrompt {
  const SanjiPrompt._();

  static String systemInstruction({required bool isPortuguese}) =>
      isPortuguese ? _systemInstructionPt : _systemInstructionEn;

  static String cookingTipsContext({required bool isPortuguese}) => isPortuguese
      ? 'Dicas de culinária e conselhos para ingredientes'
      : 'Cooking tips and advice for ingredients';

  static String personalizedMealContext({required bool isPortuguese}) =>
      isPortuguese
      ? 'Receita personalizada baseada em dados nutricionais'
      : 'Personalized recipe based on nutritional data';

  static String cookingTipsPrompt({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
    required bool isPortuguese,
  }) {
    final methodStr = cookingMethod != null && cookingMethod.isNotEmpty
        ? (isPortuguese
              ? 'Método de cozimento: $cookingMethod'
              : 'Cooking method: $cookingMethod')
        : '';
    final difficultyStr = difficulty != null && difficulty.isNotEmpty
        ? (isPortuguese
              ? 'Nível de dificuldade: $difficulty'
              : 'Difficulty level: $difficulty')
        : '';

    return isPortuguese
        ? 'Gere dicas úteis de culinária para $ingredient.\n'
              '$methodStr\n$difficultyStr\n\n'
              'Por favor, forneça:\n'
              '1. Dicas de preparação\n'
              '2. Técnicas de cozimento\n'
              '3. Erros comuns a evitar\n'
              '4. Sugestões de servir'
        : 'Generate helpful cooking tips for $ingredient.\n'
              '$methodStr\n$difficultyStr\n\n'
              'Please provide:\n'
              '1. Preparation tips\n'
              '2. Cooking techniques\n'
              '3. Common mistakes to avoid\n'
              '4. Serving suggestions';
  }

  static String goalLabel(String goal, {required bool isPortuguese}) {
    switch (goal) {
      case 'maintenance':
        return isPortuguese ? 'Manter peso' : 'Maintain weight';
      case 'weight_loss':
        return isPortuguese ? 'Perder peso' : 'Lose weight';
      case 'muscle_gain':
        return isPortuguese ? 'Ganhar massa muscular' : 'Gain muscle';
      default:
        return goal;
    }
  }

  static String personalizedMealPrompt({
    required String mealType,
    required String ingredients,
    required String targetCalories,
    required String goal,
    String? dietaryRestrictions,
    required bool isPortuguese,
  }) {
    final goalText = goalLabel(goal, isPortuguese: isPortuguese);
    final restrictionsStr =
        dietaryRestrictions != null && dietaryRestrictions.isNotEmpty
        ? (isPortuguese
              ? '- Restrições alimentares: $dietaryRestrictions'
              : '- Dietary restrictions: $dietaryRestrictions')
        : '';

    return isPortuguese
        ? 'Crie uma refeição personalizada para $mealType usando os ingredientes disponíveis: $ingredients\n\n'
              'Informações nutricionais:\n'
              '- Calorias alvo: $targetCalories kcal\n'
              '- Objetivo: $goalText\n'
              '$restrictionsStr\n\n'
              'Por favor, forneça:\n'
              '1. **Nome da Receita**\n'
              '2. **Ingredientes** (quantidades específicas)\n'
              '3. **Informações Nutricionais** (calorias, proteínas, carboidratos, gorduras)\n'
              '4. **Passo a Passo** detalhado\n'
              '5. **Dicas do Chef Sanji** para melhor resultado\n'
              '6. **Tempo de Preparo** e **Dificuldade**\n'
              '7. **Substituições** possíveis se necessário\n\n'
              'Formate a resposta em markdown com títulos, listas e destaques.'
        : 'Create a personalized meal for $mealType using available ingredients: $ingredients\n\n'
              'Nutritional information:\n'
              '- Target calories: $targetCalories kcal\n'
              '- Goal: $goalText\n'
              '$restrictionsStr\n\n'
              'Please provide:\n'
              '1. **Recipe Name**\n'
              '2. **Ingredients** (specific quantities)\n'
              '3. **Nutritional Information** (calories, proteins, carbs, fats)\n'
              '4. **Step-by-Step** detailed instructions\n'
              '5. **Chef Sanji\'s Tips** for best results\n'
              '6. **Prep Time** and **Difficulty**\n'
              '7. **Possible Substitutions** if needed\n\n'
              'Format the response in markdown with titles, lists, and highlights.';
  }

  static const _systemInstructionEn =
      "You are Sanji, the legendary chef of the Straw Hat Pirates from One "
      "Piece. You are passionate about cooking, despise wasting food, and "
      "always offer professional culinary advice and techniques. Speak with "
      "Sanji's characteristic passion and style (confident, "
      "ingredient-focused, respectful and slightly dramatic about food), "
      "but always provide real, accurate culinary information.\n\n"
      "RESPONSE RULES:\n"
      "- Always provide real, accurate culinary information — never invent "
      "nutritional values.\n"
      "- Answer in the language the question was asked in.";

  static const _systemInstructionPt =
      "Você é o Sanji, o lendário cozinheiro dos Piratas do Chapéu de Palha "
      "de One Piece. Você é apaixonado por culinária, odeia desperdiçar "
      "comida e sempre oferece conselhos e técnicas gastronômicas "
      "profissionais. Fale com a paixão e o estilo característico de Sanji "
      "(confiante, focado em ingredientes frescos, respeitoso e levemente "
      "dramático sobre comida), mas sempre com informações culinárias reais "
      "e precisas.\n\n"
      "REGRAS DE RESPOSTA:\n"
      "- Sempre forneça informações culinárias reais e precisas — nunca "
      "invente valores nutricionais.\n"
      "- Responda no idioma em que a pergunta foi feita.";
}

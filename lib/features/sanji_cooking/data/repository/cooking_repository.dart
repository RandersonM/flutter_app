import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';

class CookingRepository implements ICookingRepository {
  CookingRepository({
    required this._geminiService,
    required this._localeService,
  });

  final IGeminiService _geminiService;
  final ILocaleService _localeService;

  /// Removes control characters and caps length to prevent prompt injection.
  static String _sanitize(String input, {int maxLength = 200}) {
    final clean = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    return clean.length > maxLength ? clean.substring(0, maxLength) : clean;
  }

  @override
  Future<String?> generateCookingTips({
    required String ingredient,
    String? cookingMethod,
    String? difficulty,
  }) async {
    final safeIngredient = _sanitize(ingredient);
    final safeCookingMethod = cookingMethod != null
        ? _sanitize(cookingMethod)
        : null;
    final safeDifficulty = difficulty != null ? _sanitize(difficulty) : null;
    final isPortuguese = PromptLocale.isPortuguese(_localeService);

    final prompt = SanjiPrompt.cookingTipsPrompt(
      ingredient: safeIngredient,
      cookingMethod: safeCookingMethod,
      difficulty: safeDifficulty,
      isPortuguese: isPortuguese,
    );

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: SanjiPrompt.systemInstruction(
        isPortuguese: isPortuguese,
      ),
      context: SanjiPrompt.cookingTipsContext(isPortuguese: isPortuguese),
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
    final isPortuguese = PromptLocale.isPortuguese(_localeService);

    final prompt = SanjiPrompt.personalizedMealPrompt(
      mealType: mealType,
      ingredients: ingredientsText,
      targetCalories: targetCalories.toStringAsFixed(0),
      goal: goal,
      dietaryRestrictions: dietaryRestrictions,
      isPortuguese: isPortuguese,
    );

    return await _geminiService.generateText(
      prompt: prompt,
      systemInstruction: SanjiPrompt.systemInstruction(
        isPortuguese: isPortuguese,
      ),
      context: SanjiPrompt.personalizedMealContext(isPortuguese: isPortuguese),
    );
  }
}

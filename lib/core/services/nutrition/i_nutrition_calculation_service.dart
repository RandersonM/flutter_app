import 'package:opfan/core/models/nutrition_calculation_model.dart';

abstract class INutritionCalculationService {
  NutritionCalculationModel calculateNutrition({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required double waist,
    required String activityLevel,
    required String goal,
  });

  List<String> getActivityLevels();
  
  List<String> getGoals();
  
  String getActivityLevelDisplayName(
      String key, Function(String) getLocalizedString);
      
  String getGoalDisplayName(
      String key, Function(String) getLocalizedString);
}

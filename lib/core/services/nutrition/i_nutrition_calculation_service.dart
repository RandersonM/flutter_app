import 'package:opfan/features/sanji_cooking/data/models/nutrition_calculation_model.dart';

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
}

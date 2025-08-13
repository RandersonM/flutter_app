import 'package:opfan/core/models/nutrition_calculation_model.dart';

class NutritionCalculationService {
  static const Map<String, double> _activityFactors = {
    'sedentary': 1.2,      // Pouco ou nenhum exercício
    'light': 1.375,         // Exercício leve 1-3 dias/semana
    'moderate': 1.55,       // Exercício moderado 3-5 dias/semana
    'active': 1.725,        // Exercício intenso 6-7 dias/semana
    'very_active': 1.9,     // Exercício muito intenso, trabalho físico
  };

  static const Map<String, double> _goalFactors = {
    'weight_loss': 0.85,    // Déficit de 15%
    'maintenance': 1.0,     // Manutenção
    'muscle_gain': 1.1,     // Superávit de 10%
  };

  static NutritionCalculationModel calculateNutrition({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required double waist,
    required String activityLevel,
    required String goal,
  }) {
    // Calcular BMR usando fórmula de Mifflin-St Jeor
    final bmr = _calculateBMR(age, gender, weight, height);
    
    // Calcular TDEE
    final tdee = bmr * _activityFactors[activityLevel]!;
    
    // Calcular calorias baseadas no objetivo
    final maintenanceCalories = tdee * _goalFactors['maintenance']!;
    final weightLossCalories = tdee * _goalFactors['weight_loss']!;
    final muscleGainCalories = tdee * _goalFactors['muscle_gain']!;
    
    // Calcular classificações
    final bmiCategory = _getBMICategory(weight, height);
    final waistToHeightCategory = _getWaistToHeightCategory(waist, height);
    
    return NutritionCalculationModel(
      bmr: bmr,
      tdee: tdee,
      maintenanceCalories: maintenanceCalories,
      weightLossCalories: weightLossCalories,
      muscleGainCalories: muscleGainCalories,
      bmiCategory: bmiCategory,
      waistToHeightCategory: waistToHeightCategory,
      activityLevel: activityLevel,
      goal: goal,
    );
  }

  static double _calculateBMR(int age, String gender, double weight, double height) {
    // Fórmula de Mifflin-St Jeor
    if (gender.toLowerCase() == 'masculino' || gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  static String _getBMICategory(double weight, double height) {
    final bmi = weight / ((height / 100) * (height / 100));
    
    if (bmi < 18.5) return ('underweight');
    if (bmi < 25) return ('normalWeight');
    if (bmi < 30) return ('overweight');
    if (bmi < 35) return ('obesityGrade1');
    if (bmi < 40) return ('obesityGrade2');
    return ('obesityGrade3');
  }

  static String _getWaistToHeightCategory(double waist, double height) {
    final ratio = waist / height;
    
    if (ratio < 0.4) return ('excellent');
    if (ratio < 0.5) return ('good');
    if (ratio < 0.6) return ('attention');
    return ('highRisk');
  }

  static List<String> getActivityLevels() {
    return _activityFactors.keys.toList();
  }

  static List<String> getGoals() {
    return _goalFactors.keys.toList();
  }

  static String getActivityLevelDisplayName(String key, Function(String) getLocalizedString) {
    switch (key) {
      case 'sedentary': return getLocalizedString('sedentary');
      case 'light': return getLocalizedString('light');
      case 'moderate': return getLocalizedString('moderate');
      case 'active': return getLocalizedString('active');
      case 'very_active': return getLocalizedString('veryActive');
      default: return key;
    }
  }

  static String getGoalDisplayName(String key, Function(String) getLocalizedString) {
    switch (key) {
      case 'weight_loss': return getLocalizedString('weightLoss');
      case 'maintenance': return getLocalizedString('maintenance');
      case 'muscle_gain': return getLocalizedString('muscleGain');
      default: return key;
    }
  }
}

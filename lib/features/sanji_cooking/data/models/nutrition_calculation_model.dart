class NutritionCalculationModel {
  final double bmr;
  final double tdee;
  final double maintenanceCalories;
  final double weightLossCalories;
  final double muscleGainCalories;
  final String bmiCategory;
  final String waistToHeightCategory;
  final String activityLevel;
  final String goal;

  NutritionCalculationModel({
    required this.bmr,
    required this.tdee,
    required this.maintenanceCalories,
    required this.weightLossCalories,
    required this.muscleGainCalories,
    required this.bmiCategory,
    required this.waistToHeightCategory,
    required this.activityLevel,
    required this.goal,
  });

  factory NutritionCalculationModel.fromMap(Map<String, dynamic> map) {
    return NutritionCalculationModel(
      bmr: map['bmr']?.toDouble() ?? 0.0,
      tdee: map['tdee']?.toDouble() ?? 0.0,
      maintenanceCalories: map['maintenanceCalories']?.toDouble() ?? 0.0,
      weightLossCalories: map['weightLossCalories']?.toDouble() ?? 0.0,
      muscleGainCalories: map['muscleGainCalories']?.toDouble() ?? 0.0,
      bmiCategory: map['bmiCategory'] ?? '',
      waistToHeightCategory: map['waistToHeightCategory'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      goal: map['goal'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bmr': bmr,
      'tdee': tdee,
      'maintenanceCalories': maintenanceCalories,
      'weightLossCalories': weightLossCalories,
      'muscleGainCalories': muscleGainCalories,
      'bmiCategory': bmiCategory,
      'waistToHeightCategory': waistToHeightCategory,
      'activityLevel': activityLevel,
      'goal': goal,
    };
  }
}

class WorkoutConstants {
  static const List<String> genderOptions = ['male', 'female'];

  static const Map<String, int> healthScoreThresholds = {
    'excellent': 80,
    'good': 60,
    'regular': 40,
  };

  static const Map<String, double> bmiThresholds = {
    'underweight': 18.5,
    'normal': 25.0,
    'overweight': 30.0,
    'obesity_1': 35.0,
    'obesity_2': 40.0,
  };

  static const Map<String, double> waistToHeightThresholds = {
    'excellent': 0.4,
    'good': 0.5,
    'attention': 0.6,
  };

  static const Map<String, double> bodyFatThresholdsMale = {
    'very_low': 8.0,
    'athletic': 15.0,
    'good': 20.0,
    'acceptable': 25.0,
  };

  static const Map<String, double> bodyFatThresholdsFemale = {
    'very_low': 15.0,
    'athletic': 22.0,
    'good': 28.0,
    'acceptable': 35.0,
  };
}

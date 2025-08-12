import 'package:json_annotation/json_annotation.dart';

part 'workout_assessment_model.g.dart';

@JsonSerializable()
class WorkoutAssessmentModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'month_year')
  final String monthYear;

  @JsonKey(name: 'gender')
  final String gender;

  @JsonKey(name: 'age')
  final int age;

  @JsonKey(name: 'height')
  final double height;

  @JsonKey(name: 'weight')
  final double weight;

  @JsonKey(name: 'waist')
  final double waist;

  @JsonKey(name: 'bmi')
  final double? bmi;

  @JsonKey(name: 'waist_to_height_ratio')
  final double? waistToHeightRatio;

  @JsonKey(name: 'body_fat_percentage')
  final double? bodyFatPercentage;

  @JsonKey(name: 'health_score')
  final double? healthScore;

  @JsonKey(name: 'workout_days_goal')
  final int? workoutDaysGoal;

  @JsonKey(name: 'activity_level')
  final String? activityLevel;

  @JsonKey(name: 'goal')
  final String? goal;

  @JsonKey(name: 'workout_days')
  final List<int>? workoutDays;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const WorkoutAssessmentModel({
    this.id,
    required this.userId,
    required this.monthYear,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.waist,
    this.bmi,
    this.waistToHeightRatio,
    this.bodyFatPercentage,
    this.healthScore,
    this.workoutDaysGoal,
    this.activityLevel,
    this.goal,
    this.workoutDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutAssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutAssessmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutAssessmentModelToJson(this);

  WorkoutAssessmentModel copyWith({
    String? id,
    String? userId,
    String? monthYear,
    String? gender,
    int? age,
    double? height,
    double? weight,
    double? waist,
    double? bmi,
    double? waistToHeightRatio,
    double? bodyFatPercentage,
    double? healthScore,
    int? workoutDaysGoal,
    String? activityLevel,
    String? goal,
    List<int>? workoutDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutAssessmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthYear: monthYear ?? this.monthYear,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      waist: waist ?? this.waist,
      bmi: bmi ?? this.bmi,
      waistToHeightRatio: waistToHeightRatio ?? this.waistToHeightRatio,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      healthScore: healthScore ?? this.healthScore,
      workoutDaysGoal: workoutDaysGoal ?? this.workoutDaysGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      workoutDays: workoutDays ?? this.workoutDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkoutAssessmentModel(id: $id, userId: $userId, gender: $gender, age: $age, height: $height, weight: $weight, waist: $waist)';
  }
}

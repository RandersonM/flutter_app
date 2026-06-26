import 'package:opfan/core/models/workout_assessment_model.dart';
import 'package:opfan/core/models/workout_plan_model.dart';

abstract class IWorkoutAssessmentService {
  Future<WorkoutAssessmentModel> saveWorkoutAssessment({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required double waist,
    double? bmi,
    double? waistToHeightRatio,
    double? bodyFatPercentage,
    double? healthScore,
    int? workoutDaysGoal,
    List<int>? workoutDays,
    String? activityLevel,
    String? goal,
  });

  Future<WorkoutAssessmentModel?> getCurrentUserAssessment();

  Future<WorkoutAssessmentModel?> getLatestUserAssessment();

  Future<bool> hasCurrentMonthAssessment();

  Future<bool> hasAssessment();

  Future<List<WorkoutAssessmentModel>> getUserAssessmentHistory();

  Future<void> deleteCurrentMonthAssessment();

  Future<void> deleteAllUserAssessments();

  Future<void> updateWorkoutDays(List<int> workoutDays);

  Future<void> updateWorkoutPlan(WorkoutPlanModel plan);

  Future<WorkoutAssessmentModel> updateNutritionData({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required double waist,
    String? activityLevel,
    String? goal,
  });
}

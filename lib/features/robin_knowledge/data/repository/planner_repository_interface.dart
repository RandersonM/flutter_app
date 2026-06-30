import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';

abstract class PlannerRepositoryInterface {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel?> getGoalById(String id);
  Future<String> createGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> updateGoalProgress(String id, double progress, {String? notes});
  Stream<List<GoalModel>> streamGoals();
}

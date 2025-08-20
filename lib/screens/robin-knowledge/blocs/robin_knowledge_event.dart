part of 'robin_knowledge_bloc.dart';

abstract class RobinKnowledgeEvent extends Equatable {
  const RobinKnowledgeEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends RobinKnowledgeEvent {
  const LoadGoals();
}

class AddGoal extends RobinKnowledgeEvent {
  final GoalModel goal;

  const AddGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends RobinKnowledgeEvent {
  final GoalModel goal;

  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends RobinKnowledgeEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class UpdateGoalProgress extends RobinKnowledgeEvent {
  final String goalId;
  final double progress;
  final String? notes;

  const UpdateGoalProgress(this.goalId, this.progress, {this.notes});

  @override
  List<Object?> get props => [goalId, progress, notes];
}

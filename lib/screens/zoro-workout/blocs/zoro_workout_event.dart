import 'package:equatable/equatable.dart';

abstract class ZoroWorkoutEvent extends Equatable {
  const ZoroWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class InitializeWorkoutAssessment extends ZoroWorkoutEvent {
  const InitializeWorkoutAssessment();
}

class CheckAndCreateNewMonth extends ZoroWorkoutEvent {
  const CheckAndCreateNewMonth();
}

class SaveNewAssessment extends ZoroWorkoutEvent {
  final Map<String, dynamic> healthResults;
  final int workoutDaysGoal;

  const SaveNewAssessment({
    required this.healthResults,
    required this.workoutDaysGoal,
  });

  @override
  List<Object?> get props => [healthResults, workoutDaysGoal];
}

class UpdateWorkoutDays extends ZoroWorkoutEvent {
  final List<int> workoutDays;

  const UpdateWorkoutDays({required this.workoutDays});

  @override
  List<Object?> get props => [workoutDays];
}

class UpdateHealthResults extends ZoroWorkoutEvent {
  final Map<String, dynamic> healthResults;

  const UpdateHealthResults({required this.healthResults});

  @override
  List<Object?> get props => [healthResults];
}

class UpdateWorkoutDaysGoal extends ZoroWorkoutEvent {
  final int workoutDaysGoal;

  const UpdateWorkoutDaysGoal({required this.workoutDaysGoal});

  @override
  List<Object?> get props => [workoutDaysGoal];
}

class RefreshAssessment extends ZoroWorkoutEvent {
  const RefreshAssessment();
}

class ClearError extends ZoroWorkoutEvent {
  const ClearError();
}

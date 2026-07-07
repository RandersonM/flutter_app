import 'package:equatable/equatable.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';

abstract class ZoroWorkoutState extends Equatable {
  const ZoroWorkoutState();

  @override
  List<Object?> get props => [];
}

class ZoroWorkoutInitial extends ZoroWorkoutState {
  const ZoroWorkoutInitial();
}

class ZoroWorkoutLoading extends ZoroWorkoutState {
  const ZoroWorkoutLoading();
}

class ZoroWorkoutLoaded extends ZoroWorkoutState {
  final WorkoutAssessmentModel? currentAssessment;
  final List<WorkoutAssessmentModel> assessmentHistory;
  final bool hasCurrentAssessment;
  final bool canEditCurrentAssessment;
  final double currentMonthProgress;
  final int remainingDaysToGoal;

  const ZoroWorkoutLoaded({
    this.currentAssessment,
    this.assessmentHistory = const [],
    this.hasCurrentAssessment = false,
    this.canEditCurrentAssessment = false,
    this.currentMonthProgress = 0.0,
    this.remainingDaysToGoal = 0,
  });

  @override
  List<Object?> get props => [
    currentAssessment,
    assessmentHistory,
    hasCurrentAssessment,
    canEditCurrentAssessment,
    currentMonthProgress,
    remainingDaysToGoal,
  ];

  ZoroWorkoutLoaded copyWith({
    WorkoutAssessmentModel? currentAssessment,
    List<WorkoutAssessmentModel>? assessmentHistory,
    bool? hasCurrentAssessment,
    bool? canEditCurrentAssessment,
    double? currentMonthProgress,
    int? remainingDaysToGoal,
  }) {
    return ZoroWorkoutLoaded(
      currentAssessment: currentAssessment ?? this.currentAssessment,
      assessmentHistory: assessmentHistory ?? this.assessmentHistory,
      hasCurrentAssessment: hasCurrentAssessment ?? this.hasCurrentAssessment,
      canEditCurrentAssessment:
          canEditCurrentAssessment ?? this.canEditCurrentAssessment,
      currentMonthProgress: currentMonthProgress ?? this.currentMonthProgress,
      remainingDaysToGoal: remainingDaysToGoal ?? this.remainingDaysToGoal,
    );
  }
}

class ZoroWorkoutError extends ZoroWorkoutState {
  final String message;

  const ZoroWorkoutError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ZoroWorkoutSuccess extends ZoroWorkoutState {
  final String message;

  const ZoroWorkoutSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

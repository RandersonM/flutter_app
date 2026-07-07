import 'package:flutter/foundation.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_plan_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

/// Resolves which workout split to show for today based on a rotation
/// algorithm:  split_index = (total workouts done so far) % splits.length
///
/// Requirements: WP-04, WP-05, WP-06
class WorkoutPlanResolver {
  /// Returns the split the user should do today (or next scheduled day).
  ///
  /// The rotation is based on the total number of workout days done so far
  /// in `assessment.workoutDays`, counting only days ≤ today.
  static WorkoutSplitModel? resolveTodaySplit(
    WorkoutAssessmentModel? assessment,
  ) {
    if (assessment == null) return null;
    final plan = assessment.workoutPlan;
    if (plan == null || plan.isEmpty) return null;

    final doneCount = _countWorkoutsDoneUpToToday(assessment);
    final index = doneCount % plan.splits.length;
    return plan.splits[index];
  }

  /// Returns the split for the NEXT scheduled workout (done+1).
  static WorkoutSplitModel? resolveNextSplit(
    WorkoutAssessmentModel? assessment,
  ) {
    if (assessment == null) return null;
    final plan = assessment.workoutPlan;
    if (plan == null || plan.isEmpty) return null;

    final doneCount = _countWorkoutsDoneUpToToday(assessment);
    final index = (doneCount + 1) % plan.splits.length;
    return plan.splits[index];
  }

  /// Returns true if today is already marked in `workout_days`.
  static bool isTodayWorkoutDone(WorkoutAssessmentModel? assessment) {
    if (assessment == null) return false;
    final today = DateTime.now().day;
    final now = DateTime.now();

    // Use the canonical monthYear field (e.g. "2025-06") instead of createdAt
    // so carry-over assessments from the last day of a month are still
    // recognised as belonging to the month they were created for.
    final expectedMonthYear =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (assessment.monthYear != expectedMonthYear) return false;

    return assessment.workoutDays?.contains(today) ?? false;
  }

  /// Counts how many days in `workout_days` are ≤ today (current month only).
  static int _countWorkoutsDoneUpToToday(WorkoutAssessmentModel assessment) {
    final days = assessment.workoutDays ?? [];
    final today = DateTime.now().day;
    return days.where((d) => d <= today).length;
  }

  /// Returns a human-readable label for when the split is scheduled.
  static String resolveScheduleLabel(
    WorkoutAssessmentModel? assessment,
    AppLocalizations loc,
  ) {
    if (assessment == null) return '';
    final done = isTodayWorkoutDone(assessment);
    return done ? loc.todayCompleted : loc.today;
  }

  static void debugLog(WorkoutAssessmentModel? assessment) {
    if (assessment == null) {
      debugPrint('WorkoutPlanResolver: no assessment');
      return;
    }
    final plan = assessment.workoutPlan;
    if (plan == null) {
      debugPrint('WorkoutPlanResolver: no plan');
      return;
    }
    final done = _countWorkoutsDoneUpToToday(assessment);
    debugPrint(
      'WorkoutPlanResolver: $done workouts done, '
      '${plan.splits.length} splits, index=${done % plan.splits.length}',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

import '../all_recommendations_screen.dart';
import 'workout_calendar.dart';
import 'workout_metrics_list.dart';
import 'workout_next_card.dart';
import 'workout_progress_row.dart';
import 'workout_recommendations_row.dart';

/// Assessment results page body.
///
/// Composition only — each section is its own widget so a change in one
/// (streak, metrics, recommendations) rebuilds just that subtree.
class WorkoutResults extends StatelessWidget {
  const WorkoutResults({
    super.key,
    required this.healthResults,
    required this.recommendedExercises,
    required this.onBackToSetup,
    this.currentAssessment,
  });

  final Map<String, dynamic> healthResults;
  final List<Map<String, dynamic>> recommendedExercises;
  final VoidCallback onBackToSetup;
  final WorkoutAssessmentModel? currentAssessment;

  /// Day-of-month numbers the user logged a workout on.
  List<int> get _workoutDays =>
      (healthResults['workout_days'] as List<dynamic>?)
          ?.whereType<int>()
          .toList() ??
      const [];

  int get _weeklyGoal =>
      (healthResults['workout_days_goal'] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final sectionTitle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkoutProgressRow(workoutDays: _workoutDays, weeklyGoal: _weeklyGoal),
        const SizedBox(height: Constants.margin),
        WorkoutNextCard(currentAssessment: currentAssessment),
        const SizedBox(height: Constants.margin * 2),
        Text(loc.assessmentResultsTitle, style: sectionTitle),
        const SizedBox(height: 12),
        WorkoutMetricsList(healthResults: healthResults),
        const SizedBox(height: Constants.margin * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                loc.topRecommendationsTitle,
                maxLines: 2,
                style: sectionTitle,
              ),
            ),
            AppButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AllRecommendationsScreen(exercises: recommendedExercises),
                ),
              ),
              variant: AppButtonVariant.text,
              label: loc.seeAll,
            ),
          ],
        ),
        const SizedBox(height: 8),
        WorkoutRecommendationsRow(exercises: recommendedExercises),
        const SizedBox(height: Constants.margin * 2),
        const WorkoutCalendar(),
        const SizedBox(height: 30),
        AppButton(
          onPressed: onBackToSetup,
          variant: AppButtonVariant.outline,
          label: loc.workout_new_assessment,
          isFullWidth: true,
        ),
      ],
    );
  }
}

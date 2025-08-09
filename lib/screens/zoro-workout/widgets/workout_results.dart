import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/theme.dart';
import '../workout_constants.dart';
import 'workout_calendar.dart';

class WorkoutResults extends StatelessWidget {
  final Map<String, dynamic> healthResults;
  final List<String> recommendedExercises;
  final VoidCallback onBackToSetup;

  const WorkoutResults({
    super.key,
    required this.healthResults,
    required this.recommendedExercises,
    required this.onBackToSetup,
  });

  Widget _buildMetricRow(BuildContext context, String label, String value, String category) {
    Color categoryColor = AppColors.green[300]!;
    if (category.contains('Regular') || category.contains('Atenção')) {
      categoryColor = Theme.of(context).colorScheme.tertiary;
    } else if (category.contains('Alto') ||
        category.contains('Risco') ||
        category.contains('Precisa')) {
      categoryColor = Theme.of(context).colorScheme.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: categoryColor),
            ),
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.workout_results,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_health_score,
                  '${healthResults['healthScore'].toStringAsFixed(0)}/100',
                  _getHealthCategory(context, healthResults['healthScore'])),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_bmi,
                  healthResults['bmi'].toStringAsFixed(1),
                  _getBMICategory(context, healthResults['bmi'])),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_waist_to_height,
                  '${(healthResults['waistToHeightRatio'] * 100).toStringAsFixed(1)}%',
                  _getWaistToHeightCategory(context, healthResults['waistToHeightRatio'])),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_body_fat,
                  '${healthResults['bodyFatPercentage'].toStringAsFixed(1)}%',
                  _getBodyFatCategory(context, healthResults['bodyFatPercentage'], healthResults['gender'] ?? 'Masculino')),
              if (healthResults['workoutDaysGoal'] != null)
                _buildMetricRow(
                    context,
                    AppLocalizations.of(context)!.workout_workout_days_goal,
                    '${healthResults['workoutDaysGoal']} ${healthResults['workoutDaysGoal'] == 1 ? AppLocalizations.of(context)!.workout_day : AppLocalizations.of(context)!.workout_days}',
                    'Meta definida'),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.workout_recommendations,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...(recommendedExercises.map((exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.green.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      exercise,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ))),
        const SizedBox(height: 30),
        
        const WorkoutCalendar(),
        
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onBackToSetup,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(AppLocalizations.of(context)!.workout_new_assessment),
          ),
        ),
      ],
    );
  }

  String _getBMICategory(BuildContext context, double bmi) {
    if (bmi < WorkoutConstants.bmiThresholds['underweight']!) return AppLocalizations.of(context)!.workout_category_underweight;
    if (bmi < WorkoutConstants.bmiThresholds['normal']!) return AppLocalizations.of(context)!.workout_category_normal;
    if (bmi < WorkoutConstants.bmiThresholds['overweight']!) return AppLocalizations.of(context)!.workout_category_overweight;
    if (bmi < WorkoutConstants.bmiThresholds['obesity_1']!) return AppLocalizations.of(context)!.workout_category_obesity_1;
    if (bmi < WorkoutConstants.bmiThresholds['obesity_2']!) return AppLocalizations.of(context)!.workout_category_obesity_2;
    return AppLocalizations.of(context)!.workout_category_obesity_3;
  }

  String _getWaistToHeightCategory(BuildContext context, double ratio) {
    if (ratio < WorkoutConstants.waistToHeightThresholds['excellent']!) return AppLocalizations.of(context)!.workout_category_excellent;
    if (ratio < WorkoutConstants.waistToHeightThresholds['good']!) return AppLocalizations.of(context)!.workout_category_good;
    if (ratio < WorkoutConstants.waistToHeightThresholds['attention']!) return AppLocalizations.of(context)!.workout_category_attention;
    return AppLocalizations.of(context)!.workout_category_high_risk;
  }

  String _getBodyFatCategory(BuildContext context, double percentage, String gender) {
    if (gender == 'Masculino') {
      if (percentage < WorkoutConstants.bodyFatThresholdsMale['very_low']!) return AppLocalizations.of(context)!.workout_category_very_low;
      if (percentage < WorkoutConstants.bodyFatThresholdsMale['athletic']!) return AppLocalizations.of(context)!.workout_category_athletic;
      if (percentage < WorkoutConstants.bodyFatThresholdsMale['good']!) return AppLocalizations.of(context)!.workout_category_good;
      if (percentage < WorkoutConstants.bodyFatThresholdsMale['acceptable']!) return AppLocalizations.of(context)!.workout_category_acceptable;
      return AppLocalizations.of(context)!.workout_category_high;
    } else {
      if (percentage < WorkoutConstants.bodyFatThresholdsFemale['very_low']!) return AppLocalizations.of(context)!.workout_category_very_low;
      if (percentage < WorkoutConstants.bodyFatThresholdsFemale['athletic']!) return AppLocalizations.of(context)!.workout_category_athletic;
      if (percentage < WorkoutConstants.bodyFatThresholdsFemale['good']!) return AppLocalizations.of(context)!.workout_category_good;
      if (percentage < WorkoutConstants.bodyFatThresholdsFemale['acceptable']!) return AppLocalizations.of(context)!.workout_category_acceptable;
      return AppLocalizations.of(context)!.workout_category_high;
    }
  }

  String _getHealthCategory(BuildContext context, double score) {
    if (score >= WorkoutConstants.healthScoreThresholds['excellent']!) return AppLocalizations.of(context)!.workout_category_excellent;
    if (score >= WorkoutConstants.healthScoreThresholds['good']!) return AppLocalizations.of(context)!.workout_category_good;
    if (score >= WorkoutConstants.healthScoreThresholds['regular']!) return AppLocalizations.of(context)!.workout_category_regular;
    return AppLocalizations.of(context)!.workout_category_needs_improvement;
  }
}

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/utils/gender_mapper.dart';
import 'package:opfan/widgets/atoms/gomu_gomu_divider.dart';
import '../workout_constants.dart';
import 'workout_calendar.dart';

class WorkoutResults extends StatelessWidget {
  final Map<String, dynamic> healthResults;
  final List<Map<String, dynamic>> recommendedExercises;
  final VoidCallback onBackToSetup;

  const WorkoutResults({
    super.key,
    required this.healthResults,
    required this.recommendedExercises,
    required this.onBackToSetup,
  });

  Widget _buildMetricRow(BuildContext context, String label, String value, String category) {
    Color categoryColor = AppColors.green[300]!;
    IconData categoryIcon = Icons.check_circle;

    if (category
            .contains(AppLocalizations.of(context)!.workout_category_regular) ||
        category
            .contains(AppLocalizations.of(context)!.workout_category_high) ||
        category.contains(
            AppLocalizations.of(context)!.workout_category_attention)) {
      categoryColor = AppColors.yellow[500]!;
      categoryIcon = Icons.warning;
    } else if (category.contains(
            AppLocalizations.of(context)!.workout_category_high_risk) ||
        category.contains(
            AppLocalizations.of(context)!.workout_category_needs_improvement)) {
      categoryColor = Theme.of(context).colorScheme.errorContainer;
      categoryIcon = Icons.error;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.3),
                width: 1,
              ),
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
        const WorkoutCalendar(),
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
                  Icon(
                    exercise['icon'] as IconData,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      exercise['name'] as String,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ))),
        const SizedBox(height: Constants.margin * 2),
        GomuGomuDivider(color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: Constants.margin * 2),
        SizedBox(
          width: double.infinity,
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
                  '${(healthResults['health_score'] as double? ?? 0.0).toStringAsFixed(0)}/100',
                  _getHealthCategory(context,
                      healthResults['health_score'] as double? ?? 0.0)),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_bmi,
                  (healthResults['bmi'] as double? ?? 0.0).toStringAsFixed(1),
                  _getBMICategory(
                      context, healthResults['bmi'] as double? ?? 0.0)),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_waist_to_height,
                  '${((healthResults['waist_to_height_ratio'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%',
                  _getWaistToHeightCategory(
                      context,
                      healthResults['waist_to_height_ratio'] as double? ??
                          0.0)),
              _buildMetricRow(
                  context,
                  AppLocalizations.of(context)!.workout_body_fat,
                  '${(healthResults['body_fat_percentage'] as double? ?? 0.0).toStringAsFixed(1)}%',
                  _getBodyFatCategory(
                      context,
                      healthResults['body_fat_percentage'] as double? ?? 0.0,
                      healthResults['gender'] as String? ??
                          AppLocalizations.of(context)!.workout_gender_male)),
              if (healthResults['workout_days_goal'] != null)
                _buildMetricRow(
                    context,
                    AppLocalizations.of(context)!.workout_workout_days_goal,
                    '${healthResults['workout_days_goal']} ${healthResults['workout_days_goal'] == 1 ? AppLocalizations.of(context)!.workout_day : AppLocalizations.of(context)!.workout_days}',
                    'Meta definida'),
            ],
          ),
        ),

        
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
    const thresholds = WorkoutConstants.bmiThresholds;
    final loc = AppLocalizations.of(context)!;

    if (bmi < thresholds['underweight']!) {
      return loc.workout_category_underweight;
    }
    if (bmi < thresholds['normal']!) return loc.workout_category_normal;
    if (bmi < thresholds['overweight']!) return loc.workout_category_overweight;
    if (bmi < thresholds['obesity_1']!) return loc.workout_category_obesity_1;
    if (bmi < thresholds['obesity_2']!) return loc.workout_category_obesity_2;

    return loc.workout_category_obesity_3;
  }

  String _getWaistToHeightCategory(BuildContext context, double ratio) {
    const thresholds = WorkoutConstants.waistToHeightThresholds;
    final loc = AppLocalizations.of(context)!;

    if (ratio < thresholds['excellent']!) {
      return loc.workout_category_excellent;
    }
    if (ratio < thresholds['good']!) return loc.workout_category_good;
    if (ratio < thresholds['attention']!) return loc.workout_category_attention;

    return loc.workout_category_high_risk;
  }

  String _getBodyFatCategory(BuildContext context, double percentage, String gender) {
    const maleThresholds = WorkoutConstants.bodyFatThresholdsMale;
    const femaleThresholds = WorkoutConstants.bodyFatThresholdsFemale;
    final loc = AppLocalizations.of(context)!;
    final internalGender = GenderMapper.getInternalValue(gender, loc);

    if (internalGender == GenderMapper.male) {
      if (percentage < maleThresholds['very_low']!) {
        return loc.workout_category_very_low;
      }
      if (percentage < maleThresholds['athletic']!) {
        return loc.workout_category_athletic;
      }
      if (percentage < maleThresholds['good']!) {
        return loc.workout_category_good;
      }
      if (percentage < maleThresholds['acceptable']!) {
        return loc.workout_category_acceptable;
      }

      return loc.workout_category_high;
    } else {
      if (percentage < femaleThresholds['very_low']!) {
        return loc.workout_category_very_low;
      }
      if (percentage < femaleThresholds['athletic']!) {
        return loc.workout_category_athletic;
      }
      if (percentage < femaleThresholds['good']!) {
        return loc.workout_category_good;
      }
      if (percentage < femaleThresholds['acceptable']!) {
        return loc.workout_category_acceptable;
      }

      return loc.workout_category_high;
    }
  }

  String _getHealthCategory(BuildContext context, double score) {
    const thresholds = WorkoutConstants.healthScoreThresholds;
    final loc = AppLocalizations.of(context)!;

    if (score >= thresholds['excellent']!) {
      return loc.workout_category_excellent;
    }
    if (score >= thresholds['good']!) return loc.workout_category_good;
    if (score >= thresholds['regular']!) return loc.workout_category_regular;

    return loc.workout_category_needs_improvement;
  }
}

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

import 'workout_health_categories.dart';

/// Health score / BMI / body-fat bars derived from the raw assessment map.
class WorkoutMetricsList extends StatelessWidget {
  const WorkoutMetricsList({super.key, required this.healthResults});

  final Map<String, dynamic> healthResults;

  /// The assessment map arrives from Firestore, where a value may be a num or
  /// a String depending on how it was written.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    final healthScore = _parseDouble(healthResults['health_score']);
    final bmi = _parseDouble(healthResults['bmi']);
    final bodyFat = _parseDouble(healthResults['body_fat_percentage']);
    final gender = healthResults['gender']?.toString() ?? 'male';

    return Column(
      children: [
        WorkoutMetricBar(
          label: loc.workout_health_score,
          value: '${healthScore.toStringAsFixed(0)} / 100',
          status: WorkoutHealthCategories.healthScore(context, healthScore),
          progress: healthScore / 100,
          activeColor: semantic.success,
        ),
        WorkoutMetricBar(
          label: loc.workout_bmi,
          value: bmi.toStringAsFixed(1),
          status: WorkoutHealthCategories.bmi(context, bmi),
          progress: (bmi - 15) / 25,
          activeColor: semantic.warning,
        ),
        WorkoutMetricBar(
          label: loc.workout_body_fat,
          value: '${bodyFat.toStringAsFixed(1)}%',
          status: WorkoutHealthCategories.bodyFat(context, bodyFat, gender),
          progress: bodyFat / 40,
          activeColor: theme.colorScheme.error,
        ),
      ],
    );
  }
}

/// A single labelled metric: name, value, progress bar and banding label.
class WorkoutMetricBar extends StatelessWidget {
  const WorkoutMetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.status,
    required this.progress,
    required this.activeColor,
  });

  final String label;
  final String value;
  final String status;
  final double progress;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldSmall = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: boldSmall),
              Text(value, style: boldSmall),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

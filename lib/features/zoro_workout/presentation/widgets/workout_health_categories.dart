import 'package:flutter/widgets.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/gender_mapper.dart';

import '../workout_constants.dart';

/// Threshold → localized label mapping for the assessment metrics.
///
/// Pure functions over [WorkoutConstants], kept out of the widgets so the
/// banding rules can be read (and later tested) without building a tree.
abstract final class WorkoutHealthCategories {
  static String bmi(BuildContext context, double bmi) {
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

  static String bodyFat(
    BuildContext context,
    double percentage,
    String gender,
  ) {
    const maleThresholds = WorkoutConstants.bodyFatThresholdsMale;
    const femaleThresholds = WorkoutConstants.bodyFatThresholdsFemale;
    final loc = AppLocalizations.of(context)!;
    final internalGender = GenderMapper.getInternalValue(gender, loc);

    final thresholds = internalGender == GenderMapper.male
        ? maleThresholds
        : femaleThresholds;
    if (percentage < thresholds['very_low']!) {
      return loc.workout_category_very_low;
    }
    if (percentage < thresholds['athletic']!) {
      return loc.workout_category_athletic;
    }
    if (percentage < thresholds['good']!) return loc.workout_category_good;
    if (percentage < thresholds['acceptable']!) {
      return loc.workout_category_acceptable;
    }
    return loc.workout_category_high;
  }

  static String healthScore(BuildContext context, double score) {
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

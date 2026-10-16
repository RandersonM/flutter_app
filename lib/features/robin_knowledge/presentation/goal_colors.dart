import 'package:flutter/material.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

/// Categorical palette: the colour only tells goal categories apart, it carries
/// no status, so it has no theme role. Mid-tones keep icons readable on both
/// the light and the dark surface.
Color goalCategoryColor(GoalCategory category) {
  switch (category) {
    case GoalCategory.study:
      return const Color(0xFF1976D2); // harness:allow categorical
    case GoalCategory.work:
      return const Color(0xFF7C3AED); // harness:allow categorical
    case GoalCategory.personal:
      return const Color(0xFF8D6E63); // harness:allow categorical
    case GoalCategory.health:
      return const Color(0xFFE1140A); // harness:allow categorical
    case GoalCategory.finance:
      return const Color(0xFFFF6D1B); // harness:allow categorical
    case GoalCategory.other:
      return const Color(0xFF888888); // harness:allow categorical
  }
}

Color goalStatusColor(ThemeData theme, GoalStatus status) {
  switch (status) {
    case GoalStatus.completed:
      return theme.semanticColors.success;
    case GoalStatus.inProgress:
      return theme.semanticColors.warning;
    case GoalStatus.overdue:
      return theme.colorScheme.error;
    case GoalStatus.notStarted:
      return theme.colorScheme.onSurfaceVariant;
  }
}

Color goalProgressColor(ThemeData theme, double progress) {
  if (progress >= 75) return theme.semanticColors.success;
  if (progress >= 50) return theme.semanticColors.warning;
  return theme.colorScheme.error;
}

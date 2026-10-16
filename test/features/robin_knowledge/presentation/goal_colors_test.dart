import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/presentation/goal_colors.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/utils/theme.dart';

void main() {
  for (final theme in [getLightTheme(), getDarkTheme()]) {
    group('goal colours (${theme.brightness.name})', () {
      final semantic = theme.semanticColors;
      final colors = theme.colorScheme;

      test('progress bands map to success / warning / error', () {
        expect(goalProgressColor(theme, 100), semantic.success);
        expect(goalProgressColor(theme, 75), semantic.success);
        expect(goalProgressColor(theme, 74), semantic.warning);
        expect(goalProgressColor(theme, 50), semantic.warning);
        expect(goalProgressColor(theme, 49), colors.error);
        expect(goalProgressColor(theme, 0), colors.error);
      });

      test('status maps to its semantic role', () {
        expect(goalStatusColor(theme, GoalStatus.completed), semantic.success);
        expect(goalStatusColor(theme, GoalStatus.inProgress), semantic.warning);
        expect(goalStatusColor(theme, GoalStatus.overdue), colors.error);
        expect(
          goalStatusColor(theme, GoalStatus.notStarted),
          colors.onSurfaceVariant,
        );
      });
    });
  }

  test('every goal category has a distinct colour', () {
    final palette = GoalCategory.values.map(goalCategoryColor).toSet();
    expect(palette, hasLength(GoalCategory.values.length));
  });
}

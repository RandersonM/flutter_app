import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/utils/workout_plan_resolver.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';

import '../../bloc/zoro_workout_bloc.dart';
import '../workout_plan_editor_screen.dart';
import 'workout_next_modal.dart';

/// Today's workout summary card.
///
/// Renders one of two states: a call-to-action to build a plan when none
/// exists, or today's split with a tap-through to [WorkoutNextModal].
class WorkoutNextCard extends StatelessWidget {
  const WorkoutNextCard({super.key, this.currentAssessment});

  final WorkoutAssessmentModel? currentAssessment;

  @override
  Widget build(BuildContext context) {
    final hasPlan = currentAssessment?.workoutPlan?.isNotEmpty ?? false;

    if (!hasPlan) {
      return _CreatePlanCard(currentAssessment: currentAssessment);
    }

    final split = WorkoutPlanResolver.resolveTodaySplit(currentAssessment);
    final isDone = WorkoutPlanResolver.isTodayWorkoutDone(currentAssessment);

    return _TodaySplitCard(
      onTap: () => WorkoutNextModal.show(
        context,
        split: split,
        isDone: isDone,
        currentAssessment: currentAssessment,
      ),
      splitName:
          split?.name ?? AppLocalizations.of(context)!.defaultWorkoutName,
      exerciseNames: split?.exercises.map((e) => e.name).toList() ?? const [],
      isDone: isDone,
    );
  }
}

class _CreatePlanCard extends StatelessWidget {
  const _CreatePlanCard({this.currentAssessment});

  final WorkoutAssessmentModel? currentAssessment;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        final bloc = context.read<ZoroWorkoutBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const WorkoutPlanEditorScreen(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(PhosphorIconsRegular.plus, color: primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.createWorkoutPlan,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.createCustomPlanTap,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            AppIcon(
              PhosphorIconsRegular.caretRight,
              color: primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySplitCard extends StatelessWidget {
  const _TodaySplitCard({
    required this.onTap,
    required this.splitName,
    required this.exerciseNames,
    required this.isDone,
  });

  final VoidCallback onTap;
  final String splitName;
  final List<String> exerciseNames;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final accent = isDone
        ? theme.semanticColors.success
        : theme.colorScheme.primary.withValues(alpha: 0.8);
    final preview = exerciseNames.take(3).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone
                    ? PhosphorIconsRegular.checkCircle
                    : PhosphorIconsRegular.barbell,
                color: accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDone ? loc.todayWorkoutCompleted : loc.todayWorkout,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    splitName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.exerciseCount(exerciseNames.length)} • $preview',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppIcon(
              PhosphorIconsRegular.caretRight,
              color: onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

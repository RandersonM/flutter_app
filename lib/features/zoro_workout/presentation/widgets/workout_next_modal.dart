import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_plan_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';

import '../../bloc/zoro_workout_bloc.dart';
import '../workout_plan_editor_screen.dart';

/// Bottom sheet listing the exercises of today's split.
///
/// Requires a [ZoroWorkoutBloc] above it — [show] forwards the caller's bloc
/// into the sheet, which sits outside the calling widget's tree.
class WorkoutNextModal extends StatelessWidget {
  const WorkoutNextModal({
    super.key,
    required this.split,
    this.isDone = false,
    this.currentAssessment,
  });

  final WorkoutSplitModel? split;
  final bool isDone;
  final WorkoutAssessmentModel? currentAssessment;

  static void show(
    BuildContext context, {
    required WorkoutSplitModel? split,
    required bool isDone,
    WorkoutAssessmentModel? currentAssessment,
  }) {
    final bloc = context.read<ZoroWorkoutBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: WorkoutNextModal(
          split: split,
          isDone: isDone,
          currentAssessment: currentAssessment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const _DragHandle(),
              _ModalHeader(split: split, isDone: isDone),
              const SizedBox(height: 8),
              _StatusChips(split: split, isDone: isDone),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _ExerciseList(
                  exercises: split?.exercises ?? const [],
                  isDone: isDone,
                  scrollController: scrollController,
                ),
              ),
              _ModalActions(
                isDone: isDone,
                currentAssessment: currentAssessment,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.split, required this.isDone});

  final WorkoutSplitModel? split;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = isDone
        ? theme.semanticColors.success
        : theme.colorScheme.primary;
    final exerciseCount = split?.exercises.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone
                  ? PhosphorIconsRegular.checkCircle
                  : PhosphorIconsRegular.barbell,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  split?.name ?? loc.defaultWorkoutName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loc.exerciseCount(exerciseCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isDone ? loc.completedWithCheck : loc.today,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.split, required this.isDone});

  final WorkoutSplitModel? split;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final exerciseCount = split?.exercises.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          WorkoutInfoChip(
            icon: PhosphorIconsRegular.arrowsClockwise,
            label: loc.exerciseCount(exerciseCount),
            accentColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          WorkoutInfoChip(
            icon: isDone
                ? PhosphorIconsRegular.check
                : PhosphorIconsRegular.circle,
            label: isDone ? loc.doneTodayLabel : loc.pendingLabel,
            accentColor: isDone
                ? theme.semanticColors.success
                : theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.exercises,
    required this.isDone,
    required this.scrollController,
  });

  final List<WorkoutExerciseModel> exercises;
  final bool isDone;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (exercises.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noExercisesInSplit,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) =>
          _ExerciseRow(exercise: exercises[i], position: i + 1, isDone: isDone),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.position,
    required this.isDone,
  });

  final WorkoutExerciseModel exercise;
  final int position;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Icon(
          isDone
              ? PhosphorIconsRegular.checkCircle
              : PhosphorIconsRegular.circle,
          color: isDone
              ? theme.semanticColors.success
              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          size: 20,
        ),
        const SizedBox(width: 10),
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$position',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            exercise.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : null,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            exercise.volume,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModalActions extends StatelessWidget {
  const _ModalActions({required this.isDone, this.currentAssessment});

  final bool isDone;
  final WorkoutAssessmentModel? currentAssessment;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () {
                final bloc = context.read<ZoroWorkoutBloc>();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: WorkoutPlanEditorScreen(
                        existingPlan: currentAssessment?.workoutPlan,
                      ),
                    ),
                  ),
                );
              },
              variant: AppButtonVariant.outline,
              icon: const AppIcon(PhosphorIconsRegular.pencilSimple, size: 16),
              label: loc.editPlan,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              onPressed: () => Navigator.pop(context),
              label: isDone ? loc.viewProgress : loc.startWorkout,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill showing an icon + label, used for the modal's status row.
class WorkoutInfoChip extends StatelessWidget {
  const WorkoutInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

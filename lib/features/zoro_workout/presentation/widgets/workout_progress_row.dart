import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

/// Week-progress bar next to the monthly streak counter.
///
/// Both cards read the same `workout_days` list, so they share one widget
/// rather than each re-deriving the day math.
class WorkoutProgressRow extends StatelessWidget {
  const WorkoutProgressRow({
    super.key,
    required this.workoutDays,
    required this.weeklyGoal,
  });

  /// Day-of-month numbers the user logged a workout on.
  final List<int> workoutDays;
  final int weeklyGoal;

  /// Workouts logged since Monday of the current week.
  int get _weekWorkouts {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfToday = now.add(const Duration(days: 1));

    var count = 0;
    for (var i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (day.isBefore(endOfToday) && workoutDays.contains(day.day)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: _WeekProgressCard(
              weekWorkouts: _weekWorkouts,
              goal: weeklyGoal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: _StreakCard(monthStreak: workoutDays.length),
          ),
        ],
      ),
    );
  }
}

class _WeekProgressCard extends StatelessWidget {
  const _WeekProgressCard({required this.weekWorkouts, required this.goal});

  final int weekWorkouts;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? (weekWorkouts / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.weekProgressTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                )!.zoroWeekProgressCount(weekWorkouts, goal),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.monthStreak});

  final int monthStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakColor = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: streakColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.streakTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.thisMonthSuffix,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '$monthStreak',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.daysSuffix,
            style: theme.textTheme.bodySmall?.copyWith(
              color: streakColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

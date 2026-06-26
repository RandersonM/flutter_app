import 'package:flutter/material.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_assessment_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

class WorkoutHeader extends StatelessWidget {
  final WorkoutAssessmentModel? currentAssessment;

  const WorkoutHeader({
    super.key,
    this.currentAssessment,
  });

  @override
  Widget build(BuildContext context) {
    // Estado sem avaliação — GIF simples
    if (currentAssessment == null ||
        currentAssessment!.workoutDaysGoal == null) {
      return _buildGifOnly(context, defeated: false);
    }

    final stats = _getWorkoutStats();
    final isDefeated = stats['workouts'] < stats['goal'];

    return Column(
      children: [
        _buildGifWithBadge(context, isDefeated: isDefeated),
        const SizedBox(height: 16),
        _buildStatusCard(context, isDefeated: isDefeated, stats: stats),
      ],
    );
  }

  // ---------- GIF sem avaliação ----------
  Widget _buildGifOnly(BuildContext context, {required bool defeated}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Image.asset(
          'assets/logo/zoro-workout.gif',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ---------- GIF com badge de status sobreposto ----------
  Widget _buildGifWithBadge(BuildContext context, {required bool isDefeated}) {
    final statusColor = isDefeated
        ? Theme.of(context).colorScheme.error
        : Colors.green.shade500;
    final statusLabel = isDefeated
        ? AppLocalizations.of(context)!.workoutStatusDefeated
        : AppLocalizations.of(context)!.workoutStatusOnTarget;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.asset(
              isDefeated
                  ? 'assets/logo/zoro-defetead.gif'
                  : 'assets/logo/zoro-workout.gif',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradiente inferior para dar profundidade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        // Badge de status no canto superior direito
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Card de status redesenhado ----------
  Widget _buildStatusCard(
    BuildContext context, {
    required bool isDefeated,
    required Map<String, dynamic> stats,
  }) {
    final int workouts = stats['workouts'] as int;
    final int goal = stats['goal'] as int;
    final int remaining = goal - workouts;

    final cardColor = isDefeated
        ? Theme.of(context).colorScheme.onErrorContainer.withValues(alpha: 0.6)
        : Colors.green.shade900.withValues(alpha: 0.25);

    final borderColor = isDefeated
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.4)
        : Colors.green.shade600.withValues(alpha: 0.5);

    final accentColor = isDefeated
        ? Theme.of(context).colorScheme.error
        : Colors.green.shade400;

    final quoteText = isDefeated
        ? AppLocalizations.of(context)!.zoroQuoteDefeated
        : AppLocalizations.of(context)!.zoroQuoteProud;

    final titleText = isDefeated
        ? AppLocalizations.of(context)!.zoroStatusDefeated
        : AppLocalizations.of(context)!.zoroStatusProud;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
          ),

          const SizedBox(height: 10),
          // Citação em itálico
          Text(
            quoteText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accentColor,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDefeated
                          ? AppLocalizations.of(context)!
                              .workoutsRemaining(remaining)
                          : AppLocalizations.of(context)!.weeklyGoalCompleted,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: goal > 0 ? (workouts / goal).clamp(0.0, 1.0) : 0.0,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!
                          .workoutDaysCount(workouts, goal),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Cálculo de dias da semana ----------
  Map<String, dynamic> _getWorkoutStats() {
    final int goal = currentAssessment!.workoutDaysGoal ?? 0;
    final List<int> workoutDays = currentAssessment!.workoutDays ?? [];

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int workoutsThisWeek = 0;

    if (now.month == currentAssessment!.createdAt.month &&
        now.year == currentAssessment!.createdAt.year) {
      for (int i = 0; i < 7; i++) {
        final weekDay = startOfWeek.add(Duration(days: i));
        if (weekDay.isBefore(now.add(const Duration(days: 1))) &&
            workoutDays.contains(weekDay.day)) {
          workoutsThisWeek++;
        }
      }
    }

    return {
      'workouts': workoutsThisWeek,
      'goal': goal,
    };
  }
}

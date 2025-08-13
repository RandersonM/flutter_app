import 'package:flutter/material.dart';
import 'package:opfan/core/models/workout_assessment_model.dart';

class WorkoutHeader extends StatelessWidget {
  final WorkoutAssessmentModel? currentAssessment;
  
  const WorkoutHeader({
    super.key,
    this.currentAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowDefeatedImage = _shouldShowDefeatedImage();
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          height: 250,
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            shouldShowDefeatedImage 
              ? 'assets/logo/zoro-defetead.gif'
              : 'assets/logo/zoro-workout.gif',
            fit: BoxFit.fill,
          ),
        ),
        if (shouldShowDefeatedImage) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.error),
            ),
            child: Column(
              children: [
                Text(
                  'Zoro está derrotado...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mas lembre-se: "Eu nunca vou perder novamente. Tem alguma coisa que eu quero proteger!" - Roronoa Zoro\n\n'
                  'Com treino e determinação, você pode superar qualquer obstáculo e se tornar a melhor versão de você mesmo!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowDefeatedImage() {
    if (currentAssessment == null ||
        currentAssessment!.workoutDaysGoal == null) {
      return false;
    }
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int workoutDaysThisWeek = 0;
    
    if (now.month == currentAssessment!.createdAt.month && 
        now.year == currentAssessment!.createdAt.year) {
      
      for (int i = 0; i < 7; i++) {
        final weekDay = startOfWeek.add(Duration(days: i));
        if (weekDay.isBefore(now.add(const Duration(days: 1))) &&
            currentAssessment!.workoutDays != null &&
            currentAssessment!.workoutDays!.contains(weekDay.day)) {
          workoutDaysThisWeek++;
        }
      }
    }
    
    return workoutDaysThisWeek < currentAssessment!.workoutDaysGoal!;
  }
}

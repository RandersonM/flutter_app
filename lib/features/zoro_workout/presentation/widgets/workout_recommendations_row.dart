import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../all_recommendations_screen.dart';

/// Horizontally scrolling preview of the top recommended exercises.
class WorkoutRecommendationsRow extends StatelessWidget {
  const WorkoutRecommendationsRow({
    super.key,
    required this.exercises,
    this.maxVisible = 3,
  });

  final List<Map<String, dynamic>> exercises;

  /// Only a preview is shown inline; the rest live behind "see all".
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visibleCount = exercises.length > maxVisible
        ? maxVisible
        : exercises.length;

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleCount,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _RecommendationCard(
          exercise: exercises[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AllRecommendationsScreen(exercises: exercises),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.exercise, required this.onTap});

  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                exercise['icon'] as IconData? ?? PhosphorIconsRegular.barbell,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              exercise['name'] as String? ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

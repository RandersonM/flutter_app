import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/features/robin_knowledge/presentation/goal_details_screen.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildProgressSection(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildCategoryIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        _buildStatusIcon(context),
      ],
    );
  }

  Widget _buildCategoryIcon() {
    final iconData = _getCategoryIcon(goal.category);
    final color = _getCategoryColor(goal.category);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (goal.status) {
      case GoalStatus.completed:
        iconData = PhosphorIconsRegular.checkCircle;
        color = AppColors.purple[350]!;
        break;
      case GoalStatus.inProgress:
        iconData = PhosphorIconsRegular.clock;
        color = Theme.of(context).semanticColors.warning;
        break;
      case GoalStatus.overdue:
        iconData = PhosphorIconsRegular.warning;
        color = Theme.of(context).colorScheme.error;
        break;
      default:
        iconData = PhosphorIconsRegular.circle;
        color = Colors.grey;
    }

    return Icon(iconData, color: color, size: 20);
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.progress,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '${goal.progress.toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.purple[350],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: goal.progress / 100,
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(12),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(goal.progress),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDeadlineInfo(context), _buildActions(context)],
    );
  }

  Widget _buildDeadlineInfo(BuildContext context) {
    final daysUntilDeadline = goal.daysUntilDeadline;
    final isOverdue = goal.isOverdue;

    String deadlineText;
    Color textColor;

    if (isOverdue) {
      deadlineText = AppLocalizations.of(
        context,
      )!.overdueDays(daysUntilDeadline.abs());
      textColor = Theme.of(context).colorScheme.error;
    } else if (daysUntilDeadline == 0) {
      deadlineText = AppLocalizations.of(context)!.dueToday;
      textColor = Theme.of(context).semanticColors.warning;
    } else if (daysUntilDeadline < 0) {
      deadlineText = AppLocalizations.of(
        context,
      )!.dueDaysAgo(daysUntilDeadline.abs());
      textColor = Theme.of(context).colorScheme.error;
    } else {
      deadlineText = AppLocalizations.of(context)!.dueInDays(daysUntilDeadline);
      textColor = daysUntilDeadline <= 3
          ? Theme.of(context).semanticColors.warning
          : Colors.grey[600]!;
    }

    return Row(
      children: [
        AppIcon(PhosphorIconsRegular.calendar, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          deadlineText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const AppIcon(PhosphorIconsRegular.trash, size: 16),
          onPressed: () => _deleteGoal(context),
          tooltip: AppLocalizations.of(context)!.delete,
        ),
      ],
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.study:
        return PhosphorIconsRegular.book;
      case GoalCategory.work:
        return PhosphorIconsRegular.briefcase;
      case GoalCategory.personal:
        return PhosphorIconsRegular.user;
      case GoalCategory.health:
        return PhosphorIconsRegular.heart;
      case GoalCategory.finance:
        return PhosphorIconsRegular.coins;
      case GoalCategory.other:
        return PhosphorIconsRegular.star;
    }
  }

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.study:
        return AppColors.blue;
      case GoalCategory.work:
        return AppColors.purple;
      case GoalCategory.personal:
        return AppColors.brown[500]!;
      case GoalCategory.health:
        return AppColors.red;
      case GoalCategory.finance:
        return AppColors.orange;
      case GoalCategory.other:
        return AppColors.grey;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppColors.purple[350]!;
    if (progress >= 75) return AppColors.yellow[500]!;
    if (progress >= 50) return AppColors.orange[500]!;
    if (progress >= 25) return AppColors.red[500]!;
    return AppColors.purple[350]!;
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RobinKnowledgeBloc>(),
          child: GoalDetailsScreen(goal: goal),
        ),
      ),
    );
  }

  void _deleteGoal(BuildContext context) {
    final bloc = context.read<RobinKnowledgeBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteObjective),
        content: Text(
          AppLocalizations.of(context)!.deleteObjectiveConfirmation(goal.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteGoal(goal.id));
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

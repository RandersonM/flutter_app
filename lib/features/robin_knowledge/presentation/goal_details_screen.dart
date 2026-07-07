import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/features/robin_knowledge/presentation/widgets/update_progress_dialog.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/l10n/app_localizations.dart';

class GoalDetailsScreen extends StatelessWidget {
  final GoalModel goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text(goal.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildProgressSection(context),
            const SizedBox(height: 24),
            _buildDetailsSection(context),
            if (goal.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              _buildNotesSection(context),
            ],
            if (goal.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildTagsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCategoryIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(context),
                    ],
                  ),
                ),
              ],
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final iconData = _getCategoryIcon(goal.category);
    final color = _getCategoryColor(goal.category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    String label;
    Color color;

    switch (goal.status) {
      case GoalStatus.completed:
        label = AppLocalizations.of(context)!.completed;
        color = AppColors.purple[350]!;
        break;
      case GoalStatus.inProgress:
        label = AppLocalizations.of(context)!.inProgress;
        color = AppColors.orange;
        break;
      case GoalStatus.overdue:
        label = AppLocalizations.of(context)!.overdue;
        color = AppColors.red;
        break;
      default:
        label = AppLocalizations.of(context)!.notStarted;
        color = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.progress,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${goal.progress.toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress / 100,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(12),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(goal.progress),
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressButton(context, 5),
                _buildProgressButton(context, 10),
                _buildProgressButton(context, 25),
                _buildProgressButton(context, 50),
                _buildProgressButton(context, 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressButton(BuildContext context, int increment) {
    final newProgress = (goal.progress + increment).clamp(0.0, 100.0);
    final isDisabled = newProgress == goal.progress;

    return ElevatedButton(
      onPressed: isDisabled
          ? null
          : () => _showUpdateProgressDialog(context, increment),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(60, 36),
      ),
      child: Text(
        increment > 0 ? '+$increment%' : '$increment%',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, int increment) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          UpdateProgressDialog(goal: goal, increment: increment),
    );

    if (result != null) {
      final newProgress = result['progress'] as double;
      final notes = result['notes'] as String;

      getIt.robinKnowledgeBloc.add(
        UpdateGoalProgress(goal.id, newProgress, notes: notes),
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildDetailsSection(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.details,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              PhosphorIconsRegular.calendar,
              AppLocalizations.of(context)!.creationDate,
              dateFormat.format(goal.createdAt),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              PhosphorIconsRegular.clock,
              AppLocalizations.of(context)!.deadline,
              dateFormat.format(goal.deadline),
              isOverdue: goal.isOverdue,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              PhosphorIconsRegular.tag,
              AppLocalizations.of(context)!.category,
              _getCategoryName(context, goal.category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isOverdue ? Colors.red : Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isOverdue ? Colors.red : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.note,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.notes,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(goal.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.tag,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.tags,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goal.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
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
        return AppColors.yellow;
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

  String _getCategoryName(BuildContext context, GoalCategory category) {
    switch (category) {
      case GoalCategory.study:
        return AppLocalizations.of(context)!.study;
      case GoalCategory.work:
        return AppLocalizations.of(context)!.work;
      case GoalCategory.personal:
        return AppLocalizations.of(context)!.personal;
      case GoalCategory.health:
        return AppLocalizations.of(context)!.health;
      case GoalCategory.finance:
        return AppLocalizations.of(context)!.finance;
      case GoalCategory.other:
        return AppLocalizations.of(context)!.other;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppColors.purple[350]!;
    if (progress >= 75) return AppColors.yellow[500]!;
    if (progress >= 50) return AppColors.orange[500]!;
    if (progress >= 25) return AppColors.red[500]!;
    return Colors.red;
  }
}

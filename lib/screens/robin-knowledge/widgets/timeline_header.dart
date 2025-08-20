import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:opfan/core/models/goal_model.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/robin-knowledge/blocs/robin_knowledge_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';


class TimelineHeader extends StatelessWidget {
  const TimelineHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobinKnowledgeBloc, RobinKnowledgeState>(
      bloc: getIt.robinKnowledgeBloc,
      builder: (context, state) {
        if (state is RobinKnowledgeLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatsRow(context, state.goals),
                const SizedBox(height: 16),
                _buildFilterChips(context),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, List<GoalModel> goals) {
    final completed = goals.where((g) => g.isCompleted).length;
    final inProgress = goals.where((g) => g.status == GoalStatus.inProgress).length;
    final overdue = goals.where((g) => g.isOverdue).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          context,
          AppLocalizations.of(context)!.completed,
          completed.toString(),
          FontAwesomeIcons.circleCheck,
          Colors.green,
        ),
        _buildStatCard(
          context,
          AppLocalizations.of(context)!.inProgress,
          inProgress.toString(),
          FontAwesomeIcons.clock,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          AppLocalizations.of(context)!.overdue,
          overdue.toString(),
          FontAwesomeIcons.triangleExclamation,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(context, AppLocalizations.of(context)!.all, null),
          _buildFilterChip(context, AppLocalizations.of(context)!.study, GoalCategory.study),
          _buildFilterChip(context, AppLocalizations.of(context)!.work, GoalCategory.work),
          _buildFilterChip(context, AppLocalizations.of(context)!.personal, GoalCategory.personal),
          _buildFilterChip(context, AppLocalizations.of(context)!.health, GoalCategory.health),
          _buildFilterChip(context, AppLocalizations.of(context)!.finance, GoalCategory.finance),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, GoalCategory? category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false, // TODO: Implementar filtro
        onSelected: (selected) {
          // TODO: Implementar filtro
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
    );
  }
}

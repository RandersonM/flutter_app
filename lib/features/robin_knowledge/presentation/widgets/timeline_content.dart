import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/robin_knowledge/data/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';

import 'package:opfan/shared/utils/constants.dart';

import 'goal_card.dart';
import 'empty_timeline.dart';

class TimelineContent extends StatelessWidget {
  const TimelineContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobinKnowledgeBloc, RobinKnowledgeState>(
      bloc: getIt.robinKnowledgeBloc,
      builder: (context, state) {
        if (state is RobinKnowledgeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RobinKnowledgeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  PhosphorIconsRegular.warning,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: Constants.margin * 2),
                Text(
                  'Erro ao carregar objetivos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Constants.margin),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is RobinKnowledgeLoaded) {
          if (state.goals.isEmpty) {
            return const EmptyTimeline();
          }

          return _buildTimelineList(context, state.goals);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimelineList(BuildContext context, List<GoalModel> goals) {
    final sortedGoals = List<GoalModel>.from(goals)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.all(Constants.margin * 2),
      itemCount: sortedGoals.length,
      itemBuilder: (context, index) {
        final goal = sortedGoals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: Constants.margin * 2),
          child: GoalCard(goal: goal),
        );
      },
    );
  }
}

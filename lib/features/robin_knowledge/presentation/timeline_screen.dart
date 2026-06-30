import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'widgets/timeline_header.dart';
import 'widgets/timeline_content.dart';
import 'widgets/add_goal_dialog.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt.robinKnowledgeBloc.add(const LoadGoals());
    });

    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.timelineOfObjectives),
        actions: [
          IconButton(
            icon: const AppIcon(PhosphorIconsRegular.plus),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Column(
          children: [
            TimelineHeader(),
            Expanded(
              child: TimelineContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final robinKnowledgeBloc = getIt.robinKnowledgeBloc;
    showDialog(
      context: context,
      builder: (context) =>
          AddGoalDialog(robinKnowledgeBloc: robinKnowledgeBloc),
    );
  }
}

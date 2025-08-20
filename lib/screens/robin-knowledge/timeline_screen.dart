import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/robin-knowledge/blocs/robin_knowledge_bloc.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
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
            icon: const Icon(FontAwesomeIcons.plus),
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
      builder: (context) => AddGoalDialog(robinKnowledgeBloc: robinKnowledgeBloc),
    );
  }
}

import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/robin_knowledge/bloc/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'add_goal_dialog.dart';

class EmptyTimeline extends StatelessWidget {
  const EmptyTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                PhosphorIconsRegular.target,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noObjectivesCreated,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.emptyTimelineSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final robinKnowledgeBloc = context.read<RobinKnowledgeBloc>();
                showDialog(
                  context: context,
                  builder: (context) =>
                      AddGoalDialog(robinKnowledgeBloc: robinKnowledgeBloc),
                );
              },
              icon: const AppIcon(PhosphorIconsRegular.plus),
              label: Text(AppLocalizations.of(context)!.createFirstGoal),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

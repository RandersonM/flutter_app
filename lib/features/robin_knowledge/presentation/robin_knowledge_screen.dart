import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/shared/widgets/organisms/offline_blocker_overlay.dart';

import 'widgets/index.dart';
import 'timeline_screen.dart';

class RobinKnowledgeScreen extends StatelessWidget {
  const RobinKnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt.robinKnowledgeBloc.add(const LoadGoals());
    });

    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.knowledgeTitleScreen),
      ),
      body: BlocProvider.value(
        value: getIt<ConnectivityCubit>(),
        child: OfflineBlockerOverlay(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const RobinKnowledgeHeader(),
                const SizedBox(height: 24),
                _buildTimelineSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.timelineOfObjectives,
                  maxLines: 2,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimelineScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.purple[350],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const AppIcon(PhosphorIconsRegular.arrowRight),
                  label: Text(AppLocalizations.of(context)!.seeAll),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<RobinKnowledgeBloc, RobinKnowledgeState>(
            bloc: getIt.robinKnowledgeBloc,
            builder: (context, state) {
              if (state is RobinKnowledgeLoading) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (state is RobinKnowledgeLoaded) {
                if (state.goals.isEmpty) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.purple[350]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIcon(
                            PhosphorIconsRegular.chartLine,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.noObjectivesCreated,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.startCreatingFirstObjective,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final recentGoals = state.goals.take(3).toList();
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Constants.margin * 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recentObjectives,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.goals.length} ${AppLocalizations.of(context)!.total}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentGoals.length,
                          itemBuilder: (context, index) {
                            final goal = recentGoals[index];
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              margin: const EdgeInsets.only(
                                right: Constants.margin * 2,
                              ),
                              child: GoalCard(goal: goal),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is RobinKnowledgeError) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          PhosphorIconsRegular.warningCircle,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingObjectives,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Estado inicial
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon(
                        PhosphorIconsRegular.chartLine,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.timelineOfObjectives,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.organizeStudyGoals,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

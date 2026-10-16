import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';

String robinKnowledgeFailureMessage(
  AppLocalizations l10n,
  RobinKnowledgeFailure failure,
) => switch (failure) {
  RobinKnowledgeFailure.loadFailed => l10n.robinLoadGoalsError,
  RobinKnowledgeFailure.createFailed => l10n.robinCreateGoalError,
  RobinKnowledgeFailure.updateFailed => l10n.robinUpdateGoalError,
  RobinKnowledgeFailure.deleteFailed => l10n.robinDeleteGoalError,
  RobinKnowledgeFailure.progressUpdateFailed => l10n.robinUpdateProgressError,
};

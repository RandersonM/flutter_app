import 'package:opfan/features/zoro_workout/bloc/zoro_workout_state.dart';
import 'package:opfan/l10n/app_localizations.dart';

String zoroWorkoutFailureMessage(
  AppLocalizations l10n,
  ZoroWorkoutFailure failure,
) => switch (failure) {
  ZoroWorkoutFailure.loadFailed => l10n.zoroWorkoutLoadError,
  ZoroWorkoutFailure.saveAssessmentFailed =>
    l10n.zoroWorkoutSaveAssessmentError,
  ZoroWorkoutFailure.refreshFailed => l10n.zoroWorkoutRefreshError,
  ZoroWorkoutFailure.noAssessmentFound => l10n.noAssessmentFound,
  ZoroWorkoutFailure.updateDaysFailed => l10n.zoroWorkoutUpdateDaysError,
  ZoroWorkoutFailure.savePlanFailed => l10n.zoroWorkoutSavePlanError,
};

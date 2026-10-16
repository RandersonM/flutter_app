import 'package:opfan/features/sanji_cooking/bloc/sanji_cooking_state.dart';
import 'package:opfan/l10n/app_localizations.dart';

String sanjiCookingFailureMessage(
  AppLocalizations l10n,
  SanjiCookingFailure failure,
) => switch (failure) {
  SanjiCookingFailure.loadFailed => l10n.sanjiCookingLoadError,
  SanjiCookingFailure.calculationFailed => l10n.sanjiCookingCalculationError,
  SanjiCookingFailure.saveFailed => l10n.sanjiCookingSaveError,
  SanjiCookingFailure.noIngredients => l10n.sanjiCookingNoIngredients,
  SanjiCookingFailure.tipsFailed => l10n.sanjiCookingTipsError,
  SanjiCookingFailure.mealFailed => l10n.sanjiCookingMealError,
};

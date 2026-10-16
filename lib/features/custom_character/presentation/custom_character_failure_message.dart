import 'package:opfan/features/custom_character/bloc/custom_character_state.dart';
import 'package:opfan/l10n/app_localizations.dart';

String customCharacterFailureMessage(
  AppLocalizations l10n,
  CustomCharacterFailure failure,
) => switch (failure) {
  CustomCharacterFailure.loadFailed => l10n.customCharacterLoadError,
  CustomCharacterFailure.createFailed => l10n.customCharacterCreateError,
  CustomCharacterFailure.updateFailed => l10n.customCharacterUpdateError,
  CustomCharacterFailure.deleteFailed => l10n.customCharacterDeleteError,
  CustomCharacterFailure.listRefreshFailed =>
    l10n.customCharacterListRefreshError,
};

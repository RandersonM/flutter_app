import 'package:opfan/core/services/config/i_locale_service.dart';

/// Single source of truth for which language an AI prompt is built in.
class PromptLocale {
  const PromptLocale._();

  static bool isPortuguese(ILocaleService localeService) =>
      localeService.languageCode == 'pt';
}

import 'dart:ui' as ui;

import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/index.dart';

/// Single source of truth for resolving which language an AI prompt should
/// be built in. Falls back to the device locale when [ILocaleService] has no
/// explicit override — mirrors how the app itself decides its UI language.
class PromptLocale {
  const PromptLocale._();

  static bool isPortuguese() {
    final lang = GetIt.I.get<ILocaleService>().locale?.languageCode;
    return (lang ?? ui.PlatformDispatcher.instance.locale.languageCode) ==
        'pt';
  }
}

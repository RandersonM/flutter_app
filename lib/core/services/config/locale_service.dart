import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'i_locale_service.dart';

class LocaleService implements ILocaleService {
  static const _boxName = 'settings';
  static const _localeKey = 'app_locale';
  Locale? _locale;

  @override
  Future<void> loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final code = box.get(_localeKey);
    if (code != null) {
      _locale = Locale(code);
    }
  }

  @override
  Locale? get locale => _locale;

  @override
  Future<void> persistLocale(Locale locale) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
    _locale = locale;
  }
}

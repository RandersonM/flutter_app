import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleService {
  static const _boxName = 'settings';
  static const _localeKey = 'app_locale';
  static Locale? _locale;

  static Future<void> loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final code = box.get(_localeKey);
    if (code != null) {
      _locale = Locale(code);
    }
  }

  static Locale? get locale => _locale;

  static Future<void> persistLocale(Locale locale) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
    _locale = locale;
  }
}

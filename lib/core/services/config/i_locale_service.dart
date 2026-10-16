import 'package:flutter/material.dart';

abstract class ILocaleService {
  Future<void> loadLocale();

  /// The language the user picked, or null to follow the device.
  Locale? get locale;

  /// The language non-UI text (AI prompts) should use: [locale] when set,
  /// otherwise the device language.
  String get languageCode;

  Future<void> persistLocale(Locale locale);
}

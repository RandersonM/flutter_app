import 'package:flutter/material.dart';

abstract class ILocaleService {
  Future<void> loadLocale();

  Locale? get locale;

  Future<void> persistLocale(Locale locale);
}

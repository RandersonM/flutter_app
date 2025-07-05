// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';

class ZodiacIcons {
  static String? getZodiacIconPath(String? zodiacSign) {
    if (zodiacSign == null || zodiacSign.isEmpty) {
      return null;
    }

    String sign = zodiacSign.toLowerCase().trim();

    switch (sign) {
      case 'aries':
        return 'assets/svg/zodiac-aries.svg';
      case 'taurus':
        return 'assets/svg/zodiac-taurus.svg';
      case 'gemini':
        return 'assets/svg/zodiac-gemini.svg';
      case 'cancer':
        return 'assets/svg/zodiac-cancer.svg';
      case 'leo':
        return 'assets/svg/zodiac-leo.svg';
      case 'virgo':
        return 'assets/svg/zodiac-virgo.svg';
      case 'libra':
        return 'assets/svg/zodiac-libra.svg';
      case 'scorpio':
        return 'assets/svg/zodiac-scorpio.svg';
      case 'sagittarius':
        return 'assets/svg/zodiac-sagittarius.svg';
      case 'capricorn':
        return 'assets/svg/zodiac-capricorn.svg';
      case 'aquarius':
        return 'assets/svg/zodiac-aquarius.svg';
      case 'pisces':
        return 'assets/svg/zodiac-pisces.svg';
      default:
        return null;
    }
  }

  static List<String> getAllZodiacSigns() {
    return [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces',
    ];
  }

  static String getZodiacTranslationKey(String? zodiacSign) {
    if (zodiacSign == null || zodiacSign.isEmpty) {
      return 'unknown';
    }

    String sign = zodiacSign.toLowerCase().trim();

    switch (sign) {
      case 'aries':
        return 'ariesSign';
      case 'taurus':
        return 'taurusSign';
      case 'gemini':
        return 'geminiSign';
      case 'cancer':
        return 'cancerSign';
      case 'leo':
        return 'leoSign';
      case 'virgo':
        return 'virgoSign';
      case 'libra':
        return 'libraSign';
      case 'scorpio':
        return 'scorpioSign';
      case 'sagittarius':
        return 'sagittariusSign';
      case 'capricorn':
        return 'capricornSign';
      case 'aquarius':
        return 'aquariusSign';
      case 'pisces':
        return 'piscesSign';
      default:
        return 'unknown';
    }
  }

  /// Returns the localized name of the zodiac sign
  ///
  /// [context] - The build context to access localizations
  /// [zodiacSign] - The zodiac sign name (e.g., 'aries', 'taurus', etc.)
  /// Returns the localized name of the zodiac sign or 'Unknown' if not found
  static String getLocalizedZodiacSign(
      BuildContext context, String? zodiacSign) {
    if (zodiacSign == null || zodiacSign.isEmpty) {
      return AppLocalizations.of(context)!.unknown;
    }

    final translationKey = getZodiacTranslationKey(zodiacSign);

    switch (translationKey) {
      case 'ariesSign':
        return AppLocalizations.of(context)!.ariesSign;
      case 'taurusSign':
        return AppLocalizations.of(context)!.taurusSign;
      case 'geminiSign':
        return AppLocalizations.of(context)!.geminiSign;
      case 'cancerSign':
        return AppLocalizations.of(context)!.cancerSign;
      case 'leoSign':
        return AppLocalizations.of(context)!.leoSign;
      case 'virgoSign':
        return AppLocalizations.of(context)!.virgoSign;
      case 'libraSign':
        return AppLocalizations.of(context)!.libraSign;
      case 'scorpioSign':
        return AppLocalizations.of(context)!.scorpioSign;
      case 'sagittariusSign':
        return AppLocalizations.of(context)!.sagittariusSign;
      case 'capricornSign':
        return AppLocalizations.of(context)!.capricornSign;
      case 'aquariusSign':
        return AppLocalizations.of(context)!.aquariusSign;
      case 'piscesSign':
        return AppLocalizations.of(context)!.piscesSign;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  static String? getZodiacSignFromDate(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      return 'pisces';
    }

    return null;
  }

  static DateTime? parseDateFromString(String dateString) {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        if (year >= 1900 &&
            year <= 2100 &&
            month >= 1 &&
            month <= 12 &&
            day >= 1 &&
            day <= 31) {
          return DateTime(year, month, day);
        }
      }
    
    return null;
  }

  static int? calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age >= 0 ? age : null;
  }
}

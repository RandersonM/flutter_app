// Developed by Randerson Mayllon
// Copyright © 2022.

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
}

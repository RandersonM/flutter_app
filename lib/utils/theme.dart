// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/utils/constants.dart';

class IconSize {
  static const double standard = 16.0;
  static const double small = 24.0;
  static const double medium = 32.0;
  static const double medium2 = 40.0;
}

class AppColors {
  static const int _greenPrimaryValue = 0xFF6AC346;
  static const MaterialColor green = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      300: Color(0xFFA2D98B),
      500: Color(_greenPrimaryValue),
      700: Color(0xFF498D2E),
    },
  );

  static const int _greyPrimaryValue = 0xFF888888;
  static const MaterialColor grey =
      MaterialColor(_greyPrimaryValue, <int, Color>{
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFCCCCCC),
    400: Color(0xFFBDBDBD),
    500: Color(_greyPrimaryValue), // Default color used
    700: Color(0xFF666666),
    800: Color(0xFF424242),
    900: Color(0xFF222222),
  });

  static const int _redPrimaryValue = 0xFFE1140A;
  static const MaterialColor red = MaterialColor(_redPrimaryValue, <int, Color>{
    100: Color(0xFFFDEAEE),
    500: Color(_redPrimaryValue),
    600: Color(0xFFC62828),
    700: Color(0xFFB71C1C),
    800: Color(0xFFB00020),
    900: Color(0xFF7F0000),
  });

  static const int _purplePrimaryValue = 0xFF800080;
  static const MaterialColor purple =
      MaterialColor(_purplePrimaryValue, <int, Color>{
    50: Color(0xFFECD8E9),
    100: Color(0xFFD8B1D4),
    200: Color(0xFFC38BBF),
    300: Color(0xFFAD66A9),
    400: Color(0xFF973E95),
    500: Color(_purplePrimaryValue),
    600: Color(0xFF6A0C6A),
    700: Color(0xFF551054),
    800: Color(0xFF411140),
    900: Color(0xFF2D102C),
  });

  static const int _bluePrimaryValue = 0xFF1976D2;

  static const MaterialColor blue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(_bluePrimaryValue), // Base
      600: Color(0xFF1565C0),
      700: Color(0xFF0D47A1),
      800: Color(0xFF0B3C91),
      900: Color(0xFF082D72),
      // Variação azul-esverdeado tipo cyan/light blue
      1000: Color(0xFF00B0FF),
    },
  );

  static const int _brownPrimaryValue = 0xFF795548;

  static const MaterialColor brown = MaterialColor(
    _brownPrimaryValue,
    <int, Color>{
      50: Color(0xFFEFEBE9),
      100: Color(0xFFD7CCC8),
      200: Color(0xFFBCAAA4),
      300: Color(0xFFA1887F),
      400: Color(0xFF8D6E63),
      500: Color(_brownPrimaryValue), // Base
      600: Color(0xFF6D4C41),
      700: Color(0xFF5D4037),
      800: Color(0xFF4E342E),
      900: Color(0xFF3E2723),
    },
  );

  static const int _gradientPurplePrimaryValue = 0xFFFF0099;
  static const MaterialColor gradientPurple =
      MaterialColor(_gradientPurplePrimaryValue, <int, Color>{
    200: Color(0xFFF953C6),
    500: Color(_gradientPurplePrimaryValue),
    800: Color(0xFF493240)
  });

  static const int _orangePrimaryValue = 0xFFFF6D1B;

  static const MaterialColor orange = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF3E5),
      100: Color(0xFFFFE0CC),
      200: Color(0xFFFFC2A3),
      300: Color(0xFFFFA47A),
      400: Color(0xFFFF8752),
      500: Color(_orangePrimaryValue), // Base
      600: Color(0xFFE65F18),
      700: Color(0xFFCC5315),
      800: Color(0xFFB34712),
      900: Color(0xFF8F3D00),
      // Variação amber-like
      1000: Color(0xFFFFC107), // semelhante ao amber[500]
    },
  );

}

class _Typography {
  // Legacy names for compatibility
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 96.0,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 60.0,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 48.0,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 34.0,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 24.0,
  );

  static const TextStyle headline6 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
    fontSize: 20.0,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
    fontSize: 10.0,
  );

  // New Flutter 3 text style names
  static const TextStyle headlineLarge = headline4;
  static const TextStyle headlineSmall = headline6;
  static const TextStyle titleMedium = subtitle1;
  static const TextStyle bodyMedium = bodyText2;
  static const TextStyle labelLarge = button;
  static const TextStyle bodySmall = caption;
}

ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Colors.white,
      centerTitle: true,
      titleTextStyle: _Typography.headlineSmall
          .merge(TextStyle(color: AppColors.grey[900])),
      iconTheme: IconThemeData(color: AppColors.grey[700]),
      actionsIconTheme: IconThemeData(color: AppColors.grey[700]),
      toolbarTextStyle: _Typography.headlineSmall.merge(
        TextStyle(color: AppColors.grey[900]),
      ),
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColors.purple,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.purple[600]!,
      onPrimary: AppColors.purple[900],
      onPrimaryContainer: AppColors.purple[300],
      primaryContainer: AppColors.purple[100],
      secondary: AppColors.brown[700]!,
      onSecondary: AppColors.brown[900]!,
      secondaryContainer: AppColors.orange[100],
      tertiary: AppColors.orange[700]!,
      tertiaryContainer: AppColors.orange[100],
      onTertiaryContainer: AppColors.orange[300]!,
      onTertiary: AppColors.orange[1000]!,
      error: AppColors.red[500]!,
      onError: AppColors.red[800],
      surfaceContainer: Colors.white,
      surface: AppColors.grey[100],
      onSurface: AppColors.grey[900],
      surfaceContainerLow: AppColors.purple[300],
      surfaceContainerHigh: AppColors.grey[100],
    ),
    dividerColor: AppColors.grey[300],
    textTheme: const TextTheme(
        displayLarge: _Typography.headline1,
        displayMedium: _Typography.headline2,
        displaySmall: _Typography.headline3,
        headlineLarge: _Typography.headlineLarge,
        headlineMedium: _Typography.headline5,
        headlineSmall: _Typography.headlineSmall,
        titleMedium: _Typography.titleMedium,
        titleSmall: _Typography.subtitle2,
        bodyLarge: _Typography.bodyText1,
        bodyMedium: _Typography.bodyMedium,
        labelLarge: _Typography.labelLarge,
        bodySmall: _Typography.bodySmall,
        labelSmall: _Typography.overline),
    fontFamily: 'Lato',
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey[50],
      labelStyle: _Typography.bodySmall.copyWith(color: AppColors.purple[500]),
      side: BorderSide(color: AppColors.purple[500]!),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.purple),
          borderRadius: BorderRadius.circular(Constants.margin * 2)),
      margin: EdgeInsets.zero,
      shadowColor: AppColors.purple[700],
      color: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.purple[200]!),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey[200]!),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.purple[200]!),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.purple[500]!),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      fillColor: Colors.white,
      filled: true,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.grey[100]),
      ),
      inputDecorationTheme: InputDecorationTheme(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey[200]!),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.purple[200]!),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.purple[500]!),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: const Color(0xFF1A1A1A),
      centerTitle: true,
      titleTextStyle:
          _Typography.headlineSmall.merge(const TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white70),
      actionsIconTheme: const IconThemeData(color: Colors.white70),
      toolbarTextStyle: _Typography.headlineSmall.merge(
        const TextStyle(color: Colors.white70),
      ),
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.purple[300]!, // purple[300]
      onPrimary: Colors.black,
      onPrimaryContainer: AppColors.purple[700]!,
      primaryContainer: AppColors.purple[600]!,
      secondary: AppColors.brown[300]!,
      onSecondary: AppColors.grey[100]!,
      secondaryContainer: AppColors.brown[900]!,
      tertiary: AppColors.orange[300]!, // orange[300]
      onTertiary: Colors.black,
      tertiaryContainer: AppColors.brown[500],
      onTertiaryContainer: AppColors.brown[300]!,
      error: AppColors.red[900]!,
      onError: AppColors.red[800]!,
      surface: Colors.black,
      surfaceContainer: Colors.black,
      onSurface: Colors.white,
      surfaceContainerLow: AppColors.grey[900]!,
      surfaceContainerHigh: AppColors.grey[900]!,
    ),
    dividerColor: const Color(0xFF404040),
    textTheme: const TextTheme(
        displayLarge: _Typography.headline1,
        displayMedium: _Typography.headline2,
        displaySmall: _Typography.headline3,
        headlineLarge: _Typography.headlineLarge,
        headlineMedium: _Typography.headline5,
        headlineSmall: _Typography.headlineSmall,
        titleMedium: _Typography.titleMedium,
        titleSmall: _Typography.subtitle2,
        bodyLarge: _Typography.bodyText1,
        bodyMedium: _Typography.bodyMedium,
        labelLarge: _Typography.labelLarge,
        bodySmall: _Typography.bodySmall,
        labelSmall: _Typography.overline),
    fontFamily: 'Lato',
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: Color(0xFFAD66A9)), // purple[300]
      side: BorderSide(color: Color(0xFFAD66A9)), // purple[300]
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFAD66A9)), // purple[300]
          borderRadius: BorderRadius.all(Radius.circular(16))),
      margin: EdgeInsets.zero,
      shadowColor: Colors.black,
      color: Color(0xFF2A2A2A),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF551054)), // purple[700]
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF404040)),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF551054)), // purple[700]
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFAD66A9)), // purple[300]
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      fillColor: Color(0xFF2A2A2A),
      filled: true,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF2A2A2A)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF551054)), // purple[700]
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFAD66A9)), // purple[300]
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        fillColor: Color(0xFF2A2A2A),
        filled: true,
      ),
    ),
  );
}

ThemeData appTheme = getLightTheme();

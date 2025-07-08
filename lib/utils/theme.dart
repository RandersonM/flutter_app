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
    800: Color(0xFFB00020),
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

  static const int _gradientPurplePrimaryValue = 0xFFFF0099;
  static const MaterialColor gradientPurple =
      MaterialColor(_gradientPurplePrimaryValue, <int, Color>{
    200: Color(0xFFF953C6),
    500: Color(_gradientPurplePrimaryValue),
    800: Color(0xFF493240)
  });

  static const int _orangePrimaryValue = 0xFFFA6A00;
  static const MaterialColor orange =
      MaterialColor(_orangePrimaryValue, <int, Color>{
    100: Color(0xFFFFF7F2),
    500: Color(_orangePrimaryValue),
    800: Color(0xFF8F3D00),
  });
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

ThemeData appTheme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.white,
    centerTitle: true,
    titleTextStyle:
        _Typography.headlineSmall.merge(TextStyle(color: AppColors.grey[900])),
    iconTheme: IconThemeData(color: AppColors.grey[700]),
    actionsIconTheme: IconThemeData(color: AppColors.grey[700]),
    toolbarTextStyle: _Typography.headlineSmall.merge(
      TextStyle(color: AppColors.grey[900]),
    ),
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: AppColors.purple,
  ).copyWith(
    primary: AppColors.purple[600]!,
    onPrimary: AppColors.purple[900],
    secondary: AppColors.purple[300],
    onSecondary: AppColors.purple[100],
    error: AppColors.red[500]!,
    onError: AppColors.red[100],
    surface: AppColors.grey[100],
    onSurface: AppColors.grey[900],
    surfaceContainerLow: AppColors.grey[100],
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
  ),
  scaffoldBackgroundColor: Colors.white,
);

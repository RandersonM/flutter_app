import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/theme.dart';

Widget getTestableWidget(Widget child) => MediaQuery(
  data: const MediaQueryData(),
  child: MaterialApp(
    home: child,
    locale: const Locale('en', 'US'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: appTheme,
  ),
);

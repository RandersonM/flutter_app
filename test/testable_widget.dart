// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/shared/theme.dart';

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

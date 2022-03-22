// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:simple_app/core/one_piece/characters_provider.dart';
import 'package:simple_app/screens/splash/splash_screen.dart';
import 'package:simple_app/shared/app_routes.dart';

import 'package:simple_app/shared/theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white24,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.locale}) : super(key: key);

  final Locale? locale;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<CharactersProvider>(
            create: (_) => CharactersProvider(),
            lazy: false,
          ),
        ],
        child: MaterialApp(
          title: 'Simple App',
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const <Locale>[
            Locale('en', ''),
            Locale('pt', ''),
          ],
          theme: appTheme,
          home: const SplashScreen(),
          onGenerateRoute: AppRoutes.getRoute,
        ),
      );
}

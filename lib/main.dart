// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_app/screens/one_piece/blocs/search_cubit.dart';
import 'package:simple_app/core/services/environment_service.dart';
import 'package:simple_app/core/services/service_locator.dart';
import 'package:simple_app/core/home/models/featured_character.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:simple_app/screens/one_piece/blocs/characters_cubit.dart';

import 'package:simple_app/screens/splash/splash_screen.dart';
import 'package:simple_app/utils/app_routes.dart';

import 'package:simple_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive primeiro
  await Hive.initFlutter();

  // Registrar adapters do Hive
  Hive.registerAdapter(FeaturedCharacterAdapter());

  // Inicializar outros serviços
  await Future.wait([
    EnvironmentService.initialize(),
    configureDependencies(),
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white24,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.locale}) : super(key: key);

  final Locale? locale;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<CharactersCubit>(
            create: (_) => getIt<CharactersCubit>(),
            lazy: false,
          ),
          BlocProvider<SearchCubit>(
            create: (_) => getIt<SearchCubit>(),
            lazy: true,
          ),
        ],
        child: MaterialApp(
          title: EnvironmentService.instance.appName,
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

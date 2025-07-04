// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/core/one_piece/models/featured_character.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

import 'package:opfan/screens/one_piece/blocs/characters_cubit.dart';
import 'package:opfan/core/auth/app_wrapper.dart';

import 'package:opfan/utils/app_routes.dart';

import 'package:opfan/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();

  Hive.registerAdapter(FeaturedCharacterAdapter());
  Hive.registerAdapter(UserModelAdapter());

  try {
    await Future.wait([
      () async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }(),
      () async {
        await EnvironmentService.initialize();
      }(),
      () async {
        await configureDependencies();
      }(),
    ]);
  } catch (e, stackTrace) {
    debugPrint('MAIN: Initialization error: $e');
    debugPrint('MAIN: Stack trace: $stackTrace');
    rethrow;
  }

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
          home: const AppWrapper(),
          onGenerateRoute: AppRoutes.getRoute,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/core/models/one_piece/today_character.dart';
import 'package:opfan/core/models/theme_model.dart';
import 'package:opfan/core/services/theme_service.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

import 'package:opfan/screens/one_piece/blocs/characters_cubit.dart';
import 'package:opfan/core/auth/app_wrapper.dart';
import 'package:opfan/core/auth/blocs/index.dart';

import 'package:opfan/utils/app_routes.dart';

import 'package:opfan/utils/theme.dart';
import 'core/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();

  Hive.registerAdapter(TodayCharacterAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ThemeSettingsAdapter());

  await LocaleService.loadLocale();

  try {
    await Future.wait([
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      EnvironmentService.initialize(),
      configureDependencies(),
      ThemeService.initialize(),
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _currentThemeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    ThemeService().addListener(_onThemeChanged);
    LocaleService().addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    LocaleService().removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _loadThemeMode() {
    try {
      final isDarkMode = ThemeService.isDarkMode;
      setState(() {
        _currentThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      // Keep default light theme
    }
  }

  void _onThemeChanged() {
    _loadThemeMode();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => getIt<AuthBloc>(),
            lazy: false,
          ),
          BlocProvider<CharactersCubit>(
            create: (_) => getIt<CharactersCubit>(),
            lazy: false,
          ),
          BlocProvider<SearchCubit>(
            create: (_) => getIt<SearchCubit>(),
            lazy: true,
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return MaterialApp(
              title: EnvironmentService.instance.appName,
              locale: LocaleService.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const <Locale>[
                Locale('en', ''),
                Locale('pt', ''),
              ],
              theme: getLightTheme(),
              darkTheme: getDarkTheme(),
              themeMode: _currentThemeMode,
              home: const AppWrapper(),
              onGenerateRoute: (settings) =>
                  AuthRouteMiddleware.onGenerateRoute(
                settings,
                authState,
              ),
            );
          },
        ),
      );
}

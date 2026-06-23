import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/notification_service.dart';
import 'package:opfan/core/services/navigation_service.dart';
import 'package:opfan/core/models/one_piece/today_character.dart';
import 'package:opfan/core/models/theme_model.dart';
import 'package:opfan/core/services/theme_service.dart';
import 'package:opfan/core/theme/cubit/theme_cubit.dart';
import 'package:opfan/core/theme/cubit/theme_state.dart';
import 'package:opfan/core/locale/cubit/locale_cubit.dart';
import 'package:opfan/core/locale/cubit/locale_state.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

import 'package:opfan/features/one_piece/bloc/characters_cubit.dart';
import 'package:opfan/core/auth/app_wrapper.dart';
import 'package:opfan/core/auth/blocs/index.dart';

import 'package:opfan/shared/utils/app_routes.dart';

import 'package:opfan/shared/utils/theme.dart';
import 'core/services/locale_service.dart';
import 'package:opfan/core/models/nami_finances_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();

  Hive.registerAdapter(TodayCharacterAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ThemeSettingsAdapter());
  
  Hive.registerAdapter(NamiFinancesModelAdapter());
  Hive.registerAdapter(MonthlyIncomeModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());

  await LocaleService.loadLocale();

  try {
    await Future.wait([
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      EnvironmentService.initialize(),
      setupDependencies(),
      ThemeService.initialize(),
    ]);

    await getIt<NotificationService>().initialize();
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => getIt<ThemeCubit>(),
          ),
          BlocProvider<LocaleCubit>(
            create: (_) => getIt<LocaleCubit>(),
          ),
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
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) =>
              BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) =>
                BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) => MaterialApp(
                title: EnvironmentService.instance.appName,
                locale: localeState.locale,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: const <Locale>[
                  Locale('en', ''),
                  Locale('pt', ''),
                ],
                theme: getLightTheme(),
                darkTheme: getDarkTheme(),
                themeMode: themeState.themeMode,
                navigatorKey: NavigationService().navigatorKey,
                home: const AppWrapper(),
                onGenerateRoute: (settings) =>
                    AuthRouteMiddleware.onGenerateRoute(settings, authState),
              ),
            ),
          ),
        ),
      );
}

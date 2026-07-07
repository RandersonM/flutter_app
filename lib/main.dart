import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/app/di/injection.dart';
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
import 'package:opfan/shared/widgets/atoms/offline_banner.dart';

import 'package:opfan/shared/utils/app_routes.dart';

import 'package:opfan/shared/utils/theme.dart';

import 'package:opfan/app/app_bloc_observer.dart';
import 'package:opfan/shared/widgets/global_error_boundary.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_gemma_embeddings/flutter_gemma_embeddings.dart';
import 'package:flutter_gemma_rag_sqlite/flutter_gemma_rag_sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await setupDependencies();
  await getIt<IStorageService>().initialize();

  await getIt<ILocaleService>().loadLocale();

  try {
    debugPrint('MAIN: Starting Firebase, Env, Theme initialize...');
    await Future.wait([
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      getIt<IEnvironmentService>().initialize(),
      getIt<IThemeService>().initialize(),
    ]);
    debugPrint('MAIN: Firebase, Env, Theme initialized.');

    debugPrint('MAIN: Inicializando NotificationService em background...');
    // Não usamos "await" aqui. Assim, o pedido de permissão não bloqueia
    // o Flutter de renderizar a primeira tela do aplicativo.
    getIt<INotificationService>().initialize().catchError((e) {
      debugPrint('MAIN: Erro ao inicializar NotificationService: $e');
    });

    debugPrint('MAIN: Initializing FlutterGemma...');
    await FlutterGemma.initialize(
      huggingFaceToken: getIt<IEnvironmentService>().huggingFaceApiKey,
      inferenceEngines: [LiteRtLmEngine()],
      embeddingBackends: [LiteRtEmbeddingBackend()],
      vectorStore: SqliteVectorStore(),
    );
    debugPrint('MAIN: FlutterGemma initialized.');
  } catch (e, stackTrace) {
    debugPrint('MAIN: Initialization error: $e');
    debugPrint('MAIN: Stack trace: $stackTrace');
    rethrow;
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white24,
  ));

  runApp(const GlobalErrorBoundary(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            builder: (context, localeState) => BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) => MaterialApp(
                title: getIt<IEnvironmentService>().appName,
                locale: localeState.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: const <Locale>[
                  Locale('en', ''),
                  Locale('pt', ''),
                ],
                theme: getLightTheme(),
                darkTheme: getDarkTheme(),
                themeMode: themeState.themeMode,
                navigatorKey: NavigationService().navigatorKey,
                home: const OfflineBannerWrapper(child: AppWrapper()),
                onGenerateRoute: (settings) =>
                    AuthRouteMiddleware.onGenerateRoute(settings, authState),
              ),
            ),
          ),
        ),
      );
}

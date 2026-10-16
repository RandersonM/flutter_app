import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository_interface.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/core/services/rag/rag_service.dart';
import 'package:opfan/core/services/web_search/i_web_search_service.dart';
import 'package:opfan/core/services/web_search/web_search_service.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/search_internet_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/get_user_profile_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/get_workout_history_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/save_workout_handler.dart';
import 'package:opfan/features/vegapunk_chat/tools/handlers/get_character_info_handler.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/crews/data/repository/crew_repository.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';

void registerCoreModule(GetIt getIt) {
  // ── Connectivity (must be first — other services may depend on it) ──────────
  getIt.registerSingleton<IConnectivityService>(ConnectivityService());
  getIt.registerSingleton<ConnectivityCubit>(
    ConnectivityCubit(connectivityService: getIt<IConnectivityService>()),
  );

  getIt.registerSingleton<IStorageService>(HiveStorageService());
  getIt.registerSingleton<IEnvironmentService>(EnvironmentService());
  getIt.registerLazySingleton<ILocaleService>(() => LocaleService());
  getIt.registerLazySingleton<IThemeService>(() => ThemeService());

  // NavigationService owns the app's single navigatorKey, so it must be a
  // singleton and resolved from here — never constructed ad hoc.
  getIt.registerLazySingleton<INavigationService>(() => NavigationService());

  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(
      navigationService: getIt<INavigationService>(),
      firestoreService: getIt<IFirestoreService>(),
    ),
  );
  getIt.registerLazySingleton<IDevilFruitService>(() => DevilFruitService());
  getIt.registerLazySingleton<IYouTubeService>(() => YouTubeService());
  getIt.registerLazySingleton<IGeminiService>(() => GeminiService());
  getIt.registerLazySingleton<ICharacterImageService>(
    () => CharacterImageService(geminiService: getIt<IGeminiService>()),
  );
  getIt.registerLazySingleton<ICrewImageService>(
    () => CrewImageService(geminiService: getIt<IGeminiService>()),
  );

  getIt.registerLazySingleton<ICookingRepository>(() => CookingRepository());
  getIt.registerLazySingleton<IFeaturedCharacterRepository>(
    () => FeaturedCharacterRepository(
      firestoreService: getIt<IFirestoreService>(),
    ),
  );

  getIt.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepository(),
  );

  getIt.registerLazySingleton<IAuthService>(
    () => AuthService(
      userProfileRepository: getIt<IUserProfileRepository>(),
      notificationService: getIt<INotificationService>(),
    ),
  );
  getIt.registerLazySingleton<IFirestoreService>(() => FirestoreService());

  getIt.registerLazySingleton<ICrewRepository>(
    () => CrewRepository(firestoreService: getIt<IFirestoreService>()),
  );
  getIt.registerLazySingleton<ICustomCharacterRepository>(
    () => CustomCharacterRepository(
      getIt<ICrewRepository>(),
      firestoreService: getIt<IFirestoreService>(),
    ),
  );
  getIt.registerLazySingleton<IVegapunkChatHistoryRepository>(
    () => VegapunkChatHistoryRepository(),
  );
  getIt.registerLazySingleton<PlannerRepositoryInterface>(
    () => PlannerRepository(firestoreService: getIt<IFirestoreService>()),
  );
  getIt.registerLazySingleton<INamiFinancesService>(
    () => NamiFinancesService(),
  );
  getIt.registerLazySingleton<INutritionCalculationService>(
    () => NutritionCalculationService(),
  );
  getIt.registerLazySingleton<IWorkoutAssessmentService>(
    () => WorkoutAssessmentService(),
  );

  getIt.registerLazySingleton<IRAGService>(() => RAGService());
  getIt.registerLazySingleton<IWebSearchService>(() => WebSearchService());

  // ── Function Calling (Gemma tool registry) ─────────────────────────────────
  // FunctionRegistry and FunctionExecutor are lazy singletons. The factory
  // closure captures getIt<IWebSearchService>() at creation time (not
  // registration time), so IWebSearchService must be registered first.
  getIt.registerLazySingleton<FunctionRegistry>(() {
    final registry = FunctionRegistry();
    registry.register(
      SearchInternetHandler(
        webSearch: getIt<IWebSearchService>(),
        connectivityService: getIt<IConnectivityService>(),
      ),
    );
    registry.register(
      GetUserProfileHandler(authService: getIt<IAuthService>()),
    );
    registry.register(
      GetWorkoutHistoryHandler(
        workoutService: getIt<IWorkoutAssessmentService>(),
      ),
    );
    registry.register(
      SaveWorkoutHandler(workoutService: getIt<IWorkoutAssessmentService>()),
    );
    registry.register(
      GetCharacterInfoHandler(
        featuredCharacterRepository: getIt<IFeaturedCharacterRepository>(),
        customCharacterRepository: getIt<ICustomCharacterRepository>(),
      ),
    );
    return registry;
  });
  getIt.registerLazySingleton<FunctionExecutor>(() => FunctionExecutor());

  getIt.registerLazySingleton<IGemmaService>(() {
    final gemma = GemmaService();
    // Register native tools from FunctionRegistry so the Gemma 4 SDK
    // handles function calling at the SDK level (structured JSON Schema).
    final registry = getIt<FunctionRegistry>();
    gemma.setTools(registry.getTools());
    return gemma;
  });

  // Registered after IGemmaService — the repository takes it as a constructor
  // dependency, so the closure must be able to resolve it when first read.
  getIt.registerLazySingleton<IVegapunkChatRepository>(
    () => VegapunkChatRepository(
      gemmaService: getIt<IGemmaService>(),
      ragService: getIt<IRAGService>(),
      functionRegistry: getIt<FunctionRegistry>(),
      functionExecutor: getIt<FunctionExecutor>(),
    ),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authService: getIt<IAuthService>()),
  );
}

extension CoreModuleExtensions on GetIt {
  IEnvironmentService get environmentService => get<IEnvironmentService>();
  ILocaleService get localeService => get<ILocaleService>();
  IStorageService get storageService => get<IStorageService>();
  INotificationService get notificationService => get<INotificationService>();
  IFeaturedCharacterRepository get featuredCharacterRepository =>
      get<IFeaturedCharacterRepository>();
  IDevilFruitService get devilFruitService => get<IDevilFruitService>();
  IYouTubeService get youTubeService => get<IYouTubeService>();
  IGeminiService get geminiService => get<IGeminiService>();
  ICharacterImageService get characterImageService =>
      get<ICharacterImageService>();
  ICrewImageService get crewImageService => get<ICrewImageService>();
  ICookingRepository get cookingRepository => get<ICookingRepository>();
  IUserProfileRepository get userProfileRepository =>
      get<IUserProfileRepository>();
  IAuthService get authService => get<IAuthService>();
  IFirestoreService get firestoreService => get<IFirestoreService>();
  ICustomCharacterRepository get customCharacterRepository =>
      get<ICustomCharacterRepository>();
  ICrewRepository get crewRepository => get<ICrewRepository>();
  IVegapunkChatHistoryRepository get vegapunkChatHistoryRepository =>
      get<IVegapunkChatHistoryRepository>();
  PlannerRepositoryInterface get plannerRepository =>
      get<PlannerRepositoryInterface>();
  INamiFinancesService get namiFinancesService => get<INamiFinancesService>();
  IGemmaService get gemmaService => get<IGemmaService>();
  IRAGService get ragService => get<IRAGService>();
  IWebSearchService get webSearchService => get<IWebSearchService>();
  FunctionRegistry get functionRegistry => get<FunctionRegistry>();
  FunctionExecutor get functionExecutor => get<FunctionExecutor>();
  AuthBloc get authBloc => get<AuthBloc>();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';
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
import 'package:opfan/features/home/data/repository/i_featured_character_repository.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'package:opfan/features/crews/data/repository/crew_repository.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository.dart';
import 'package:opfan/features/sanji_cooking/data/repository/i_cooking_repository.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository.dart';
import 'package:opfan/features/robin_knowledge/data/repository/i_planner_repository.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';

void registerCoreModule(GetIt getIt) {
  // ── Platform SDK handles (lazy: resolved after Firebase.initializeApp) ──────
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      // Readable after the first unlock so background work can open the
      // boxes; not `this_device`, so an encrypted backup restores the key too.
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // ── Local storage (per user, encrypted) ────────────────────────────────────
  getIt.registerLazySingleton<IEncryptionKeyStore>(
    () =>
        SecureEncryptionKeyStore(secureStorage: getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<IUserStorageService>(
    () => UserStorageService(
      auth: getIt<FirebaseAuth>(),
      keyStore: getIt<IEncryptionKeyStore>(),
      documentsDirectory: getApplicationDocumentsDirectory,
    ),
  );

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
      firebaseMessaging: getIt<FirebaseMessaging>(),
    ),
  );
  getIt.registerLazySingleton<IDevilFruitService>(
    () => DevilFruitService(env: getIt<IEnvironmentService>()),
  );
  getIt.registerLazySingleton<IYouTubeService>(
    () => YouTubeService(env: getIt<IEnvironmentService>()),
  );
  getIt.registerLazySingleton<IGeminiService>(
    () => GeminiService(env: getIt<IEnvironmentService>()),
  );
  getIt.registerLazySingleton<ICharacterImageService>(
    () => CharacterImageService(geminiService: getIt<IGeminiService>()),
  );
  getIt.registerLazySingleton<ICrewImageService>(
    () => CrewImageService(geminiService: getIt<IGeminiService>()),
  );

  getIt.registerLazySingleton<ICookingRepository>(
    () => CookingRepository(
      geminiService: getIt<IGeminiService>(),
      localeService: getIt<ILocaleService>(),
    ),
  );
  getIt.registerLazySingleton<IFeaturedCharacterRepository>(
    () => FeaturedCharacterRepository(
      firestoreService: getIt<IFirestoreService>(),
    ),
  );

  getIt.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepository(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<IAuthService>(
    () => AuthService(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
      userProfileRepository: getIt<IUserProfileRepository>(),
      notificationService: getIt<INotificationService>(),
      storage: getIt<IUserStorageService>(),
    ),
  );
  getIt.registerLazySingleton<IFirestoreService>(
    () => FirestoreService(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

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
    () => VegapunkChatHistoryRepository(storage: getIt<IUserStorageService>()),
  );
  getIt.registerLazySingleton<IPlannerRepository>(
    () => PlannerRepository(firestoreService: getIt<IFirestoreService>()),
  );
  getIt.registerLazySingleton<INamiFinancesService>(
    () => NamiFinancesService(storage: getIt<IUserStorageService>()),
  );
  getIt.registerLazySingleton<INutritionCalculationService>(
    () => NutritionCalculationService(),
  );
  getIt.registerLazySingleton<IWorkoutAssessmentService>(
    () => WorkoutAssessmentService(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<IRAGService>(
    () => RAGService(storage: getIt<IUserStorageService>()),
  );
  getIt.registerLazySingleton<IWebSearchService>(
    () => WebSearchService(env: getIt<IEnvironmentService>()),
  );

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
        localeService: getIt<ILocaleService>(),
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
    final gemma = GemmaService(
      env: getIt<IEnvironmentService>(),
      localeService: getIt<ILocaleService>(),
    );
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
  IPlannerRepository get plannerRepository => get<IPlannerRepository>();
  INamiFinancesService get namiFinancesService => get<INamiFinancesService>();
  IGemmaService get gemmaService => get<IGemmaService>();
  IRAGService get ragService => get<IRAGService>();
  IWebSearchService get webSearchService => get<IWebSearchService>();
  FunctionRegistry get functionRegistry => get<FunctionRegistry>();
  FunctionExecutor get functionExecutor => get<FunctionExecutor>();
  AuthBloc get authBloc => get<AuthBloc>();
}

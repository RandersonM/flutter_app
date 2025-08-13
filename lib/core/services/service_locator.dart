import 'package:get_it/get_it.dart';
import 'package:opfan/core/calculator/calculator_provider.dart';
import 'package:opfan/screens/one_piece/blocs/characters_cubit.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/repository/featured_character_repository.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/services/notification_service.dart';
import 'package:opfan/core/services/notification_manager_service.dart';
import 'package:opfan/core/services/ai_image_service.dart';
import 'package:opfan/core/services/gemini_image_service.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/screens/home/blocs/home_bloc.dart';
import 'package:opfan/screens/devil_fruit/blocs/devil_fruit_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/screens/crews/blocs/index.dart';
import 'package:opfan/screens/nami-finances/blocs/nami_finances_bloc.dart';
import 'package:opfan/core/services/nami_finances_service.dart';
import 'package:opfan/screens/zoro-workout/blocs/index.dart';
import 'package:opfan/screens/sanji-cooking/blocs/index.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<EnvironmentService>(EnvironmentService.instance);

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  getIt.registerLazySingleton<NotificationManagerService>(
    () => NotificationManagerService(),
  );

  getIt.registerLazySingleton<DevilFruitService>(
    () => DevilFruitService(),
  );

  getIt.registerLazySingleton<YouTubeService>(
    () => YouTubeService(),
  );

  getIt.registerLazySingleton<AiImageService>(
    () => AiImageService(),
  );

  getIt.registerLazySingleton<GeminiImageService>(
    () => GeminiImageService(),
  );

  getIt.registerLazySingleton<FeaturedCharacterRepository>(
    () => FeaturedCharacterRepository(),
  );

  getIt.registerLazySingleton<AuthService>(
    () {
      final authService = AuthService();
      return authService;
    },
  );

  getIt.registerLazySingleton<FirestoreService>(
    () => FirestoreService(),
  );

  getIt.registerLazySingleton<CustomCharacterRepository>(
    () => CustomCharacterRepository(),
  );

  getIt.registerLazySingleton<CustomCharacterService>(
    () => CustomCharacterService(),
  );

  getIt.registerLazySingleton<CrewRepository>(
    () => CrewRepository(),
  );

  getIt.registerFactory<CalculatorProvider>(
    () => CalculatorProvider(),
  );

  getIt.registerFactory<CharactersCubit>(
    () => CharactersCubit(getIt<FeaturedCharacterRepository>()),
  );

  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<FeaturedCharacterRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      youTubeService: getIt<YouTubeService>(),
      featuredCharacterRepository: getIt<FeaturedCharacterRepository>(),
    ),
  );

  getIt.registerFactory<DevilFruitBloc>(
    () => DevilFruitBloc(
      devilFruitService: getIt<DevilFruitService>(),
    ),
  );

  getIt.registerFactory<ListCrewsBloc>(
    () => ListCrewsBloc(crewRepository: getIt<CrewRepository>()),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () {
      final authService = getIt<AuthService>();
      final authBloc = AuthBloc(authService: authService);
      authBloc.add(const AuthStarted());
      return authBloc;
    },
  );

  getIt.registerLazySingleton<NamiFinancesService>(
    () => NamiFinancesService(),
  );

  getIt.registerFactory<NamiFinancesBloc>(
    () => NamiFinancesBloc(getIt<NamiFinancesService>()),
  );

  getIt.registerFactory<ZoroWorkoutBloc>(
    () => ZoroWorkoutBloc(),
  );

  getIt.registerFactory<SanjiCookingBloc>(
    () => SanjiCookingBloc(),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}

bool isDependencyConfigured() {
  return getIt.isRegistered<EnvironmentService>() &&
      getIt.isRegistered<FeaturedCharacterRepository>() &&
      getIt.isRegistered<DevilFruitService>() &&
      getIt.isRegistered<YouTubeService>() &&
      getIt.isRegistered<AuthService>();
}

extension ServiceLocatorExtensions on GetIt {
  EnvironmentService get environmentService => get<EnvironmentService>();
  NotificationService get notificationService => get<NotificationService>();
  FeaturedCharacterRepository get featuredCharacterRepository =>
      get<FeaturedCharacterRepository>();
  DevilFruitService get devilFruitService => get<DevilFruitService>();
  YouTubeService get youTubeService => get<YouTubeService>();
  AiImageService get aiImageService => get<AiImageService>();
  GeminiImageService get geminiImageService => get<GeminiImageService>();

  AuthService get authService => get<AuthService>();
  FirestoreService get firestoreService => get<FirestoreService>();
  CustomCharacterRepository get customCharacterRepository =>
      get<CustomCharacterRepository>();

  CustomCharacterService get customCharacterService =>
      get<CustomCharacterService>();

  CrewRepository get crewRepository => get<CrewRepository>();

  CalculatorProvider get calculatorProvider => get<CalculatorProvider>();

  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
  ListCrewsBloc get listCrewsBloc => get<ListCrewsBloc>();
  AuthBloc get authBloc => get<AuthBloc>();
  ZoroWorkoutBloc get zoroWorkoutBloc => get<ZoroWorkoutBloc>();
  SanjiCookingBloc get sanjiCookingBloc => get<SanjiCookingBloc>();
}



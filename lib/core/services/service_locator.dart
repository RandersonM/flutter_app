import 'package:get_it/get_it.dart';
import 'package:opfan/core/calculator/calculator_provider.dart';
import 'package:opfan/screens/one_piece/blocs/characters_cubit.dart';
import 'package:opfan/screens/one_piece/blocs/search_cubit.dart';
import 'package:opfan/core/services/characters_backend_service.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/featured_character_service.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/services/ai_image_service.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/screens/home/blocs/home_bloc.dart';
import 'package:opfan/screens/devil_fruit/blocs/devil_fruit_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/screens/crews/blocs/index.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<EnvironmentService>(EnvironmentService.instance);

  getIt.registerLazySingleton<CharactersBackendService>(
    () => CharactersBackendService(),
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

  getIt.registerLazySingleton<FeaturedCharacterService>(
    () => FeaturedCharacterService(
        charactersService: getIt<CharactersBackendService>()),
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
    () => CharactersCubit(getIt<CharactersBackendService>()),
  );

  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<CharactersBackendService>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      youTubeService: getIt<YouTubeService>(),
      featuredCharacterService: getIt<FeaturedCharacterService>(),
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
}

Future<void> resetDependencies() async {
  await getIt.reset();
}

bool isDependencyConfigured() {
  return getIt.isRegistered<EnvironmentService>() &&
      getIt.isRegistered<CharactersBackendService>() &&
      getIt.isRegistered<DevilFruitService>() &&
      getIt.isRegistered<YouTubeService>() &&
      getIt.isRegistered<AuthService>();
}

extension ServiceLocatorExtensions on GetIt {
  EnvironmentService get environmentService => get<EnvironmentService>();
  CharactersBackendService get charactersService =>
      get<CharactersBackendService>();
  DevilFruitService get devilFruitService => get<DevilFruitService>();
  YouTubeService get youTubeService => get<YouTubeService>();
  AiImageService get aiImageService => get<AiImageService>();
  FeaturedCharacterService get featuredCharacterService =>
      get<FeaturedCharacterService>();
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
}



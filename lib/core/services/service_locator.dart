// Developed by Randerson Mayllon
// Copyright © 2022.

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
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/screens/home/blocs/home_bloc.dart';
import 'package:opfan/screens/devil_fruit/blocs/devil_fruit_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';

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
  FeaturedCharacterService get featuredCharacterService =>
      get<FeaturedCharacterService>();
  AuthService get authService => get<AuthService>();
  FirestoreService get firestoreService => get<FirestoreService>();
  CustomCharacterRepository get customCharacterRepository =>
      get<CustomCharacterRepository>();

  CustomCharacterService get customCharacterService =>
      get<CustomCharacterService>();

  CalculatorProvider get calculatorProvider => get<CalculatorProvider>();

  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
  AuthBloc get authBloc => get<AuthBloc>();
}

void registerTestDependencies() {
  if (getIt.isRegistered<CharactersBackendService>()) {
    getIt.unregister<CharactersBackendService>();
  }

  if (getIt.isRegistered<DevilFruitService>()) {
    getIt.unregister<DevilFruitService>();
  }

  if (getIt.isRegistered<YouTubeService>()) {
    getIt.unregister<YouTubeService>();
  }
}

void validateDependencies() {
  if (!getIt.isRegistered<EnvironmentService>()) {
    throw Exception('Serviço obrigatório não registrado: EnvironmentService');
  }

  if (!getIt.isRegistered<CharactersBackendService>()) {
    throw Exception(
        'Serviço obrigatório não registrado: CharactersBackendService');
  }

  if (!getIt.isRegistered<DevilFruitService>()) {
    throw Exception('Serviço obrigatório não registrado: DevilFruitService');
  }

  if (!getIt.isRegistered<YouTubeService>()) {
    throw Exception('Serviço obrigatório não registrado: YouTubeService');
  }
}

Map<String, dynamic> getDependencyInfo() {
  return {
    'environment_service': getIt.isRegistered<EnvironmentService>(),
    'characters_service': getIt.isRegistered<CharactersBackendService>(),
    'devil_fruit_service': getIt.isRegistered<DevilFruitService>(),
    'youtube_service': getIt.isRegistered<YouTubeService>(),
    'auth_service': getIt.isRegistered<AuthService>(),
    'calculator_provider': getIt.isRegistered<CalculatorProvider>(),
    'characters_cubit': getIt.isRegistered<CharactersCubit>(),
    'search_cubit': getIt.isRegistered<SearchCubit>(),
    'home_bloc': getIt.isRegistered<HomeBloc>(),
    'devil_fruit_bloc': getIt.isRegistered<DevilFruitBloc>(),
    'auth_bloc': getIt.isRegistered<AuthBloc>(),
  };
}

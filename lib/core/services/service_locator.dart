// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:get_it/get_it.dart';
import 'package:simple_app/core/calculator/calculator_provider.dart';
import 'package:simple_app/screens/one_piece/blocs/characters_cubit.dart';
import 'package:simple_app/screens/one_piece/blocs/search_cubit.dart';
import 'package:simple_app/core/services/characters_backend_service.dart';
import 'package:simple_app/core/services/devil_fruit_service.dart';
import 'package:simple_app/core/services/environment_service.dart';
import 'package:simple_app/core/services/youtube_service.dart';
import 'package:simple_app/screens/home/blocs/home_bloc.dart';
import 'package:simple_app/screens/devil_fruit/blocs/devil_fruit_bloc.dart';

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
      charactersService: getIt<CharactersBackendService>(),
      youTubeService: getIt<YouTubeService>(),
    ),
  );

  getIt.registerFactory<DevilFruitBloc>(
    () => DevilFruitBloc(
      devilFruitService: getIt<DevilFruitService>(),
    ),
  );
}

Future<void> resetDependencies() async {
  await getIt.reset();
}

bool isDependencyConfigured() {
  return getIt.isRegistered<EnvironmentService>() &&
      getIt.isRegistered<CharactersBackendService>() &&
      getIt.isRegistered<DevilFruitService>() &&
      getIt.isRegistered<YouTubeService>();
}

extension ServiceLocatorExtensions on GetIt {
  EnvironmentService get environmentService => get<EnvironmentService>();
  CharactersBackendService get charactersService =>
      get<CharactersBackendService>();
  DevilFruitService get devilFruitService => get<DevilFruitService>();
  YouTubeService get youTubeService => get<YouTubeService>();

  CalculatorProvider get calculatorProvider => get<CalculatorProvider>();

  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
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
    'calculator_provider': getIt.isRegistered<CalculatorProvider>(),
    'characters_cubit': getIt.isRegistered<CharactersCubit>(),
    'search_cubit': getIt.isRegistered<SearchCubit>(),
    'home_bloc': getIt.isRegistered<HomeBloc>(),
    'devil_fruit_bloc': getIt.isRegistered<DevilFruitBloc>(),
  };
}

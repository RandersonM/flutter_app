import 'package:get_it/get_it.dart';
import 'package:opfan/features/calculator/bloc/calculator_cubit.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/nami_finances_service.dart';
import 'package:opfan/features/one_piece/bloc/characters_cubit.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/features/home/bloc/home_bloc.dart';
import 'package:opfan/features/devil_fruit/bloc/devil_fruit_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/nami_finances/bloc/nami_finances_bloc.dart';
import 'package:opfan/features/zoro_workout/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';

void registerFeaturesModule(GetIt getIt) {
  getIt.registerFactory<CalculatorCubit>(() => CalculatorCubit());

  getIt.registerFactory<CharactersCubit>(
    () => CharactersCubit(getIt<IFeaturedCharacterRepository>()),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<IFeaturedCharacterRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      youTubeService: getIt<YouTubeService>(),
      featuredCharacterRepository: getIt<IFeaturedCharacterRepository>(),
    ),
  );

  getIt.registerFactory<DevilFruitBloc>(
    () => DevilFruitBloc(devilFruitService: getIt<DevilFruitService>()),
  );

  getIt.registerFactory<ListCrewsBloc>(
    () => ListCrewsBloc(crewRepository: getIt<ICrewRepository>()),
  );

  getIt.registerFactory<NamiFinancesBloc>(
    () => NamiFinancesBloc(getIt<NamiFinancesService>()),
  );

  getIt.registerFactory<ZoroWorkoutBloc>(() => ZoroWorkoutBloc());
  getIt.registerFactory<SanjiCookingBloc>(() => SanjiCookingBloc());

  getIt.registerLazySingleton<RobinKnowledgeBloc>(
    () => RobinKnowledgeBloc(plannerRepository: getIt<PlannerRepositoryInterface>()),
  );
}

extension FeaturesModuleExtensions on GetIt {
  CalculatorCubit get calculatorCubit => get<CalculatorCubit>();
  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
  ListCrewsBloc get listCrewsBloc => get<ListCrewsBloc>();
  ZoroWorkoutBloc get zoroWorkoutBloc => get<ZoroWorkoutBloc>();
  SanjiCookingBloc get sanjiCookingBloc => get<SanjiCookingBloc>();
  RobinKnowledgeBloc get robinKnowledgeBloc => get<RobinKnowledgeBloc>();
}

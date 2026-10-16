import 'package:get_it/get_it.dart';
import 'package:opfan/features/calculator/bloc/calculator_cubit.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart';
import 'package:opfan/features/vegapunk_chat/data/repository/i_vegapunk_chat_repository.dart';
import 'package:opfan/features/one_piece/bloc/characters_cubit.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/features/home/bloc/home_bloc.dart';
import 'package:opfan/features/devil_fruit/bloc/devil_fruit_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/features/duels/bloc/index.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_bloc.dart';
import 'package:opfan/features/nami_finances/bloc/nami_finances_bloc.dart';
import 'package:opfan/features/zoro_workout/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/features/vegapunk_chat/cubit/index.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';
import 'package:opfan/features/nami_finances/tools/find_expenses_handler.dart';
import 'package:opfan/features/nami_finances/tools/get_finances_handler.dart';
import 'package:opfan/features/nami_finances/tools/finance_calculator_handlers.dart';

/// Instance name for the Nami-scoped tool registry (kept separate from the
/// Vegapunk FunctionRegistry so these tools are exposed only in the Nami chat).
const kNamiToolsRegistry = 'namiToolsRegistry';

void registerFeaturesModule(GetIt getIt) {
  getIt.registerLazySingleton<INamiRagService>(() => NamiRagService());

  // Nami's function-calling tools: finances data + deterministic financial
  // calculators. The handlers are reusable (they could also be registered in
  // the Vegapunk FunctionRegistry later); for now they live only here.
  getIt.registerLazySingleton<FunctionRegistry>(() {
    final registry = FunctionRegistry();
    final finances = getIt<INamiFinancesService>();
    registry.register(GetFinancesHandler(financesService: finances));
    registry.register(AffordableInstallmentHandler(financesService: finances));
    registry.register(SimulateGoalPlanHandler(financesService: finances));
    registry.register(BudgetBreakdownHandler(financesService: finances));
    // Semantic lookup over expense descriptions. Registered here because the
    // router can emit `findExpenses`; without it that call would find no
    // handler at execution time.
    registry.register(
      FindExpensesHandler(
        ragService: getIt<INamiRagService>(),
        financesService: finances,
      ),
    );
    return registry;
  }, instanceName: kNamiToolsRegistry);
  getIt.registerFactory<CalculatorCubit>(() => CalculatorCubit());

  getIt.registerFactory<CharactersCubit>(
    () => CharactersCubit(getIt<IFeaturedCharacterRepository>()),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<IFeaturedCharacterRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      youTubeService: getIt<IYouTubeService>(),
      featuredCharacterRepository: getIt<IFeaturedCharacterRepository>(),
      connectivityService: getIt<IConnectivityService>(),
    ),
  );

  getIt.registerFactory<DevilFruitBloc>(
    () => DevilFruitBloc(devilFruitService: getIt<IDevilFruitService>()),
  );

  getIt.registerFactory<CustomCharacterBloc>(
    () => CustomCharacterBloc(
      customCharacterRepository: getIt<ICustomCharacterRepository>(),
      crewRepository: getIt<ICrewRepository>(),
    ),
  );
  getIt.registerFactory<CharacterFormOptionsCubit>(
    () => CharacterFormOptionsCubit(
      devilFruitService: getIt<IDevilFruitService>(),
      crewRepository: getIt<ICrewRepository>(),
    ),
  );
  getIt.registerFactory<DuelsBloc>(
    () => DuelsBloc(
      featuredCharacterRepository: getIt<IFeaturedCharacterRepository>(),
      customCharacterRepository: getIt<ICustomCharacterRepository>(),
    ),
  );

  getIt.registerFactory<ListCrewsBloc>(
    () => ListCrewsBloc(
      crewRepository: getIt<ICrewRepository>(),
      authService: getIt<IAuthService>(),
    ),
  );
  getIt.registerFactoryParam<CrewDetailsBloc, CrewModel, void>(
    (crew, _) => CrewDetailsBloc(
      crew: crew,
      crewRepository: getIt<ICrewRepository>(),
      customCharacterRepository: getIt<ICustomCharacterRepository>(),
      authService: getIt<IAuthService>(),
    ),
  );
  // The edit screen seeds the cubit with the crew's current images.
  getIt.registerFactoryParam<CrewImageCubit, CrewModel?, void>(
    (crew, _) => CrewImageCubit(
      crewImageService: getIt<ICrewImageService>(),
      jollyRogerUrl: crew?.jollyRogerUrl,
      boatUrl: crew?.boatImageUrl,
    ),
  );
  getIt.registerFactory<EditCrewBloc>(
    () => EditCrewBloc(crewRepository: getIt<ICrewRepository>()),
  );
  // userId comes from the auth state at screen-build time, so it is passed as
  // a factory param rather than resolved from the container.
  getIt.registerFactoryParam<CreateCrewBloc, String?, void>(
    (userId, _) => CreateCrewBloc(
      crewRepository: getIt<ICrewRepository>(),
      userId: userId,
    ),
  );

  getIt.registerFactory<NamiFinancesBloc>(
    () => NamiFinancesBloc(
      getIt<INamiFinancesService>(),
      getIt<INamiRagService>(),
    ),
  );

  getIt.registerFactory<NamiChatBloc>(
    () => NamiChatBloc(
      getIt<INamiRagService>(),
      getIt<IGemmaService>(),
      getIt<INamiFinancesService>(),
      getIt<FunctionRegistry>(instanceName: kNamiToolsRegistry),
      localeService: getIt<ILocaleService>(),
    ),
  );

  getIt.registerFactory<ZoroWorkoutBloc>(
    () => ZoroWorkoutBloc(
      service: getIt<IWorkoutAssessmentService>(),
      authService: getIt<IAuthService>(),
    ),
  );
  getIt.registerFactory<SanjiCookingBloc>(
    () => SanjiCookingBloc(
      workoutService: getIt<IWorkoutAssessmentService>(),
      cookingRepository: getIt<ICookingRepository>(),
      nutritionService: getIt<INutritionCalculationService>(),
      authService: getIt<IAuthService>(),
    ),
  );

  // A singleton on purpose: the timeline, its widgets and the goal details
  // route all read and mutate the same goals list.
  getIt.registerLazySingleton<RobinKnowledgeBloc>(
    () => RobinKnowledgeBloc(
      plannerRepository: getIt<PlannerRepositoryInterface>(),
    ),
  );

  getIt.registerFactory<VegapunkChatCubit>(
    () => VegapunkChatCubit(
      repository: getIt<IVegapunkChatRepository>(),
      ragService: getIt<IRAGService>(),
      historyRepository: getIt<IVegapunkChatHistoryRepository>(),
      localeService: getIt<ILocaleService>(),
    ),
  );
}

extension FeaturesModuleExtensions on GetIt {
  CalculatorCubit get calculatorCubit => get<CalculatorCubit>();
  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
  CustomCharacterBloc get customCharacterBloc => get<CustomCharacterBloc>();
  CharacterFormOptionsCubit get characterFormOptionsCubit =>
      get<CharacterFormOptionsCubit>();
  DuelsBloc get duelsBloc => get<DuelsBloc>();
  ListCrewsBloc get listCrewsBloc => get<ListCrewsBloc>();
  CrewDetailsBloc crewDetailsBloc(CrewModel crew) =>
      get<CrewDetailsBloc>(param1: crew);
  CrewImageCubit crewImageCubit([CrewModel? crew]) =>
      get<CrewImageCubit>(param1: crew);
  ZoroWorkoutBloc get zoroWorkoutBloc => get<ZoroWorkoutBloc>();
  SanjiCookingBloc get sanjiCookingBloc => get<SanjiCookingBloc>();
  RobinKnowledgeBloc get robinKnowledgeBloc => get<RobinKnowledgeBloc>();
  NamiChatBloc get namiChatBloc => get<NamiChatBloc>();
  VegapunkChatCubit get vegapunkChatCubit => get<VegapunkChatCubit>();
}

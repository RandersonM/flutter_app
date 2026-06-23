import 'package:get_it/get_it.dart';
import 'package:opfan/app/di/core_module.dart';
import 'package:opfan/app/di/theme_module.dart';
import 'package:opfan/app/di/locale_module.dart';
import 'package:opfan/app/di/features_module.dart';

// Services
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/notification_service.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/gemini_service.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/services/nami_finances_service.dart';

// Repositories
import 'package:opfan/core/repository/featured_character_repository.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/core/repository/interfaces/cooking_repository_interface.dart';
import 'package:opfan/core/repository/planner_repository.dart';

// Cubits & BLoCs
import 'package:opfan/core/calculator/calculator_cubit.dart';
import 'package:opfan/core/theme/cubit/theme_cubit.dart';
import 'package:opfan/core/locale/cubit/locale_cubit.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/features/one_piece/bloc/characters_cubit.dart';
import 'package:opfan/features/one_piece/bloc/search_cubit.dart';
import 'package:opfan/features/home/bloc/home_bloc.dart';
import 'package:opfan/features/devil_fruit/bloc/devil_fruit_bloc.dart';
import 'package:opfan/features/crews/bloc/index.dart';
import 'package:opfan/features/zoro_workout/bloc/index.dart';
import 'package:opfan/features/sanji_cooking/bloc/index.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  registerCoreModule(getIt);
  registerThemeModule(getIt);
  registerLocaleModule(getIt);
  registerFeaturesModule(getIt);
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
  GeminiService get geminiService => get<GeminiService>();
  ICookingRepository get cookingRepository => get<ICookingRepository>();
  AuthService get authService => get<AuthService>();
  FirestoreService get firestoreService => get<FirestoreService>();
  CustomCharacterRepository get customCharacterRepository =>
      get<CustomCharacterRepository>();
  CustomCharacterService get customCharacterService =>
      get<CustomCharacterService>();
  CrewRepository get crewRepository => get<CrewRepository>();
  PlannerRepository get plannerRepository => get<PlannerRepository>();
  NamiFinancesService get namiFinancesService => get<NamiFinancesService>();

  ThemeCubit get themeCubit => get<ThemeCubit>();
  LocaleCubit get localeCubit => get<LocaleCubit>();
  CalculatorCubit get calculatorCubit => get<CalculatorCubit>();

  CharactersCubit get charactersCubit => get<CharactersCubit>();
  SearchCubit get searchCubit => get<SearchCubit>();
  HomeBloc get homeBloc => get<HomeBloc>();
  DevilFruitBloc get devilFruitBloc => get<DevilFruitBloc>();
  ListCrewsBloc get listCrewsBloc => get<ListCrewsBloc>();
  AuthBloc get authBloc => get<AuthBloc>();
  ZoroWorkoutBloc get zoroWorkoutBloc => get<ZoroWorkoutBloc>();
  SanjiCookingBloc get sanjiCookingBloc => get<SanjiCookingBloc>();
  RobinKnowledgeBloc get robinKnowledgeBloc => get<RobinKnowledgeBloc>();
}

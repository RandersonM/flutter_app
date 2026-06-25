import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/notification_service.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/gemini_service.dart';
import 'package:opfan/core/services/character_image_service.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository_interface.dart';
import 'package:opfan/core/services/nami_finances_service.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository.dart';
import 'package:opfan/features/custom_character/data/repository/custom_character_repository_interface.dart';
import 'package:opfan/features/crews/data/repository/crew_repository.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository.dart';
import 'package:opfan/features/sanji_cooking/data/repository/cooking_repository_interface.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';
import 'package:opfan/core/auth/blocs/index.dart';

import 'package:opfan/core/services/storage_service.dart';

void registerCoreModule(GetIt getIt) {
  getIt.registerSingleton<IStorageService>(HiveStorageService());
  getIt.registerSingleton<EnvironmentService>(EnvironmentService.instance);

  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<DevilFruitService>(() => DevilFruitService());
  getIt.registerLazySingleton<YouTubeService>(() => YouTubeService());
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());
  getIt.registerLazySingleton<CharacterImageService>(
      () => CharacterImageService());

  getIt.registerLazySingleton<ICookingRepository>(() => CookingRepository());
  getIt.registerLazySingleton<IFeaturedCharacterRepository>(
    () => FeaturedCharacterRepository(),
  );

  getIt.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepository(),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(userProfileRepository: getIt<IUserProfileRepository>()),
  );
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());

  getIt.registerLazySingleton<ICrewRepository>(() => CrewRepository());
  getIt.registerLazySingleton<ICustomCharacterRepository>(
    () => CustomCharacterRepository(getIt<ICrewRepository>()),
  );
  getIt.registerLazySingleton<PlannerRepositoryInterface>(
    () => PlannerRepository(firestoreService: getIt<FirestoreService>()),
  );
  getIt.registerLazySingleton<NamiFinancesService>(() => NamiFinancesService());

  getIt.registerLazySingleton<AuthBloc>(() {
    final authBloc = AuthBloc(authService: getIt<AuthService>());
    authBloc.add(const AuthStarted());
    return authBloc;
  });
}

extension CoreModuleExtensions on GetIt {
  EnvironmentService get environmentService => get<EnvironmentService>();
  IStorageService get storageService => get<IStorageService>();
  NotificationService get notificationService => get<NotificationService>();
  IFeaturedCharacterRepository get featuredCharacterRepository =>
      get<IFeaturedCharacterRepository>();
  DevilFruitService get devilFruitService => get<DevilFruitService>();
  YouTubeService get youTubeService => get<YouTubeService>();
  GeminiService get geminiService => get<GeminiService>();
  CharacterImageService get characterImageService =>
      get<CharacterImageService>();
  ICookingRepository get cookingRepository => get<ICookingRepository>();
  IUserProfileRepository get userProfileRepository =>
      get<IUserProfileRepository>();
  AuthService get authService => get<AuthService>();
  FirestoreService get firestoreService => get<FirestoreService>();
  ICustomCharacterRepository get customCharacterRepository =>
      get<ICustomCharacterRepository>();
  ICrewRepository get crewRepository => get<ICrewRepository>();
  PlannerRepositoryInterface get plannerRepository =>
      get<PlannerRepositoryInterface>();
  NamiFinancesService get namiFinancesService => get<NamiFinancesService>();
  AuthBloc get authBloc => get<AuthBloc>();
}

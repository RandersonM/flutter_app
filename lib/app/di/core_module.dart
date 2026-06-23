import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/notification_service.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/gemini_service.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/core/services/firestore_service.dart';
import 'package:opfan/core/services/nami_finances_service.dart';
import 'package:opfan/core/repository/featured_character_repository.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/core/repository/cooking_repository.dart';
import 'package:opfan/core/repository/interfaces/cooking_repository_interface.dart';
import 'package:opfan/core/repository/planner_repository.dart';
import 'package:opfan/core/auth/blocs/index.dart';

void registerCoreModule(GetIt getIt) {
  getIt.registerSingleton<EnvironmentService>(EnvironmentService.instance);

  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<DevilFruitService>(() => DevilFruitService());
  getIt.registerLazySingleton<YouTubeService>(() => YouTubeService());
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

  getIt.registerLazySingleton<ICookingRepository>(() => CookingRepository());
  getIt.registerLazySingleton<FeaturedCharacterRepository>(
    () => FeaturedCharacterRepository(),
  );

  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());

  getIt.registerLazySingleton<CustomCharacterRepository>(
    () => CustomCharacterRepository(),
  );
  getIt.registerLazySingleton<CustomCharacterService>(
    () => CustomCharacterService(),
  );
  getIt.registerLazySingleton<CrewRepository>(() => CrewRepository());
  getIt.registerLazySingleton<PlannerRepository>(
    () => PlannerRepository(firestoreService: getIt<FirestoreService>()),
  );
  getIt.registerLazySingleton<NamiFinancesService>(() => NamiFinancesService());

  getIt.registerLazySingleton<AuthBloc>(() {
    final authBloc = AuthBloc(authService: getIt<AuthService>());
    authBloc.add(const AuthStarted());
    return authBloc;
  });
}

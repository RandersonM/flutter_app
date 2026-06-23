import 'package:get_it/get_it.dart';
import 'package:opfan/app/di/core_module.dart';
import 'package:opfan/app/di/theme_module.dart';
import 'package:opfan/app/di/locale_module.dart';
import 'package:opfan/app/di/features_module.dart';

import 'package:opfan/core/services/environment_service.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/auth_service.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';

export 'package:opfan/app/di/core_module.dart';
export 'package:opfan/app/di/theme_module.dart';
export 'package:opfan/app/di/locale_module.dart';
export 'package:opfan/app/di/features_module.dart';

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
      getIt.isRegistered<IFeaturedCharacterRepository>() &&
      getIt.isRegistered<DevilFruitService>() &&
      getIt.isRegistered<YouTubeService>() &&
      getIt.isRegistered<AuthService>();
}

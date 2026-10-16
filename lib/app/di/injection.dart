import 'package:get_it/get_it.dart';
import 'package:opfan/app/di/core_module.dart';
import 'package:opfan/app/di/theme_module.dart';
import 'package:opfan/app/di/locale_module.dart';
import 'package:opfan/app/di/features_module.dart';

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

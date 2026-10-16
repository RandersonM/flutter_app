import 'package:get_it/get_it.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/theme/cubit/theme_cubit.dart';

void registerThemeModule(GetIt getIt) {
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<IThemeService>()),
  );
}

extension ThemeModuleExtensions on GetIt {
  ThemeCubit get themeCubit => get<ThemeCubit>();
}

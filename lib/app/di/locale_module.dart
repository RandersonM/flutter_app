import 'package:get_it/get_it.dart';
import 'package:opfan/core/locale/cubit/locale_cubit.dart';

void registerLocaleModule(GetIt getIt) {
  getIt.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
}

extension LocaleModuleExtensions on GetIt {
  LocaleCubit get localeCubit => get<LocaleCubit>();
}

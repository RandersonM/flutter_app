import 'package:get_it/get_it.dart';
import 'package:opfan/core/locale/bloc/locale_cubit.dart';
import 'package:opfan/core/services/index.dart';

void registerLocaleModule(GetIt getIt) {
  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<ILocaleService>()),
  );
}

extension LocaleModuleExtensions on GetIt {
  LocaleCubit get localeCubit => get<LocaleCubit>();
}

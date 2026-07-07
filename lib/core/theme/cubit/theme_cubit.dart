import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/theme/cubit/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(isDarkMode: GetIt.I.get<IThemeService>().isDarkMode));

  Future<void> toggleTheme() async {
    await GetIt.I.get<IThemeService>().persistToggle();
    emit(ThemeState(isDarkMode: GetIt.I.get<IThemeService>().isDarkMode));
  }

  Future<void> setDarkMode(bool isDark) async {
    await GetIt.I.get<IThemeService>().persistDarkMode(isDark);
    emit(ThemeState(isDarkMode: isDark));
  }
}

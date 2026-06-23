import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/theme_service.dart';
import 'package:opfan/core/theme/cubit/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDarkMode: ThemeService.isDarkMode));

  Future<void> toggleTheme() async {
    await ThemeService.persistToggle();
    emit(ThemeState(isDarkMode: ThemeService.isDarkMode));
  }

  Future<void> setDarkMode(bool isDark) async {
    await ThemeService.persistDarkMode(isDark);
    emit(ThemeState(isDarkMode: isDark));
  }
}

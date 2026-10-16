import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/theme/cubit/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._themeService)
    : super(ThemeState(isDarkMode: _themeService.isDarkMode));

  final IThemeService _themeService;

  Future<void> toggleTheme() async {
    await _themeService.persistToggle();
    emit(ThemeState(isDarkMode: _themeService.isDarkMode));
  }

  Future<void> setDarkMode(bool isDark) async {
    await _themeService.persistDarkMode(isDark);
    emit(ThemeState(isDarkMode: isDark));
  }
}

abstract class IThemeService {
  Future<void> initialize();
  bool get isDarkMode;
  Future<void> persistToggle();
  Future<void> persistDarkMode(bool isDark);
}

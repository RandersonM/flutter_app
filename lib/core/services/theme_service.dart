import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/theme_model.dart';

class ThemeService extends ChangeNotifier {
  static const String _boxName = 'theme_settings_box';
  static const String _settingsKey = 'theme_settings';
  
  static Box<ThemeSettings>? _box;
  static ThemeSettings _currentSettings = ThemeSettings();
  
  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<ThemeSettings>(_boxName);
      } else {
        _box = Hive.box<ThemeSettings>(_boxName);
      }
      
      // Load saved settings
      final savedSettings = _box!.get(_settingsKey);
      if (savedSettings != null) {
        _currentSettings = savedSettings;
      }
    } catch (e) {
      debugPrint('ThemeService: Error initializing - $e');
      // If there's an error, use default settings
      _currentSettings = ThemeSettings();
    }
  }

  static ThemeSettings get currentSettings => _currentSettings;

  static bool get isDarkMode => _currentSettings.isDarkMode;

  static Future<void> toggleTheme() async {
    try {
      _currentSettings = _currentSettings.copyWith(
        isDarkMode: !_currentSettings.isDarkMode,
      );
      await _box?.put(_settingsKey, _currentSettings);
      _instance.notifyListeners();
    } catch (e) {
      debugPrint('ThemeService: Error toggling theme - $e');
    }
  }

  static Future<void> setDarkMode(bool isDark) async {
    try {
      _currentSettings = _currentSettings.copyWith(isDarkMode: isDark);
      await _box?.put(_settingsKey, _currentSettings);
      _instance.notifyListeners();
    } catch (e) {
      debugPrint('ThemeService: Error setting dark mode - $e');
    }
  }
} 
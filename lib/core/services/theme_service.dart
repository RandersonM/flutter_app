import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/theme_model.dart';

class ThemeService {
  static const String _boxName = 'theme_settings_box';
  static const String _settingsKey = 'theme_settings';

  static Box<ThemeSettings>? _box;
  static ThemeSettings _currentSettings = ThemeSettings();

  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<ThemeSettings>(_boxName);
      } else {
        _box = Hive.box<ThemeSettings>(_boxName);
      }
      final savedSettings = _box!.get(_settingsKey);
      if (savedSettings != null) {
        _currentSettings = savedSettings;
      }
    } catch (e) {
      debugPrint('ThemeService: Error initializing - $e');
      _currentSettings = ThemeSettings();
    }
  }

  static bool get isDarkMode => _currentSettings.isDarkMode;

  static Future<void> persistToggle() async {
    try {
      _currentSettings = _currentSettings.copyWith(
        isDarkMode: !_currentSettings.isDarkMode,
      );
      await _box?.put(_settingsKey, _currentSettings);
    } catch (e) {
      debugPrint('ThemeService: Error toggling theme - $e');
    }
  }

  static Future<void> persistDarkMode(bool isDark) async {
    try {
      _currentSettings = _currentSettings.copyWith(isDarkMode: isDark);
      await _box?.put(_settingsKey, _currentSettings);
    } catch (e) {
      debugPrint('ThemeService: Error setting dark mode - $e');
    }
  }
}
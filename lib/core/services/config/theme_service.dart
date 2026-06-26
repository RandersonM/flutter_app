import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/theme_model.dart';

import 'i_theme_service.dart';

class ThemeService implements IThemeService {
  static const String _boxName = 'theme_settings_box';
  static const String _settingsKey = 'theme_settings';

  Box<ThemeSettings>? _box;
  ThemeSettings _currentSettings = ThemeSettings();

  @override
  Future<void> initialize() async {
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

  @override
  bool get isDarkMode => _currentSettings.isDarkMode;

  @override
  Future<void> persistToggle() async {
    try {
      _currentSettings = _currentSettings.copyWith(
        isDarkMode: !_currentSettings.isDarkMode,
      );
      await _box?.put(_settingsKey, _currentSettings);
    } catch (e) {
      debugPrint('ThemeService: Error toggling theme - $e');
    }
  }

  @override
  Future<void> persistDarkMode(bool isDark) async {
    try {
      _currentSettings = _currentSettings.copyWith(isDarkMode: isDark);
      await _box?.put(_settingsKey, _currentSettings);
    } catch (e) {
      debugPrint('ThemeService: Error setting dark mode - $e');
    }
  }
}

import 'package:hive/hive.dart';

part 'theme_model.g.dart';

@HiveType(typeId: 2)
class ThemeSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  ThemeSettings({
    this.isDarkMode = false,
  });

  ThemeSettings copyWith({
    bool? isDarkMode,
  }) {
    return ThemeSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
} 
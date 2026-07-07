import 'package:hive/hive.dart';

class ThemeSettings extends HiveObject {
  bool isDarkMode;

  ThemeSettings({this.isDarkMode = false});

  ThemeSettings copyWith({bool? isDarkMode}) {
    return ThemeSettings(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}

class ThemeSettingsAdapter extends TypeAdapter<ThemeSettings> {
  @override
  final int typeId = 2;

  @override
  ThemeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeSettings(
      isDarkMode: fields[0] == null ? false : fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeSettings obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.isDarkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:json_annotation/json_annotation.dart';

part 'devil_fruit.g.dart';

@JsonSerializable(explicitToJson: true)
class DevilFruit {
  DevilFruit({
    required this.id,
    required this.name,
    required this.description,
    required this.romanName,
    required this.type,
    this.filename,
    this.technicalFile,
  });

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name', defaultValue: 'Nome não disponível')
  String name;

  @JsonKey(name: 'description', defaultValue: 'Descrição não disponível')
  String description;

  @JsonKey(name: 'roman_name', defaultValue: '')
  String romanName;

  @JsonKey(name: 'type', defaultValue: 'Tipo não disponível')
  String type;

  @JsonKey(name: 'filename')
  String? filename;

  @JsonKey(name: 'technicalFile')
  String? technicalFile;

  factory DevilFruit.fromJson(Map<String, dynamic> json) =>
      _$DevilFruitFromJson(json);

  Map<String, dynamic> toJson() => _$DevilFruitToJson(this);
}

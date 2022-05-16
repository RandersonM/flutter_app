// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:json_annotation/json_annotation.dart';

part 'character.g.dart';

@JsonSerializable(explicitToJson: true)
class Character {
  Character(
      {required this.id,
      required this.name,
      this.nickname,
      this.devilFruit,
      this.haki,
      required this.affiliations,
      required this.image,
      required this.occupation,
      required this.bounty});

  @JsonKey(name: 'bounty')
  String bounty;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'nickname')
  String? nickname;

  @JsonKey(name: 'affiliations')
  List<String> affiliations;

  @JsonKey(name: 'haki')
  List<String>? haki;

  @JsonKey(name: 'devil_fruit')
  String? devilFruit;

  @JsonKey(name: 'occupation')
  List<String> occupation;

  @JsonKey(name: 'image')
  String image;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}

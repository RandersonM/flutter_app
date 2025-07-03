// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:hive/hive.dart';
import 'package:simple_app/core/one_piece/models/character.dart';

part 'featured_character.g.dart';

@HiveType(typeId: 0)
class FeaturedCharacter extends HiveObject {
  @HiveField(0)
  late String date; // Data no formato YYYY-MM-DD

  @HiveField(1)
  late int characterId;

  @HiveField(2)
  late String characterName;

  @HiveField(3)
  late String characterImage;

  @HiveField(4)
  late String characterBounty;

  @HiveField(5)
  String? characterNickname;

  @HiveField(6)
  late List<String> characterAffiliations;

  @HiveField(7)
  List<String>? characterHaki;

  @HiveField(8)
  String? characterDevilFruit;

  @HiveField(9)
  late List<String> characterOccupation;

  @HiveField(10)
  late bool isManuallySelected; // Se foi selecionado manualmente pelo usuário

  FeaturedCharacter();

  FeaturedCharacter.fromCharacter(Character character, this.date,
      {this.isManuallySelected = false}) {
    characterId = character.id;
    characterName = character.name;
    characterImage = character.image;
    characterBounty = character.bounty;
    characterNickname = character.nickname;
    characterAffiliations = character.affiliations;
    characterHaki = character.haki;
    characterDevilFruit = character.devilFruit;
    characterOccupation = character.occupation;
  }

  Character toCharacter() {
    return Character(
      id: characterId,
      name: characterName,
      image: characterImage,
      bounty: characterBounty,
      nickname: characterNickname,
      affiliations: characterAffiliations,
      haki: characterHaki,
      devilFruit: characterDevilFruit,
      occupation: characterOccupation,
    );
  }

  bool get isToday {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return date == todayString;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayString =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    return date == yesterdayString;
  }

  @override
  String toString() {
    return 'FeaturedCharacter(date: $date, characterName: $characterName, isManuallySelected: $isManuallySelected)';
  }
}

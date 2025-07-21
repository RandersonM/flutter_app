// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';

part 'today_character.g.dart';

@HiveType(typeId: 0)
class TodayCharacter extends HiveObject {
  @HiveField(0)
  late String date;

  @HiveField(1)
  late String characterId;

  @HiveField(2)
  late bool isManuallySelected;

  final String? id;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodayCharacter({
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  TodayCharacter.fromCharacter(CustomCharacterModel character, this.date,
      {this.isManuallySelected = false,
      this.id,
      this.userId,
      this.createdAt,
      this.updatedAt}) {
    characterId = character.id ?? '0';
  }

  factory TodayCharacter.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    final character = TodayCharacter(
      id: documentId,
      userId: data['userId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );

    character.date = data['date'] as String;
    character.characterId = data['characterId'] as String;
    character.isManuallySelected = data['isManuallySelected'] as bool;

    return character;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'characterId': characterId,
      'isManuallySelected': isManuallySelected,
    };
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

  TodayCharacter copyWith({
    String? id,
    String? userId,
    String? date,
    String? characterId,
    bool? isManuallySelected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final character = TodayCharacter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

    character.date = date ?? this.date;
    character.characterId = characterId ?? this.characterId;
    character.isManuallySelected =
        isManuallySelected ?? this.isManuallySelected;

    return character;
  }

  @override
  String toString() {
    return 'TodayCharacter(date: $date, characterId: $characterId, isManuallySelected: $isManuallySelected)';
  }
}

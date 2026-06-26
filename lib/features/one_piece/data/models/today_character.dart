// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

class TodayCharacter extends HiveObject {
  late String date;

  late String characterId;

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

class TodayCharacterAdapter extends TypeAdapter<TodayCharacter> {
  @override
  final int typeId = 0;

  @override
  TodayCharacter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final character = TodayCharacter();
    if (fields[0] != null) character.date = fields[0] as String;
    if (fields[1] != null) character.characterId = fields[1] as String;
    if (fields[2] != null) character.isManuallySelected = fields[2] as bool;
    return character;
  }

  @override
  void write(BinaryWriter writer, TodayCharacter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.characterId)
      ..writeByte(2)
      ..write(obj.isManuallySelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayCharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

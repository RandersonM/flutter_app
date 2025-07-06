import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_model.dart';

class CustomCharacterModel {
  final String? id;
  final String? userId;
  final String name;
  final String? nickname;
  final String? devilFruit;
  final List<String>? haki;
  final List<String> affiliations;
  final String image;
  final List<String> occupation;
  final String bounty;
  final String? signo;
  final String? crew;
  final String? status;
  final int? age;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomCharacterModel({
    this.id,
    this.userId,
    required this.name,
    this.nickname,
    this.devilFruit,
    this.haki,
    required this.affiliations,
    required this.image,
    required this.occupation,
    required this.bounty,
    this.signo,
    this.crew,
    this.status,
    this.age,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomCharacterModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CustomCharacterModel(
      id: documentId,
      userId: data['userId'] as String?,
      name: data['name'] as String,
      nickname: data['nickname'] as String?,
      devilFruit: data['devilFruit'] as String?,
      haki: data['haki'] != null 
          ? List<String>.from(data['haki'] as List)
          : null,
      affiliations: List<String>.from(data['affiliations'] as List),
      image: data['image'] as String,
      occupation: List<String>.from(data['occupation'] as List),
      bounty: data['bounty'] as String,
      signo: data['signo'] as String?,
      crew: data['crew'] as String?,
      status: data['status'] as String?,
      age: data['age'] as int?,
      description: data['description'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nickname': nickname,
      'devilFruit': devilFruit,
      'haki': haki,
      'affiliations': affiliations,
      'image': image,
      'occupation': occupation,
      'bounty': bounty,
      'signo': signo,
      'crew': crew,
      'status': status,
      'age': age,
      'description': description,
    };
  }

  Map<String, dynamic> toFirestoreWithEnglishKeys() {
    return {
      'name': name,
      'nickname': nickname,
      'devilFruit': devilFruit,
      'haki': haki,
      'affiliations': affiliations,
      'image': image,
      'occupation': occupation,
      'bounty': bounty,
      'signo': signo,
      'crew': crew,
      'status': status,
      'age': age,
      'description': description,
    };
  }

  CustomCharacterModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? nickname,
    String? devilFruit,
    List<String>? haki,
    List<String>? affiliations,
    String? image,
    List<String>? occupation,
    String? bounty,
    String? signo,
    String? crew,
    String? status,
    int? age,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomCharacterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      devilFruit: devilFruit ?? this.devilFruit,
      haki: haki ?? this.haki,
      affiliations: affiliations ?? this.affiliations,
      image: image ?? this.image,
      occupation: occupation ?? this.occupation,
      bounty: bounty ?? this.bounty,
      signo: signo ?? this.signo,
      crew: crew ?? this.crew,
      status: status ?? this.status,
      age: age ?? this.age,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CustomCharacterModel(id: $id, userId: $userId, name: $name, nickname: $nickname, devilFruit: $devilFruit, bounty: $bounty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCharacterModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.nickname == nickname &&
        other.devilFruit == devilFruit &&
        other.bounty == bounty;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        nickname.hashCode ^
        devilFruit.hashCode ^
        bounty.hashCode;
  }

  CharacterModel toCharacterModel() {
    return CharacterModel(
      id: id,
      userId: userId,
      name: name,
      nickname: nickname,
      devilFruit: devilFruit,
      haki: haki,
      affiliations: affiliations,
      image: image,
      occupation: occupation,
      bounty: bounty,
      signo: signo,
      crew: crew,
      status: status,
      age: age,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
} 
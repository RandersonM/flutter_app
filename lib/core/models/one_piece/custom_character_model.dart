import 'package:cloud_firestore/cloud_firestore.dart';
import 'fighting_style_model.dart';

class CustomCharacterModel {
  final String? id;
  final String? userId;
  final String name;
  final String? nickname;
  final String? devilFruit;
  final List<String>? haki;
  final List<String> affiliations;
  final String image;
  final List<String> occupation; // apenas funções de tripulação
  final FightingStyleModel? fightingStyle; // novo campo para estilo de luta
  final String bounty;
  final String? signo;
  final String? crew;
  final String? status;
  final String? race;
  final int? age;
  final DateTime? birthDate;
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
    this.fightingStyle,
    required this.bounty,
    this.signo,
    this.crew,
    this.status,
    this.race,
    this.age,
    this.birthDate,
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
      fightingStyle: data['fightingStyle'] != null
          ? FightingStyleModel.fromMap(
              data['fightingStyle'] as Map<String, dynamic>)
          : null,
      bounty: data['bounty'] as String,
      signo: data['signo'] as String?,
      crew: data['crew'] as String?,
      status: data['status'] as String?,
      race: data['race'] as String?,
      age: data['age'] as int?,
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      description: data['description'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  factory CustomCharacterModel.fromJson(Map<String, dynamic> json) {
    return CustomCharacterModel(
      id: json['id']?.toString(),
      userId: json['userId'] as String?,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      devilFruit: json['devilFruit'] as String?,
      haki:
          json['haki'] != null ? List<String>.from(json['haki'] as List) : null,
      affiliations: List<String>.from(json['affiliations'] as List),
      image: json['image'] as String,
      occupation: List<String>.from(json['occupation'] as List),
      fightingStyle: json['fightingStyle'] != null
          ? FightingStyleModel.fromMap(
              json['fightingStyle'] as Map<String, dynamic>)
          : null,
      bounty: json['bounty'] as String,
      signo: json['signo'] as String?,
      crew: json['crew'] as String?,
      status: json['status'] as String?,
      race: json['race'] as String?,
      age: json['age'] as int?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
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
      'fightingStyle': fightingStyle?.toMap(),
      'bounty': bounty,
      'signo': signo,
      'crew': crew,
      'status': status,
      'race': race,
      'age': age,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
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
      'fightingStyle': fightingStyle?.toMap(),
      'bounty': bounty,
      'signo': signo,
      'crew': crew,
      'status': status,
      'race': race,
      'age': age,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
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
    FightingStyleModel? fightingStyle,
    String? bounty,
    String? signo,
    String? crew,
    String? status,
    String? race,
    int? age,
    DateTime? birthDate,
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
      fightingStyle: fightingStyle ?? this.fightingStyle,
      bounty: bounty ?? this.bounty,
      signo: signo ?? this.signo,
      crew: crew ?? this.crew,
      status: status ?? this.status,
      race: race ?? this.race,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
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

  bool get isCustomCharacter => userId != null;

  int? get calculatedAge => age;

  // Removendo o getter birthDate que estava calculando incorretamente
  // Agora usamos o campo birthDate diretamente
} 
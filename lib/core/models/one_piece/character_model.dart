import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CharacterModel {
  @JsonKey(name: 'id', fromJson: _idFromJson, toJson: _idToJson)
  final String? id;
  
  @JsonKey(name: 'userId', includeFromJson: false, includeToJson: false)
  final String? userId;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'nickname')
  final String? nickname;
  
  @JsonKey(name: 'devil_fruit')
  final String? devilFruit;
  
  @JsonKey(name: 'haki')
  final List<String>? haki;
  
  @JsonKey(name: 'affiliations')
  final List<String> affiliations;
  
  @JsonKey(name: 'image')
  final String image;
  
  @JsonKey(name: 'occupation')
  final List<String> occupation;
  
  @JsonKey(name: 'bounty')
  final String bounty;
  
  @JsonKey(name: 'signo')
  final String? signo;
  
  @JsonKey(name: 'crew')
  final String? crew;
  
  @JsonKey(name: 'status')
  final String? status;
  
  @JsonKey(name: 'age')
  final int? age;
  
  @JsonKey(name: 'birthDate', includeFromJson: false, includeToJson: false)
  final DateTime? birthDate;
  
  @JsonKey(name: 'description', includeFromJson: false, includeToJson: false)
  final String? description;
  
  @JsonKey(name: 'createdAt', includeFromJson: false, includeToJson: false)
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt', includeFromJson: false, includeToJson: false)
  final DateTime? updatedAt;

  CharacterModel({
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
    this.birthDate,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);

  factory CharacterModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CharacterModel(
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

  Map<String, dynamic> toJson() => _$CharacterModelToJson(this);

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
      'bounty': bounty,
      'signo': signo,
      'crew': crew,
      'status': status,
      'age': age,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'description': description,
    };
  }

  CharacterModel copyWith({
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
    DateTime? birthDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CharacterModel(
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
      birthDate: birthDate ?? this.birthDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  int? get calculatedAge {
    if (birthDate == null) return age;
    
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate!.year;
    
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      calculatedAge--;
    }
    
    return calculatedAge;
  }

  bool get isCustomCharacter => userId != null;

  static String? _idFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toString();
    if (value is String) return value;
    return value.toString();
  }

  static dynamic _idToJson(String? value) {
    if (value == null) return null;
    return int.tryParse(value) ?? value;
  }

  @override
  String toString() {
    return 'CharacterModel(id: $id, userId: $userId, name: $name, nickname: $nickname, devilFruit: $devilFruit, bounty: $bounty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterModel &&
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
} 
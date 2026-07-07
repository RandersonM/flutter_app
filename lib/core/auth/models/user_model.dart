// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(name: 'uid')
  final String uid;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'display_name')
  final String displayName;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  @JsonKey(name: 'provider_id')
  final String providerId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'last_sign_in')
  final DateTime lastSignIn;

  // ── Body Profile Fields ────────────────────────────────────────────────────

  /// Sexo biológico: 'male' | 'female'
  @JsonKey(name: 'gender')
  final String? gender;

  /// Idade em anos completos
  @JsonKey(name: 'age')
  final int? age;

  /// Altura em centímetros (ex: 175.0)
  @JsonKey(name: 'height_cm')
  final double? heightCm;

  /// Peso em quilogramas (ex: 78.5)
  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  /// Nível de atividade física:
  /// 'sedentary' | 'light' | 'moderate' | 'intense' | 'very_intense'
  @JsonKey(name: 'activity_level')
  final String? activityLevel;

  /// Objetivo: 'weight_loss' | 'maintenance' | 'muscle_gain'
  @JsonKey(name: 'goal')
  final String? goal;

  // ── Optional Circumferences (cm) ──────────────────────────────────────────

  @JsonKey(name: 'waist_cm')
  final double? waistCm;

  @JsonKey(name: 'chest_cm')
  final double? chestCm;

  @JsonKey(name: 'arm_cm')
  final double? armCm;

  @JsonKey(name: 'hip_cm')
  final double? hipCm;

  @JsonKey(name: 'thigh_cm')
  final double? thighCm;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.providerId,
    required this.createdAt,
    required this.lastSignIn,
    // Body profile — mandatory
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
    // Body profile — optional circumferences
    this.waistCm,
    this.chestCm,
    this.armCm,
    this.hipCm,
    this.thighCm,
  });

  /// Returns [true] when all mandatory body profile fields are filled.
  bool get isProfileComplete =>
      gender != null &&
      gender!.isNotEmpty &&
      age != null &&
      age! > 0 &&
      heightCm != null &&
      heightCm! > 0 &&
      weightKg != null &&
      weightKg! > 0 &&
      activityLevel != null &&
      activityLevel!.isNotEmpty &&
      goal != null &&
      goal!.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    emailVerified,
    providerId,
    createdAt,
    lastSignIn,
    gender,
    age,
    heightCm,
    weightKg,
    activityLevel,
    goal,
    waistCm,
    chestCm,
    armCm,
    hipCm,
    thighCm,
  ];

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    String? providerId,
    DateTime? createdAt,
    DateTime? lastSignIn,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? goal,
    double? waistCm,
    double? chestCm,
    double? armCm,
    double? hipCm,
    double? thighCm,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      armCm: armCm ?? this.armCm,
      hipCm: hipCm ?? this.hipCm,
      thighCm: thighCm ?? this.thighCm,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
        'gender: $gender, age: $age, heightCm: $heightCm, weightKg: $weightKg, '
        'activityLevel: $activityLevel, goal: $goal, '
        'isProfileComplete: $isProfileComplete)';
  }
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String,
      photoUrl: fields[3] as String?,
      emailVerified: fields[4] as bool,
      providerId: fields[5] as String,
      createdAt: fields[6] as DateTime,
      lastSignIn: fields[7] as DateTime,
      gender: fields[8] as String?,
      age: fields[9] as int?,
      heightCm: fields[10] as double?,
      weightKg: fields[11] as double?,
      activityLevel: fields[12] as String?,
      goal: fields[13] as String?,
      waistCm: fields[14] as double?,
      chestCm: fields[15] as double?,
      armCm: fields[16] as double?,
      hipCm: fields[17] as double?,
      thighCm: fields[18] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.emailVerified)
      ..writeByte(5)
      ..write(obj.providerId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastSignIn)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.age)
      ..writeByte(10)
      ..write(obj.heightCm)
      ..writeByte(11)
      ..write(obj.weightKg)
      ..writeByte(12)
      ..write(obj.activityLevel)
      ..writeByte(13)
      ..write(obj.goal)
      ..writeByte(14)
      ..write(obj.waistCm)
      ..writeByte(15)
      ..write(obj.chestCm)
      ..writeByte(16)
      ..write(obj.armCm)
      ..writeByte(17)
      ..write(obj.hipCm)
      ..writeByte(18)
      ..write(obj.thighCm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

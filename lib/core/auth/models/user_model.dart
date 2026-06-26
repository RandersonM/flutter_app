// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class UserModel extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'uid')
  final String uid;

  @HiveField(1)
  @JsonKey(name: 'email')
  final String email;

  @HiveField(2)
  @JsonKey(name: 'display_name')
  final String displayName;

  @HiveField(3)
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  @HiveField(4)
  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  @HiveField(5)
  @JsonKey(name: 'provider_id')
  final String providerId;

  @HiveField(6)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(7)
  @JsonKey(name: 'last_sign_in')
  final DateTime lastSignIn;

  // ── Body Profile Fields ────────────────────────────────────────────────────

  /// Sexo biológico: 'male' | 'female'
  @HiveField(8)
  @JsonKey(name: 'gender')
  final String? gender;

  /// Idade em anos completos
  @HiveField(9)
  @JsonKey(name: 'age')
  final int? age;

  /// Altura em centímetros (ex: 175.0)
  @HiveField(10)
  @JsonKey(name: 'height_cm')
  final double? heightCm;

  /// Peso em quilogramas (ex: 78.5)
  @HiveField(11)
  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  /// Nível de atividade física:
  /// 'sedentary' | 'light' | 'moderate' | 'intense' | 'very_intense'
  @HiveField(12)
  @JsonKey(name: 'activity_level')
  final String? activityLevel;

  /// Objetivo: 'weight_loss' | 'maintenance' | 'muscle_gain'
  @HiveField(13)
  @JsonKey(name: 'goal')
  final String? goal;

  // ── Optional Circumferences (cm) ──────────────────────────────────────────

  @HiveField(14)
  @JsonKey(name: 'waist_cm')
  final double? waistCm;

  @HiveField(15)
  @JsonKey(name: 'chest_cm')
  final double? chestCm;

  @HiveField(16)
  @JsonKey(name: 'arm_cm')
  final double? armCm;

  @HiveField(17)
  @JsonKey(name: 'hip_cm')
  final double? hipCm;

  @HiveField(18)
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

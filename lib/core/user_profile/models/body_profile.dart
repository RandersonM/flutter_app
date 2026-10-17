import 'package:equatable/equatable.dart';
import 'package:opfan/core/auth/models/user_model.dart';

/// The body fields of a user, as stored at Firestore `users/{uid}`. Identity
/// (name, email, provider) comes from Firebase Auth, and the rules
/// (`profileKeys()`) only allow these fields in the document.
class BodyProfile extends Equatable {
  const BodyProfile({
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
    this.waistCm,
    this.chestCm,
    this.armCm,
    this.hipCm,
    this.thighCm,
  });

  factory BodyProfile.fromUser(UserModel user) => BodyProfile(
    gender: user.gender,
    age: user.age,
    heightCm: user.heightCm,
    weightKg: user.weightKg,
    activityLevel: user.activityLevel,
    goal: user.goal,
    waistCm: user.waistCm,
    chestCm: user.chestCm,
    armCm: user.armCm,
    hipCm: user.hipCm,
    thighCm: user.thighCm,
  );

  /// Reads only the body fields, so a legacy document that also carries
  /// identity fields still parses. Whole numbers may come back as `int`.
  factory BodyProfile.fromFirestore(Map<String, dynamic> data) => BodyProfile(
    gender: _string(data['gender']),
    age: _number(data['age'])?.toInt(),
    heightCm: _number(data['height_cm'])?.toDouble(),
    weightKg: _number(data['weight_kg'])?.toDouble(),
    activityLevel: _string(data['activity_level']),
    goal: _string(data['goal']),
    waistCm: _number(data['waist_cm'])?.toDouble(),
    chestCm: _number(data['chest_cm'])?.toDouble(),
    armCm: _number(data['arm_cm'])?.toDouble(),
    hipCm: _number(data['hip_cm'])?.toDouble(),
    thighCm: _number(data['thigh_cm'])?.toDouble(),
  );

  final String? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? goal;
  final double? waistCm;
  final double? chestCm;
  final double? armCm;
  final double? hipCm;
  final double? thighCm;

  /// Keys and types must match `validProfile` in `firestore.rules`.
  Map<String, dynamic> toFirestore() => {
    'gender': gender,
    'age': age,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'activity_level': activityLevel,
    'goal': goal,
    'waist_cm': waistCm,
    'chest_cm': chestCm,
    'arm_cm': armCm,
    'hip_cm': hipCm,
    'thigh_cm': thighCm,
  };

  /// [user] with every field this profile has; fields it lacks keep the
  /// user's value.
  UserModel applyTo(UserModel user) => user.copyWith(
    gender: gender,
    age: age,
    heightCm: heightCm,
    weightKg: weightKg,
    activityLevel: activityLevel,
    goal: goal,
    waistCm: waistCm,
    chestCm: chestCm,
    armCm: armCm,
    hipCm: hipCm,
    thighCm: thighCm,
  );

  static String? _string(Object? value) => value is String ? value : null;

  static num? _number(Object? value) => value is num ? value : null;

  @override
  List<Object?> get props => [
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
}

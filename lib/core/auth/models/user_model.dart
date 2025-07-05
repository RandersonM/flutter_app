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

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.providerId,
    required this.createdAt,
    required this.lastSignIn,
  });

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
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified, providerId: $providerId)';
  }
}

// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:opfan/core/auth/models/user_model.dart';

/// Contract for reading and writing user body profile data in Firestore.
abstract class IUserProfileRepository {
  /// Fetches the profile document for [uid] from `/users/{uid}`.
  /// Returns [null] if the document does not exist.
  Future<UserModel?> fetchProfile(String uid);

  /// Creates or fully overwrites the profile document at `/users/{uid}`.
  Future<void> saveProfile(UserModel profile);

  /// Returns [true] if the document at `/users/{uid}` exists and all
  /// mandatory body-profile fields are non-null.
  Future<bool> hasCompleteProfile(String uid);

  /// Deletes the profile document at `/users/{uid}`.
  Future<void> deleteProfile(String uid);
}

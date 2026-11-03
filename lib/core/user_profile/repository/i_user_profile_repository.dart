// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';

/// Contract for reading and writing user body profile data in Firestore.
abstract class IUserProfileRepository {
  /// The body profile stored at `/users/{uid}`, or null when there is no
  /// document. Throws when the document cannot be read (offline with nothing
  /// cached, denied).
  Future<BodyProfile?> fetchBodyProfile(String uid);

  /// Merges the body fields of [profile] into `/users/{uid}`. A field
  /// [profile] lacks is deleted only when [previous] had it (the user cleared
  /// it); otherwise the stored value is kept.
  Future<void> saveProfile(UserModel profile, {UserModel? previous});

  /// Returns [true] if the document at `/users/{uid}` exists and all
  /// mandatory body-profile fields are non-null.
  Future<bool> hasCompleteProfile(String uid);

  /// Deletes the profile document at `/users/{uid}`.
  Future<void> deleteProfile(String uid);
}

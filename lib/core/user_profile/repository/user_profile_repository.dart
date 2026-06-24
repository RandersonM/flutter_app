// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository_interface.dart';

/// Firestore implementation of [IUserProfileRepository].
///
/// All body profile data is stored in the top-level `/users/{uid}` collection.
/// The document ID is the Firebase Auth UID, ensuring O(1) reads.
class UserProfileRepository implements IUserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Internal helpers ───────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _docRef(String uid) =>
      _firestore.collection('users').doc(uid);

  // ── Interface implementation ───────────────────────────────────────────────

  @override
  Future<UserModel?> fetchProfile(String uid) async {
    try {
      final snapshot = await _docRef(uid).get();

      if (!snapshot.exists || snapshot.data() == null) return null;

      final data = snapshot.data()!;

      // Convert Firestore Timestamps back to ISO strings for DateTime fields.
      _convertTimestamps(data);

      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('UserProfileRepository.fetchProfile: $e');
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserModel profile) async {
    try {
      final data = profile.toJson();

      // Store timestamps as Firestore Timestamps for efficient range queries.
      data['created_at'] = Timestamp.fromDate(profile.createdAt);
      data['last_sign_in'] = Timestamp.fromDate(profile.lastSignIn);
      data['updated_at'] = FieldValue.serverTimestamp();

      await _docRef(profile.uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserProfileRepository.saveProfile: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCompleteProfile(String uid) async {
    try {
      final snapshot = await _docRef(uid).get();

      if (!snapshot.exists || snapshot.data() == null) return false;

      final data = snapshot.data()!;

      final mandatoryKeys = [
        'gender',
        'age',
        'height_cm',
        'weight_kg',
        'activity_level',
        'goal',
      ];

      for (final key in mandatoryKeys) {
        final value = data[key];
        if (value == null) return false;
        if (value is String && value.isEmpty) return false;
        if (value is num && value <= 0) return false;
      }

      return true;
    } catch (e) {
      debugPrint('UserProfileRepository.hasCompleteProfile: $e');
      return false;
    }
  }

  @override
  Future<void> deleteProfile(String uid) async {
    try {
      await _docRef(uid).delete();
    } catch (e) {
      debugPrint('UserProfileRepository.deleteProfile: $e');
      rethrow;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Converts Firestore [Timestamp] values in [data] to ISO 8601 strings
  /// so that [UserModel.fromJson] can parse them correctly.
  void _convertTimestamps(Map<String, dynamic> data) {
    for (final key in ['created_at', 'last_sign_in', 'updated_at']) {
      final value = data[key];
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      }
    }
  }
}

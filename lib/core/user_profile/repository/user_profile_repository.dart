// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';

/// Firestore implementation of [IUserProfileRepository].
///
/// All body profile data is stored in the top-level `/users/{uid}` collection.
/// The document ID is the Firebase Auth UID, ensuring O(1) reads.
class UserProfileRepository implements IUserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required this._firestore});

  // ── Internal helpers ───────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _docRef(String uid) =>
      _firestore.collection('users').doc(uid);

  // ── Interface implementation ───────────────────────────────────────────────

  @override
  Future<BodyProfile?> fetchBodyProfile(String uid) async {
    try {
      final data = (await _docRef(uid).get()).data();
      return data == null ? null : BodyProfile.fromFirestore(data);
    } catch (e) {
      debugPrint('UserProfileRepository.fetchBodyProfile: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveProfile(UserModel profile, {UserModel? previous}) async {
    try {
      final changes = BodyProfile.fromUser(profile).toFirestoreChanges(
        previous: previous == null ? null : BodyProfile.fromUser(previous),
      );
      final data = {
        for (final MapEntry(:key, :value) in changes.entries)
          key: value ?? FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      };

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
}

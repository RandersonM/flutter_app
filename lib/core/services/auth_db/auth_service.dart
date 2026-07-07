// Developed by Randerson Mayllon
// Copyright © 2025.

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/user_profile/repository/user_profile_repository_interface.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }


class AuthService implements IAuthService {
  static const String _boxName = 'auth_cache';
  static const String _userKey = 'current_user';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final IUserProfileRepository _userProfileRepository;
  late Box<UserModel> _box;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required this._userProfileRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox<UserModel>(_boxName);

      final cachedUser = currentUser;
      if (cachedUser != null) {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null && firebaseUser.uid == cachedUser.uid) {
          try {
            await firebaseUser.getIdToken(true);
            debugPrint('AuthService: Valid cached session found');
          } catch (e) {
            debugPrint(
                'AuthService: Cached session expired, clearing cache - $e');
            await _clearUser();
          }
        } else {
          debugPrint('AuthService: Cached user mismatch, clearing cache');
          await _clearUser();
        }
      }
    } catch (e) {
      debugPrint('AuthService: Error opening Hive box - $e');
      rethrow;
    }
  }

  @override
  Stream<AuthStatus> get authStatusStream {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user != null) {
        return AuthStatus.authenticated;
      } else {
        return AuthStatus.unauthenticated;
      }
    });
  }

  @override
  UserModel? get currentUser => _box.get(_userKey);

  @override
  bool get isAuthenticated =>
      currentUser != null && _firebaseAuth.currentUser != null;

  @override
  Future<bool> isSessionValid() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      // Attempt a forced token refresh (requires network).
      await firebaseUser.getIdToken(true);

      final cachedUser = currentUser;
      if (cachedUser == null || cachedUser.uid != firebaseUser.uid) {
        return false;
      }
      return true;
    } on SocketException catch (_) {
      // Device is offline — fall back to the cached session.
      debugPrint('AuthService: Offline — validating session from local cache');
      return _isLocalSessionValid();
    } catch (e) {
      if (_isNetworkError(e)) {
        debugPrint(
            'AuthService: Network error — validating session from local cache');
        return _isLocalSessionValid();
      }
      debugPrint('AuthService: Session validation error - $e');
      return false;
    }
  }

  /// Validates the session using only local state (no network call).
  ///
  /// Returns true if both the Firebase SDK has a current user AND the Hive
  /// cache has a matching [UserModel]. This covers the offline startup case.
  bool _isLocalSessionValid() {
    final firebaseUser = _firebaseAuth.currentUser;
    final cachedUser = currentUser; // reads from Hive
    return firebaseUser != null &&
        cachedUser != null &&
        firebaseUser.uid == cachedUser.uid;
  }

  /// Heuristic to detect network-related exceptions from Firebase.
  bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection') ||
        msg.contains('unavailable');
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      await firebaseUser.getIdToken(true);
      return true;
    } catch (e) {
      debugPrint('AuthService: Error refreshing token - $e');
      return false;
    }
  }

  @override
  Future<bool> restoreGoogleSession() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        debugPrint('AuthService: Google session restored successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AuthService: Error restoring Google session - $e');
      return false;
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        await user.getIdToken(true);

        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          emailVerified: user.emailVerified,
          providerId: user.providerData.first.providerId,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          lastSignIn: user.metadata.lastSignInTime ?? DateTime.now(),
        );

        final firestoreProfile =
            await _userProfileRepository.fetchProfile(user.uid);
        final finalUser = firestoreProfile != null
            ? userModel.copyWith(
                gender: firestoreProfile.gender,
                age: firestoreProfile.age,
                heightCm: firestoreProfile.heightCm,
                weightKg: firestoreProfile.weightKg,
                activityLevel: firestoreProfile.activityLevel,
                goal: firestoreProfile.goal,
                waistCm: firestoreProfile.waistCm,
                chestCm: firestoreProfile.chestCm,
                armCm: firestoreProfile.armCm,
                hipCm: firestoreProfile.hipCm,
                thighCm: firestoreProfile.thighCm,
              )
            : userModel;

        await _saveUser(finalUser);

        try {
          final notificationService = NotificationService();
          if (notificationService.isInitialized) {
            await notificationService.saveTokenToFirestore(user.uid);
          }
        } catch (e) {
          debugPrint('AuthService: Erro ao salvar token FCM: $e');
        }

        debugPrint('AuthService: User signed in successfully and cached');
        return finalUser;
      }

      return null;
    } catch (e) {
      debugPrint('AuthService: Error in Google Sign-In - $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      try {
        final notificationService = NotificationService();
        if (notificationService.isInitialized) {
          await notificationService.clearToken();
        }
      } catch (e) {
        debugPrint('AuthService: Erro ao limpar token FCM: $e');
      }

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      await _clearUser();
    } catch (e) {
      debugPrint('AuthService: Error in sign out - $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        try {
          await firebaseUser.getIdToken(true);
        } catch (e) {
          debugPrint('AuthService: Firebase token expired, signing out - $e');
          await signOut();
          return null;
        }

        final isGoogleProvider = firebaseUser.providerData
            .any((provider) => provider.providerId == 'google.com');

        if (isGoogleProvider) {
          try {
            final googleUser = _googleSignIn.currentUser;
            if (googleUser == null) {
              final restored = await restoreGoogleSession();
              if (!restored) {
                debugPrint('AuthService: Google session expired, signing out');
                await signOut();
                return null;
              }
            }
          } catch (e) {
            debugPrint('AuthService: Error checking Google session - $e');
          }
        }

        final cachedUser = currentUser;
        UserModel baseUser;

        if (cachedUser != null && cachedUser.uid == firebaseUser.uid) {
          baseUser = cachedUser.copyWith(
            lastSignIn: DateTime.now(),
          );
        } else {
          baseUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? '',
            photoUrl: firebaseUser.photoURL,
            emailVerified: firebaseUser.emailVerified,
            providerId: firebaseUser.providerData.first.providerId,
            createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
            lastSignIn: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
          );
        }

        final firestoreProfile =
            await _userProfileRepository.fetchProfile(firebaseUser.uid);
        final finalUser = firestoreProfile != null
            ? baseUser.copyWith(
                gender: firestoreProfile.gender,
                age: firestoreProfile.age,
                heightCm: firestoreProfile.heightCm,
                weightKg: firestoreProfile.weightKg,
                activityLevel: firestoreProfile.activityLevel,
                goal: firestoreProfile.goal,
                waistCm: firestoreProfile.waistCm,
                chestCm: firestoreProfile.chestCm,
                armCm: firestoreProfile.armCm,
                hipCm: firestoreProfile.hipCm,
                thighCm: firestoreProfile.thighCm,
              )
            : baseUser;

        await _saveUser(finalUser);
        return finalUser;
      }

      await _clearUser();
      return null;
    } catch (e) {
      debugPrint('AuthService: Error checking auth status - $e');
      return null;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        await _userProfileRepository.deleteProfile(user.uid);
        await _googleSignIn.signOut();
        await _clearUser();
      }
    } catch (e) {
      debugPrint('AuthService: Error deleting account - $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return null;

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);

      final updatedUser = currentUser?.copyWith(
        displayName: displayName ?? currentUser?.displayName,
        photoUrl: photoUrl ?? currentUser?.photoUrl,
      );

      if (updatedUser != null) {
        await _saveUser(updatedUser);
        return updatedUser;
      }
    } catch (e) {
      debugPrint('AuthService: Error updating profile - $e');
      rethrow;
    }

    return null;
  }

  @override
  Future<bool> hasCompleteProfile(String uid) {
    return _userProfileRepository.hasCompleteProfile(uid);
  }

  @override
  Future<void> updateBodyProfile(UserModel updatedProfile) async {
    await _userProfileRepository.saveProfile(updatedProfile);
    await _saveUser(updatedProfile);
  }

  Future<void> _saveUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

  Future<void> _clearUser() async {
    await _box.delete(_userKey);
  }

  @override
  Future<void> clearCache() async {
    await _box.clear();
  }

  @override
  Map<String, dynamic> getServiceStatus() {
    return {
      'isAuthenticated': isAuthenticated,
      'currentUser': currentUser?.email,
      'firebaseUser': _firebaseAuth.currentUser?.email,
      'cachedUsers': _box.length,
      'isGoogleSignedIn': _googleSignIn.currentUser != null,
      'firebaseUid': _firebaseAuth.currentUser?.uid,
      'cachedUid': currentUser?.uid,
      'sessionValid': _firebaseAuth.currentUser != null && currentUser != null,
    };
  }
}

// Developed by Randerson Mayllon
// Copyright © 2025.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/storage/user_data_names.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService implements IAuthService {
  static const String _userKey = 'current_user';
  static const _revokedSessionCodes = {
    'user-token-expired',
    'user-disabled',
    'user-not-found',
    'invalid-user-token',
  };

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final IUserProfileRepository _userProfileRepository;
  final INotificationService _notificationService;
  final IUserStorageService _storage;
  final IUserDataEraser _userDataEraser;
  late Box<UserModel> _box;
  final _profileChanges = StreamController<UserModel>.broadcast();
  final _profileSyncFailures = StreamController<void>.broadcast();

  AuthService({
    required this._firebaseAuth,
    required this._googleSignIn,
    required this._userProfileRepository,
    required this._notificationService,
    required this._storage,
    required this._userDataEraser,
  });

  @override
  Future<void> init() async {
    try {
      _box = await _storage.openDeviceBox<UserModel>(
        UserDataNames.authCacheBox,
      );

      final cachedUser = currentUser;
      if (cachedUser != null) {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null && firebaseUser.uid == cachedUser.uid) {
          try {
            await firebaseUser.getIdToken(true);
            debugPrint('AuthService: Valid cached session found');
          } catch (e) {
            if (_isSessionRevoked(e)) {
              debugPrint('AuthService: Session revoked, clearing cache - $e');
              await _clearUser();
            } else {
              debugPrint(
                'AuthService: Token refresh failed, keeping cache - $e',
              );
            }
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

  /// The Firebase user decides, not the local cache: [checkAuthStatus]
  /// rebuilds a lost cache (reinstall, reset keychain) from the Firebase user.
  @override
  Future<bool> isSessionValid() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return false;
    try {
      await firebaseUser.getIdToken(true);
    } catch (e) {
      if (_isSessionRevoked(e)) {
        debugPrint('AuthService: Session revoked - $e');
        return false;
      }
      debugPrint('AuthService: Token refresh failed, keeping session - $e');
    }
    return true;
  }

  /// Only an answer from the auth server ends the session. Offline, timeouts
  /// and unknown failures keep the cached user, so opening the app without
  /// network never signs anyone out.
  bool _isSessionRevoked(Object e) =>
      e is FirebaseAuthException && _revokedSessionCodes.contains(e.code);

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

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

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

        final finalUser = await _withStoredBodyProfile(userModel);
        if (!_isStillSignedIn(user.uid)) return null;

        final cachedUser = await _cacheSignedInUser(finalUser);

        unawaited(_saveFcmToken(user.uid));

        debugPrint('AuthService: User signed in successfully and cached');
        return cachedUser;
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
        final notificationService = _notificationService;
        if (notificationService.isInitialized) {
          await notificationService.clearToken();
        }
      } catch (e) {
        debugPrint('AuthService: Erro ao limpar token FCM: $e');
      }

      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

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
          if (_isSessionRevoked(e)) {
            debugPrint('AuthService: Session revoked, signing out - $e');
            await signOut();
            return null;
          }
          debugPrint('AuthService: Token refresh failed, keeping session - $e');
        }

        final isGoogleProvider = firebaseUser.providerData.any(
          (provider) => provider.providerId == 'google.com',
        );

        if (isGoogleProvider &&
            _googleSignIn.currentUser == null &&
            await _isGoogleSessionGone()) {
          debugPrint('AuthService: Google session expired, signing out');
          await signOut();
          return null;
        }

        final cachedUser = currentUser;
        UserModel baseUser;

        if (cachedUser != null && cachedUser.uid == firebaseUser.uid) {
          baseUser = cachedUser.copyWith(lastSignIn: DateTime.now());
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

        final finalUser = await _withStoredBodyProfile(baseUser);
        if (!_isStillSignedIn(firebaseUser.uid)) return null;

        return _cacheSignedInUser(finalUser);
      }

      await _clearUser();
      return null;
    } catch (e) {
      debugPrint('AuthService: Error checking auth status - $e');
      return null;
    }
  }

  /// A sign-out during the token refresh or the profile read must win:
  /// caching the user afterwards would sign them back in.
  bool _isStillSignedIn(String uid) => _firebaseAuth.currentUser?.uid == uid;

  /// Onboarding may save the body profile while a slow sign-in or status
  /// check is still reading the server (offline, the save is only local), so
  /// a complete cache of the same user is kept over an incomplete read.
  Future<UserModel> _cacheSignedInUser(UserModel user) async {
    final cached = currentUser;
    if (cached != null &&
        cached.uid == user.uid &&
        cached.isProfileComplete &&
        !user.isProfileComplete) {
      return cached;
    }
    await _saveUser(user);
    return user;
  }

  /// [user] with the body profile stored in Firestore. When it cannot be read
  /// (offline with nothing cached, App Check), [user] keeps the body it
  /// already has, so a complete cached profile never falls back to onboarding.
  Future<UserModel> _withStoredBodyProfile(UserModel user) async {
    try {
      final stored = await _userProfileRepository.fetchBodyProfile(user.uid);
      return stored?.applyTo(user) ?? user;
    } catch (e) {
      debugPrint('AuthService: Body profile unavailable, keeping cache - $e');
      return user;
    }
  }

  /// Not awaited by sign-in: the write completes only on the server ack, and
  /// the signed-in state must not wait for it.
  Future<void> _saveFcmToken(String uid) async {
    try {
      await _notificationService.initialize();
      await _notificationService.saveTokenToFirestore(uid);
    } catch (e) {
      debugPrint('AuthService: Could not save the FCM token - $e');
    }
  }

  Future<bool> _isGoogleSessionGone() async {
    try {
      return await _googleSignIn.signInSilently(suppressErrors: false) == null;
    } on PlatformException catch (e) {
      return e.code == GoogleSignIn.kSignInRequiredError;
    } catch (e) {
      debugPrint('AuthService: Google session not restored - $e');
      return false;
    }
  }

  /// Firestore data goes first: once the Auth user is gone the rules deny
  /// every delete. Signing in again first keeps `user.delete()` from failing
  /// with `requires-recent-login` after the data is already erased.
  @override
  Future<void> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return;
      final uid = user.uid;

      await _reauthenticateWithGoogle(user);
      await _userDataEraser.eraseRemoteData(uid);
      await user.delete();
      await _storage.deleteUserData(uid);
      await _googleSignIn.signOut();
      await _clearUser();
    } catch (e) {
      debugPrint('AuthService: Error deleting account - $e');
      rethrow;
    }
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw const CancelledByUserException();
    final googleAuth = await googleUser.authentication;
    await user.reauthenticateWithCredential(
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ),
    );
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
    final cached = currentUser;
    await _saveUser(updatedProfile);
    _profileChanges.add(updatedProfile);
    unawaited(
      _syncBodyProfile(
        updatedProfile,
        previous: cached?.uid == updatedProfile.uid ? cached : null,
      ),
    );
  }

  /// Firestore keeps the write while offline and syncs it later, but its
  /// future completes only on the server ack: awaiting it hangs an offline save.
  /// A write the server refuses is rolled back in Firestore's cache, so the
  /// local profile follows it back instead of diverging until the next start.
  Future<void> _syncBodyProfile(
    UserModel profile, {
    UserModel? previous,
  }) async {
    try {
      await _userProfileRepository.saveProfile(profile, previous: previous);
    } catch (e) {
      debugPrint('AuthService: Body profile not synced to Firestore - $e');
      await _restoreStoredBodyProfile(profile.uid);
      _profileSyncFailures.add(null);
    }
  }

  /// With no stored document the refused save was the first one: the cache
  /// drops it too, so the user is sent back to onboarding instead of keeping
  /// a profile only this device has.
  Future<void> _restoreStoredBodyProfile(String uid) async {
    try {
      final stored = await _userProfileRepository.fetchBodyProfile(uid);
      final cached = currentUser;
      if (cached == null || cached.uid != uid) return;
      final restored = (stored ?? const BodyProfile()).replaceIn(cached);
      await _saveUser(restored);
      _profileChanges.add(restored);
    } catch (e) {
      debugPrint('AuthService: Stored body profile not restored - $e');
    }
  }

  @override
  Stream<UserModel> get profileChanges => _profileChanges.stream;

  @override
  Stream<void> get profileSyncFailures => _profileSyncFailures.stream;

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

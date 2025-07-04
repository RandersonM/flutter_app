// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:flutter/services.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService {
  static const String _boxName = 'auth_cache';
  static const String _userKey = 'current_user';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  late Box<UserModel> _box;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<void> init() async {
    try {
      _box = await Hive.openBox<UserModel>(_boxName);
    } catch (e) {
      debugPrint('AuthService: Error opening Hive box - $e');
      rethrow;
    }
  }

  Stream<AuthStatus> get authStatusStream {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user != null) {
        return AuthStatus.authenticated;
      } else {
        return AuthStatus.unauthenticated;
      }
    });
  }

  UserModel? get currentUser => _box.get(_userKey);

  bool get isAuthenticated =>
      currentUser != null && _firebaseAuth.currentUser != null;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          emailVerified: user.emailVerified,
          providerId: 'google.com',
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          lastSignIn: user.metadata.lastSignInTime ?? DateTime.now(),
        );

        await _saveUser(userModel);
        return userModel;
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('AuthService: Error in Google sign in - $e');
      debugPrint('AuthService: Stack trace - $stackTrace');
      
      if (e is PlatformException) {
        debugPrint('AuthService: PlatformException - Code: ${e.code}');
        debugPrint('AuthService: Message: ${e.message}');
        debugPrint('AuthService: Details: ${e.details}');
      }
      
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
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

  Future<UserModel?> checkAuthStatus() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        final isGoogleProvider = firebaseUser.providerData
            .any((provider) => provider.providerId == 'google.com');
        
        if (isGoogleProvider) {
          final googleUser = _googleSignIn.currentUser;
          if (googleUser == null) {
            await signOut();
            return null;
          }
        }

        final cachedUser = currentUser;

        if (cachedUser != null && cachedUser.uid == firebaseUser.uid) {
          final updatedUser = cachedUser.copyWith(
            lastSignIn: DateTime.now(),
          );
          await _saveUser(updatedUser);

          return updatedUser;
        }

        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          photoUrl: firebaseUser.photoURL,
          emailVerified: firebaseUser.emailVerified,
          providerId: firebaseUser.providerData.first.providerId,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastSignIn: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
        );

        await _saveUser(userModel);
        return userModel;
      }

      await _clearUser();
      return null;
    } catch (e) {
      debugPrint('AuthService: Error checking auth status - $e');
      return null;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        await _googleSignIn.signOut();
        await _clearUser();
      }
    } catch (e) {
      debugPrint('AuthService: Error deleting account - $e');
      rethrow;
    }
  }

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

  Future<void> _saveUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

  Future<void> _clearUser() async {
    await _box.delete(_userKey);
  }

  Future<void> clearCache() async {
    await _box.clear();
  }

  Map<String, dynamic> getServiceStatus() {
    return {
      'isAuthenticated': isAuthenticated,
      'currentUser': currentUser?.email,
      'firebaseUser': _firebaseAuth.currentUser?.email,
      'cachedUsers': _box.length,
      'isGoogleSignedIn': _googleSignIn.currentUser != null,
    };
  }
}

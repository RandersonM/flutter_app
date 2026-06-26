import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/index.dart';

abstract class IAuthService {
  Future<void> init();
  Stream<AuthStatus> get authStatusStream;
  UserModel? get currentUser;
  bool get isAuthenticated;
  Future<bool> isSessionValid();
  Future<bool> refreshToken();
  Future<bool> restoreGoogleSession();
  Future<UserModel?> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> checkAuthStatus();
  Future<void> deleteAccount();
  Future<UserModel?> updateProfile({String? displayName, String? photoUrl});
  Future<bool> hasCompleteProfile(String uid);
  Future<void> updateBodyProfile(UserModel updatedProfile);
  Future<void> clearCache();
  Map<String, dynamic> getServiceStatus();
}

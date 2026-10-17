import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/auth_service.dart';
import 'package:opfan/core/services/auth_db/i_user_data_eraser.dart';
import 'package:opfan/core/services/notification/i_notification_service.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserInfo extends Mock implements UserInfo {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockProfileRepository extends Mock implements IUserProfileRepository {}

class _MockNotificationService extends Mock implements INotificationService {}

class _MockStorage extends Mock implements IUserStorageService {}

class _MockBox extends Mock implements Box<UserModel> {}

final _cachedUser = UserModel(
  uid: 'u1',
  email: 'u1@example.com',
  displayName: 'Alice',
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
);

void main() {
  late _MockFirebaseAuth firebaseAuth;
  late _MockUser user;
  late _MockGoogleSignIn googleSignIn;
  late _MockNotificationService notifications;
  late _MockBox box;
  late AuthService service;

  setUpAll(() => registerFallbackValue(_cachedUser));

  setUp(() async {
    firebaseAuth = _MockFirebaseAuth();
    user = _MockUser();
    googleSignIn = _MockGoogleSignIn();
    notifications = _MockNotificationService();
    box = _MockBox();
    final storage = _MockStorage();
    final profiles = _MockProfileRepository();
    final google = _MockUserInfo();

    when(() => firebaseAuth.currentUser).thenReturn(user);
    when(() => firebaseAuth.signOut()).thenAnswer((_) async {});
    when(() => user.uid).thenReturn('u1');
    when(() => user.providerData).thenReturn([google]);
    when(() => google.providerId).thenReturn('google.com');
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');
    when(() => googleSignIn.currentUser).thenReturn(null);
    when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
    when(() => notifications.isInitialized).thenReturn(false);
    when(() => profiles.fetchProfile('u1')).thenAnswer((_) async => null);
    when(
      () => storage.openDeviceBox<UserModel>(any()),
    ).thenAnswer((_) async => box);
    when(() => box.get(any())).thenReturn(_cachedUser);
    when(() => box.put(any(), any())).thenAnswer((_) async {});
    when(() => box.delete(any())).thenAnswer((_) async {});

    service = AuthService(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      userProfileRepository: profiles,
      notificationService: notifications,
      storage: storage,
      userDataEraser: _MockEraser(),
    );
  });

  void tokenRefreshFails(String code) => when(
    () => user.getIdToken(true),
  ).thenThrow(FirebaseAuthException(code: code));

  void googleSilentSignInFails(String code) => when(
    () => googleSignIn.signInSilently(suppressErrors: false),
  ).thenThrow(PlatformException(code: code));

  group('AuthService offline session behaviour', () {
    test(
      'keeps the cached user when the token cannot refresh offline',
      () async {
        tokenRefreshFails('network-request-failed');

        await service.init();

        verifyNever(() => box.delete(any()));
        expect(await service.isSessionValid(), isTrue);
      },
    );

    test('clears the cached user when the session was revoked', () async {
      tokenRefreshFails('user-disabled');

      await service.init();

      verify(() => box.delete(any())).called(1);
      expect(await service.isSessionValid(), isFalse);
    });

    test(
      'restores the cached user offline without signing out of Google',
      () async {
        await service.init();
        tokenRefreshFails('network-request-failed');
        googleSilentSignInFails(GoogleSignIn.kNetworkError);

        final restored = await service.checkAuthStatus();

        expect(restored?.uid, 'u1');
        verifyNever(() => firebaseAuth.signOut());
      },
    );

    test('signs out when Google no longer has a session', () async {
      await service.init();
      googleSilentSignInFails(GoogleSignIn.kSignInRequiredError);

      final restored = await service.checkAuthStatus();

      expect(restored, isNull);
      verify(() => firebaseAuth.signOut()).called(1);
    });
  });
}

class _MockEraser extends Mock implements IUserDataEraser {}

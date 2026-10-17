import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/core/services/auth_db/auth_service.dart';
import 'package:opfan/core/services/auth_db/i_user_data_eraser.dart';
import 'package:opfan/core/services/notification/i_notification_service.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleAuth extends Mock implements GoogleSignInAuthentication {}

class _MockProfileRepository extends Mock implements IUserProfileRepository {}

class _MockNotificationService extends Mock implements INotificationService {}

class _MockStorage extends Mock implements IUserStorageService {}

class _MockEraser extends Mock implements IUserDataEraser {}

class _MockBox extends Mock implements Box<UserModel> {}

class _FakeCredential extends Fake implements AuthCredential {}

void main() {
  late _MockFirebaseAuth firebaseAuth;
  late _MockUser user;
  late _MockGoogleSignIn googleSignIn;
  late _MockStorage storage;
  late _MockEraser eraser;
  late _MockBox box;
  late AuthService service;

  setUpAll(() => registerFallbackValue(_FakeCredential()));

  setUp(() async {
    firebaseAuth = _MockFirebaseAuth();
    user = _MockUser();
    googleSignIn = _MockGoogleSignIn();
    storage = _MockStorage();
    eraser = _MockEraser();
    box = _MockBox();

    when(() => firebaseAuth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('u1');
    when(() => user.delete()).thenAnswer((_) async {});
    when(() => eraser.eraseRemoteData('u1')).thenAnswer((_) async {});
    when(() => storage.deleteUserData('u1')).thenAnswer((_) async {});
    when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
    when(() => box.delete(any())).thenAnswer((_) async {});
    when(
      () => storage.openDeviceBox<UserModel>(any()),
    ).thenAnswer((_) async => box);
    when(() => box.get(any())).thenReturn(null);

    service = AuthService(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      userProfileRepository: _MockProfileRepository(),
      notificationService: _MockNotificationService(),
      storage: storage,
      userDataEraser: eraser,
    );
    await service.init();
  });

  void googleAccountChosen() {
    final account = _MockGoogleAccount();
    final googleAuth = _MockGoogleAuth();
    when(() => googleSignIn.signIn()).thenAnswer((_) async => account);
    when(() => account.authentication).thenAnswer((_) async => googleAuth);
    when(() => googleAuth.accessToken).thenReturn('access');
    when(() => googleAuth.idToken).thenReturn('id');
    when(
      () => user.reauthenticateWithCredential(any()),
    ).thenAnswer((_) async => _MockUserCredential());
  }

  group('AuthService.deleteAccount behaviour', () {
    test(
      'signs in again, erases remote data, then deletes the auth user and local data',
      () async {
        googleAccountChosen();

        await service.deleteAccount();

        verifyInOrder([
          () => user.reauthenticateWithCredential(any()),
          () => eraser.eraseRemoteData('u1'),
          () => user.delete(),
          () => storage.deleteUserData('u1'),
        ]);
      },
    );

    test('keeps everything when the user cancels signing in again', () async {
      when(() => googleSignIn.signIn()).thenAnswer((_) async => null);

      await expectLater(
        service.deleteAccount(),
        throwsA(isA<CancelledByUserException>()),
      );
      verifyNever(() => eraser.eraseRemoteData(any()));
      verifyNever(() => user.delete());
    });

    test('keeps the auth user when erasing remote data fails', () async {
      googleAccountChosen();
      when(
        () => eraser.eraseRemoteData('u1'),
      ).thenThrow(Exception('permission-denied'));

      await expectLater(service.deleteAccount(), throwsException);
      verifyNever(() => user.delete());
      verifyNever(() => storage.deleteUserData(any()));
    });
  });
}

class _MockUserCredential extends Mock implements UserCredential {}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/auth_service.dart';
import 'package:opfan/core/services/auth_db/i_user_data_eraser.dart';
import 'package:opfan/core/services/notification/i_notification_service.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/user_profile/models/body_profile.dart';
import 'package:opfan/core/user_profile/repository/i_user_profile_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserInfo extends Mock implements UserInfo {}

class _MockUserMetadata extends Mock implements UserMetadata {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class _MockProfileRepository extends Mock implements IUserProfileRepository {}

class _MockNotificationService extends Mock implements INotificationService {}

class _MockStorage extends Mock implements IUserStorageService {}

class _MockEraser extends Mock implements IUserDataEraser {}

class _MockBox extends Mock implements Box<UserModel> {}

const _storedBody = BodyProfile(
  gender: 'female',
  age: 30,
  heightCm: 165,
  weightKg: 60,
  activityLevel: 'moderate',
  goal: 'maintenance',
);

final _signedInUser = UserModel(
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
  late _MockProfileRepository profiles;
  late _MockNotificationService notifications;
  late Map<dynamic, UserModel> cache;
  late AuthService service;
  late AuthBloc bloc;

  setUpAll(() {
    registerFallbackValue(_signedInUser);
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'id'));
  });

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    user = _MockUser();
    googleSignIn = _MockGoogleSignIn();
    profiles = _MockProfileRepository();
    notifications = _MockNotificationService();
    cache = {};
    final storage = _MockStorage();
    final box = _MockBox();
    final google = _MockUserInfo();
    final metadata = _MockUserMetadata();
    final account = _MockGoogleAccount();
    final googleAuth = _MockGoogleAuthentication();
    final credential = _MockUserCredential();

    when(
      () => storage.openDeviceBox<UserModel>(any()),
    ).thenAnswer((_) async => box);
    when(
      () => box.get(any()),
    ).thenAnswer((invocation) => cache[invocation.positionalArguments.first]);
    when(() => box.put(any(), any())).thenAnswer((invocation) async {
      cache[invocation.positionalArguments[0]] =
          invocation.positionalArguments[1] as UserModel;
    });
    when(() => box.delete(any())).thenAnswer(
      (invocation) async => cache.remove(invocation.positionalArguments.first),
    );
    when(() => box.clear()).thenAnswer((_) async {
      final count = cache.length;
      cache.clear();
      return count;
    });

    when(
      () => firebaseAuth.authStateChanges(),
    ).thenAnswer((_) => const Stream<User?>.empty());
    when(() => firebaseAuth.currentUser).thenReturn(null);
    when(
      () => firebaseAuth.signInWithCredential(any()),
    ).thenAnswer((_) async => credential);
    when(() => credential.user).thenReturn(user);
    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('u1@example.com');
    when(() => user.displayName).thenReturn('Alice');
    when(() => user.photoURL).thenReturn(null);
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.providerData).thenReturn([google]);
    when(() => user.metadata).thenReturn(metadata);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'token');
    when(() => google.providerId).thenReturn('google.com');
    when(() => metadata.creationTime).thenReturn(DateTime(2024));
    when(() => metadata.lastSignInTime).thenReturn(DateTime(2024));

    when(() => googleSignIn.signIn()).thenAnswer((_) async => account);
    when(() => googleSignIn.currentUser).thenReturn(account);
    when(() => account.authentication).thenAnswer((_) async => googleAuth);
    when(() => googleAuth.accessToken).thenReturn('access');
    when(() => googleAuth.idToken).thenReturn('id');

    when(
      () => profiles.fetchBodyProfile('u1'),
    ).thenAnswer((_) async => _storedBody);
    when(() => notifications.initialize()).thenAnswer((_) async {});
    when(
      () => notifications.saveTokenToFirestore(any()),
    ).thenAnswer((_) async {});

    service = AuthService(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      userProfileRepository: profiles,
      notificationService: notifications,
      storage: storage,
      userDataEraser: _MockEraser(),
    );
    bloc = AuthBloc(authService: service);
  });

  tearDown(() => bloc.close());

  Future<void> signIn() async {
    await service.init();
    bloc.add(const AuthSignInRequested());
    await pumpEventQueue();
  }

  group('AuthService body profile behaviour', () {
    test('signs a returning user with a stored profile straight in', () async {
      await signIn();

      expect(bloc.state, isA<AuthAuthenticated>());
      expect(cache.values.single.isProfileComplete, isTrue);
    });

    test('restores a returning user whose local cache was cleared', () async {
      when(() => firebaseAuth.currentUser).thenReturn(user);

      bloc.add(const AuthStarted());
      await pumpEventQueue();

      expect(bloc.state, isA<AuthAuthenticated>());
    });

    test(
      'keeps a complete cached profile when the stored one cannot be read',
      () async {
        cache['current_user'] = _storedBody.applyTo(_signedInUser);
        when(() => firebaseAuth.currentUser).thenReturn(user);
        when(
          () => profiles.fetchBodyProfile('u1'),
        ).thenThrow(Exception('unavailable'));

        bloc.add(const AuthStarted());
        await pumpEventQueue();

        expect(bloc.state, isA<AuthAuthenticated>());
      },
    );

    test('does not wait for the FCM token to finish signing in', () async {
      when(
        () => notifications.saveTokenToFirestore(any()),
      ).thenAnswer((_) => Completer<void>().future);

      await signIn();

      expect(bloc.state, isA<AuthAuthenticated>());
      verify(() => notifications.saveTokenToFirestore('u1')).called(1);
    });

    test('retries the notification setup before saving the token', () async {
      await signIn();

      verifyInOrder([
        () => notifications.initialize(),
        () => notifications.saveTokenToFirestore('u1'),
      ]);
    });

    test('saves a body profile without waiting for the server', () async {
      when(
        () => profiles.saveProfile(any()),
      ).thenAnswer((_) => Completer<void>().future);
      final completeUser = _storedBody.applyTo(_signedInUser);
      await service.init();
      final changes = <UserModel>[];
      service.profileChanges.listen(changes.add);

      await service.updateBodyProfile(completeUser);
      await pumpEventQueue();

      expect(cache['current_user'], completeUser);
      expect(changes, [completeUser]);
      verify(() => profiles.saveProfile(completeUser)).called(1);
    });
  });
}

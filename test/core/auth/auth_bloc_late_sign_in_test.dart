import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/auth_service.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';

class _MockAuthService extends Mock implements IAuthService {}

UserModel _user({bool withBodyProfile = false}) => UserModel(
  uid: 'alice',
  email: 'alice@example.com',
  displayName: 'Alice',
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
  gender: withBodyProfile ? 'female' : null,
  age: withBodyProfile ? 30 : null,
  heightCm: withBodyProfile ? 165 : null,
  weightKg: withBodyProfile ? 60 : null,
  activityLevel: withBodyProfile ? 'moderate' : null,
  goal: withBodyProfile ? 'maintenance' : null,
);

void main() {
  late _MockAuthService auth;
  late StreamController<AuthStatus> authStatus;
  late Completer<UserModel?> signIn;

  setUpAll(() => registerFallbackValue(_user()));

  setUp(() {
    auth = _MockAuthService();
    authStatus = StreamController<AuthStatus>.broadcast();
    signIn = Completer<UserModel?>();
    when(
      () => auth.profileChanges,
    ).thenAnswer((_) => const Stream<UserModel>.empty());
    when(() => auth.authStatusStream).thenAnswer((_) => authStatus.stream);
    when(() => auth.init()).thenAnswer((_) async {});
    when(() => auth.isSessionValid()).thenAnswer((_) async => false);
    when(() => auth.clearCache()).thenAnswer((_) async {});
    when(() => auth.checkAuthStatus()).thenAnswer((_) async => _user());
    when(() => auth.signInWithGoogle()).thenAnswer((_) => signIn.future);
    when(() => auth.updateBodyProfile(any())).thenAnswer((_) async {});
  });

  tearDown(() => authStatus.close());

  group('AuthBloc late sign-in behaviour', () {
    test(
      'keeps a profile completed while the sign-in call was still running',
      () async {
        final bloc = AuthBloc(authService: auth);
        bloc.add(const AuthStarted());
        await pumpEventQueue();

        bloc.add(const AuthSignInRequested());
        await pumpEventQueue();
        authStatus.add(AuthStatus.authenticated);
        await pumpEventQueue();
        expect(bloc.state, isA<AuthNeedsOnboarding>());

        bloc.add(
          AuthProfileBodyUpdated(updatedUser: _user(withBodyProfile: true)),
        );
        await pumpEventQueue();
        signIn.complete(_user());
        await pumpEventQueue();

        expect(
          bloc.state,
          AuthAuthenticated(user: _user(withBodyProfile: true)),
        );
        await bloc.close();
      },
    );
  });
}

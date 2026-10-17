import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/auth_service.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';

class _MockAuthService extends Mock implements IAuthService {}

UserModel _user({String uid = 'alice', bool withBodyProfile = false}) =>
    UserModel(
      uid: uid,
      email: '$uid@example.com',
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
      goal: withBodyProfile ? 'maintain' : null,
    );

void main() {
  late _MockAuthService auth;
  late StreamController<AuthStatus> authStatus;

  setUp(() {
    auth = _MockAuthService();
    authStatus = StreamController<AuthStatus>.broadcast();
    when(
      () => auth.profileChanges,
    ).thenAnswer((_) => const Stream<UserModel>.empty());
    when(() => auth.authStatusStream).thenAnswer((_) => authStatus.stream);
    when(() => auth.init()).thenAnswer((_) async {});
    when(() => auth.isSessionValid()).thenAnswer((_) async => true);
  });

  tearDown(() => authStatus.close());

  group('AuthBloc onboarding behaviour', () {
    blocTest<AuthBloc, AuthState>(
      'sends a new user without a body profile to onboarding after sign-in',
      setUp: () =>
          when(() => auth.signInWithGoogle()).thenAnswer((_) async => _user()),
      build: () => AuthBloc(authService: auth),
      act: (bloc) => bloc.add(const AuthSignInRequested()),
      expect: () => [
        const AuthLoading(message: 'Signing in...'),
        AuthNeedsOnboarding(user: _user()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'signs in a user whose body profile is complete',
      setUp: () => when(
        () => auth.signInWithGoogle(),
      ).thenAnswer((_) async => _user(withBodyProfile: true)),
      build: () => AuthBloc(authService: auth),
      act: (bloc) => bloc.add(const AuthSignInRequested()),
      expect: () => [
        const AuthLoading(message: 'Signing in...'),
        AuthAuthenticated(
          user: _user(withBodyProfile: true),
          isFirstLogin: true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'keeps onboarding when Firebase replays the same signed-in user',
      setUp: () =>
          when(() => auth.checkAuthStatus()).thenAnswer((_) async => _user()),
      build: () => AuthBloc(authService: auth),
      act: (bloc) async {
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        authStatus.add(AuthStatus.authenticated);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const AuthLoading(message: 'Checking authentication status...'),
        AuthNeedsOnboarding(user: _user()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sends a different account without a body profile to onboarding',
      build: () => AuthBloc(authService: auth),
      seed: () => AuthAuthenticated(user: _user(withBodyProfile: true)),
      act: (bloc) => bloc.add(AuthStatusChanged(_user(uid: 'bob'))),
      expect: () => [AuthNeedsOnboarding(user: _user(uid: 'bob'))],
    );

    test(
      'keeps a single auth status subscription when started again',
      () async {
        final statusStreams = <StreamController<AuthStatus>>[];
        when(() => auth.authStatusStream).thenAnswer((_) {
          final controller = StreamController<AuthStatus>();
          statusStreams.add(controller);
          return controller.stream;
        });
        when(() => auth.checkAuthStatus()).thenAnswer((_) async => _user());
        final bloc = AuthBloc(authService: auth);

        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AuthStarted());
        await Future<void>.delayed(Duration.zero);

        expect(statusStreams, hasLength(2));
        expect(statusStreams.where((s) => s.hasListener), hasLength(1));
        await bloc.close();
      },
    );

    blocTest<AuthBloc, AuthState>(
      'signs out when Firebase reports no user',
      build: () => AuthBloc(authService: auth),
      seed: () => AuthNeedsOnboarding(user: _user()),
      act: (bloc) => bloc.add(const AuthStatusChanged(null)),
      expect: () => [const AuthUnauthenticated()],
    );
  });
}

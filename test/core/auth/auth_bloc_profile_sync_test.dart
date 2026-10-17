import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';

class _MockAuthService extends Mock implements IAuthService {}

UserModel _user({double? weightKg}) => UserModel(
  uid: 'alice',
  email: 'alice@example.com',
  displayName: 'Alice',
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
  weightKg: weightKg,
);

UserModel _completeUser({required double weightKg}) =>
    _user(weightKg: weightKg).copyWith(
      gender: 'female',
      age: 30,
      heightCm: 165,
      activityLevel: 'moderate',
      goal: 'maintenance',
    );

void main() {
  late _MockAuthService auth;
  late StreamController<UserModel> profileChanges;

  setUpAll(() => registerFallbackValue(_user()));

  setUp(() {
    auth = _MockAuthService();
    profileChanges = StreamController<UserModel>.broadcast();
    when(() => auth.profileChanges).thenAnswer((_) => profileChanges.stream);
  });

  tearDown(() => profileChanges.close());

  group('AuthBloc profile sync', () {
    blocTest<AuthBloc, AuthState>(
      'adopts a body profile saved by another feature',
      build: () => AuthBloc(authService: auth),
      seed: () => AuthAuthenticated(user: _user(weightKg: 70)),
      act: (_) => profileChanges.add(_user(weightKg: 68)),
      expect: () => [AuthAuthenticated(user: _user(weightKg: 68))],
    );

    blocTest<AuthBloc, AuthState>(
      'ignores profile changes while signed out',
      build: () => AuthBloc(authService: auth),
      seed: () => const AuthUnauthenticated(),
      act: (_) => profileChanges.add(_user(weightKg: 68)),
      expect: () => const <AuthState>[],
    );

    blocTest<AuthBloc, AuthState>(
      'keeps the user signed in with the stored profile when a save fails',
      setUp: () {
        when(
          () => auth.updateBodyProfile(any()),
        ).thenThrow(Exception('offline'));
        when(() => auth.currentUser).thenReturn(_completeUser(weightKg: 70));
      },
      build: () => AuthBloc(authService: auth),
      seed: () => AuthAuthenticated(user: _completeUser(weightKg: 70)),
      act: (bloc) => bloc.add(
        AuthProfileBodyUpdated(updatedUser: _completeUser(weightKg: 68)),
      ),
      expect: () => [
        AuthProfileUpdating(user: _completeUser(weightKg: 68)),
        const AuthProfileUpdateFailed(),
        AuthAuthenticated(user: _completeUser(weightKg: 70)),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'keeps a new user on onboarding when the first save fails',
      setUp: () {
        when(
          () => auth.updateBodyProfile(any()),
        ).thenThrow(Exception('offline'));
        when(() => auth.currentUser).thenReturn(_user());
      },
      build: () => AuthBloc(authService: auth),
      seed: () => AuthNeedsOnboarding(user: _user()),
      act: (bloc) => bloc.add(
        AuthProfileBodyUpdated(updatedUser: _completeUser(weightKg: 68)),
      ),
      expect: () => [
        AuthProfileUpdating(user: _completeUser(weightKg: 68)),
        const AuthProfileUpdateFailed(),
        AuthNeedsOnboarding(user: _user()),
      ],
    );

    test('stops listening when closed', () async {
      final bloc = AuthBloc(authService: auth);
      await bloc.close();

      expect(profileChanges.hasListener, isFalse);
    });
  });
}

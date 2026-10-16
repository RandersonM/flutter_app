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

void main() {
  late _MockAuthService auth;
  late StreamController<UserModel> profileChanges;

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

    test('stops listening when closed', () async {
      final bloc = AuthBloc(authService: auth);
      await bloc.close();

      expect(profileChanges.hasListener, isFalse);
    });
  });
}

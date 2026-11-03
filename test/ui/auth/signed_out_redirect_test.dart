import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/auth/signed_out_redirect.dart';
import 'package:opfan/core/services/config/navigation_service.dart';
import 'package:opfan/shared/utils/app_routes.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

final _alice = UserModel(
  uid: 'alice',
  email: 'alice@example.com',
  displayName: 'Alice',
  emailVerified: true,
  providerId: 'google.com',
  createdAt: DateTime(2024),
  lastSignIn: DateTime(2024),
);

void main() {
  late _MockAuthBloc authBloc;
  late StreamController<AuthState> states;
  late NavigationService navigation;

  setUp(() {
    authBloc = _MockAuthBloc();
    states = StreamController<AuthState>();
    navigation = NavigationService();
  });

  tearDown(() => states.close());

  Future<void> pumpApp(WidgetTester tester, AuthState initial) async {
    whenListen(authBloc, states.stream, initialState: initial);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          navigatorKey: navigation.navigatorKey,
          home: const Text('guest home'),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Text('route ${settings.name}'),
          ),
          builder: (context, child) =>
              SignedOutRedirect(navigationService: navigation, child: child!),
        ),
      ),
    );
  }

  group('SignedOutRedirect behaviour', () {
    testWidgets('sends a user who signs out to Login with nothing behind', (
      tester,
    ) async {
      await pumpApp(tester, const AuthInitial());
      states.add(AuthAuthenticated(user: _alice));
      await tester.pumpAndSettle();

      states
        ..add(const AuthLoading())
        ..add(const AuthUnauthenticated());
      await tester.pumpAndSettle();

      expect(find.text('route ${AppRoutes.login}'), findsOneWidget);
      expect(navigation.canPop(), isFalse);
    });

    testWidgets('leaves a guest where they are when a sign-in is cancelled', (
      tester,
    ) async {
      await pumpApp(tester, const AuthUnauthenticated());

      states
        ..add(const AuthLoading())
        ..add(const AuthUnauthenticated());
      await tester.pumpAndSettle();

      expect(find.text('guest home'), findsOneWidget);
    });
  });
}

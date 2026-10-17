import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/shared/widgets/organisms/profile_update_failure_listener.dart';

import '../../../testable_widget.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _failureMessage = "Couldn't save your profile. Please try again.";

final _user = UserModel(
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

  setUp(() {
    authBloc = _MockAuthBloc();
    states = StreamController<AuthState>();
    whenListen(
      authBloc,
      states.stream,
      initialState: AuthAuthenticated(user: _user),
    );
  });

  tearDown(() => states.close());

  Future<void> pumpListener(WidgetTester tester) => tester.pumpWidget(
    getTestableWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const Scaffold(
          body: ProfileUpdateFailureListener(child: SizedBox()),
        ),
      ),
    ),
  );

  group('ProfileUpdateFailureListener behaviour', () {
    testWidgets('tells the user a profile save failed', (tester) async {
      await pumpListener(tester);

      states.add(const AuthProfileUpdateFailed());
      await tester.pump();

      expect(find.text(_failureMessage), findsOneWidget);
    });

    testWidgets('stays quiet when the profile is saved', (tester) async {
      await pumpListener(tester);

      states
        ..add(AuthProfileUpdated(user: _user))
        ..add(AuthAuthenticated(user: _user));
      await tester.pump();

      expect(find.text(_failureMessage), findsNothing);
    });
  });
}

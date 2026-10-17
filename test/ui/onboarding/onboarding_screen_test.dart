import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/features/onboarding/presentation/onboarding_screen.dart';
import 'package:opfan/shared/utils/app_routes.dart';

import '../../testable_widget.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _loginPlaceholder = 'login screen';

void main() {
  final user = UserModel(
    uid: 'uid-1',
    email: 'luffy@strawhat.com',
    displayName: 'Monkey D. Luffy',
    emailVerified: true,
    providerId: 'google.com',
    createdAt: DateTime(2024),
    lastSignIn: DateTime(2024),
  );

  late _MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(const AuthSignOutRequested()));

  setUp(() => authBloc = _MockAuthBloc());

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      getTestableWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => settings.name == AppRoutes.login
                  ? const Text(_loginPlaceholder)
                  : const OnboardingScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fillAndFinish(WidgetTester tester) async {
    await tester.tap(find.text('Male'));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '25');
    await tester.enterText(fields.at(1), '180');
    await tester.enterText(fields.at(2), '75');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lose Weight'));
    await tester.tap(find.text('Sedentary'));
    await tester.pump();
    await tester.tap(find.text('Finish Sign-up'));
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen submit', () {
    testWidgets('sends a guest to login instead of saving a profile', (
      tester,
    ) async {
      when(() => authBloc.state).thenReturn(const AuthUnauthenticated());
      await pumpOnboarding(tester);

      await fillAndFinish(tester);

      expect(tester.takeException(), isNull);
      expect(find.text(_loginPlaceholder), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('saves the body profile of a user who needs onboarding', (
      tester,
    ) async {
      when(() => authBloc.state).thenReturn(AuthNeedsOnboarding(user: user));
      await pumpOnboarding(tester);

      await fillAndFinish(tester);

      final event =
          verify(() => authBloc.add(captureAny())).captured.single
              as AuthProfileBodyUpdated;
      expect(event.updatedUser.uid, 'uid-1');
      expect(event.updatedUser.goal, 'weight_loss');
      expect(event.updatedUser.activityLevel, 'sedentary');
    });

    testWidgets('tells a new user when the profile could not be saved', (
      tester,
    ) async {
      final states = StreamController<AuthState>();
      addTearDown(states.close);
      whenListen(
        authBloc,
        states.stream,
        initialState: AuthNeedsOnboarding(user: user),
      );
      await pumpOnboarding(tester);

      states.add(const AuthProfileUpdateFailed());
      await tester.pump();

      expect(
        find.text("Couldn't save your profile. Please try again."),
        findsOneWidget,
      );
    });
  });
}

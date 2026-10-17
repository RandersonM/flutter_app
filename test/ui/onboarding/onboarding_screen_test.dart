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
const _homePlaceholder = 'home screen';

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

  /// [routeName] `/` stands for the AppWrapper child; login pushes
  /// [AppRoutes.onboarding].
  Future<void> pumpOnboarding(
    WidgetTester tester, {
    String routeName = '/',
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Route<void> route(RouteSettings settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        AppRoutes.login => const Text(_loginPlaceholder),
        AppRoutes.home => const Text(_homePlaceholder),
        _ => const OnboardingScreen(),
      },
    );
    await tester.pumpWidget(
      getTestableWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: Navigator(
            initialRoute: routeName,
            onGenerateInitialRoutes: (_, name) => [
              route(RouteSettings(name: name)),
            ],
            onGenerateRoute: route,
          ),
        ),
      ),
    );
  }

  Future<void> fillStepOne(
    WidgetTester tester, {
    String age = '25',
    String height = '180',
    String weight = '75',
  }) async {
    await tester.tap(find.text('Male'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), age);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Height'),
      height,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current Weight'),
      weight,
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  Future<void> fillStepTwo(WidgetTester tester, {String waist = ''}) async {
    await tester.tap(find.text('Lose Weight'));
    await tester.tap(find.text('Sedentary'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Waist'), waist);
    await tester.pump();
  }

  Future<void> tapFinish(WidgetTester tester) async {
    await tester.tap(find.text('Finish Sign-up'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> fillAndFinish(WidgetTester tester) async {
    await fillStepOne(tester);
    await fillStepTwo(tester);
    await tapFinish(tester);
  }

  AuthProfileBodyUpdated savedEvent() =>
      verify(() => authBloc.add(captureAny())).captured.single
          as AuthProfileBodyUpdated;

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

      final event = savedEvent();
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

    testWidgets('submits the profile once while it is being saved', (
      tester,
    ) async {
      when(() => authBloc.state).thenReturn(AuthNeedsOnboarding(user: user));
      await pumpOnboarding(tester);
      await fillStepOne(tester);
      await fillStepTwo(tester);

      await tapFinish(tester);
      await tapFinish(tester);

      verify(() => authBloc.add(any())).called(1);
    });

    testWidgets('lets AppWrapper switch to home once the profile is saved', (
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

      states.add(AuthAuthenticated(user: user));
      await tester.pumpAndSettle();

      expect(find.text(_homePlaceholder), findsNothing);
    });

    testWidgets('replaces the stack with home when login pushed onboarding', (
      tester,
    ) async {
      final states = StreamController<AuthState>();
      addTearDown(states.close);
      whenListen(
        authBloc,
        states.stream,
        initialState: AuthNeedsOnboarding(user: user),
      );
      await pumpOnboarding(tester, routeName: AppRoutes.onboarding);

      states.add(AuthAuthenticated(user: user));
      await tester.pumpAndSettle();

      expect(find.text(_homePlaceholder), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OnboardingScreen measurements', () {
    setUp(
      () => when(
        () => authBloc.state,
      ).thenReturn(AuthNeedsOnboarding(user: user)),
    );

    testWidgets('accepts a weight typed with a decimal comma', (tester) async {
      await pumpOnboarding(tester);

      await fillStepOne(tester, weight: '72,5');
      await fillStepTwo(tester, waist: '80,5');
      await tapFinish(tester);

      final saved = savedEvent().updatedUser;
      expect(saved.weightKg, 72.5);
      expect(saved.waistCm, 80.5);
    });

    testWidgets('refuses a height outside a human range', (tester) async {
      await pumpOnboarding(tester);

      await fillStepOne(tester, height: '0.5');

      expect(find.text('Enter a value between 50 and 260'), findsOneWidget);
      expect(find.text('Finish Sign-up'), findsNothing);
    });

    testWidgets('refuses an age outside a human range', (tester) async {
      await pumpOnboarding(tester);

      await fillStepOne(tester, age: '200');

      expect(find.text('Enter a value between 10 and 120'), findsOneWidget);
    });

    testWidgets('refuses an optional measurement outside its range', (
      tester,
    ) async {
      await pumpOnboarding(tester);
      await fillStepOne(tester);

      await fillStepTwo(tester, waist: '5');
      await tapFinish(tester);

      expect(find.text('Enter a value between 30 and 250'), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });
  });
}

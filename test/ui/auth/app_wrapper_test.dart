import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/auth/app_wrapper.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/features/onboarding/presentation/onboarding_screen.dart';
import 'package:opfan/features/splash/presentation/splash_screen.dart';

import '../../testable_widget.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

final _newUser = UserModel(
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
      initialState: AuthNeedsOnboarding(user: _newUser),
    );
  });

  tearDown(() => states.close());

  group('AppWrapper behaviour', () {
    testWidgets('keeps the current screen while the profile is saved', (
      tester,
    ) async {
      await tester.pumpWidget(
        getTestableWidget(
          BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const AppWrapper(),
          ),
        ),
      );
      expect(find.byType(OnboardingScreen), findsOneWidget);

      states.add(
        AuthProfileUpdating(user: _newUser.copyWith(gender: 'female')),
      );
      await tester.pump();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}

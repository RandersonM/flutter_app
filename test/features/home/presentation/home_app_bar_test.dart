import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/features/home/presentation/widgets/home_app_bar.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/theme.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

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

  setUp(() {
    authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthAuthenticated(user: user));
  });

  Widget buildApp(ThemeData theme) => MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const Scaffold(appBar: HomeAppBar()),
    ),
  );

  for (final (name, theme) in [
    ('light', getLightTheme()),
    ('dark', getDarkTheme()),
  ]) {
    testWidgets(
      'opens the user drawer without hiding ListTile ink ($name theme)',
      (tester) async {
        final reported = <FlutterErrorDetails>[];
        final previousOnError = FlutterError.onError;
        FlutterError.onError = reported.add;
        try {
          await tester.pumpWidget(buildApp(theme));
          await tester.tap(find.byType(IconButton).first);
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = previousOnError;
        }

        expect(find.text(user.email), findsOneWidget);
        expect(find.byType(ListTile), findsWidgets);
        expect(
          reported.map((details) => details.exceptionAsString()),
          isNot(contains(contains('ListTile background color'))),
        );
      },
    );
  }
}

import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/auth/presentation/login_screen.dart';
import 'package:opfan/features/home/presentation/home_screen.dart';
import 'package:opfan/features/splash/presentation/splash_screen.dart';
import 'package:opfan/features/onboarding/presentation/onboarding_screen.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _authBloc.add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const SplashScreen();
          }

          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }

          if (state is AuthNeedsOnboarding) {
            return const OnboardingScreen();
          }

          if (state is AuthUnauthenticated) {
            return const LoginScreen();
          }

          if (state is AuthError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIcon(
                      PhosphorIconsRegular.warningCircle,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.authenticationError,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _authBloc.add(const AuthStarted());
                      },
                      child: Text(AppLocalizations.of(context)!.tryAgainButton),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _authBloc.add(const AuthClearCache());
                      },
                      child: Text(
                          AppLocalizations.of(context)!.clearDataAndContinue),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SplashScreen();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

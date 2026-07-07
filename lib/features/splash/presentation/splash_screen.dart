// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/splash/presentation/widgets/logo.dart';
import 'package:opfan/shared/utils/decorations/gradient.dart';

/// Purely presentational — shown by [AppWrapper] while `AuthBloc` is
/// `AuthInitial`/`AuthLoading`. It must NOT navigate on its own: this used to
/// fire an unconditional `Navigator.pushNamedAndRemoveUntil(AppRoutes.home)`
/// after a fixed 3s timer, racing `AppWrapper`'s own auth-reactive navigation.
/// Whenever the real session check took longer than 3s, this timer won the
/// race and pushed a second, independent Home route before auth resolved —
/// showing the logged-out Home banner until AuthBloc finally caught up.
/// `AppWrapper`'s `BlocBuilder<AuthBloc, AuthState>` is the only thing that
/// should decide when to leave this screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: purpleGradient(),
        child: const Center(
          child: FractionallySizedBox(
            widthFactor: .5,
            child: SplashLogo(),
          ),
        ),
      ),
    );
  }
}

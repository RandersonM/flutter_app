import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/l10n/app_localizations.dart';

/// Reports a failed body profile save on the screen that opened onboarding in
/// edit mode: onboarding pops right after saving, so it cannot report it.
class ProfileUpdateFailureListener extends StatelessWidget {
  const ProfileUpdateFailureListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) => state is AuthProfileUpdateFailed,
      listener: (context, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdateFailed),
        ),
      ),
      child: child,
    );
  }
}

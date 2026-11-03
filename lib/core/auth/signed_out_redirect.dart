import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/services/config/i_navigation_service.dart';
import 'package:opfan/shared/utils/app_routes.dart';

/// Signing in replaces the whole route stack (login and onboarding push with
/// `pushNamedAndRemoveUntil`), so `AppWrapper` is gone by the time the user
/// signs out and nothing would leave the signed-in screens. Every way out of
/// a session (sign-out, account deletion, revoked session) lands on Login.
class SignedOutRedirect extends StatefulWidget {
  const SignedOutRedirect({
    required this.navigationService,
    required this.child,
    super.key,
  });

  final INavigationService navigationService;
  final Widget child;

  @override
  State<SignedOutRedirect> createState() => _SignedOutRedirectState();
}

class _SignedOutRedirectState extends State<SignedOutRedirect> {
  bool _wasSignedIn = false;

  void _onAuthState(BuildContext context, AuthState state) {
    if (_isSignedIn(state)) {
      _wasSignedIn = true;
    } else if (state is AuthUnauthenticated && _wasSignedIn) {
      _wasSignedIn = false;
      widget.navigationService.navigateAndClear(AppRoutes.login);
    }
  }

  static bool _isSignedIn(AuthState state) =>
      state is AuthAuthenticated ||
      state is AuthNeedsOnboarding ||
      state is AuthProfileUpdating ||
      state is AuthProfileUpdated;

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: _onAuthState,
    child: widget.child,
  );
}

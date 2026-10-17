// Developed by Randerson Mayllon
// Copyright © 2025.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/core/middleware/user_name_middleware.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService _authService;
  StreamSubscription<AuthStatus>? _authStatusSubscription;
  late final StreamSubscription<UserModel> _profileSubscription;

  AuthBloc({required this._authService}) : super(const AuthInitial()) {
    //

    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthUpdateProfile>(_onAuthUpdateProfile);
    on<AuthProfileBodyUpdated>(_onAuthProfileBodyUpdated);
    on<AuthProfileChanged>(_onAuthProfileChanged);
    on<AuthDeleteAccount>(_onAuthDeleteAccount);
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthClearCache>(_onAuthClearCache);

    _profileSubscription = _authService.profileChanges.listen(
      (user) => add(AuthProfileChanged(user)),
    );
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Checking authentication status...'));

      await _authService.init();

      final isSessionValid = await _authService.isSessionValid();

      if (isSessionValid) {
        final user = await _authService.checkAuthStatus();
        if (user != null) {
          emit(_signedInState(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        await _authService.clearCache();
        emit(const AuthUnauthenticated());
      }

      _authStatusSubscription = _authService.authStatusStream.listen((
        status,
      ) async {
        if (status == AuthStatus.authenticated) {
          final currentUser = await _authService.checkAuthStatus();
          if (currentUser != null) {
            add(AuthStatusChanged(currentUser));
          }
        } else if (status == AuthStatus.unauthenticated) {
          add(const AuthStatusChanged(null));
        }
      });
    } catch (e) {
      debugPrint('AuthBloc: Error initializing authentication - $e');
      emit(
        const AuthError(message: 'Authentication failed. Please try again.'),
      );
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in...'));

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        emit(_signedInState(user, isFirstLogin: true));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error in sign in - $e');
      emit(const AuthError(message: 'Sign in failed. Please try again.'));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing out...'));

      await _authService.signOut();

      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Error in sign out - $e');
      emit(const AuthError(message: 'Sign out failed. Please try again.'));
    }
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user == null) {
      emit(const AuthUnauthenticated());
    } else if (user.uid != _signedInUid) {
      emit(_signedInState(user));
    }
  }

  Future<void> _onAuthUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      emit(AuthProfileUpdating(user: currentState.user));

      final updatedUser = await _authService.updateProfile(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
      );

      if (updatedUser != null) {
        emit(AuthProfileUpdated(user: updatedUser));
        emit(AuthAuthenticated(user: updatedUser));
      } else {
        emit(AuthAuthenticated(user: currentState.user));
      }
    } catch (e) {
      debugPrint('AuthBloc: Error updating profile - $e');
      emit(
        const AuthError(message: 'Profile update failed. Please try again.'),
      );
    }
  }

  Future<void> _onAuthProfileBodyUpdated(
    AuthProfileBodyUpdated event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthProfileUpdating(user: event.updatedUser));

      await _authService.updateBodyProfile(event.updatedUser);

      emit(AuthProfileUpdated(user: event.updatedUser));
      emit(AuthAuthenticated(user: event.updatedUser));
    } catch (e) {
      debugPrint('AuthBloc: Error updating body profile - $e');
      emit(
        const AuthError(message: 'Profile update failed. Please try again.'),
      );
    }
  }

  void _onAuthProfileChanged(
    AuthProfileChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthAuthenticated) emit(AuthAuthenticated(user: event.user));
  }

  Future<void> _onAuthDeleteAccount(
    AuthDeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthDeletingAccount());

      await _authService.deleteAccount();

      emit(const AuthAccountDeleted());
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Error deleting account - $e');
      emit(
        const AuthError(message: 'Account deletion failed. Please try again.'),
      );
    }
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isSessionValid = await _authService.isSessionValid();

      if (isSessionValid) {
        final user = await _authService.checkAuthStatus();
        if (user != null) {
          emit(_signedInState(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        await _authService.clearCache();
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error checking status - $e');
      emit(
        const AuthError(message: 'Authentication failed. Please try again.'),
      );
    }
  }

  Future<void> _onAuthClearCache(
    AuthClearCache event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.clearCache();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Error clearing cache - $e');
      emit(const AuthError(message: 'Session error. Please sign in again.'));
    }
  }

  AuthState _signedInState(UserModel user, {bool isFirstLogin = false}) {
    final processedUser = _processUserWithMiddleware(user);
    return processedUser.isProfileComplete
        ? AuthAuthenticated(user: processedUser, isFirstLogin: isFirstLogin)
        : AuthNeedsOnboarding(user: processedUser);
  }

  /// Firebase replays the current user on every subscription, so a status
  /// change for the uid already in the state carries nothing new.
  String? get _signedInUid => switch (state) {
    AuthAuthenticated(:final user) ||
    AuthNeedsOnboarding(:final user) ||
    AuthProfileUpdating(:final user) ||
    AuthProfileUpdated(:final user) => user.uid,
    _ => null,
  };

  UserModel _processUserWithMiddleware(UserModel user) {
    final processedDisplayName = UserNameMiddleware.processDisplayName(
      user.displayName,
    );

    if (processedDisplayName != user.displayName) {
      return user.copyWith(displayName: processedDisplayName);
    }

    return user;
  }

  Map<String, dynamic> getServiceStatus() {
    return _authService.getServiceStatus();
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    _profileSubscription.cancel();
    return super.close();
  }
}

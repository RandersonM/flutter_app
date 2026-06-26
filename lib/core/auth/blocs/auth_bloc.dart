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

  AuthBloc({
    required this._authService}) : super(const AuthInitial()) {
    //
  
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthUpdateProfile>(_onAuthUpdateProfile);
    on<AuthProfileBodyUpdated>(_onAuthProfileBodyUpdated);
    on<AuthDeleteAccount>(_onAuthDeleteAccount);
    on<AuthCheckStatus>(_onAuthCheckStatus);
    on<AuthClearCache>(_onAuthClearCache);
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
          final processedUser = _processUserWithMiddleware(user);

          if (processedUser.isProfileComplete) {
            emit(AuthAuthenticated(user: processedUser));
          } else {
            emit(AuthNeedsOnboarding(user: processedUser));
          }
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        await _authService.clearCache();
        emit(const AuthUnauthenticated());
      }

      _authStatusSubscription = _authService.authStatusStream.listen(
        (status) async {
          if (status == AuthStatus.authenticated) {
            final currentUser = await _authService.checkAuthStatus();
            if (currentUser != null) {
              add(AuthStatusChanged(currentUser));
            }
          } else if (status == AuthStatus.unauthenticated) {
            add(const AuthStatusChanged(null));
          }
        },
      );
    } catch (e) {
      debugPrint('AuthBloc: Error initializing authentication - $e');
      emit(AuthError(message: 'Error checking authentication: $e'));
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
        final processedUser = _processUserWithMiddleware(user);
        emit(AuthAuthenticated(user: processedUser, isFirstLogin: true));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error in sign in - $e');
      emit(AuthError(message: 'Sign in error: $e'));
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
      emit(AuthError(message: 'Sign out error: $e'));
    }
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      final processedUser = _processUserWithMiddleware(event.user!);
      emit(AuthAuthenticated(user: processedUser));
    } else {
      emit(const AuthUnauthenticated());
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
      emit(AuthError(message: 'Profile update error: $e'));
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
      emit(AuthError(message: 'Body profile update error: $e'));
    }
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
      emit(AuthError(message: 'Account deletion error: $e'));
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
          final processedUser = _processUserWithMiddleware(user);

          if (processedUser.isProfileComplete) {
            emit(AuthAuthenticated(user: processedUser));
          } else {
            emit(AuthNeedsOnboarding(user: processedUser));
          }
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        await _authService.clearCache();
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error checking status - $e');
      emit(AuthError(message: 'Status check error: $e'));
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
      emit(AuthError(message: 'Cache clear error: $e'));
    }
  }

  UserModel _processUserWithMiddleware(UserModel user) {
    final processedDisplayName =
        UserNameMiddleware.processDisplayName(user.displayName);

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
    return super.close();
  }
}

// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:equatable/equatable.dart';
import 'package:opfan/core/auth/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isFirstLogin;

  const AuthAuthenticated({required this.user, this.isFirstLogin = false});

  @override
  List<Object?> get props => [user, isFirstLogin];

  AuthAuthenticated copyWith({UserModel? user, bool? isFirstLogin}) {
    return AuthAuthenticated(
      user: user ?? this.user,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }
}

class AuthNeedsOnboarding extends AuthState {
  final UserModel user;

  const AuthNeedsOnboarding({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class AuthProfileUpdating extends AuthState {
  final UserModel user;

  const AuthProfileUpdating({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthProfileUpdated extends AuthState {
  final UserModel user;

  const AuthProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthDeletingAccount extends AuthState {
  const AuthDeletingAccount();
}

class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}

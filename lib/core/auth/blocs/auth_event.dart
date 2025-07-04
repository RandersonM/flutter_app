// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:equatable/equatable.dart';
import 'package:opfan/core/auth/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthStatusChanged extends AuthEvent {
  final UserModel? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUpdateProfile extends AuthEvent {
  final String? displayName;
  final String? photoUrl;

  const AuthUpdateProfile({
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}

class AuthDeleteAccount extends AuthEvent {
  const AuthDeleteAccount();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthClearCache extends AuthEvent {
  const AuthClearCache();
}

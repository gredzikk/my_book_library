import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in with email and password
class SignInRequested extends AuthEvent {
  /// User's email address
  final String email;

  /// User's password
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up a new user
class SignUpRequested extends AuthEvent {
  /// User's email address
  final String email;

  /// User's password
  final String password;

  const SignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign out the current user
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event to send password reset email
class PasswordResetRequested extends AuthEvent {
  /// Email address to send reset link to
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to update user password
class PasswordUpdateRequested extends AuthEvent {
  /// New password
  final String password;

  const PasswordUpdateRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

/// Event to resend confirmation email
class ConfirmationEmailResendRequested extends AuthEvent {
  /// Email address to resend confirmation to
  final String email;

  const ConfirmationEmailResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to check initial authentication state
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Event to clear any error state
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

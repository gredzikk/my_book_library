import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before authentication status is checked
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State while an authentication operation is in progress
class AuthLoading extends AuthState {
  /// Optional message about what operation is in progress
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when user is authenticated
class Authenticated extends AuthState {
  /// The authenticated user
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when an authentication error occurs
class AuthError extends AuthState {
  /// Error message to display to the user
  final String message;

  /// Optional: the previous state before the error
  /// This allows UI to decide whether to stay on current screen
  final AuthState? previousState;

  const AuthError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// State when password reset email was sent successfully
class PasswordResetEmailSent extends AuthState {
  /// Email address the reset link was sent to
  final String email;

  const PasswordResetEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// State when password was updated successfully
class PasswordUpdateSuccess extends AuthState {
  const PasswordUpdateSuccess();
}

/// State when sign up was successful
class SignUpSuccess extends AuthState {
  /// Email address that was registered
  final String email;

  const SignUpSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

/// State when confirmation email was resent successfully
class ConfirmationEmailResent extends AuthState {
  /// Email address the confirmation was sent to
  final String email;

  const ConfirmationEmailResent(this.email);

  @override
  List<Object?> get props => [email];
}

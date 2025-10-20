import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../services/auth_service.dart';
import '../../../core/exceptions.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state and business logic
///
/// This BLoC handles:
/// - Sign in with email and password
/// - Sign up new users
/// - Sign out
/// - Password reset flow
/// - Password update
/// - Authentication state management
///
/// It coordinates with AuthService to provide a unified interface for the UI.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final Logger _logger = Logger('AuthBloc');
  StreamSubscription? _authStateSubscription;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<ConfirmationEmailResendRequested>(_onConfirmationEmailResendRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthErrorCleared>(_onAuthErrorCleared);

    // Listen to auth state changes from Supabase
    _authStateSubscription = _authService.authStateChanges.listen((authState) {
      if (authState.session != null) {
        final user = authState.session!.user;
        _logger.info('Auth state changed: user authenticated - ${user.id}');
        add(const AuthStatusChecked());
      } else {
        _logger.info('Auth state changed: user signed out');
        add(const AuthStatusChecked());
      }
    });

    // Check initial auth status
    add(const AuthStatusChecked());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  // ==========================================================================
  // Sign In
  // ==========================================================================

  /// Handles sign in request
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing sign in request for: ${event.email}');
    emit(const AuthLoading(message: 'Logowanie...'));

    try {
      await _authService.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      // Get the current user after successful sign in
      final user = _authService.currentUser;
      if (user != null) {
        _logger.info('Sign in successful for user: ${user.id}');
        emit(Authenticated(user));
      } else {
        _logger.warning('Sign in completed but no user found');
        emit(const AuthError('Wystąpił błąd podczas logowania'));
      }
    } on UnauthorizedException catch (e) {
      _logger.warning('Sign in failed: unauthorized - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
      _logger.info('Emitted AuthError state with message: ${e.message}');
    } on ValidationException catch (e) {
      _logger.warning('Sign in failed: validation - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
      _logger.info('Emitted AuthError state with message: ${e.message}');
    } on NoInternetException {
      _logger.warning('Sign in failed: no internet');
      const errorMessage = 'Brak połączenia z internetem';
      emit(AuthError(errorMessage, previousState: const Unauthenticated()));
      _logger.info('Emitted AuthError state with message: $errorMessage');
    } on ServerException catch (e) {
      _logger.severe('Sign in failed: server error - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
      _logger.info('Emitted AuthError state with message: ${e.message}');
    } catch (e, stackTrace) {
      _logger.severe('Sign in failed: unexpected error - $e\n$stackTrace');
      const errorMessage = 'Wystąpił nieoczekiwany błąd';
      emit(const AuthError(errorMessage, previousState: Unauthenticated()));
      _logger.info('Emitted AuthError state with message: $errorMessage');
    }
  }

  // ==========================================================================
  // Sign Up
  // ==========================================================================

  /// Handles sign up request
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing sign up request for: ${event.email}');
    emit(const AuthLoading(message: 'Rejestracja...'));

    try {
      await _authService.signUp(email: event.email, password: event.password);

      _logger.info('Sign up successful for: ${event.email}');
      emit(SignUpSuccess(event.email));
    } on ValidationException catch (e) {
      _logger.warning('Sign up failed: validation - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } on NoInternetException {
      _logger.warning('Sign up failed: no internet');
      emit(
        AuthError(
          'Brak połączenia z internetem',
          previousState: const Unauthenticated(),
        ),
      );
    } on ServerException catch (e) {
      _logger.severe('Sign up failed: server error - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } catch (e) {
      _logger.severe('Sign up failed: unexpected error - $e');
      emit(
        const AuthError(
          'Wystąpił nieoczekiwany błąd',
          previousState: Unauthenticated(),
        ),
      );
    }
  }

  // ==========================================================================
  // Sign Out
  // ==========================================================================

  /// Handles sign out request
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing sign out request');

    // Store current user for logging
    final currentUser = _authService.currentUser;
    emit(const AuthLoading(message: 'Wylogowywanie...'));

    try {
      await _authService.signOut();

      _logger.info('Sign out successful for user: ${currentUser?.id}');
      emit(const Unauthenticated());
    } on NoInternetException {
      _logger.warning('Sign out failed: no internet');
      // Even without internet, clear local session
      emit(const Unauthenticated());
    } on ServerException catch (e) {
      _logger.severe('Sign out failed: server error - ${e.message}');
      // Clear local session even if server call fails
      emit(const Unauthenticated());
    } catch (e) {
      _logger.severe('Sign out failed: unexpected error - $e');
      // Always ensure user is signed out locally
      emit(const Unauthenticated());
    }
  }

  // ==========================================================================
  // Password Reset
  // ==========================================================================

  /// Handles password reset request
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing password reset request for: ${event.email}');
    emit(const AuthLoading(message: 'Wysyłanie linku resetującego...'));

    try {
      await _authService.sendPasswordResetEmail(email: event.email);

      _logger.info('Password reset email sent to: ${event.email}');
      emit(PasswordResetEmailSent(event.email));
    } on ValidationException catch (e) {
      _logger.warning('Password reset failed: validation - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } on NoInternetException {
      _logger.warning('Password reset failed: no internet');
      emit(
        AuthError(
          'Brak połączenia z internetem',
          previousState: const Unauthenticated(),
        ),
      );
    } on ServerException catch (e) {
      _logger.severe('Password reset failed: server error - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } catch (e) {
      _logger.severe('Password reset failed: unexpected error - $e');
      emit(
        const AuthError(
          'Wystąpił nieoczekiwany błąd',
          previousState: Unauthenticated(),
        ),
      );
    }
  }

  // ==========================================================================
  // Password Update
  // ==========================================================================

  /// Handles password update request
  Future<void> _onPasswordUpdateRequested(
    PasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing password update request');
    emit(const AuthLoading(message: 'Aktualizacja hasła...'));

    try {
      await _authService.updateUserPassword(password: event.password);

      _logger.info('Password updated successfully');
      emit(const PasswordUpdateSuccess());
    } on UnauthorizedException catch (e) {
      _logger.warning('Password update failed: unauthorized - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } on ValidationException catch (e) {
      _logger.warning('Password update failed: validation - ${e.message}');
      // Keep user authenticated state if just validation error
      final user = _authService.currentUser;
      final previousState = user != null
          ? Authenticated(user)
          : const Unauthenticated();
      emit(AuthError(e.message, previousState: previousState));
    } on NoInternetException {
      _logger.warning('Password update failed: no internet');
      final user = _authService.currentUser;
      final previousState = user != null
          ? Authenticated(user)
          : const Unauthenticated();
      emit(
        AuthError('Brak połączenia z internetem', previousState: previousState),
      );
    } on ServerException catch (e) {
      _logger.severe('Password update failed: server error - ${e.message}');
      final user = _authService.currentUser;
      final previousState = user != null
          ? Authenticated(user)
          : const Unauthenticated();
      emit(AuthError(e.message, previousState: previousState));
    } catch (e) {
      _logger.severe('Password update failed: unexpected error - $e');
      emit(
        const AuthError(
          'Wystąpił nieoczekiwany błąd',
          previousState: Unauthenticated(),
        ),
      );
    }
  }

  // ==========================================================================
  // Resend Confirmation Email
  // ==========================================================================

  /// Handles resend confirmation email request
  Future<void> _onConfirmationEmailResendRequested(
    ConfirmationEmailResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Processing resend confirmation email for: ${event.email}');
    emit(const AuthLoading(message: 'Wysyłanie emaila weryfikacyjnego...'));

    try {
      await _authService.resendConfirmationEmail(email: event.email);

      _logger.info('Confirmation email resent to: ${event.email}');
      emit(ConfirmationEmailResent(event.email));
    } on ValidationException catch (e) {
      _logger.warning('Resend confirmation failed: validation - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } on NoInternetException {
      _logger.warning('Resend confirmation failed: no internet');
      emit(
        AuthError(
          'Brak połączenia z internetem',
          previousState: const Unauthenticated(),
        ),
      );
    } on ServerException catch (e) {
      _logger.severe('Resend confirmation failed: server error - ${e.message}');
      emit(AuthError(e.message, previousState: const Unauthenticated()));
    } catch (e) {
      _logger.severe('Resend confirmation failed: unexpected error - $e');
      emit(
        const AuthError(
          'Wystąpił nieoczekiwany błąd',
          previousState: Unauthenticated(),
        ),
      );
    }
  }

  // ==========================================================================
  // Auth Status Check
  // ==========================================================================

  /// Handles authentication status check
  void _onAuthStatusChecked(AuthStatusChecked event, Emitter<AuthState> emit) {
    _logger.info('Checking authentication status');

    final user = _authService.currentUser;
    if (user != null) {
      _logger.info('User is authenticated: ${user.id}');
      emit(Authenticated(user));
    } else {
      _logger.info('User is not authenticated');
      emit(const Unauthenticated());
    }
  }

  // ==========================================================================
  // Error Cleared
  // ==========================================================================

  /// Handles clearing error state
  void _onAuthErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    _logger.info('Clearing auth error state');

    // Check current auth status
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }
}

/// Service for managing authentication operations via Supabase Auth
///
/// This service provides methods for:
/// - Sign in with email and password
/// - Sign up new users
/// - Sign out
/// - Password reset flow
/// - Password update
///
/// All operations use Supabase Auth and handle errors appropriately.
library;

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../core/exceptions.dart';

// ============================================================================
// Abstract Interface
// ============================================================================

/// Abstract interface for authentication service
///
/// This interface defines the contract for authentication operations,
/// allowing for easier testing and potential alternative implementations.
abstract class IAuthService {
  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges;

  /// Current authenticated user, null if not authenticated
  User? get currentUser;

  /// Sign in with email and password
  ///
  /// Throws:
  /// - [UnauthorizedException] if credentials are invalid
  /// - [ValidationException] if email format is invalid
  /// - [ServerException] if Supabase service is unavailable
  /// - [NoInternetException] if no network connection
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Sign up a new user with email and password
  ///
  /// Throws:
  /// - [ValidationException] if email is already registered or password is weak
  /// - [ServerException] if Supabase service is unavailable
  /// - [NoInternetException] if no network connection
  Future<void> signUp({required String email, required String password});

  /// Sign out the current user
  ///
  /// Throws:
  /// - [ServerException] if sign out fails
  /// - [NoInternetException] if no network connection
  Future<void> signOut();

  /// Send password reset email
  ///
  /// Throws:
  /// - [ValidationException] if email format is invalid
  /// - [ServerException] if Supabase service is unavailable
  /// - [NoInternetException] if no network connection
  Future<void> sendPasswordResetEmail({required String email});

  /// Update user password
  ///
  /// Throws:
  /// - [UnauthorizedException] if not authenticated
  /// - [ValidationException] if password is too weak
  /// - [ServerException] if update fails
  /// - [NoInternetException] if no network connection
  Future<void> updateUserPassword({required String password});

  /// Resend confirmation email for unverified user
  ///
  /// Throws:
  /// - [ValidationException] if email format is invalid
  /// - [ServerException] if Supabase service is unavailable
  /// - [NoInternetException] if no network connection
  Future<void> resendConfirmationEmail({required String email});
}

// ============================================================================
// Implementation
// ============================================================================

/// Service for managing authentication operations
///
/// This class provides a high-level interface for interacting with
/// Supabase Auth. It handles:
/// - Error handling and transformation to appropriate exceptions
/// - Logging for debugging and monitoring
/// - Session management through Supabase client
class AuthService implements IAuthService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('AuthService');

  /// Creates a new AuthService instance
  ///
  /// [_supabase] The Supabase client to use for auth operations
  AuthService(this._supabase);

  /// Access to the GoTrue auth client
  GoTrueClient get _auth => _supabase.auth;

  // ==========================================================================
  // Stream and Current User
  // ==========================================================================

  @override
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  @override
  User? get currentUser => _auth.currentUser;

  // ==========================================================================
  // Sign In
  // ==========================================================================

  /// Sign in with email and password
  ///
  /// **Parameters:**
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// **Throws:**
  /// - [UnauthorizedException]: Invalid credentials (401)
  /// - [ValidationException]: Invalid email format (400)
  /// - [ServerException]: Database error or service unavailable (500)
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.signInWithPassword(
  ///     email: 'user@example.com',
  ///     password: 'securePassword123',
  ///   );
  ///   // User is now authenticated
  /// } on UnauthorizedException catch (e) {
  ///   // Show invalid credentials error
  /// }
  /// ```
  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _logger.info('Attempting sign in for email: $email');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      stopwatch.stop();
      _logger.info(
        'Sign in successful in ${stopwatch.elapsedMilliseconds}ms. '
        'User: ${response.user?.id}, Session: ${response.session != null}',
      );
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Sign in failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'sign in');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during sign in: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during sign in: $e');
      throw ServerException('Wystąpił nieoczekiwany błąd podczas logowania');
    }
  }

  // ==========================================================================
  // Sign Up
  // ==========================================================================

  /// Sign up a new user
  ///
  /// **Parameters:**
  /// - [email]: User's email address
  /// - [password]: User's password (minimum 8 characters)
  ///
  /// **Throws:**
  /// - [ValidationException]: Email already exists or password too weak (400)
  /// - [ServerException]: Database error or service unavailable (500)
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.signUp(
  ///     email: 'newuser@example.com',
  ///     password: 'securePassword123',
  ///   );
  ///   // User account created, check email for verification
  /// } on ValidationException catch (e) {
  ///   // Show validation error (e.g., email already registered)
  /// }
  /// ```
  @override
  Future<void> signUp({required String email, required String password}) async {
    _logger.info('Attempting sign up for email: $email');
    final stopwatch = Stopwatch()..start();

    try {
      await _auth.signUp(
        email: email.trim(),
        password: password,
        //emailRedirectTo: 'io.supabase.mybooklibrary://login-callback',
      );

      stopwatch.stop();
      _logger.info('Sign up successful in ${stopwatch.elapsedMilliseconds}ms');
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Sign up failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'sign up');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during sign up: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during sign up: $e');
      throw ServerException('Wystąpił nieoczekiwany błąd podczas rejestracji');
    }
  }

  // ==========================================================================
  // Sign Out
  // ==========================================================================

  /// Sign out the current user
  ///
  /// **Throws:**
  /// - [ServerException]: Sign out operation failed (500)
  /// - [NoInternetException]: No network connection
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.signOut();
  ///   // User is now signed out, navigate to login screen
  /// } on ServerException catch (e) {
  ///   // Show error, but user session may still be cleared locally
  /// }
  /// ```
  @override
  Future<void> signOut() async {
    _logger.info('Attempting sign out');
    final stopwatch = Stopwatch()..start();

    try {
      await _auth.signOut();

      stopwatch.stop();
      _logger.info('Sign out successful in ${stopwatch.elapsedMilliseconds}ms');
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Sign out failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'sign out');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during sign out: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during sign out: $e');
      throw ServerException('Wystąpił nieoczekiwany błąd podczas wylogowania');
    }
  }

  // ==========================================================================
  // Password Reset
  // ==========================================================================

  /// Send password reset email
  ///
  /// **Parameters:**
  /// - [email]: User's email address
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid email format (400)
  /// - [ServerException]: Service unavailable (500)
  /// - [NoInternetException]: No network connection
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.sendPasswordResetEmail(
  ///     email: 'user@example.com',
  ///   );
  ///   // Email sent, show success message
  /// } on ValidationException catch (e) {
  ///   // Invalid email format
  /// }
  /// ```
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    _logger.info('Sending password reset email to: $email');
    final stopwatch = Stopwatch()..start();

    try {
      await _auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.mybooklibrary://login-callback',
      );

      stopwatch.stop();
      _logger.info(
        'Password reset email sent in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Password reset failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'password reset');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during password reset: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during password reset: $e');
      throw ServerException(
        'Wystąpił nieoczekiwany błąd podczas resetowania hasła',
      );
    }
  }

  // ==========================================================================
  // Update Password
  // ==========================================================================

  /// Update user password
  ///
  /// **Parameters:**
  /// - [password]: New password (minimum 8 characters)
  ///
  /// **Throws:**
  /// - [UnauthorizedException]: User not authenticated (401)
  /// - [ValidationException]: Password too weak (400)
  /// - [ServerException]: Update failed (500)
  /// - [NoInternetException]: No network connection
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.updateUserPassword(
  ///     password: 'newSecurePassword123',
  ///   );
  ///   // Password updated successfully
  /// } on UnauthorizedException catch (e) {
  ///   // User not authenticated, redirect to login
  /// }
  /// ```
  @override
  Future<void> updateUserPassword({required String password}) async {
    _logger.info('Attempting to update user password');
    final stopwatch = Stopwatch()..start();

    try {
      await _auth.updateUser(UserAttributes(password: password));

      stopwatch.stop();
      _logger.info(
        'Password updated successfully in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Password update failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'password update');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during password update: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during password update: $e');
      throw ServerException(
        'Wystąpił nieoczekiwany błąd podczas aktualizacji hasła',
      );
    }
  }

  // ==========================================================================
  // Resend Confirmation Email
  // ==========================================================================

  /// Resend confirmation email for unverified user
  ///
  /// **Parameters:**
  /// - [email]: User's email address
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid email format (400)
  /// - [ServerException]: Service unavailable (500)
  /// - [NoInternetException]: No network connection
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await authService.resendConfirmationEmail(
  ///     email: 'user@example.com',
  ///   );
  ///   // Email sent, show success message
  /// } on ValidationException catch (e) {
  ///   // Invalid email format
  /// }
  /// ```
  @override
  Future<void> resendConfirmationEmail({required String email}) async {
    _logger.info('Resending confirmation email to: $email');
    final stopwatch = Stopwatch()..start();

    try {
      await _auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: 'io.supabase.mybooklibrary://login-callback',
      );

      stopwatch.stop();
      _logger.info(
        'Confirmation email resent in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on AuthException catch (e) {
      stopwatch.stop();
      _logger.warning(
        'Resend confirmation failed after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _handleAuthException(e, 'resend confirmation');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.severe('Network error during resend confirmation: $e');
      throw NoInternetException();
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error during resend confirmation: $e');
      throw ServerException(
        'Wystąpił nieoczekiwany błąd podczas wysyłania emaila weryfikacyjnego',
      );
    }
  }

  // ==========================================================================
  // Error Handling
  // ==========================================================================

  /// Handles Supabase AuthException and converts to appropriate app exceptions
  ///
  /// This method maps common Supabase Auth error messages to our custom
  /// exception types with user-friendly Polish messages.
  Never _handleAuthException(AuthException e, String operation) {
    final message = e.message.toLowerCase();

    // Log full error details for debugging
    _logger.severe(
      'AuthException during $operation:\n'
      '  Message: ${e.message}\n'
      '  StatusCode: ${e.statusCode}\n'
      '  Error: $e',
    );

    // Email not confirmed - specific message
    if (message.contains('email not confirmed')) {
      throw UnauthorizedException(
        'Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową i kliknij link weryfikacyjny.',
      );
    }

    // Invalid login credentials
    if (message.contains('invalid login credentials') ||
        message.contains('invalid password') ||
        message.contains('invalid email or password')) {
      throw UnauthorizedException('Nieprawidłowy e-mail lub hasło');
    }

    // User already registered
    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      throw ValidationException('Użytkownik o tym adresie e-mail już istnieje');
    }

    // Email validation errors
    if (message.contains('invalid email') ||
        message.contains('unable to validate email')) {
      throw ValidationException('Wprowadź poprawny adres e-mail');
    }

    // Password validation errors
    if (message.contains('password') &&
        (message.contains('weak') ||
            message.contains('short') ||
            message.contains('minimum'))) {
      throw ValidationException('Hasło musi mieć co najmniej 8 znaków');
    }

    // Not authenticated
    if (message.contains('not authenticated') ||
        message.contains('no user') ||
        message.contains('session not found')) {
      throw UnauthorizedException('Musisz być zalogowany');
    }

    // Rate limiting
    if (message.contains('rate limit') || message.contains('too many')) {
      throw ValidationException('Zbyt wiele prób. Spróbuj ponownie za chwilę');
    }

    // Network/timeout errors
    if (message.contains('network') || message.contains('timeout')) {
      throw NoInternetException();
    }

    // Default to server error with original message
    _logger.severe('Unhandled auth error during $operation: ${e.message}');
    throw ServerException(e.message);
  }
}

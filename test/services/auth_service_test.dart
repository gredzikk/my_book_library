import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/services/auth_service.dart';
import 'package:my_book_library/core/exceptions.dart';

import 'auth_service_test.mocks.dart';

/// Unit tests for AuthService
///
/// These tests verify that:
/// - Authentication operations work correctly
/// - Errors are properly handled and transformed to appropriate exceptions
/// - Edge cases are handled gracefully
/// - Network errors are properly caught
/// - Business rules are enforced
///
/// Test coverage includes:
/// - Sign in with password (happy path and errors)
/// - Sign up (happy path and errors)
/// - Sign out (happy path and errors)
/// - Password reset (happy path and errors)
/// - Password update (happy path and errors)
/// - Email confirmation resend (happy path and errors)
/// - Email trimming and validation
/// - Rate limiting handling
/// - Network error handling
///
/// According to TDD principles:
/// - Test all possible cases including edge cases
/// - Use meaningful test names that describe what is being tested
/// - Follow the testing pyramid: focus on unit tests
@GenerateMocks([SupabaseClient, GoTrueClient, User, Session, AuthResponse])
void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late AuthService authService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(mockSupabase.auth).thenReturn(mockAuth);
    authService = AuthService(mockSupabase);
  });

  group('currentUser', () {
    test('should return current user when authenticated', () {
      // Arrange
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, equals(mockUser));
      verify(mockAuth.currentUser).called(1);
    });

    test('should return null when not authenticated', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, isNull);
      verify(mockAuth.currentUser).called(1);
    });
  });

  group('signInWithPassword', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should sign in successfully with valid credentials', () async {
      // Arrange
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockAuthResponse();

      when(mockResponse.user).thenReturn(mockUser);
      when(mockResponse.session).thenReturn(mockSession);
      when(mockUser.id).thenReturn('test-user-id');
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await authService.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      verify(
        mockAuth.signInWithPassword(email: testEmail, password: testPassword),
      ).called(1);
    });

    test('should trim email before signing in', () async {
      // Arrange
      const emailWithSpaces = '  test@example.com  ';
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockAuthResponse();

      when(mockResponse.user).thenReturn(mockUser);
      when(mockResponse.session).thenReturn(mockSession);
      when(mockUser.id).thenReturn('test-user-id');
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await authService.signInWithPassword(
        email: emailWithSpaces,
        password: testPassword,
      );

      // Assert
      verify(
        mockAuth.signInWithPassword(
          email: testEmail, // Should be trimmed
          password: testPassword,
        ),
      ).called(1);
    });

    test(
      'should throw UnauthorizedException for invalid credentials',
      () async {
        // Arrange
        when(
          mockAuth.signInWithPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(AuthException('Invalid login credentials'));

        // Act & Assert
        expect(
          () => authService.signInWithPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(
            isA<UnauthorizedException>().having(
              (e) => e.message,
              'message',
              contains('Nieprawidłowy e-mail lub hasło'),
            ),
          ),
        );
      },
    );

    test('should throw UnauthorizedException for unconfirmed email', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Email not confirmed'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            contains('Adres e-mail nie został potwierdzony'),
          ),
        ),
      );
    });

    test('should throw ValidationException for invalid email format', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Unable to validate email'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: 'invalid-email',
          password: testPassword,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Wprowadź poprawny adres e-mail'),
          ),
        ),
      );
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should throw ValidationException for rate limiting', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Too many requests'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Zbyt wiele prób'),
          ),
        ),
      );
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('signUp', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'password123';
    const redirectUrl = 'io.supabase.mybooklibrary://login-callback';

    test('should sign up successfully with valid data', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await authService.signUp(email: testEmail, password: testPassword);

      // Assert
      verify(
        mockAuth.signUp(
          email: testEmail,
          password: testPassword,
          emailRedirectTo: redirectUrl,
        ),
      ).called(1);
    });

    test('should trim email before signing up', () async {
      // Arrange
      const emailWithSpaces = '  newuser@example.com  ';
      final mockResponse = MockAuthResponse();
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await authService.signUp(email: emailWithSpaces, password: testPassword);

      // Assert
      verify(
        mockAuth.signUp(
          email: testEmail, // Should be trimmed
          password: testPassword,
          emailRedirectTo: redirectUrl,
        ),
      ).called(1);
    });

    test('should throw ValidationException when user already exists', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('User already registered'));

      // Act & Assert
      expect(
        () => authService.signUp(email: testEmail, password: testPassword),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Użytkownik o tym adresie e-mail już istnieje'),
          ),
        ),
      );
    });

    test('should throw ValidationException for weak password', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Password is too weak'));

      // Act & Assert
      expect(
        () => authService.signUp(email: testEmail, password: 'weak'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Hasło musi mieć co najmniej 8 znaków'),
          ),
        ),
      );
    });

    test('should throw ValidationException for invalid email', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () =>
            authService.signUp(email: 'invalid-email', password: testPassword),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Wprowadź poprawny adres e-mail'),
          ),
        ),
      );
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authService.signUp(email: testEmail, password: testPassword),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => authService.signUp(email: testEmail, password: testPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('signOut', () {
    test('should sign out successfully', () async {
      // Arrange
      when(mockAuth.signOut()).thenAnswer((_) async => {});

      // Act
      await authService.signOut();

      // Assert
      verify(mockAuth.signOut()).called(1);
    });

    test('should throw ServerException when sign out fails', () async {
      // Arrange
      when(mockAuth.signOut()).thenThrow(AuthException('Sign out failed'));

      // Act & Assert
      expect(() => authService.signOut(), throwsA(isA<ServerException>()));
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(mockAuth.signOut()).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(() => authService.signOut(), throwsA(isA<NoInternetException>()));
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(mockAuth.signOut()).thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(() => authService.signOut(), throwsA(isA<ServerException>()));
    });
  });

  group('sendPasswordResetEmail', () {
    const testEmail = 'user@example.com';
    const redirectUrl = 'io.supabase.mybooklibrary://login-callback';

    test('should send password reset email successfully', () async {
      // Arrange
      when(
        mockAuth.resetPasswordForEmail(any, redirectTo: anyNamed('redirectTo')),
      ).thenAnswer((_) async => {});

      // Act
      await authService.sendPasswordResetEmail(email: testEmail);

      // Assert
      verify(
        mockAuth.resetPasswordForEmail(testEmail, redirectTo: redirectUrl),
      ).called(1);
    });

    test('should trim email before sending reset email', () async {
      // Arrange
      const emailWithSpaces = '  user@example.com  ';
      when(
        mockAuth.resetPasswordForEmail(any, redirectTo: anyNamed('redirectTo')),
      ).thenAnswer((_) async => {});

      // Act
      await authService.sendPasswordResetEmail(email: emailWithSpaces);

      // Assert
      verify(
        mockAuth.resetPasswordForEmail(
          testEmail, // Should be trimmed
          redirectTo: redirectUrl,
        ),
      ).called(1);
    });

    test('should throw ValidationException for invalid email', () async {
      // Arrange
      when(
        mockAuth.resetPasswordForEmail(any, redirectTo: anyNamed('redirectTo')),
      ).thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () => authService.sendPasswordResetEmail(email: 'invalid-email'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Wprowadź poprawny adres e-mail'),
          ),
        ),
      );
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(
        mockAuth.resetPasswordForEmail(any, redirectTo: anyNamed('redirectTo')),
      ).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authService.sendPasswordResetEmail(email: testEmail),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(
        mockAuth.resetPasswordForEmail(any, redirectTo: anyNamed('redirectTo')),
      ).thenThrow(Exception('Service unavailable'));

      // Act & Assert
      expect(
        () => authService.sendPasswordResetEmail(email: testEmail),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updateUserPassword', () {
    const newPassword = 'newSecurePassword123';

    test('should update password successfully', () async {
      // Arrange
      when(
        mockAuth.updateUser(any),
      ).thenAnswer((_) async => MockUserResponse());

      // Act
      await authService.updateUserPassword(password: newPassword);

      // Assert
      verify(
        mockAuth.updateUser(
          argThat(
            isA<UserAttributes>().having(
              (attr) => attr.password,
              'password',
              equals(newPassword),
            ),
          ),
        ),
      ).called(1);
    });

    test('should throw UnauthorizedException when not authenticated', () async {
      // Arrange
      when(
        mockAuth.updateUser(any),
      ).thenThrow(AuthException('Not authenticated'));

      // Act & Assert
      expect(
        () => authService.updateUserPassword(password: newPassword),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('should throw ValidationException for weak password', () async {
      // Arrange
      when(
        mockAuth.updateUser(any),
      ).thenThrow(AuthException('Password is too weak'));

      // Act & Assert
      expect(
        () => authService.updateUserPassword(password: 'weak'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Hasło musi mieć co najmniej 8 znaków'),
          ),
        ),
      );
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(
        mockAuth.updateUser(any),
      ).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authService.updateUserPassword(password: newPassword),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(mockAuth.updateUser(any)).thenThrow(Exception('Update failed'));

      // Act & Assert
      expect(
        () => authService.updateUserPassword(password: newPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('resendConfirmationEmail', () {
    const testEmail = 'user@example.com';
    const redirectUrl = 'io.supabase.mybooklibrary://login-callback';

    test('should resend confirmation email successfully', () async {
      // Arrange
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenAnswer((_) async => MockResendResponse());

      // Act
      await authService.resendConfirmationEmail(email: testEmail);

      // Assert
      verify(
        mockAuth.resend(
          type: OtpType.signup,
          email: testEmail,
          emailRedirectTo: redirectUrl,
        ),
      ).called(1);
    });

    test('should trim email before resending confirmation', () async {
      // Arrange
      const emailWithSpaces = '  user@example.com  ';
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenAnswer((_) async => MockResendResponse());

      // Act
      await authService.resendConfirmationEmail(email: emailWithSpaces);

      // Assert
      verify(
        mockAuth.resend(
          type: OtpType.signup,
          email: testEmail, // Should be trimmed
          emailRedirectTo: redirectUrl,
        ),
      ).called(1);
    });

    test('should throw ValidationException for invalid email', () async {
      // Arrange
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () => authService.resendConfirmationEmail(email: 'invalid-email'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Wprowadź poprawny adres e-mail'),
          ),
        ),
      );
    });

    test('should throw ValidationException for rate limiting', () async {
      // Arrange
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Rate limit exceeded'));

      // Act & Assert
      expect(
        () => authService.resendConfirmationEmail(email: testEmail),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Zbyt wiele prób'),
          ),
        ),
      );
    });

    test('should throw NoInternetException for network errors', () async {
      // Arrange
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(const SocketException('No Internet'));

      // Act & Assert
      expect(
        () => authService.resendConfirmationEmail(email: testEmail),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should throw ServerException for unexpected errors', () async {
      // Arrange
      when(
        mockAuth.resend(
          type: anyNamed('type'),
          email: anyNamed('email'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(Exception('Service error'));

      // Act & Assert
      expect(
        () => authService.resendConfirmationEmail(email: testEmail),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('Edge Cases', () {
    test('should handle empty email in signIn', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () =>
            authService.signInWithPassword(email: '', password: 'password123'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should handle empty password in signIn', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Invalid login credentials'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: 'test@example.com',
          password: '',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('should handle email with only whitespace', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      final mockSession = MockSession();
      when(mockResponse.user).thenReturn(mockUser);
      when(mockResponse.session).thenReturn(mockSession);
      when(mockUser.id).thenReturn('test-user-id');
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await authService.signInWithPassword(
        email: '   ',
        password: 'password123',
      );

      // Assert - should trim to empty string
      verify(
        mockAuth.signInWithPassword(email: '', password: 'password123'),
      ).called(1);
    });

    test('should handle session not found error', () async {
      // Arrange
      when(
        mockAuth.updateUser(any),
      ).thenThrow(AuthException('Session not found'));

      // Act & Assert
      expect(
        () => authService.updateUserPassword(password: 'newPassword'),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('should handle network timeout during signIn', () async {
      // Arrange
      when(
        mockAuth.signInWithPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(AuthException('Network timeout'));

      // Act & Assert
      expect(
        () => authService.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should handle various password error messages', () async {
      // Test "password minimum" error
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Password must be minimum 8 characters'));

      expect(
        () => authService.signUp(email: 'test@example.com', password: 'short'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Hasło musi mieć co najmniej 8 znaków'),
          ),
        ),
      );
    });

    test('should handle user already registered variations', () async {
      // Arrange
      when(
        mockAuth.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
          emailRedirectTo: anyNamed('emailRedirectTo'),
        ),
      ).thenThrow(AuthException('Email has already been registered'));

      // Act & Assert
      expect(
        () => authService.signUp(
          email: 'existing@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Użytkownik o tym adresie e-mail już istnieje'),
          ),
        ),
      );
    });
  });
}

// Mock class for UserResponse
class MockUserResponse extends Mock implements UserResponse {}

// Mock class for ResendResponse
class MockResendResponse extends Mock implements ResendResponse {}

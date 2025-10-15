import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

/// AuthenticationScreen - ekran uwierzytelnienia
///
/// Wyświetla formularz logowania/rejestracji z wykorzystaniem pakietu supabase_auth_ui.
/// Obsługuje automatycznie:
/// - Logowanie użytkownika
/// - Rejestrację nowego użytkownika
/// - Walidację danych (email, hasło)
/// - Wyświetlanie błędów
class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo lub tytuł aplikacji
              const Icon(Icons.menu_book_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 24),

              const Text(
                'My Book Library',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                'Zarządzaj swoją biblioteką książek',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Widget SupaEmailAuth z pakietu flutter_auth_ui
              SupaEmailAuth(
                showConfirmPasswordField: true,
                redirectTo: 'io.supabase.mybooklibrary://login-callback/',

                onSignInComplete: (response) {
                  // Logowanie zakończone pomyślnie
                  // AuthGate automatycznie przekieruje do HomeScreen
                },
                onSignUpComplete: (response) {
                  // Rejestracja zakończona pomyślnie
                  // Jeśli sesja jest null, oznacza to, że wymagane jest potwierdzenie emaila.
                  if (response.session == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Rejestracja pomyślna! Sprawdź email, aby potwierdzić konto.',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                onError: (error) {
                  // Obsługa błędów - wyświetl SnackBar
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_getErrorMessage(error)),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                metadataFields: const [],
                localization: const SupaEmailAuthLocalization(
                  enterEmail: 'Wprowadź adres email',
                  enterPassword: 'Wprowadź hasło',
                  confirmPassword: "Wprowadź hasło ponownie",
                  signIn: 'Zaloguj się',
                  signUp: 'Zarejestruj się',
                  forgotPassword: 'Zapomniałeś hasła?',
                  dontHaveAccount: 'Nie masz konta?',
                  haveAccount: 'Masz już konto?',
                  sendPasswordReset: 'Wyślij link resetujący',
                  backToSignIn: 'Powrót do logowania',
                  passwordResetSent: 'Link do resetowania hasła został wysłany',
                  unexpectedError: 'Wystąpił nieoczekiwany błąd',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mapuje błędy z Supabase na przyjazne komunikaty dla użytkownika
  String _getErrorMessage(Object error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case String msg when msg.contains('invalid login credentials'):
          return 'Nieprawidłowe dane logowania';
        case String msg when msg.contains('user already registered'):
          return 'Użytkownik o tym adresie email już istnieje';
        case String msg when msg.contains('password'):
          return 'Hasło nie spełnia wymagań (minimum 6 znaków)';
        case String msg when msg.contains('email'):
          return 'Nieprawidłowy format adresu email';
        default:
          return 'Błąd uwierzytelnienia: ${error.message}';
      }
    }

    if (error.toString().toLowerCase().contains('network')) {
      return 'Brak połączenia z internetem. Sprawdź swoje połączenie.';
    }

    return 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/bloc/bloc.dart';
import '../screens/authentication_screen.dart';
import '../features/onboarding/onboarding.dart';

/// AuthGate - strażnik autoryzacji aplikacji
///
/// Komponent nasłuchuje na zmiany stanu uwierzytelnienia poprzez AuthBloc i wyświetla:
/// - AuthenticationScreen gdy użytkownik nie jest zalogowany
/// - OnboardingWrapper (wrapping HomeScreen) gdy użytkownik jest zalogowany
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Podczas inicjalizacji pokazujemy wskaźnik ładowania
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sprawdzamy czy użytkownik jest zalogowany
        if (state is Authenticated) {
          // Użytkownik jest zalogowany - przekieruj do HomeScreen z onboardingiem
          return const OnboardingWrapper();
        } else {
          // Użytkownik nie jest zalogowany - pokaż ekran uwierzytelnienia
          return const AuthenticationScreen();
        }
      },
    );
  }
}

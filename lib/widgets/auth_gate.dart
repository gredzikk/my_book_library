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
      buildWhen: (previous, current) {
        // Always rebuild to ensure UI stays in sync
        // Log state transitions
        print(
          '🚪 AuthGate - State transition: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      builder: (context, state) {
        // Debug logging
        print('🚪 AuthGate - Building with state: ${state.runtimeType}');

        // Podczas inicjalizacji pokazujemy wskaźnik ładowania
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sprawdzamy czy użytkownik jest zalogowany
        if (state is Authenticated) {
          // Użytkownik jest zalogowany - przekieruj do HomeScreen z onboardingiem
          print('🚪 AuthGate - Navigating to OnboardingWrapper');
          return const OnboardingWrapper();
        } else {
          // Użytkownik nie jest zalogowany - pokaż ekran uwierzytelnienia
          print('🚪 AuthGate - Showing AuthenticationScreen');
          return const AuthenticationScreen();
        }
      },
    );
  }
}

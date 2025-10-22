import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_book_library/features/home/view/home_screen_view.dart';
import '../features/auth/bloc/bloc.dart';
import '../screens/authentication_screen.dart';

/// AuthGate - strażnik autoryzacji aplikacji
///
/// Komponent nasłuchuje na zmiany stanu uwierzytelnienia poprzez AuthBloc i wyświetla:
/// - AuthenticationScreen gdy użytkownik nie jest zalogowany
/// - OnboardingWrapper (wrapping HomeScreen) gdy użytkownik jest zalogowany
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚪 AuthGate - build() method called');
    print('🚪 AuthGate - Checking BlocProvider availability');

    // Test if we can access the AuthBloc
    try {
      final authBloc = context.read<AuthBloc>();
      print('🚪 AuthGate - AuthBloc found: ${authBloc.state.runtimeType}');
    } catch (e) {
      print('🚪 AuthGate - ERROR: Cannot access AuthBloc: $e');
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        print(
          '🚪 AuthGate - listenWhen: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      listener: (context, state) {
        print('🚪 AuthGate - listener called with state: ${state.runtimeType}');
      },
      buildWhen: (previous, current) {
        // Always rebuild to ensure UI stays in sync
        // Log state transitions
        print(
          '🚪 AuthGate - buildWhen called: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      builder: (context, state) {
        // Debug logging
        print('🚪 AuthGate - builder called with state: ${state.runtimeType}');

        // Podczas inicjalizacji pokazujemy wskaźnik ładowania
        if (state is AuthInitial) {
          print('🚪 AuthGate - Showing loading indicator (AuthInitial)');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sprawdzamy czy użytkownik jest zalogowany
        if (state is Authenticated) {
          // Użytkownik jest zalogowany - przekieruj do HomeScreen
          print(
            '🚪 AuthGate - Rendering HomeScreenView for authenticated user',
          );
          return const HomeScreenView();
        } else {
          // Użytkownik nie jest zalogowany - pokaż ekran uwierzytelnienia
          print(
            '🚪 AuthGate - Rendering AuthenticationScreen for ${state.runtimeType}',
          );
          return const AuthenticationScreen();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
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

  static final Logger _logger = Logger('AuthGate');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        _logger.fine(
          'listenWhen: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      listener: (context, state) {
        _logger.fine('listener called with state: ${state.runtimeType}');
      },
      buildWhen: (previous, current) {
        // Always rebuild to ensure UI stays in sync
        // Log state transitions
        _logger.fine(
          'buildWhen called: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      builder: (context, state) {
        // Debug logging
        _logger.fine('builder called with state: ${state.runtimeType}');

        // Podczas inicjalizacji pokazujemy wskaźnik ładowania
        if (state is AuthInitial) {
          _logger.fine('Showing loading indicator (AuthInitial)');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sprawdzamy czy użytkownik jest zalogowany
        if (state is Authenticated) {
          // Użytkownik jest zalogowany - przekieruj do HomeScreen
          _logger.fine('Rendering HomeScreenView for authenticated user');
          return const HomeScreenView();
        } else {
          // Użytkownik nie jest zalogowany - pokaż ekran uwierzytelnienia
          _logger.fine(
            'Rendering AuthenticationScreen for ${state.runtimeType}',
          );
          return const AuthenticationScreen();
        }
      },
    );
  }
}

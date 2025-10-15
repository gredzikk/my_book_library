import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/authentication_screen.dart';
import '../features/home/view/home_screen_view.dart';

/// AuthGate - strażnik autoryzacji aplikacji
///
/// Komponent nasłuchuje na zmiany stanu uwierzytelnienia i wyświetla:
/// - AuthenticationScreen gdy użytkownik nie jest zalogowany
/// - HomeScreen gdy użytkownik jest zalogowany
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Podczas inicjalizacji pokazujemy wskaźnik ładowania
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Sprawdzamy czy użytkownik jest zalogowany
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // Użytkownik jest zalogowany - przekieruj do HomeScreen
          return const HomeScreenView();
        } else {
          // Użytkownik nie jest zalogowany - pokaż ekran uwierzytelnienia
          return const AuthenticationScreen();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// HomeScreen - główny ekran aplikacji (po zalogowaniu)
///
/// Tymczasowy ekran wyświetlany po pomyślnym uwierzytelnieniu.
/// Wyświetla informacje o zalogowanym użytkowniku i przycisk wylogowania.
///
/// TODO: W przyszłości tutaj zostanie zaimplementowana logika sprawdzania,
/// czy użytkownik odbył onboarding i przekierowanie na odpowiedni ekran.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj się',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              // AuthGate automatycznie przekieruje do AuthenticationScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),

              const Text(
                'Zalogowano pomyślnie!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (user?.email != null) ...[
                const Text(
                  'Twój email:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  user!.email!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.construction,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ekran w budowie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tutaj pojawi się główny widok aplikacji z listą książek.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Wyloguj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Przycisk wylogowania użytkownika
///
/// Wyświetla przycisk ElevatedButton z ikoną i tekstem,
/// który wywołuje callback wylogowania.
class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onLogout,
      icon: const Icon(Icons.logout),
      label: const Text('Wyloguj się'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}

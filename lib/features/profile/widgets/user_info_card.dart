import 'package:flutter/material.dart';
import '../models/profile_view_model.dart';

/// Widżet wyświetlający informacje o koncie użytkownika
///
/// Prezentuje adres e-mail użytkownika w formie karty (Card) z ikoną.
class UserInfoCard extends StatelessWidget {
  final ProfileViewModel viewModel;

  const UserInfoCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.person,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Adres e-mail',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          viewModel.userEmail,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

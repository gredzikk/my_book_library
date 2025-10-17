import 'package:flutter/material.dart';
import '../models/profile_view_model.dart';

/// Widżet wyświetlający statystyki dotyczące biblioteki książek
///
/// Prezentuje łączną liczbę książek w bibliotece użytkownika.
/// W trakcie ładowania wyświetla wskaźnik postępu, w przypadku błędu
/// pokazuje komunikat o błędzie.
class BookStatsCard extends StatelessWidget {
  final ProfileViewModel viewModel;

  const BookStatsCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.library_books,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Liczba książek',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: _buildSubtitle(context),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    // Wyświetl wskaźnik ładowania
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Wyświetl komunikat błędu
    if (viewModel.errorMessage != null) {
      return Text(
        viewModel.errorMessage!,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    // Wyświetl liczbę książek
    return Text(
      '${viewModel.bookCount ?? 0} książek',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    );
  }
}

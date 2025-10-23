import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../add_book/add_book.dart';
import '../bloc/bloc.dart';

/// Empty state widget displayed when user has no books
///
/// Shows a message and a button to add the first book.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Brak książek',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Twoja biblioteka jest pusta.\nDodaj swoją pierwszą książkę!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                // Navigate to add book screen and wait for result
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddBookScreen(),
                  ),
                );

                // Refresh the list if a book was added/modified
                if (result == true && context.mounted) {
                  context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Dodaj książkę'),
            ),
          ],
        ),
      ),
    );
  }
}

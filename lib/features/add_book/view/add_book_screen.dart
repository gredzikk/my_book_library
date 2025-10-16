import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/book_service.dart';
import '../../../services/genre_service.dart';
import '../../../services/google_books_api_service.dart';
import '../bloc/bloc.dart';
import '../widgets/isbn_input_field.dart';
import '../widgets/scan_isbn_button.dart';
import 'book_form_screen.dart';

/// Add Book Screen - ekran wyboru metody dodawania książki
///
/// Umożliwia użytkownikowi:
/// - Wyszukanie książki po ISBN (ręczne wpisanie)
/// - Przejście do ręcznego dodawania książki
class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddBookBloc(
        bookService: context.read<BookService>(),
        genreService: context.read<GenreService>(),
        googleBooksService: context.read<GoogleBooksService>(),
      ),
      child: const _AddBookView(),
    );
  }
}

/// Główny widok ekranu AddBook
class _AddBookView extends StatelessWidget {
  const _AddBookView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj książkę')),
      body: BlocConsumer<AddBookBloc, AddBookState>(
        listener: (context, state) async {
          // Obsługa nawigacji do formularza po znalezieniu książki
          if (state is BookFound) {
            // Capture navigator before async gap
            final navigator = Navigator.of(context);
            final result = await navigator.push(
              MaterialPageRoute(
                builder: (context) => BookFormScreen(
                  bookData: state.bookData,
                  genres: state.genres,
                ),
              ),
            );
            // If book was saved, pop back to home screen with result
            if (result == true) {
              navigator.pop(true);
            }
          }

          // Obsługa nawigacji do formularza gdy gatunki są załadowane
          if (state is AddBookReady && state.bookData != null) {
            // Capture navigator before async gap
            final navigator = Navigator.of(context);
            final result = await navigator.push(
              MaterialPageRoute(
                builder: (context) => BookFormScreen(
                  bookData: state.bookData,
                  genres: state.genres,
                ),
              ),
            );
            // If book was saved, pop back to home screen with result
            if (result == true) {
              navigator.pop(true);
            }
          }

          // Wyświetlanie błędów
          if (state is AddBookError) {
            final messenger = ScaffoldMessenger.of(context);
            final theme = Theme.of(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddBookLoading;
          final bottomSafeArea = MediaQuery.of(context).padding.bottom;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: 24.0 + bottomSafeArea,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikona i tytuł sekcji ISBN
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Wyszukaj po ISBN',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wprowadź numer ISBN, aby automatycznie wypełnić dane książki',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Przycisk skanowania
                ScanIsbnButton(
                  enabled: !isLoading,
                  onScanned: (isbn) {
                    context.read<AddBookBloc>().add(FetchBookByIsbn(isbn));
                  },
                ),
                const SizedBox(height: 16),

                // Pole ISBN
                IsbnInputField(
                  enabled: !isLoading,
                  onSearch: (isbn) {
                    context.read<AddBookBloc>().add(FetchBookByIsbn(isbn));
                  },
                ),

                const SizedBox(height: 32),

                // Separator "lub"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'lub',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 32),

                // Sekcja dodawania ręcznego
                Icon(
                  Icons.edit,
                  size: 80,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Dodaj ręcznie',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wypełnij formularz z danymi książki samodzielnie',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Przycisk dodawania ręcznego
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BookFormScreen(),
                            ),
                          );
                          // If book was saved, pop back to home screen with result
                          if (result == true && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj książkę ręcznie'),
                ),

                // Wskaźnik ładowania
                if (isLoading) ...[
                  const SizedBox(height: 32),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

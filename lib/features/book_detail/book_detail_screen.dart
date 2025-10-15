import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/book_service.dart';
import '../../services/reading_session_service.dart';
import 'bloc/bloc.dart';
import 'widgets/book_info_header.dart';
import 'widgets/book_progress_indicator.dart';
import 'widgets/book_action_buttons.dart';
import 'widgets/reading_session_history.dart';

/// Screen for displaying book details
///
/// Shows complete information about a book including:
/// - Cover image and basic information
/// - Reading progress
/// - Action buttons (start session, mark as read)
/// - Reading session history
///
/// Uses BLoC pattern for state management
class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final supabase = Supabase.instance.client;
        return BookDetailsBloc(
          bookService: BookService(supabase),
          readingSessionService: ReadingSessionService(supabase),
        )..add(FetchBookDetails(bookId));
      },
      child: const _BookDetailView(),
    );
  }
}

/// Internal view widget that has access to the BLoC
class _BookDetailView extends StatelessWidget {
  const _BookDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły książki'),
        actions: [
          BlocBuilder<BookDetailsBloc, BookDetailsState>(
            builder: (context, state) {
              // Disable actions when loading or during other actions
              final isEnabled =
                  state is BookDetailsSuccess ||
                  state is BookDetailsActionFailure;

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edytuj',
                    onPressed: isEnabled
                        ? () {
                            // TODO: Navigate to edit screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edycja - wkrótce dostępna'),
                              ),
                            );
                          }
                        : null,
                  ),
                  PopupMenuButton<String>(
                    enabled: isEnabled,
                    onSelected: (value) {
                      if (value == 'mark_read') {
                        context.read<BookDetailsBloc>().add(
                          const MarkAsReadRequested(),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 8),
                            Text('Oznacz jako przeczytaną'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Usuń książkę',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
        listener: (context, state) {
          // Handle action success states
          if (state is BookDetailsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back if needed (e.g., after deletion)
            if (state.shouldNavigateBack) {
              Navigator.of(context).pop();
            }
          }

          // Handle action failure states
          if (state is BookDetailsActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // Loading state
          if (state is BookDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (state is BookDetailsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final bloc = context.read<BookDetailsBloc>();
                        final bookId = bloc.currentBookId;
                        if (bookId != null) {
                          bloc.add(FetchBookDetails(bookId));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success state (or action in progress/action failure which keep the data)
          final book = state is BookDetailsSuccess
              ? state.book
              : state is BookDetailsActionInProgress
              ? state.book
              : state is BookDetailsActionFailure
              ? state.book
              : null;

          final sessions = state is BookDetailsSuccess
              ? state.sessions
              : state is BookDetailsActionInProgress
              ? state.sessions
              : state is BookDetailsActionFailure
              ? state.sessions
              : null;

          if (book == null || sessions == null) {
            return const Center(child: Text('Brak danych'));
          }

          // Show loading overlay if action is in progress
          final showLoading = state is BookDetailsActionInProgress;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<BookDetailsBloc>();
                  final bookId = bloc.currentBookId;
                  if (bookId != null) {
                    bloc.add(FetchBookDetails(bookId));
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Book header with cover and basic info
                        BookInfoHeader(book: book),
                        const SizedBox(height: 24),

                        // Progress indicator
                        BookProgressIndicator(book: book),
                        const SizedBox(height: 24),

                        // Action buttons
                        BookActionButtons(
                          book: book,
                          onStartSession: () {
                            // TODO: Navigate to reading session screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rozpoczęcie sesji - wkrótce dostępne',
                                ),
                              ),
                            );
                          },
                          onMarkAsRead: () {
                            context.read<BookDetailsBloc>().add(
                              const MarkAsReadRequested(),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Reading session history
                        ReadingSessionHistory(sessions: sessions),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ),

              // Loading overlay
              if (showLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Proszę czekać...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usuń książkę'),
        content: const Text(
          'Czy na pewno chcesz usunąć tę książkę? '
          'Ta operacja jest nieodwracalna i usunie również '
          'wszystkie sesje czytania.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BookDetailsBloc>().add(const DeleteBookConfirmed());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }
}

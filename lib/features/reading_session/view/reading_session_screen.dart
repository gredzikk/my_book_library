import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/types.dart';
import '../../../services/reading_session_service.dart';
import '../bloc/reading_session_bloc.dart';
import '../widgets/book_info_header.dart';
import '../widgets/stopwatch_display.dart';
import '../widgets/end_session_button.dart';

/// Screen for managing an active reading session
///
/// This screen displays:
/// - Book information (cover, title, author)
/// - A running stopwatch
/// - A button to end the session
///
/// When the user ends the session, a dialog appears to collect
/// the last page read, which is then saved to the backend.
class ReadingSessionScreen extends StatelessWidget {
  final BookListItemDto book;

  const ReadingSessionScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingSessionBloc(
        readingSessionService: context.read<ReadingSessionService>(),
      )..add(SessionStarted(book)),
      child: _ReadingSessionView(),
    );
  }
}

class _ReadingSessionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ReadingSessionBloc, ReadingSessionState>(
      listener: (context, state) {
        // Show dialog when state is showDialog
        if (state.status == ReadingSessionStatus.showDialog) {
          _showEndSessionDialog(context, state.book!);
        }

        // Navigate back on success
        if (state.status == ReadingSessionStatus.success) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }

        // Show error message
        if (state.status == ReadingSessionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Wystąpił błąd'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          // Return to in-progress after showing error
          context.read<ReadingSessionBloc>().add(DialogDismissed());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sesja czytania')),
        body: BlocBuilder<ReadingSessionBloc, ReadingSessionState>(
          builder: (context, state) {
            if (state.status == ReadingSessionStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Book information
                    BookInfoHeader(book: state.book!),

                    // Stopwatch
                    if (state.startTime != null)
                      StopwatchDisplay(startTime: state.startTime!),

                    // End session button
                    EndSessionButton(
                      onPressed: () {
                        context.read<ReadingSessionBloc>().add(
                          EndSessionButtonTapped(),
                        );
                      },
                      isLoading:
                          state.status == ReadingSessionStatus.submitting,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shows the end session dialog to collect user input
  void _showEndSessionDialog(BuildContext context, BookListItemDto book) {
    showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _EndSessionDialog(
        book: book,
        onSave: (lastPage) {
          // Close dialog and send event to BLoC
          Navigator.of(dialogContext).pop();
          context.read<ReadingSessionBloc>().add(SessionFinished(lastPage));
        },
        onCancel: () {
          // Close dialog and return to in-progress
          Navigator.of(dialogContext).pop();
          context.read<ReadingSessionBloc>().add(DialogDismissed());
        },
      ),
    );
  }
}

/// Dialog for entering the last page read
class _EndSessionDialog extends StatefulWidget {
  final BookListItemDto book;
  final void Function(int lastPage) onSave;
  final VoidCallback onCancel;

  const _EndSessionDialog({
    required this.book,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends State<_EndSessionDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = 'Wprowadź numer strony';
        _isValid = false;
        return;
      }

      final pageNumber = int.tryParse(value);
      if (pageNumber == null) {
        _errorText = 'Wprowadź poprawną liczbę';
        _isValid = false;
        return;
      }

      if (pageNumber <= widget.book.lastReadPageNumber) {
        _errorText =
            'Numer strony musi być większy niż ${widget.book.lastReadPageNumber}';
        _isValid = false;
        return;
      }

      if (pageNumber < 1) {
        _errorText = 'Numer strony musi być większy niż 0';
        _isValid = false;
        return;
      }

      if (pageNumber > widget.book.pageCount) {
        _errorText =
            'Numer strony nie może być większy niż ${widget.book.pageCount}';
        _isValid = false;
        return;
      }

      _errorText = null;
      _isValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zakończ sesję'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Na której stronie skończyłeś czytanie?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Ostatnio przeczytana: ${widget.book.lastReadPageNumber} / ${widget.book.pageCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Numer strony',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            onChanged: _validateInput,
            onSubmitted: (_) {
              if (_isValid) {
                widget.onSave(int.parse(_controller.text));
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Anuluj')),
        FilledButton(
          onPressed: _isValid
              ? () => widget.onSave(int.parse(_controller.text))
              : null,
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}

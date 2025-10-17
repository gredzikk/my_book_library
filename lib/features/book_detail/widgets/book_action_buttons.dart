import 'package:flutter/material.dart';
import '../../../models/types.dart';
import '../../../models/database_types.dart';

/// Widget displaying action buttons based on book status
///
/// Shows different actions depending on the reading status:
/// - unread/planned: "Rozpocznij czytanie"
/// - in_progress: "Kontynuuj czytanie"
/// - finished: "Przeczytaj ponownie"
/// - abandoned: "Wznów czytanie"
class BookActionButtons extends StatelessWidget {
  final BookDetailDto book;
  final VoidCallback onStartSession;
  final VoidCallback onMarkAsRead;

  const BookActionButtons({
    super.key,
    required this.book,
    required this.onStartSession,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Akcje',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Primary action button (depends on status)
            _buildPrimaryActionButton(context),

            // Secondary actions
            const SizedBox(height: 12),

            // Show "Mark as read" button if not already finished
            if (book.status != BookStatus.finished)
              OutlinedButton.icon(
                onPressed: onMarkAsRead,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Oznacz jako przeczytaną'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the primary action button based on book status
  Widget _buildPrimaryActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    IconData icon;

    switch (book.status) {
      case BookStatus.unread:
      case BookStatus.planned:
        label = 'Rozpocznij czytanie';
        icon = Icons.play_arrow;
        break;
      case BookStatus.in_progress:
        label = 'Kontynuuj czytanie';
        icon = Icons.auto_stories;
        break;
      case BookStatus.finished:
        label = 'Czytaj ponownie';
        icon = Icons.refresh;
        break;
      case BookStatus.abandoned:
        label = 'Wznów czytanie';
        icon = Icons.replay;
        break;
    }

    return FilledButton.icon(
      onPressed: onStartSession,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

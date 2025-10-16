import 'package:flutter/material.dart';
import '../../../models/types.dart';
import '../../../models/database_types.dart';

/// Widget displaying reading progress for a book
///
/// Shows:
/// - Visual progress bar
/// - Percentage completion
/// - Pages read / total pages
/// - Status badge
class BookProgressIndicator extends StatelessWidget {
  final BookDetailDto book;

  const BookProgressIndicator({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = _calculateProgress();
    final progressPercentage = (progress * 100).toStringAsFixed(1);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Postęp czytania',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(colorScheme),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pages read
                Text(
                  '${book.lastReadPageNumber} / ${book.pageCount} stron',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Percentage
                Text(
                  '$progressPercentage%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(colorScheme),
                  ),
                ),
              ],
            ),

            // Additional info for in-progress books
            if (book.status == BookStatus.in_progress &&
                book.lastReadPageNumber > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getRemainingPagesText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Calculates reading progress as a value between 0 and 1
  double _calculateProgress() {
    if (book.pageCount == 0) return 0.0;
    final progress = book.lastReadPageNumber / book.pageCount;
    return progress.clamp(0.0, 1.0);
  }

  /// Gets the appropriate color based on book status
  Color _getProgressColor(ColorScheme colorScheme) {
    switch (book.status) {
      case BookStatus.finished:
        return Colors.green;
      case BookStatus.in_progress:
        return colorScheme.primary;
      case BookStatus.unread:
      case BookStatus.planned:
      case BookStatus.abandoned:
        return colorScheme.outline;
    }
  }

  /// Builds status badge chip
  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (book.status) {
      case BookStatus.unread:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        icon = Icons.schedule;
        label = 'Nieprzeczytana';
        break;
      case BookStatus.planned:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        icon = Icons.bookmark_outline;
        label = 'Planowana';
        break;
      case BookStatus.in_progress:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.auto_stories;
        label = 'W trakcie';
        break;
      case BookStatus.finished:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        label = 'Przeczytana';
        break;
      case BookStatus.abandoned:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.cancel_outlined;
        label = 'Porzucona';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets text describing remaining pages
  String _getRemainingPagesText() {
    final remainingPages = book.pageCount - book.lastReadPageNumber;
    if (remainingPages <= 0) return 'Ukończono!';

    return 'Pozostało $remainingPages ${_getPageWord(remainingPages)}';
  }

  /// Returns correct Polish word form for "pages"
  String _getPageWord(int count) {
    if (count == 1) return 'strona';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'strony';
    }
    return 'stron';
  }
}

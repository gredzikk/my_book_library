import 'package:flutter/material.dart';
import '../../../models/types.dart';

/// Widget displaying book information in the reading session
///
/// Shows the book cover, title, and author in a clean layout
class BookInfoHeader extends StatelessWidget {
  final BookListItemDto book;

  const BookInfoHeader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Book cover
        if (book.coverUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.coverUrl!,
              height: 180,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          )
        else
          _buildPlaceholder(),

        const SizedBox(height: 24),

        // Book title
        Text(
          book.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Book author
        Text(
          book.author,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds a placeholder widget when cover is not available
  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.book, size: 48, color: Colors.grey),
    );
  }
}

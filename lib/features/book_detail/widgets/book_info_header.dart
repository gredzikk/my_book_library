import 'package:flutter/material.dart';
import '../../../models/types.dart';

/// Widget displaying book's basic information and cover
///
/// Shows:
/// - Cover image (with fallback icon)
/// - Title
/// - Author
/// - Genre (if available)
/// - ISBN, Publisher, Publication Year
class BookInfoHeader extends StatelessWidget {
  final BookDetailDto book;

  const BookInfoHeader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            _buildCover(context),
            const SizedBox(width: 16),

            // Book information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.author,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Genre
                  if (book.genres?.name != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.genres!.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Additional info divider
                  const Divider(),
                  const SizedBox(height: 8),

                  // ISBN
                  if (book.isbn != null)
                    _buildInfoRow(context, 'ISBN', book.isbn!),

                  // Publisher
                  if (book.publisher != null)
                    _buildInfoRow(context, 'Wydawnictwo', book.publisher!),

                  // Publication Year
                  if (book.publicationYear != null)
                    _buildInfoRow(
                      context,
                      'Rok wydania',
                      book.publicationYear.toString(),
                    ),

                  // Page count
                  _buildInfoRow(
                    context,
                    'Liczba stron',
                    book.pageCount.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the cover image or fallback icon
  Widget _buildCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            book.coverUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackCover(colorScheme);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildFallbackCover(colorScheme);
  }

  /// Builds fallback cover when no image is available
  Widget _buildFallbackCover(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.menu_book,
        size: 64,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Builds a row with label and value
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

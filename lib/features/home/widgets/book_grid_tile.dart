import 'package:flutter/material.dart';
import '../../../models/types.dart';
import '../../../models/database_types.dart';

/// Individual book tile in the grid
///
/// Displays book cover, title, author, and status icon.
class BookGridTile extends StatelessWidget {
  final BookListItemDto book;
  final VoidCallback onTap;

  const BookGridTile({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverImage(),
                  // Status icon overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildStatusIcon(context),
                  ),
                ],
              ),
            ),
            // Book info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Image.network(
        book.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.book, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (book.status) {
      case BookStatus.in_progress:
        icon = Icons.play_circle_filled;
        color = Colors.blue;
        break;
      case BookStatus.finished:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case BookStatus.planned:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case BookStatus.abandoned:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case BookStatus.unread:
        icon = Icons.circle_outlined;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

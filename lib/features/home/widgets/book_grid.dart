import 'package:flutter/material.dart';
import '../../../models/types.dart';
import '../../book_detail/book_detail_screen.dart';
import 'book_grid_tile.dart';

/// Grid widget displaying list of books
///
/// Creates a responsive grid layout with book tiles.
class BookGrid extends StatelessWidget {
  final List<BookListItemDto> books;

  const BookGrid({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridTile(
          book: book,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(bookId: book.id),
              ),
            );
          },
        );
      },
    );
  }
}

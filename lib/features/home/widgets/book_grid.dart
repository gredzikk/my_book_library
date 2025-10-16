import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/types.dart';
import '../../book_detail/book_detail_screen.dart';
import '../bloc/bloc.dart';
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
          onTap: () async {
            // Navigate to book details and wait for result
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(bookId: book.id),
              ),
            );

            // Refresh the list if book was modified or deleted
            if (result == true && context.mounted) {
              context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
            }
          },
        );
      },
    );
  }
}

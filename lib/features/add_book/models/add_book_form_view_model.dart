import 'package:equatable/equatable.dart';
import '../../../models/types.dart';

/// Model widoku reprezentujący dane formularza dodawania/edycji książki
///
/// Jest pośrednikiem między DTO a widokiem, ułatwiając zarządzanie stanem
/// formularza i konwersję danych.
class AddBookFormViewModel extends Equatable {
  final String title;
  final String author;
  final int pageCount;
  final String? genreId;
  final String? coverUrl;
  final String? isbn;
  final String? publisher;
  final int? publicationYear;

  const AddBookFormViewModel({
    required this.title,
    required this.author,
    required this.pageCount,
    this.genreId,
    this.coverUrl,
    this.isbn,
    this.publisher,
    this.publicationYear,
  });

  /// Tworzy pusty model dla nowej książki
  factory AddBookFormViewModel.empty() {
    return const AddBookFormViewModel(title: '', author: '', pageCount: 0);
  }

  /// Konwertuje z GoogleBookResult do AddBookFormViewModel
  factory AddBookFormViewModel.fromGoogleBook(
    GoogleBookResult result, {
    String? genreId,
  }) {
    return AddBookFormViewModel(
      title: result.title,
      author: result.authors?.join(', ') ?? 'Unknown Author',
      pageCount: result.pageCount ?? 0,
      publisher: result.publisher,
      publicationYear: _extractYear(result.publishedDate),
      coverUrl:
          result.imageLinks?.thumbnail ?? result.imageLinks?.smallThumbnail,
      isbn: _extractISBN(result.industryIdentifiers),
      genreId: genreId,
    );
  }

  /// Konwertuje z BookListItemDto do AddBookFormViewModel (dla edycji)
  factory AddBookFormViewModel.fromBook(BookListItemDto book) {
    return AddBookFormViewModel(
      title: book.title,
      author: book.author,
      pageCount: book.pageCount,
      genreId: book.genreId,
      coverUrl: book.coverUrl,
      isbn: book.isbn,
      publisher: book.publisher,
      publicationYear: book.publicationYear,
    );
  }

  /// Konwertuje do CreateBookDto (dla nowej książki)
  CreateBookDto toCreateBookDto() {
    return CreateBookDto(
      title: title,
      author: author,
      pageCount: pageCount,
      genreId: genreId,
      coverUrl: coverUrl,
      isbn: isbn,
      publisher: publisher,
      publicationYear: publicationYear,
    );
  }

  /// Konwertuje do UpdateBookDto (dla edycji książki)
  UpdateBookDto toUpdateBookDto() {
    return UpdateBookDto(
      title: title,
      author: author,
      pageCount: pageCount,
      genreId: genreId,
      coverUrl: coverUrl,
      isbn: isbn,
      publisher: publisher,
      publicationYear: publicationYear,
    );
  }

  /// Tworzy kopię z wybranymi polami zmienionymi
  AddBookFormViewModel copyWith({
    String? title,
    String? author,
    int? pageCount,
    String? genreId,
    String? coverUrl,
    String? isbn,
    String? publisher,
    int? publicationYear,
  }) {
    return AddBookFormViewModel(
      title: title ?? this.title,
      author: author ?? this.author,
      pageCount: pageCount ?? this.pageCount,
      genreId: genreId ?? this.genreId,
      coverUrl: coverUrl ?? this.coverUrl,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
    );
  }

  /// Waliduje, czy formularz ma wymagane pola
  bool get isValid {
    return title.isNotEmpty && author.isNotEmpty && pageCount > 0;
  }

  @override
  List<Object?> get props => [
    title,
    author,
    pageCount,
    genreId,
    coverUrl,
    isbn,
    publisher,
    publicationYear,
  ];

  /// Ekstrahuje rok z daty publikacji
  static int? _extractYear(String? date) {
    if (date == null) return null;
    final match = RegExp(r'\d{4}').firstMatch(date);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  /// Ekstrahuje ISBN z listy identyfikatorów
  static String? _extractISBN(List<IndustryIdentifier>? identifiers) {
    if (identifiers == null) return null;
    // Preferuj ISBN_13, potem ISBN_10
    try {
      final isbn13 = identifiers.firstWhere((id) => id.type == 'ISBN_13');
      return isbn13.identifier;
    } catch (_) {
      // ISBN_13 not found, try ISBN_10
      try {
        final isbn10 = identifiers.firstWhere((id) => id.type == 'ISBN_10');
        return isbn10.identifier;
      } catch (_) {
        return null;
      }
    }
  }
}

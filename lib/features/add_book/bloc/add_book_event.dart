import 'package:equatable/equatable.dart';
import 'package:my_book_library/features/add_book/models/add_book_form_view_model.dart';

/// Bazowa klasa dla wszystkich zdarzeń AddBook
abstract class AddBookEvent extends Equatable {
  const AddBookEvent();

  @override
  List<Object?> get props => [];
}

/// Zdarzenie wyszukiwania książki po ISBN
///
/// Inicjowane po wpisaniu/zeskanowaniu ISBN i naciśnięciu przycisku szukania.
/// Wywołuje zapytanie do Google Books API.
class FetchBookByIsbn extends AddBookEvent {
  final String isbn;

  const FetchBookByIsbn(this.isbn);

  @override
  List<Object?> get props => [isbn];
}

/// Zdarzenie zapisania książki
///
/// Może być wywołane dla nowej książki (bookId == null) lub edycji (bookId != null).
class SaveBook extends AddBookEvent {
  final AddBookFormViewModel data;
  final String? bookId;

  const SaveBook({required this.data, this.bookId});

  @override
  List<Object?> get props => [data, bookId];
}

/// Zdarzenie pobierania listy gatunków
///
/// Inicjowane przy wejściu na ekran formularza, aby wypełnić dropdown z gatunkami.
class FetchGenres extends AddBookEvent {
  const FetchGenres();
}

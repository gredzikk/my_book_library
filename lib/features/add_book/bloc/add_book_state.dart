import 'package:equatable/equatable.dart';
import 'package:my_book_library/features/add_book/models/add_book_form_view_model.dart';
import '../../../models/types.dart';

/// Bazowa klasa dla wszystkich stanów AddBook
abstract class AddBookState extends Equatable {
  const AddBookState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class AddBookInitial extends AddBookState {
  const AddBookInitial();
}

/// Stan ładowania (wyszukiwanie książki, zapisywanie, pobieranie gatunków)
class AddBookLoading extends AddBookState {
  final String? message;

  const AddBookLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Stan po pomyślnym załadowaniu gatunków
class GenresLoaded extends AddBookState {
  final List<GenreDto> genres;

  const GenresLoaded(this.genres);

  @override
  List<Object?> get props => [genres];
}

/// Stan po pomyślnym znalezieniu książki w Google Books API
///
/// Powoduje nawigację do BookFormScreen z wypełnionymi danymi
class BookFound extends AddBookState {
  final AddBookFormViewModel bookData;
  final List<GenreDto>? genres;

  const BookFound({required this.bookData, this.genres});

  @override
  List<Object?> get props => [bookData, genres];
}

/// Stan po pomyślnym zapisaniu książki
///
/// Powoduje nawigację powrotną do ekranu głównego
class BookSaved extends AddBookState {
  final String message;

  const BookSaved({this.message = 'Książka została zapisana'});

  @override
  List<Object?> get props => [message];
}

/// Stan błędu
class AddBookError extends AddBookState {
  final String message;

  const AddBookError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Stan gotowy do wyświetlenia formularza
///
/// Zawiera listę gatunków i opcjonalne dane książki (dla edycji lub po znalezieniu przez ISBN)
class AddBookReady extends AddBookState {
  final List<GenreDto> genres;
  final AddBookFormViewModel? bookData;

  const AddBookReady({required this.genres, this.bookData});

  @override
  List<Object?> get props => [genres, bookData];
}

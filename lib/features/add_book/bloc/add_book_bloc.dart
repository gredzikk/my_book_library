import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:my_book_library/features/add_book/models/add_book_form_view_model.dart';
import '../../../services/book_service.dart';
import '../../../services/genre_service.dart';
import '../../../services/google_books_api_service.dart';
import '../../../core/exceptions.dart';
import '../../../models/types.dart';
import 'add_book_event.dart';
import 'add_book_state.dart';

/// BLoC zarządzający stanem widoku dodawania/edycji książki
///
/// Obsługuje:
/// - Wyszukiwanie książki po ISBN w Google Books API
/// - Pobieranie listy gatunków
/// - Zapisywanie nowej książki
/// - Aktualizowanie istniejącej książki
class AddBookBloc extends Bloc<AddBookEvent, AddBookState> {
  final BookService _bookService;
  final GenreService _genreService;
  final GoogleBooksService _googleBooksService;
  final Logger _logger = Logger('AddBookBloc');

  /// Cached lista gatunków
  List<GenreDto>? _cachedGenres;

  AddBookBloc({
    required BookService bookService,
    required GenreService genreService,
    required GoogleBooksService googleBooksService,
  }) : _bookService = bookService,
       _genreService = genreService,
       _googleBooksService = googleBooksService,
       super(const AddBookInitial()) {
    on<FetchBookByIsbn>(_onFetchBookByIsbn);
    on<SaveBook>(_onSaveBook);
    on<FetchGenres>(_onFetchGenres);
  }

  /// Obsługuje wyszukiwanie książki po ISBN
  Future<void> _onFetchBookByIsbn(
    FetchBookByIsbn event,
    Emitter<AddBookState> emit,
  ) async {
    try {
      emit(const AddBookLoading(message: 'Wyszukiwanie książki...'));
      _logger.info('Fetching book by ISBN: ${event.isbn}');

      // Wyszukaj książkę w Google Books API
      final result = await _googleBooksService.fetchBookByISBN(event.isbn);

      if (result == null) {
        emit(
          const AddBookError(
            'Nie znaleziono książki dla podanego numeru ISBN. '
            'Możesz dodać książkę ręcznie.',
          ),
        );
        return;
      }

      // Konwertuj wynik do ViewModel
      final bookData = AddBookFormViewModel.fromGoogleBook(result);

      // Jeśli mamy już gatunki w cache, użyj ich
      if (_cachedGenres != null) {
        emit(AddBookReady(genres: _cachedGenres!, bookData: bookData));
      } else {
        emit(BookFound(bookData: bookData));
      }

      _logger.info('Book found: ${bookData.title}');
    } on NoInternetException {
      emit(
        const AddBookError(
          'Brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie.',
        ),
      );
    } on TimeoutException {
      emit(
        const AddBookError(
          'Przekroczono limit czasu połączenia. Spróbuj ponownie.',
        ),
      );
    } catch (e) {
      _logger.severe('Error fetching book by ISBN: $e');
      emit(
        AddBookError(
          'Wystąpił błąd podczas wyszukiwania książki: ${e.toString()}',
        ),
      );
    }
  }

  /// Obsługuje zapisywanie książki (nowa lub aktualizacja)
  Future<void> _onSaveBook(SaveBook event, Emitter<AddBookState> emit) async {
    try {
      emit(const AddBookLoading(message: 'Zapisywanie książki...'));

      if (event.bookId == null) {
        // Tworzenie nowej książki
        _logger.info('Creating new book: ${event.data.title}');
        final dto = event.data.toCreateBookDto();
        await _bookService.createBook(dto);
        _logger.info('Book created successfully');
      } else {
        // Aktualizacja istniejącej książki
        _logger.info('Updating book: ${event.bookId}');
        final dto = event.data.toUpdateBookDto();
        await _bookService.updateBook(event.bookId!, dto);
        _logger.info('Book updated successfully');
      }

      emit(const BookSaved());
    } on ValidationException catch (e) {
      emit(AddBookError('Błąd walidacji: ${e.message}'));
    } on UnauthorizedException catch (e) {
      emit(AddBookError('Błąd autoryzacji: ${e.message}'));
    } on NoInternetException {
      emit(
        const AddBookError(
          'Brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie.',
        ),
      );
    } on TimeoutException {
      emit(
        const AddBookError(
          'Przekroczono limit czasu połączenia. Spróbuj ponownie.',
        ),
      );
    } on ServerException catch (e) {
      emit(AddBookError('Błąd serwera: ${e.message}'));
    } catch (e) {
      _logger.severe('Error saving book: $e');
      emit(
        AddBookError(
          'Wystąpił błąd podczas zapisywania książki: ${e.toString()}',
        ),
      );
    }
  }

  /// Obsługuje pobieranie listy gatunków
  Future<void> _onFetchGenres(
    FetchGenres event,
    Emitter<AddBookState> emit,
  ) async {
    try {
      // Jeśli gatunki są już w cache, użyj ich
      if (_cachedGenres != null) {
        emit(AddBookReady(genres: _cachedGenres!));
        return;
      }

      emit(const AddBookLoading(message: 'Ładowanie gatunków...'));
      _logger.info('Fetching genres');

      final genres = await _genreService.listGenres();
      _cachedGenres = genres;

      emit(AddBookReady(genres: genres));
      _logger.info('Genres loaded: ${genres.length}');
    } on UnauthorizedException catch (e) {
      emit(AddBookError('Błąd autoryzacji: ${e.message}'));
    } on NoInternetException {
      emit(
        const AddBookError(
          'Brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie.',
        ),
      );
    } on TimeoutException {
      emit(
        const AddBookError(
          'Przekroczono limit czasu połączenia. Spróbuj ponownie.',
        ),
      );
    } on ServerException catch (e) {
      emit(AddBookError('Błąd serwera: ${e.message}'));
    } catch (e) {
      _logger.severe('Error fetching genres: $e');
      emit(
        AddBookError(
          'Wystąpił błąd podczas pobierania gatunków: ${e.toString()}',
        ),
      );
    }
  }
}

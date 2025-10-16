import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../services/book_service.dart';
import '../../../services/reading_session_service.dart';
import '../../../models/types.dart';
import '../../../models/database_types.dart';
import '../../../core/exceptions.dart';
import 'book_details_event.dart';
import 'book_details_state.dart';

/// BLoC for managing book details screen state and business logic
///
/// This BLoC handles:
/// - Fetching book details and reading sessions
/// - Marking book as read
/// - Deleting book
/// - Ending reading sessions
///
/// It coordinates between BookService and ReadingSessionService
/// to provide a unified interface for the UI.
class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final BookService _bookService;
  final ReadingSessionService _readingSessionService;
  final Logger _logger = Logger('BookDetailsBloc');

  /// Current book ID being displayed (exposed for UI)
  String? get currentBookId => _currentBookId;
  String? _currentBookId;

  /// Cached book data for action states
  BookDetailDto? _cachedBook;

  /// Cached sessions data for action states
  List<ReadingSessionDto>? _cachedSessions;

  BookDetailsBloc({
    required BookService bookService,
    required ReadingSessionService readingSessionService,
  }) : _bookService = bookService,
       _readingSessionService = readingSessionService,
       super(const BookDetailsInitial()) {
    on<FetchBookDetails>(_onFetchBookDetails);
    on<MarkAsReadRequested>(_onMarkAsReadRequested);
    on<DeleteBookRequested>(_onDeleteBookRequested);
    on<DeleteBookConfirmed>(_onDeleteBookConfirmed);
    on<EndSessionConfirmed>(_onEndSessionConfirmed);
  }

  /// Handles fetching book details and reading sessions
  Future<void> _onFetchBookDetails(
    FetchBookDetails event,
    Emitter<BookDetailsState> emit,
  ) async {
    _logger.info('Fetching book details for: ${event.bookId}');
    _currentBookId = event.bookId;

    emit(const BookDetailsLoading());

    try {
      // Fetch book details and sessions in parallel
      final results = await Future.wait([
        _bookService.getBook(event.bookId),
        _readingSessionService.listReadingSessions(event.bookId),
      ]);

      final book = results[0] as BookDetailDto;
      final sessions = results[1] as List<ReadingSessionDto>;

      // Cache the data
      _cachedBook = book;
      _cachedSessions = sessions;

      _logger.info(
        'Successfully loaded book "${book.title}" with ${sessions.length} sessions',
      );

      emit(BookDetailsSuccess(book: book, sessions: sessions));
    } on NotFoundException catch (e) {
      _logger.warning('Book not found: ${e.message}');
      emit(BookDetailsFailure('Książka nie została znaleziona'));
    } on UnauthorizedException catch (e) {
      _logger.warning('Unauthorized: ${e.message}');
      emit(BookDetailsFailure('Sesja wygasła. Zaloguj się ponownie'));
    } on NoInternetException catch (_) {
      _logger.warning('No internet connection');
      emit(BookDetailsFailure('Brak połączenia z internetem'));
    } on TimeoutException catch (_) {
      _logger.warning('Request timeout');
      emit(BookDetailsFailure('Przekroczono limit czasu. Spróbuj ponownie'));
    } catch (e) {
      _logger.severe('Unexpected error fetching book details: $e');
      emit(BookDetailsFailure('Wystąpił nieoczekiwany błąd'));
    }
  }

  /// Handles marking book as read
  Future<void> _onMarkAsReadRequested(
    MarkAsReadRequested event,
    Emitter<BookDetailsState> emit,
  ) async {
    if (_cachedBook == null || _cachedSessions == null) {
      _logger.warning('No cached book data for mark as read');
      return;
    }

    _logger.info('Marking book as read: ${_cachedBook!.id}');

    emit(
      BookDetailsActionInProgress(
        book: _cachedBook!,
        sessions: _cachedSessions!,
        message: 'Oznaczanie jako przeczytana...',
      ),
    );

    try {
      // Update book status to finished and set last read page to page count
      final dto = UpdateBookDto(
        status: BookStatus.finished,
        lastReadPageNumber: _cachedBook!.pageCount,
      );

      await _bookService.updateBook(_cachedBook!.id, dto);

      _logger.info('Successfully marked book as read');

      // Refresh the book details
      if (_currentBookId != null) {
        add(FetchBookDetails(_currentBookId!));
      }

      emit(
        const BookDetailsActionSuccess(
          message: 'Książka została oznaczona jako przeczytana',
        ),
      );
    } on ValidationException catch (e) {
      _logger.warning('Validation error: ${e.message}');
      emit(
        BookDetailsActionFailure(
          error: 'Błąd walidacji: ${e.message}',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on UnauthorizedException catch (_) {
      _logger.warning('Unauthorized');
      emit(
        BookDetailsActionFailure(
          error: 'Sesja wygasła. Zaloguj się ponownie',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on NoInternetException catch (_) {
      _logger.warning('No internet connection');
      emit(
        BookDetailsActionFailure(
          error: 'Brak połączenia z internetem',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } catch (e) {
      _logger.severe('Unexpected error marking as read: $e');
      emit(
        BookDetailsActionFailure(
          error: 'Wystąpił nieoczekiwany błąd',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    }
  }

  /// Handles delete book request (shows confirmation)
  Future<void> _onDeleteBookRequested(
    DeleteBookRequested event,
    Emitter<BookDetailsState> emit,
  ) async {
    // This event is just a signal to show confirmation dialog
    // The actual deletion happens in DeleteBookConfirmed
    _logger.info('Delete book requested');
  }

  /// Handles confirmed book deletion
  Future<void> _onDeleteBookConfirmed(
    DeleteBookConfirmed event,
    Emitter<BookDetailsState> emit,
  ) async {
    if (_cachedBook == null || _cachedSessions == null) {
      _logger.warning('No cached book data for deletion');
      return;
    }

    _logger.info('Deleting book: ${_cachedBook!.id}');

    emit(
      BookDetailsActionInProgress(
        book: _cachedBook!,
        sessions: _cachedSessions!,
        message: 'Usuwanie książki...',
      ),
    );

    try {
      await _bookService.deleteBook(_cachedBook!.id);

      _logger.info('Successfully deleted book');

      emit(
        const BookDetailsActionSuccess(
          message: 'Książka została usunięta',
          shouldNavigateBack: true,
        ),
      );
    } on NotFoundException catch (_) {
      _logger.warning('Book not found for deletion');
      emit(
        BookDetailsActionFailure(
          error: 'Książka nie została znaleziona',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on UnauthorizedException catch (_) {
      _logger.warning('Unauthorized');
      emit(
        BookDetailsActionFailure(
          error: 'Sesja wygasła. Zaloguj się ponownie',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on NoInternetException catch (_) {
      _logger.warning('No internet connection');
      emit(
        BookDetailsActionFailure(
          error: 'Brak połączenia z internetem',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } catch (e) {
      _logger.severe('Unexpected error deleting book: $e');
      emit(
        BookDetailsActionFailure(
          error: 'Wystąpił nieoczekiwany błąd',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    }
  }

  /// Handles ending a reading session
  Future<void> _onEndSessionConfirmed(
    EndSessionConfirmed event,
    Emitter<BookDetailsState> emit,
  ) async {
    if (_cachedBook == null || _cachedSessions == null) {
      _logger.warning('No cached book data for ending session');
      return;
    }

    _logger.info('Ending reading session for book: ${event.dto.bookId}');

    emit(
      BookDetailsActionInProgress(
        book: _cachedBook!,
        sessions: _cachedSessions!,
        message: 'Zapisywanie sesji...',
      ),
    );

    try {
      await _readingSessionService.endReadingSession(event.dto);

      _logger.info('Successfully ended reading session');

      // Refresh the book details to get updated progress and new session
      if (_currentBookId != null) {
        add(FetchBookDetails(_currentBookId!));
      }

      emit(
        const BookDetailsActionSuccess(
          message: 'Sesja czytania została zapisana',
        ),
      );
    } on ValidationException catch (e) {
      _logger.warning('Validation error: ${e.message}');
      emit(
        BookDetailsActionFailure(
          error: 'Błąd walidacji: ${e.message}',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on UnauthorizedException catch (_) {
      _logger.warning('Unauthorized');
      emit(
        BookDetailsActionFailure(
          error: 'Sesja wygasła. Zaloguj się ponownie',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } on NoInternetException catch (_) {
      _logger.warning('No internet connection');
      emit(
        BookDetailsActionFailure(
          error: 'Brak połączenia z internetem',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    } catch (e) {
      _logger.severe('Unexpected error ending session: $e');
      emit(
        BookDetailsActionFailure(
          error: 'Wystąpił nieoczekiwany błąd',
          book: _cachedBook!,
          sessions: _cachedSessions!,
        ),
      );
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../services/book_service.dart';
import '../../../core/exceptions.dart';
import '../models/filter_sort_options.dart';
import 'home_screen_event.dart';
import 'home_screen_state.dart';

/// BLoC for managing the Home Screen state
///
/// Handles loading books from the API, applying filters and sorting,
/// and managing different UI states (loading, success, empty, error).
class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final BookService _bookService;
  final Logger _logger = Logger('HomeScreenBloc');

  /// Current filter and sort options
  FilterSortOptions _currentFilters = FilterSortOptions.defaults();

  HomeScreenBloc(this._bookService) : super(const HomeScreenInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<RefreshBooksEvent>(_onRefreshBooks);
  }

  /// Handles loading books with optional filters
  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      // Update current filters if provided
      if (event.filters != null) {
        _currentFilters = event.filters!;
      }

      // Emit loading state
      emit(const HomeScreenLoading());

      _logger.info(
        'Loading books with filters: status=${_currentFilters.status}, '
        'genreId=${_currentFilters.genreId}, '
        'orderBy=${_currentFilters.orderBy}, '
        'orderDirection=${_currentFilters.orderDirection}',
      );

      // Fetch books from the service
      final books = await _bookService.listBooks(
        status: _currentFilters.status,
        genreId: _currentFilters.genreId,
        orderBy: _currentFilters.orderBy,
        orderDirection: _currentFilters.orderDirection,
      );

      _logger.info('Loaded ${books.length} books');

      // Emit appropriate state based on results
      if (books.isEmpty) {
        emit(const HomeScreenEmpty());
      } else {
        emit(HomeScreenSuccess(books));
      }
    } on NoInternetException catch (e) {
      _logger.warning('No internet connection: $e');
      emit(
        const HomeScreenError(
          'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.',
        ),
      );
    } on UnauthorizedException catch (e) {
      _logger.warning('Unauthorized: $e');
      emit(const HomeScreenError('Sesja wygasła. Zaloguj się ponownie.'));
    } on ServerException catch (e) {
      _logger.severe('Server error: $e');
      emit(
        const HomeScreenError(
          'Wystąpił błąd serwera. Spróbuj ponownie później.',
        ),
      );
    } on ValidationException catch (e) {
      _logger.warning('Validation error: $e');
      emit(HomeScreenError('Błąd walidacji: ${e.message}'));
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error loading books', e, stackTrace);
      emit(
        const HomeScreenError('Wystąpił nieoczekiwany błąd. Spróbuj ponownie.'),
      );
    }
  }

  /// Handles refreshing books (pull-to-refresh)
  Future<void> _onRefreshBooks(
    RefreshBooksEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    // Reuse LoadBooksEvent logic with forceRefresh
    await _onLoadBooks(
      LoadBooksEvent(forceRefresh: true, filters: _currentFilters),
      emit,
    );
  }

  /// Gets current filter options
  FilterSortOptions get currentFilters => _currentFilters;
}

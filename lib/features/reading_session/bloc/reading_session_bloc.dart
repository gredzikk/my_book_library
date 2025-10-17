import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../models/types.dart';
import '../../../services/reading_session_service.dart';
import '../../../core/exceptions.dart';

part 'reading_session_event.dart';
part 'reading_session_state.dart';

/// BLoC for managing reading session state and logic
///
/// This BLoC handles:
/// - Starting a reading session
/// - Showing/hiding the end session dialog
/// - Submitting session data to the API
/// - Error handling
class ReadingSessionBloc
    extends Bloc<ReadingSessionEvent, ReadingSessionState> {
  final ReadingSessionService _readingSessionService;
  final Logger _logger = Logger('ReadingSessionBloc');

  ReadingSessionBloc({required ReadingSessionService readingSessionService})
    : _readingSessionService = readingSessionService,
      super(const ReadingSessionState()) {
    on<SessionStarted>(_onSessionStarted);
    on<EndSessionButtonTapped>(_onEndSessionButtonTapped);
    on<SessionFinished>(_onSessionFinished);
    on<DialogDismissed>(_onDialogDismissed);
  }

  /// Handles the session started event
  ///
  /// Initializes the session with book data and start time
  void _onSessionStarted(
    SessionStarted event,
    Emitter<ReadingSessionState> emit,
  ) {
    _logger.info('Starting reading session for book: ${event.book.title}');

    emit(
      ReadingSessionState(
        status: ReadingSessionStatus.inProgress,
        book: event.book,
        startTime: DateTime.now(),
      ),
    );
  }

  /// Handles the end session button tap
  ///
  /// Transitions to showDialog state to trigger UI dialog
  void _onEndSessionButtonTapped(
    EndSessionButtonTapped event,
    Emitter<ReadingSessionState> emit,
  ) {
    _logger.info('End session button tapped');

    emit(state.copyWith(status: ReadingSessionStatus.showDialog));
  }

  /// Handles the session finished event
  ///
  /// Submits the session data to the API and handles the result
  Future<void> _onSessionFinished(
    SessionFinished event,
    Emitter<ReadingSessionState> emit,
  ) async {
    if (state.book == null || state.startTime == null) {
      _logger.warning('Cannot finish session: missing book or start time');
      return;
    }

    _logger.info(
      'Finishing session for book: ${state.book!.title}, '
      'last page: ${event.lastReadPage}',
    );

    // Show loading state
    emit(state.copyWith(status: ReadingSessionStatus.submitting));

    try {
      // Create DTO
      final dto = EndReadingSessionDto(
        bookId: state.book!.id,
        startTime: state.startTime!,
        endTime: DateTime.now(),
        lastReadPage: event.lastReadPage,
      );

      // Call API
      final sessionId = await _readingSessionService.endReadingSession(dto);

      if (sessionId != null) {
        _logger.info('Session created successfully: $sessionId');
        emit(state.copyWith(status: ReadingSessionStatus.success));
      } else {
        // No progress was made (0 pages read)
        _logger.info('No session created (no progress made)');
        emit(
          state.copyWith(
            status: ReadingSessionStatus.failure,
            errorMessage: 'Brak postępu w czytaniu',
          ),
        );
      }
    } on ValidationException catch (e) {
      _logger.warning('Validation error: ${e.message}');
      emit(
        state.copyWith(
          status: ReadingSessionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on NoInternetException {
      _logger.warning('No internet connection');
      emit(
        state.copyWith(
          status: ReadingSessionStatus.failure,
          errorMessage: 'Brak połączenia z internetem',
        ),
      );
    } on ServerException catch (e) {
      _logger.severe('Server error: ${e.message}');
      emit(
        state.copyWith(
          status: ReadingSessionStatus.failure,
          errorMessage: 'Błąd serwera: ${e.message}',
        ),
      );
    } on TimeoutException {
      _logger.warning('Request timeout');
      emit(
        state.copyWith(
          status: ReadingSessionStatus.failure,
          errorMessage: 'Przekroczono limit czasu żądania',
        ),
      );
    } catch (e) {
      _logger.severe('Unexpected error: $e');
      emit(
        state.copyWith(
          status: ReadingSessionStatus.failure,
          errorMessage: 'Nieoczekiwany błąd: ${e.toString()}',
        ),
      );
    }
  }

  /// Handles the dialog dismissed event
  ///
  /// Returns to in-progress state when user cancels
  void _onDialogDismissed(
    DialogDismissed event,
    Emitter<ReadingSessionState> emit,
  ) {
    _logger.info('Dialog dismissed, returning to in-progress state');

    emit(state.copyWith(status: ReadingSessionStatus.inProgress));
  }
}

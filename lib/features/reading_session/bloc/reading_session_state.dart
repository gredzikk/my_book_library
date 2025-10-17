part of 'reading_session_bloc.dart';

/// Represents the status of the reading session
enum ReadingSessionStatus {
  /// Initial state, before session starts
  initial,

  /// Session is active and stopwatch is running
  inProgress,

  /// Dialog should be shown to get user input
  showDialog,

  /// Submitting data to API
  submitting,

  /// Session successfully ended
  success,

  /// An error occurred
  failure,
}

/// State for the Reading Session feature
final class ReadingSessionState {
  /// Current status of the session
  final ReadingSessionStatus status;

  /// The book being read
  final BookListItemDto? book;

  /// Time when the session started
  final DateTime? startTime;

  /// Optional error message for failure state
  final String? errorMessage;

  const ReadingSessionState({
    this.status = ReadingSessionStatus.initial,
    this.book,
    this.startTime,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced
  ReadingSessionState copyWith({
    ReadingSessionStatus? status,
    BookListItemDto? book,
    DateTime? startTime,
    String? errorMessage,
  }) {
    return ReadingSessionState(
      status: status ?? this.status,
      book: book ?? this.book,
      startTime: startTime ?? this.startTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

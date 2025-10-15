import 'package:equatable/equatable.dart';
import '../../../models/types.dart';

/// Base class for all Book Details states
abstract class BookDetailsState extends Equatable {
  const BookDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class BookDetailsInitial extends BookDetailsState {
  const BookDetailsInitial();
}

/// State while loading book details and sessions
class BookDetailsLoading extends BookDetailsState {
  const BookDetailsLoading();
}

/// State when book details and sessions are successfully loaded
class BookDetailsSuccess extends BookDetailsState {
  /// The book details
  final BookDetailDto book;

  /// List of reading sessions for this book
  final List<ReadingSessionDto> sessions;

  const BookDetailsSuccess({required this.book, required this.sessions});

  @override
  List<Object?> get props => [book, sessions];

  /// Create a copy with updated values
  BookDetailsSuccess copyWith({
    BookDetailDto? book,
    List<ReadingSessionDto>? sessions,
  }) {
    return BookDetailsSuccess(
      book: book ?? this.book,
      sessions: sessions ?? this.sessions,
    );
  }
}

/// State when an error occurs during loading
class BookDetailsFailure extends BookDetailsState {
  /// Error message to display
  final String error;

  const BookDetailsFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// State when an action is in progress (e.g., deleting, updating)
class BookDetailsActionInProgress extends BookDetailsState {
  /// The current book data (to keep displaying it)
  final BookDetailDto book;

  /// The sessions data
  final List<ReadingSessionDto> sessions;

  /// Optional message about what action is in progress
  final String? message;

  const BookDetailsActionInProgress({
    required this.book,
    required this.sessions,
    this.message,
  });

  @override
  List<Object?> get props => [book, sessions, message];
}

/// State when an action completed successfully
class BookDetailsActionSuccess extends BookDetailsState {
  /// Success message
  final String message;

  /// Whether to navigate back (e.g., after deletion)
  final bool shouldNavigateBack;

  const BookDetailsActionSuccess({
    required this.message,
    this.shouldNavigateBack = false,
  });

  @override
  List<Object?> get props => [message, shouldNavigateBack];
}

/// State when an action failed
class BookDetailsActionFailure extends BookDetailsState {
  /// Error message
  final String error;

  /// The current book data (to restore the view)
  final BookDetailDto book;

  /// The sessions data
  final List<ReadingSessionDto> sessions;

  const BookDetailsActionFailure({
    required this.error,
    required this.book,
    required this.sessions,
  });

  @override
  List<Object?> get props => [error, book, sessions];
}

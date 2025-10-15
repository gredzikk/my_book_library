import 'package:equatable/equatable.dart';
import '../../../models/types.dart';

/// Base class for all Book Details events
abstract class BookDetailsEvent extends Equatable {
  const BookDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch book details and reading sessions
class FetchBookDetails extends BookDetailsEvent {
  /// UUID of the book to fetch
  final String bookId;

  const FetchBookDetails(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to mark the book as read
class MarkAsReadRequested extends BookDetailsEvent {
  const MarkAsReadRequested();
}

/// Event to delete the book
class DeleteBookRequested extends BookDetailsEvent {
  const DeleteBookRequested();
}

/// Event to confirm deletion with user confirmation
class DeleteBookConfirmed extends BookDetailsEvent {
  const DeleteBookConfirmed();
}

/// Event to end a reading session
class EndSessionConfirmed extends BookDetailsEvent {
  /// DTO with session end details
  final EndReadingSessionDto dto;

  const EndSessionConfirmed(this.dto);

  @override
  List<Object?> get props => [dto];
}

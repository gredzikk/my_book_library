part of 'reading_session_bloc.dart';

/// Base class for all Reading Session events
sealed class ReadingSessionEvent {}

/// Event fired when the reading session is started
///
/// This event initializes the session with the book details
/// and sets the start time.
final class SessionStarted extends ReadingSessionEvent {
  /// The book being read
  final BookListItemDto book;

  SessionStarted(this.book);
}

/// Event fired when the user taps the "End Session" button
///
/// This event triggers the display of the EndSessionDialog
/// where the user can input their progress.
final class EndSessionButtonTapped extends ReadingSessionEvent {}

/// Event fired when the user confirms ending the session
///
/// This event is triggered after the user enters the last read page
/// in the dialog and confirms. It will call the API to save the session.
final class SessionFinished extends ReadingSessionEvent {
  /// The last page number the user read
  final int lastReadPage;

  SessionFinished(this.lastReadPage);
}

/// Event fired when the user dismisses the end session dialog
///
/// This event returns the session to the in-progress state
/// without saving any data.
final class DialogDismissed extends ReadingSessionEvent {}

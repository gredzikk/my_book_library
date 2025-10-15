import 'package:equatable/equatable.dart';
import '../../../models/types.dart';

/// Base class for all Home Screen states
abstract class HomeScreenState extends Equatable {
  const HomeScreenState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class HomeScreenInitial extends HomeScreenState {
  const HomeScreenInitial();
}

/// State while loading books from the API
class HomeScreenLoading extends HomeScreenState {
  const HomeScreenLoading();
}

/// State when books are successfully loaded
class HomeScreenSuccess extends HomeScreenState {
  /// List of books to display
  final List<BookListItemDto> books;

  const HomeScreenSuccess(this.books);

  @override
  List<Object?> get props => [books];
}

/// State when books are loaded but the list is empty
class HomeScreenEmpty extends HomeScreenState {
  const HomeScreenEmpty();
}

/// State when an error occurs during loading
class HomeScreenError extends HomeScreenState {
  /// Error message to display to the user
  final String message;

  const HomeScreenError(this.message);

  @override
  List<Object?> get props => [message];
}

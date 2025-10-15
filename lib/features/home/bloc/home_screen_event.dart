import 'package:equatable/equatable.dart';
import '../models/filter_sort_options.dart';

/// Base class for all Home Screen events
abstract class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load books from the API
class LoadBooksEvent extends HomeScreenEvent {
  /// Whether to force refresh from the server (ignoring cache)
  final bool forceRefresh;

  /// Optional filter and sort options
  final FilterSortOptions? filters;

  const LoadBooksEvent({this.forceRefresh = false, this.filters});

  @override
  List<Object?> get props => [forceRefresh, filters];
}

/// Event to refresh books (pull-to-refresh)
class RefreshBooksEvent extends HomeScreenEvent {
  const RefreshBooksEvent();
}

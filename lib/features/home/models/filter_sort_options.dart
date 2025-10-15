import 'package:equatable/equatable.dart';
import '../../../models/database_types.dart';

/// ViewModel for filter and sort options on the Home Screen
class FilterSortOptions extends Equatable {
  /// Filter by book status
  final BOOK_STATUS? status;

  /// Filter by genre ID
  final String? genreId;

  /// Field to sort by (e.g., 'title', 'author', 'created_at')
  final String orderBy;

  /// Sort direction: 'asc' or 'desc'
  final String orderDirection;

  const FilterSortOptions({
    this.status,
    this.genreId,
    this.orderBy = 'title',
    this.orderDirection = 'asc',
  });

  /// Creates default filter/sort options
  factory FilterSortOptions.defaults() {
    return const FilterSortOptions();
  }

  /// Creates a copy with modified fields
  FilterSortOptions copyWith({
    BOOK_STATUS? status,
    String? genreId,
    String? orderBy,
    String? orderDirection,
  }) {
    return FilterSortOptions(
      status: status ?? this.status,
      genreId: genreId ?? this.genreId,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
    );
  }

  /// Clears all filters but keeps sorting
  FilterSortOptions clearFilters() {
    return FilterSortOptions(orderBy: orderBy, orderDirection: orderDirection);
  }

  /// Checks if any filters are applied
  bool get hasFilters => status != null || genreId != null;

  @override
  List<Object?> get props => [status, genreId, orderBy, orderDirection];
}

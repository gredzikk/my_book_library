// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'database_types.dart';

part 'types.freezed.dart';
part 'types.g.dart';

// ============================================================================
// Book DTOs
// ============================================================================

/// Response DTO for book list items, includes embedded genre name
/// Used in: GET /rest/v1/books
@freezed
class BookListItemDto with _$BookListItemDto {
  const factory BookListItemDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'genre_id') String? genreId,
    required String title,
    required String author,
    @JsonKey(name: 'page_count') required int pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    required BookStatus status,
    @JsonKey(name: 'last_read_page_number') required int lastReadPageNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Embedded genre relation
    GenreEmbeddedDto? genres,
  }) = _BookListItemDto;

  factory BookListItemDto.fromJson(Map<String, dynamic> json) =>
      _$BookListItemDtoFromJson(json);

  /// Convert from Books entity
  factory BookListItemDto.fromEntity(Books book, {String? genreName}) {
    return BookListItemDto(
      id: book.id,
      userId: book.userId,
      genreId: book.genreId,
      title: book.title,
      author: book.author,
      pageCount: book.pageCount,
      coverUrl: book.coverUrl,
      isbn: book.isbn,
      publisher: book.publisher,
      publicationYear: book.publicationYear,
      status: book.status,
      lastReadPageNumber: book.lastReadPageNumber,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      genres: genreName != null ? GenreEmbeddedDto(name: genreName) : null,
    );
  }
}

/// Embedded genre information in book responses
@freezed
class GenreEmbeddedDto with _$GenreEmbeddedDto {
  const factory GenreEmbeddedDto({required String name}) = _GenreEmbeddedDto;

  factory GenreEmbeddedDto.fromJson(Map<String, dynamic> json) =>
      _$GenreEmbeddedDtoFromJson(json);
}

/// Response DTO for single book detail
/// Used in: GET /rest/v1/books?id=eq.{book_id}
/// Same structure as BookListItemDto
typedef BookDetailDto = BookListItemDto;

/// Command DTO for creating a new book
/// Used in: POST /rest/v1/books
@freezed
class CreateBookDto with _$CreateBookDto {
  const factory CreateBookDto({
    required String title,
    required String author,
    @JsonKey(name: 'page_count') required int pageCount,
    @JsonKey(name: 'genre_id') String? genreId,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
  }) = _CreateBookDto;

  factory CreateBookDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBookDtoFromJson(json);

  const CreateBookDto._();

  /// Convert to JSON for API request
  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'author': author,
      'page_count': pageCount,
      if (genreId != null) 'genre_id': genreId,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (isbn != null) 'isbn': isbn,
      if (publisher != null) 'publisher': publisher,
      if (publicationYear != null) 'publication_year': publicationYear,
    };
  }
}

/// Command DTO for updating an existing book
/// Used in: PATCH /rest/v1/books?id=eq.{book_id}
@freezed
class UpdateBookDto with _$UpdateBookDto {
  const factory UpdateBookDto({
    @JsonKey(name: 'genre_id') String? genreId,
    String? title,
    String? author,
    @JsonKey(name: 'page_count') int? pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    BookStatus? status,
    @JsonKey(name: 'last_read_page_number') int? lastReadPageNumber,
  }) = _UpdateBookDto;

  factory UpdateBookDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBookDtoFromJson(json);

  const UpdateBookDto._();

  /// Convert to JSON for API request (excludes null values)
  Map<String, dynamic> toRequestJson() {
    return {
      if (genreId != null) 'genre_id': genreId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (pageCount != null) 'page_count': pageCount,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (isbn != null) 'isbn': isbn,
      if (publisher != null) 'publisher': publisher,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (status != null) 'status': status.toString().split('.').last,
      if (lastReadPageNumber != null)
        'last_read_page_number': lastReadPageNumber,
    };
  }
}

// ============================================================================
// Reading Session DTOs
// ============================================================================

/// Response DTO for reading session
/// Used in: GET /rest/v1/reading_sessions
@freezed
class ReadingSessionDto with _$ReadingSessionDto {
  const factory ReadingSessionDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'book_id') required String bookId,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'pages_read') required int pagesRead,
    @JsonKey(name: 'last_read_page_number') required int lastReadPageNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReadingSessionDto;

  factory ReadingSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionDtoFromJson(json);

  /// Convert from ReadingSessions entity
  factory ReadingSessionDto.fromEntity(ReadingSessions session) {
    return ReadingSessionDto(
      id: session.id,
      userId: session.userId,
      bookId: session.bookId,
      startTime: session.startTime,
      endTime: session.endTime,
      durationMinutes: session.durationMinutes,
      pagesRead: session.pagesRead,
      lastReadPageNumber: session.lastReadPageNumber,
      createdAt: session.createdAt,
    );
  }
}

/// Command DTO for ending a reading session via RPC
/// Used in: POST /rest/v1/rpc/end_reading_session
@freezed
class EndReadingSessionDto with _$EndReadingSessionDto {
  const factory EndReadingSessionDto({
    @JsonKey(name: 'p_book_id') required String bookId,
    @JsonKey(name: 'p_start_time') required DateTime startTime,
    @JsonKey(name: 'p_end_time') required DateTime endTime,
    @JsonKey(name: 'p_last_read_page') required int lastReadPage,
  }) = _EndReadingSessionDto;

  factory EndReadingSessionDto.fromJson(Map<String, dynamic> json) =>
      _$EndReadingSessionDtoFromJson(json);

  const EndReadingSessionDto._();

  /// Convert to JSON for RPC call
  Map<String, dynamic> toRequestJson() {
    return {
      'p_book_id': bookId,
      'p_start_time': startTime.toUtc().toIso8601String(),
      'p_end_time': endTime.toUtc().toIso8601String(),
      'p_last_read_page': lastReadPage,
    };
  }
}

// ============================================================================
// Genre DTOs
// ============================================================================

/// Response DTO for genre
/// Used in: GET /rest/v1/genres
@freezed
class GenreDto with _$GenreDto {
  const factory GenreDto({
    required String id,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _GenreDto;

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);

  /// Convert from Genres entity
  factory GenreDto.fromEntity(Genres genre) {
    return GenreDto(id: genre.id, name: genre.name, createdAt: genre.createdAt);
  }
}

/// DTO dla odpowiedzi z Google Books API
@freezed
class GoogleBookResult with _$GoogleBookResult {
  const factory GoogleBookResult({
    required String title,
    List<String>? authors,
    String? publisher,
    String? publishedDate,
    int? pageCount,
    List<String>? categories,
    ImageLinks? imageLinks,
    List<IndustryIdentifier>? industryIdentifiers,
  }) = _GoogleBookResult;

  factory GoogleBookResult.fromJson(Map<String, dynamic> json) =>
      _$GoogleBookResultFromJson(json);

  const GoogleBookResult._();

  /// Konwertuj do CreateBookDto
  CreateBookDto toCreateBookDto({String? genreId}) {
    return CreateBookDto(
      title: title,
      author: authors?.join(', ') ?? 'Unknown Author',
      pageCount: pageCount ?? 0,
      publisher: publisher,
      publicationYear: _extractYear(publishedDate),
      coverUrl: imageLinks?.thumbnail ?? imageLinks?.smallThumbnail,
      isbn: _extractISBN(),
      genreId: genreId,
    );
  }

  int? _extractYear(String? date) {
    if (date == null) return null;
    final match = RegExp(r'\d{4}').firstMatch(date);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  String? _extractISBN() {
    if (industryIdentifiers == null) return null;
    // Preferuj ISBN_13, potem ISBN_10
    try {
      final isbn13 = industryIdentifiers!.firstWhere(
        (id) => id.type == 'ISBN_13',
      );
      return isbn13.identifier;
    } catch (_) {
      // ISBN_13 not found, try ISBN_10
      try {
        final isbn10 = industryIdentifiers!.firstWhere(
          (id) => id.type == 'ISBN_10',
        );
        return isbn10.identifier;
      } catch (_) {
        return null;
      }
    }
  }
}

@freezed
class ImageLinks with _$ImageLinks {
  const factory ImageLinks({String? smallThumbnail, String? thumbnail}) =
      _ImageLinks;

  factory ImageLinks.fromJson(Map<String, dynamic> json) =>
      _$ImageLinksFromJson(json);
}

@freezed
class IndustryIdentifier with _$IndustryIdentifier {
  const factory IndustryIdentifier({
    required String type,
    required String identifier,
  }) = _IndustryIdentifier;

  factory IndustryIdentifier.fromJson(Map<String, dynamic> json) =>
      _$IndustryIdentifierFromJson(json);
}

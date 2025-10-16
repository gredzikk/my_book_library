/// Service for managing book-related operations via Supabase REST API
///
/// This service provides methods for:
/// - Listing books with filtering, sorting, and pagination
/// - Creating new books
/// - Updating existing books
/// - Deleting books
///
/// All operations are automatically protected by Row-Level Security (RLS),
/// ensuring users can only access their own books.
library;

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../models/database_types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

/// Service for managing book-related operations
///
/// This class provides a high-level interface for interacting with the
/// books table in Supabase. It handles:
/// - Query building with proper parameter validation
/// - Error handling and transformation to appropriate exceptions
/// - Logging for debugging and monitoring
/// - Data transformation between API responses and DTOs
class BookService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('BookService');

  /// Creates a new BookService instance
  ///
  /// [_supabase] The Supabase client to use for API calls
  BookService(this._supabase);

  // ==========================================================================
  // List Books
  // ==========================================================================

  /// Fetches a list of books for the authenticated user
  ///
  /// This method queries the books table with optional filtering, sorting,
  /// and pagination. It automatically includes the genre name via embedded
  /// select (LEFT JOIN).
  ///
  /// **Query Pattern:**
  /// ```
  /// SELECT books.*, genres.name
  /// FROM books
  /// LEFT JOIN genres ON books.genre_id = genres.id
  /// WHERE books.user_id = auth.uid()
  ///   [AND books.status = ?]
  ///   [AND books.genre_id = ?]
  /// ORDER BY [orderBy] [orderDirection]
  /// LIMIT [limit] OFFSET [offset]
  /// ```
  ///
  /// **Parameters:**
  /// - [status]: Filter books by reading status (optional)
  /// - [genreId]: Filter books by genre UUID (optional)
  /// - [orderBy]: Field to sort by (default: 'title')
  /// - [orderDirection]: Sort direction 'asc' or 'desc' (default: 'asc')
  /// - [limit]: Maximum number of results (default: 20, max: 1000)
  /// - [offset]: Number of results to skip for pagination (default: 0)
  ///
  /// **Returns:**
  /// A list of [BookListItemDto] with embedded genre information
  ///
  /// **Throws:**
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [ValidationException]: Invalid parameters (e.g., invalid UUID, limit out of range)
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  /// - [ParseException]: Failed to parse API response
  ///
  /// **Example:**
  /// ```dart
  /// // Get all books
  /// final books = await bookService.listBooks();
  ///
  /// // Get books currently in progress
  /// final inProgressBooks = await bookService.listBooks(
  ///   status: BOOK_STATUS.in_progress,
  /// );
  ///
  /// // Get second page of books sorted by title
  /// final page2 = await bookService.listBooks(
  ///   limit: 20,
  ///   offset: 20,
  ///   orderBy: 'title',
  ///   orderDirection: 'asc',
  /// );
  /// ```
  Future<List<BookListItemDto>> listBooks({
    BookStatus? status,
    String? genreId,
    String orderBy = 'title',
    String orderDirection = 'asc',
    int limit = ApiConstants.defaultPageSize,
    int offset = 0,
  }) async {
    _logger.info(
      'Fetching books: status=$status, genreId=$genreId, '
      'orderBy=$orderBy, direction=$orderDirection, limit=$limit, offset=$offset',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Validate all input parameters before making API call
      _validateListBooksParameters(
        status,
        genreId,
        limit,
        offset,
        orderDirection,
      );

      // Build the query with embedded genre relation
      // The select clause joins genres table and includes the name field
      dynamic query = _supabase.from('books').select('*,genres(name)');

      // Apply status filter if specified
      // Converts enum to string (e.g., BOOK_STATUS.in_progress -> "in_progress")
      if (status != null) {
        final statusString = status.toString().split('.').last;
        query = query.eq('status', statusString);
      }

      // Apply genre filter if specified
      if (genreId != null) {
        query = query.eq('genre_id', genreId);
      }

      // Apply sorting
      // orderDirection is case-insensitive ('asc', 'ASC', 'Asc' all work)
      final ascending = orderDirection.toLowerCase() == 'asc';
      query = query.order(orderBy, ascending: ascending);

      // Apply pagination using range
      // range is inclusive, so we use offset to offset + limit - 1
      // Example: limit=20, offset=0 -> range(0, 19) = first 20 items
      query = query.range(offset, offset + limit - 1);

      // Execute the query with timeout
      final response = await query.timeout(ApiConstants.defaultTimeout);

      // Parse the response to DTOs
      // Response is a List of Map<String, dynamic>
      final books = (response as List)
          .map((json) => BookListItemDto.fromJson(json as Map<String, dynamic>))
          .toList();

      stopwatch.stop();
      _logger.info(
        'Successfully fetched ${books.length} books in ${stopwatch.elapsedMilliseconds}ms',
      );

      return books;
    } on PostgrestException catch (e) {
      // Handle Supabase/PostgreSQL errors
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      // Map Supabase error codes to our exception types
      // PGRST301: JWT related errors (authentication)
      if (e.code == 'PGRST301' || (e.message.toLowerCase().contains('jwt'))) {
        throw UnauthorizedException(e.message);
      }
      // PGRST1xx: Query parameter errors (validation)
      else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
      }
      // PGRST116: Table not found
      else if (e.code == 'PGRST116') {
        throw NotFoundException('Books table not found');
      }
      // All other errors are treated as server errors
      else {
        throw ServerException(e.message);
      }
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      stopwatch.stop();
      _logger.severe('Failed to parse response: ${e.message}', e);
      throw ParseException('Invalid response format from server');
    } on SocketException catch (e) {
      // Handle network connectivity errors
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      // Handle timeout errors
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      // Handle any unexpected errors
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }

  // ==========================================================================
  // Private Helper Methods
  // ==========================================================================

  /// Validates parameters for the listBooks method
  ///
  /// Throws [ValidationException] if any parameter is invalid.
  ///
  /// Validation rules:
  /// - limit: must be between [ApiConstants.minPageSize] and [ApiConstants.maxPageSize]
  /// - offset: must be non-negative
  /// - genreId: must be a valid UUID format (if provided)
  /// - orderDirection: must be 'asc' or 'desc' (case-insensitive)
  void _validateListBooksParameters(
    BookStatus? status,
    String? genreId,
    int limit,
    int offset,
    String orderDirection,
  ) {
    // Validate limit
    if (limit < ApiConstants.minPageSize || limit > ApiConstants.maxPageSize) {
      throw ValidationException(
        'Limit must be between ${ApiConstants.minPageSize} and ${ApiConstants.maxPageSize}',
      );
    }

    // Validate offset
    if (offset < 0) {
      throw ValidationException('Offset must be non-negative');
    }

    // Validate UUID format for genreId
    if (genreId != null && !_isValidUuid(genreId)) {
      throw ValidationException('Invalid genre_id format (must be UUID)');
    }

    // Validate orderDirection
    final validDirections = ['asc', 'desc'];
    if (!validDirections.contains(orderDirection.toLowerCase())) {
      throw ValidationException(
        'Order direction must be one of: ${validDirections.join(", ")}',
      );
    }
  }

  /// Checks if a string is a valid UUID (v4) format
  ///
  /// Valid UUID format: 8-4-4-4-12 hexadecimal characters
  /// Example: 550e8400-e29b-41d4-a716-446655440000
  ///
  /// Returns true if the string matches the UUID pattern, false otherwise.
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // ==========================================================================
  // Get Book Details
  // ==========================================================================

  /// Fetches details of a single book by ID
  ///
  /// This method queries the books table for a specific book and includes
  /// the genre name via embedded select.
  ///
  /// **Query Pattern:**
  /// ```
  /// SELECT books.*, genres.name
  /// FROM books
  /// LEFT JOIN genres ON books.genre_id = genres.id
  /// WHERE books.id = ? AND books.user_id = auth.uid()
  /// ```
  ///
  /// **Parameters:**
  /// - [id]: UUID of the book to fetch
  ///
  /// **Returns:**
  /// A [BookDetailDto] with embedded genre information
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid book ID format
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [NotFoundException]: Book not found or doesn't belong to user
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  /// - [ParseException]: Failed to parse API response
  ///
  /// **Example:**
  /// ```dart
  /// final book = await bookService.getBook('c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
  /// print('Book: ${book.title} by ${book.author}');
  /// ```
  Future<BookDetailDto> getBook(String id) async {
    _logger.info('Fetching book with id: $id');

    final stopwatch = Stopwatch()..start();

    try {
      // Validate book ID format
      if (!_isValidUuid(id)) {
        throw ValidationException('Invalid book ID format (must be UUID)');
      }

      // Build the query with embedded genre relation
      final response = await _supabase
          .from('books')
          .select('*,genres(name)')
          .eq('id', id)
          .maybeSingle()
          .timeout(ApiConstants.defaultTimeout);

      // Check if book was found
      if (response == null) {
        throw NotFoundException('Book not found or access denied');
      }

      // Parse the response to DTO
      final book = BookDetailDto.fromJson(response);

      stopwatch.stop();
      _logger.info(
        'Successfully fetched book "${book.title}" in ${stopwatch.elapsedMilliseconds}ms',
      );

      return book;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      if (e.code == 'PGRST301' || (e.message.toLowerCase().contains('jwt'))) {
        throw UnauthorizedException(e.message);
      } else if (e.code == 'PGRST116') {
        throw NotFoundException('Book not found');
      } else {
        throw ServerException(e.message);
      }
    } on FormatException catch (e) {
      stopwatch.stop();
      _logger.severe('Failed to parse response: ${e.message}', e);
      throw ParseException('Invalid response format from server');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }

  // ==========================================================================
  // Create Book
  // ==========================================================================

  /// Creates a new book
  ///
  /// This method creates a new book for the authenticated user. The user_id
  /// is automatically set by the database based on auth.uid(). Default values
  /// are set for status (NOT_STARTED) and last_read_page_number (0).
  ///
  /// **Query Pattern:**
  /// ```
  /// INSERT INTO books (title, author, page_count, ...)
  /// VALUES (?, ?, ?, ...)
  /// RETURNING *
  /// ```
  ///
  /// **Parameters:**
  /// - [dto]: [CreateBookDto] containing book data
  ///
  /// **Returns:**
  /// [BookListItemDto] of the created book
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid DTO fields (e.g., empty title, invalid page count)
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  /// - [ParseException]: Failed to parse server response
  ///
  /// **Example:**
  /// ```dart
  /// final dto = CreateBookDto(
  ///   title: 'The Hobbit',
  ///   author: 'J.R.R. Tolkien',
  ///   pageCount: 310,
  ///   genreId: 'genre-uuid',
  /// );
  /// final book = await bookService.createBook(dto);
  /// ```
  Future<BookListItemDto> createBook(CreateBookDto dto) async {
    _logger.info('Creating book: ${dto.title} by ${dto.author}');

    final stopwatch = Stopwatch()..start();

    try {
      // Convert DTO to request JSON
      final bookData = dto.toRequestJson();

      // Execute insert and return the created book
      final response = await _supabase
          .from('books')
          .insert(bookData)
          .select('*, genres(name)')
          .single()
          .timeout(ApiConstants.defaultTimeout);

      stopwatch.stop();
      _logger.info(
        'Successfully created book in ${stopwatch.elapsedMilliseconds}ms',
      );

      // Parse response to BookListItemDto
      return BookListItemDto.fromJson(response);
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      if (e.code == 'PGRST301' || (e.message.toLowerCase().contains('jwt'))) {
        throw UnauthorizedException(e.message);
      } else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
      } else if (e.code == '23505') {
        // Unique constraint violation
        throw ValidationException('Book with this ISBN already exists');
      } else if (e.code == '23503') {
        // Foreign key violation (invalid genre_id)
        throw ValidationException('Invalid genre ID');
      } else {
        throw ServerException(e.message);
      }
    } on FormatException catch (e) {
      stopwatch.stop();
      _logger.severe('Failed to parse response: ${e.message}', e);
      throw ParseException('Invalid response format from server');
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }

  // ==========================================================================
  // Update Book
  // ==========================================================================

  /// Updates an existing book
  ///
  /// This method updates a book with the provided fields. Only non-null fields
  /// in the DTO will be updated. RLS ensures only the book owner can update it.
  ///
  /// **Query Pattern:**
  /// ```
  /// UPDATE books
  /// SET [fields from dto]
  /// WHERE id = ? AND user_id = auth.uid()
  /// ```
  ///
  /// **Parameters:**
  /// - [id]: UUID of the book to update
  /// - [dto]: [UpdateBookDto] containing fields to update
  ///
  /// **Returns:**
  /// void (throws exception on error)
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid book ID format or invalid DTO fields
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [NotFoundException]: Book not found or doesn't belong to user
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  ///
  /// **Example:**
  /// ```dart
  /// final dto = UpdateBookDto(
  ///   status: BOOK_STATUS.finished,
  ///   lastReadPageNumber: 300,
  /// );
  /// await bookService.updateBook('book-uuid', dto);
  /// ```
  Future<void> updateBook(String id, UpdateBookDto dto) async {
    _logger.info('Updating book: $id with data: ${dto.toRequestJson()}');

    final stopwatch = Stopwatch()..start();

    try {
      // Validate book ID format
      if (!_isValidUuid(id)) {
        throw ValidationException('Invalid book ID format (must be UUID)');
      }

      // Convert DTO to request JSON (excludes null values)
      final updateData = dto.toRequestJson();

      // Validate that there's at least one field to update
      if (updateData.isEmpty) {
        throw ValidationException('No fields to update');
      }

      // Execute update and check count
      final response = await _supabase
          .from('books')
          .update(updateData)
          .eq('id', id)
          .select('id')
          .timeout(ApiConstants.defaultTimeout) as List;

      // Check if any rows were updated
      if (response.isEmpty) {
        throw NotFoundException('Book not found or you don\'t have permission to update it');
      }

      stopwatch.stop();
      _logger.info(
        'Successfully updated book in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      if (e.code == 'PGRST301' || (e.message.toLowerCase().contains('jwt'))) {
        throw UnauthorizedException(e.message);
      } else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
      } else if (e.code == 'PGRST116') {
        throw NotFoundException('Book not found');
      } else {
        throw ServerException(e.message);
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }

  // ==========================================================================
  // Delete Book
  // ==========================================================================

  /// Deletes a book by ID
  ///
  /// This method permanently deletes a book and all its associated reading
  /// sessions (via CASCADE). RLS ensures only the book owner can delete it.
  ///
  /// **Query Pattern:**
  /// ```
  /// DELETE FROM books
  /// WHERE id = ? AND user_id = auth.uid()
  /// ```
  ///
  /// **Parameters:**
  /// - [id]: UUID of the book to delete
  ///
  /// **Returns:**
  /// void (throws exception on error)
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid book ID format
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [NotFoundException]: Book not found or doesn't belong to user
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  ///
  /// **Example:**
  /// ```dart
  /// await bookService.deleteBook('c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
  /// ```
  Future<void> deleteBook(String id) async {
    _logger.info('Deleting book: $id');

    final stopwatch = Stopwatch()..start();

    try {
      // Validate book ID format
      if (!_isValidUuid(id)) {
        throw ValidationException('Invalid book ID format (must be UUID)');
      }

      // Execute delete
      await _supabase
          .from('books')
          .delete()
          .eq('id', id)
          .timeout(ApiConstants.defaultTimeout);

      stopwatch.stop();
      _logger.info(
        'Successfully deleted book in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      if (e.code == 'PGRST301' || (e.message.toLowerCase().contains('jwt'))) {
        throw UnauthorizedException(e.message);
      } else if (e.code == 'PGRST116') {
        throw NotFoundException('Book not found');
      } else {
        throw ServerException(e.message);
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }
}

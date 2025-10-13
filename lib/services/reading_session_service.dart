/// Service for managing reading session operations via Supabase REST API
///
/// This service provides methods for:
/// - Listing reading sessions for a specific book
/// - Ending a reading session (creating new session + updating book progress)
///
/// All operations are automatically protected by Row-Level Security (RLS),
/// ensuring users can only access their own data.
///
/// **Authentication:**
/// All methods require a valid JWT token from Supabase Auth.
/// The token is automatically attached by the SupabaseClient.
///
/// **Error Handling:**
/// - [ValidationException]: Invalid input parameters
/// - [UnauthorizedException]: Missing or invalid JWT token
/// - [NotFoundException]: Resource not found
/// - [ServerException]: Database or server errors
/// - [NoInternetException]: Network connection failure
/// - [TimeoutException]: Request timeout
///
/// **Example Usage:**
/// ```dart
/// final service = ReadingSessionService(Supabase.instance.client);
///
/// // List sessions for a book
/// final sessions = await service.listReadingSessions('book-uuid');
///
/// // End a reading session
/// final dto = EndReadingSessionDto(
///   bookId: 'book-uuid',
///   startTime: DateTime.now().subtract(Duration(minutes: 30)),
///   endTime: DateTime.now(),
///   lastReadPage: 150,
/// );
/// final sessionId = await service.endReadingSession(dto);
/// ```

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

class ReadingSessionService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('ReadingSessionService');

  /// Creates a new instance of [ReadingSessionService]
  ///
  /// **Parameters:**
  /// - [_supabase]: Authenticated SupabaseClient instance
  ReadingSessionService(this._supabase);

  /// Fetches reading sessions for a specific book
  ///
  /// Returns a list of sessions sorted by creation date (newest first by default).
  /// RLS ensures only sessions belonging to the authenticated user are returned.
  ///
  /// **Parameters:**
  /// - [bookId]: UUID of the book to fetch sessions for (required)
  /// - [orderBy]: Field to sort by (default: 'created_at')
  /// - [ascending]: Sort direction (default: false = descending)
  ///
  /// **Returns:**
  /// List of [ReadingSessionDto], may be empty if no sessions exist
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid bookId format
  /// - [UnauthorizedException]: Authentication failed
  /// - [ServerException]: Database error
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request timeout
  ///
  /// **Example:**
  /// ```dart
  /// final sessions = await readingSessionService.listReadingSessions(
  ///   'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
  /// );
  /// ```
  Future<List<ReadingSessionDto>> listReadingSessions(
    String bookId, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    _logger.info(
      'Fetching reading sessions for book: $bookId, '
      'orderBy: $orderBy, ascending: $ascending',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Validate bookId format
      if (!_isValidUuid(bookId)) {
        throw ValidationException('Invalid book_id format (must be UUID)');
      }

      // Build query
      // RLS automatically adds: WHERE user_id = auth.uid()
      final query = _supabase
          .from('reading_sessions')
          .select()
          .eq('book_id', bookId)
          .order(orderBy, ascending: ascending);

      // Execute with timeout
      final response = await query.timeout(ApiConstants.defaultTimeout);

      // Parse response
      final sessions = (response as List)
          .map(
            (json) => ReadingSessionDto.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      stopwatch.stop();
      _logger.info(
        'Successfully fetched ${sessions.length} sessions in ${stopwatch.elapsedMilliseconds}ms',
      );

      return sessions;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);
      _handlePostgrestException(e);
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

  /// Ends a reading session by calling the PostgreSQL RPC function
  ///
  /// This method atomically:
  /// 1. Creates a new reading_session record
  /// 2. Updates book.last_read_page_number
  /// 3. Automatically updates book.status to 'finished' if completed
  ///
  /// **Parameters:**
  /// - [dto]: EndReadingSessionDto with session details
  ///
  /// **Returns:**
  /// - UUID string of created session if successful
  /// - null if no progress was made (pages_read = 0)
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid input data
  /// - [UnauthorizedException]: Authentication failed
  /// - [ServerException]: RPC function error
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request timeout
  ///
  /// **Example:**
  /// ```dart
  /// final dto = EndReadingSessionDto(
  ///   bookId: 'book-uuid',
  ///   startTime: DateTime.now().subtract(Duration(minutes: 30)),
  ///   endTime: DateTime.now(),
  ///   lastReadPage: 150,
  /// );
  /// final sessionId = await readingSessionService.endReadingSession(dto);
  /// ```
  Future<String?> endReadingSession(EndReadingSessionDto dto) async {
    _logger.info(
      'Ending reading session for book: ${dto.bookId}, '
      'pages: ${dto.lastReadPage}',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Validate DTO before sending
      _validateEndSessionDto(dto);

      // Call RPC function
      final response = await _supabase
          .rpc('end_reading_session', params: dto.toRequestJson())
          .timeout(ApiConstants.defaultTimeout);

      stopwatch.stop();

      // Parse response (UUID string or null)
      final sessionId = response as String?;

      if (sessionId != null) {
        _logger.info(
          'Successfully created reading session $sessionId in ${stopwatch.elapsedMilliseconds}ms',
        );
      } else {
        _logger.info(
          'No session created (no progress) in ${stopwatch.elapsedMilliseconds}ms',
        );
      }

      return sessionId;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('RPC error: ${e.message} (code: ${e.code})', e);
      _handlePostgrestException(e);
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
  // Private Helper Methods
  // ==========================================================================

  /// Validates EndReadingSessionDto before sending to API
  ///
  /// **Validation rules:**
  /// - bookId must be valid UUID format
  /// - endTime must be after startTime
  /// - lastReadPage must be positive
  /// - Times cannot be in the future (optional but recommended)
  ///
  /// **Throws:**
  /// - [ValidationException]: If any validation rule is violated
  void _validateEndSessionDto(EndReadingSessionDto dto) {
    // Validate UUID format
    if (!_isValidUuid(dto.bookId)) {
      throw ValidationException('Invalid book_id format (must be UUID)');
    }

    // Validate time ordering
    if (dto.endTime.isBefore(dto.startTime) ||
        dto.endTime.isAtSameMomentAs(dto.startTime)) {
      throw ValidationException('end_time must be after start_time');
    }

    // Validate last_read_page
    if (dto.lastReadPage <= 0) {
      throw ValidationException('last_read_page must be positive');
    }

    // Optional: Validate times are not in future
    final now = DateTime.now().toUtc();
    if (dto.endTime.isAfter(now)) {
      throw ValidationException('end_time cannot be in the future');
    }

    if (dto.startTime.isAfter(now)) {
      throw ValidationException('start_time cannot be in the future');
    }
  }

  /// Checks if a string is a valid UUID (v4) format
  ///
  /// **Parameters:**
  /// - [uuid]: String to validate
  ///
  /// **Returns:**
  /// true if valid UUID format, false otherwise
  ///
  /// **Example:**
  /// ```dart
  /// _isValidUuid('c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c') // true
  /// _isValidUuid('invalid-uuid') // false
  /// ```
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Handles PostgrestException and throws appropriate custom exception
  ///
  /// Maps Supabase/PostgreSQL error codes to application-specific exceptions
  /// for better error handling and user feedback.
  ///
  /// **Error Code Mapping:**
  /// - PGRST301 or 'jwt' in message → [UnauthorizedException]
  /// - PGRST116 → [NotFoundException]
  /// - PGRST1* → [ValidationException]
  /// - 22* (constraint violations) → [ValidationException]
  /// - P0001 (raised exception in function) → [ValidationException]
  /// - Others → [ServerException]
  ///
  /// **Parameters:**
  /// - [e]: PostgrestException to handle
  ///
  /// **Throws:**
  /// One of the custom exceptions based on error code
  Never _handlePostgrestException(PostgrestException e) {
    // JWT/Auth errors
    if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
      throw UnauthorizedException(e.message);
    }
    // Resource not found
    else if (e.code == 'PGRST116') {
      throw NotFoundException('Resource not found');
    }
    // Query parameter errors
    else if (e.code?.startsWith('PGRST1') ?? false) {
      throw ValidationException(e.message);
    }
    // PostgreSQL constraint violations (22xxx codes)
    else if (e.code?.startsWith('22') ?? false) {
      throw ValidationException(_parseConstraintError(e.message));
    }
    // RPC function raised exception (P0001)
    else if (e.code == 'P0001') {
      throw ValidationException(e.message);
    }
    // Generic server error
    else {
      throw ServerException(e.message);
    }
  }

  /// Parses PostgreSQL constraint error messages to user-friendly format
  ///
  /// Converts technical constraint violation messages into human-readable
  /// error messages for better user experience.
  ///
  /// **Parameters:**
  /// - [message]: Raw PostgreSQL error message
  ///
  /// **Returns:**
  /// User-friendly error message
  ///
  /// **Example:**
  /// ```dart
  /// _parseConstraintError('violates check constraint "check_end_after_start"')
  /// // Returns: 'End time must be after start time'
  /// ```
  String _parseConstraintError(String message) {
    // Example: "new row for relation "reading_sessions" violates check constraint "check_end_after_start""
    if (message.contains('check_end_after_start')) {
      return 'End time must be after start time';
    }
    if (message.contains('pages_read')) {
      return 'Invalid pages_read value';
    }
    if (message.contains('duration_minutes')) {
      return 'Invalid session duration';
    }
    // Return original message if no specific pattern matched
    return message;
  }
}

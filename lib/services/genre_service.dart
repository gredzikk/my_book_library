/// Service for managing genre-related operations via Supabase REST API
///
/// This service provides methods for:
/// - Listing all available book genres
///
/// All operations are automatically protected by Row-Level Security (RLS).
/// Genres are read-only for end users and managed by database administrators.
library;

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

/// Service for managing genre-related operations
///
/// This class provides a high-level interface for interacting with the
/// genres table in Supabase. It handles:
/// - Query building with proper parameter validation
/// - Error handling and transformation to appropriate exceptions
/// - Logging for debugging and monitoring
/// - In-memory caching for performance optimization
/// - Data transformation between API responses and DTOs
class GenreService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('GenreService');

  /// Optional in-memory cache for genres
  List<GenreDto>? _cachedGenres;
  DateTime? _cacheTimestamp;
  static const _cacheValidity = Duration(hours: 24);

  /// Creates a new GenreService instance
  ///
  /// [_supabase] The Supabase client to use for API calls
  GenreService(this._supabase);

  // ==========================================================================
  // List Genres
  // ==========================================================================

  /// Fetches the list of all available book genres
  ///
  /// This method queries the genres table and returns all available genres
  /// sorted alphabetically by name. Results are cached for 24 hours to
  /// reduce unnecessary API calls.
  ///
  /// **Query Pattern:**
  /// ```
  /// SELECT id, name, created_at
  /// FROM genres
  /// WHERE auth.role() = 'authenticated'  -- RLS policy
  /// ORDER BY name ASC
  /// ```
  ///
  /// **Parameters:**
  /// - [orderBy]: Field to sort by (default: 'name')
  /// - [orderDirection]: Sort direction 'asc' or 'desc' (default: 'asc')
  /// - [forceRefresh]: Skip cache and fetch fresh data (default: false)
  ///
  /// **Returns:**
  /// A list of [GenreDto] objects sorted by name
  ///
  /// **Throws:**
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  /// - [ParseException]: Failed to parse API response
  ///
  /// **Example:**
  /// ```dart
  /// // Get all genres (uses cache if available)
  /// final genres = await genreService.listGenres();
  ///
  /// // Force refresh from database
  /// final freshGenres = await genreService.listGenres(forceRefresh: true);
  /// ```
  Future<List<GenreDto>> listGenres({
    String orderBy = 'name',
    String orderDirection = 'asc',
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && _cachedGenres != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheValidity) {
        _logger.info(
          'Returning cached genres (${_cachedGenres!.length} items, '
          'age: ${age.inMinutes}m)',
        );
        return _cachedGenres!;
      }
    }

    _logger.info(
      'Fetching genres: orderBy=$orderBy, direction=$orderDirection',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Build the query
      final ascending = orderDirection.toLowerCase() == 'asc';
      final query = _supabase
          .from('genres')
          .select('*')
          .order(orderBy, ascending: ascending);

      // Execute the query with timeout
      final response = await query.timeout(ApiConstants.defaultTimeout);

      // Parse the response to DTOs
      final genres = (response as List)
          .map((json) => GenreDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update cache
      _cachedGenres = genres;
      _cacheTimestamp = DateTime.now();

      stopwatch.stop();
      _logger.info(
        'Successfully fetched ${genres.length} genres in '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      return genres;
    } on PostgrestException catch (e) {
      // Handle Supabase/PostgreSQL errors
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      // Map Supabase error codes to our exception types
      // PGRST301: JWT related errors (authentication)
      if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
        throw UnauthorizedException(e.message);
      }
      // PGRST1xx: Query parameter errors (validation)
      else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
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
  // Cache Management
  // ==========================================================================

  /// Invalidates the genres cache
  ///
  /// Forces the next call to [listGenres] to fetch fresh data from the server.
  /// Useful when implementing pull-to-refresh functionality.
  void invalidateCache() {
    _logger.info('Invalidating genres cache');
    _cachedGenres = null;
    _cacheTimestamp = null;
  }

  /// Returns the number of cached genres (for debugging)
  int? get cachedGenresCount => _cachedGenres?.length;

  /// Returns the age of the cache (for debugging)
  Duration? get cacheAge {
    if (_cacheTimestamp == null) return null;
    return DateTime.now().difference(_cacheTimestamp!);
  }
}

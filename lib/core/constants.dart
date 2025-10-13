/// Application-wide constants for API configuration and limits
///
/// This file defines constants used across the application for:
/// - API pagination limits
/// - Network timeouts
/// - Cache durations
/// - Retry policies

// ============================================================================
// API Constants
// ============================================================================

/// Constants for API configuration and behavior
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  // =========================================================================
  // Pagination Settings
  // =========================================================================

  /// Default number of items per page
  ///
  /// This is used when no explicit limit is specified in API calls.
  /// Chosen to balance between:
  /// - Reducing number of API calls
  /// - Keeping payload size reasonable
  /// - Providing good UX for infinite scroll
  static const int defaultPageSize = 20;

  /// Maximum allowed items per page
  ///
  /// This is the hard limit enforced by Supabase and our validation.
  /// Requesting more than this will throw a ValidationException.
  ///
  /// Note: While Supabase allows up to 1000, we recommend staying
  /// below 100 for better performance and user experience.
  static const int maxPageSize = 1000;

  /// Minimum allowed items per page
  ///
  /// Requesting less than this will throw a ValidationException.
  static const int minPageSize = 1;

  // =========================================================================
  // Timeout Settings
  // =========================================================================

  /// Default timeout for API requests
  ///
  /// Most API requests should complete within this timeframe.
  /// If a request takes longer, a TimeoutException is thrown.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Short timeout for quick operations
  ///
  /// Used for simple queries that should complete quickly.
  /// Examples: fetching genres, checking authentication status.
  static const Duration shortTimeout = Duration(seconds: 10);

  // =========================================================================
  // Cache Settings
  // =========================================================================

  /// Duration to keep cached data before refetching
  ///
  /// Cached data older than this will be considered stale
  /// and will be refetched from the API.
  ///
  /// This helps reduce unnecessary API calls while ensuring
  /// data doesn't become too outdated.
  static const Duration cacheDuration = Duration(minutes: 5);

  // =========================================================================
  // Retry Settings
  // =========================================================================

  /// Maximum number of retry attempts for failed requests
  ///
  /// When a request fails due to network issues, it will be
  /// retried up to this many times before giving up.
  static const int maxRetries = 3;

  /// Delay between retry attempts
  ///
  /// After a failed request, wait this long before retrying.
  /// This gives the network or server time to recover.
  static const Duration retryDelay = Duration(seconds: 2);
}

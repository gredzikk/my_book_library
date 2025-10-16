/// Core exception classes for error handling throughout the application
///
/// This file defines a hierarchy of exceptions that provide structured
/// error handling for network, API, and data-related errors.
///
/// Hierarchy:
/// - AppException (abstract base)
///   - NetworkException (network-related errors)
///     - NoInternetException
///     - TimeoutException
///   - ApiException (API/HTTP errors)
///     - UnauthorizedException (401)
///     - ForbiddenException (403)
///     - NotFoundException (404)
///     - ValidationException (400)
///     - ServerException (500)
///   - DataException (data processing errors)
///     - ParseException
///     - InvalidDataException
library;

// ============================================================================
// Base Exception
// ============================================================================

/// Base class for all application exceptions
///
/// All custom exceptions should extend this class to provide
/// consistent error handling across the application.
abstract class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional additional error details
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() => message;
}

// ============================================================================
// Network Exceptions
// ============================================================================

/// Base class for network-related exceptions
///
/// Used for errors that occur during network communication,
/// such as connection failures or timeouts.
class NetworkException extends AppException {
  NetworkException(super.message, [super.details]);
}

/// Exception thrown when there is no internet connection
///
/// This typically occurs when the device is offline or
/// cannot reach the remote server.
class NoInternetException extends NetworkException {
  NoInternetException() : super('No internet connection');
}

/// Exception thrown when a network request times out
///
/// This occurs when the server takes too long to respond
/// or the connection is too slow.
class TimeoutException extends NetworkException {
  TimeoutException(super.message);
}

// ============================================================================
// API Exceptions
// ============================================================================

/// Base class for API/HTTP-related exceptions
///
/// These exceptions correspond to HTTP status codes and
/// represent errors returned by the API server.
class ApiException extends AppException {
  /// HTTP status code (e.g., 400, 401, 404, 500)
  final int? statusCode;

  ApiException(super.message, [this.statusCode, super.details]);
}

/// Exception thrown when authentication is required or has failed (401)
///
/// This typically occurs when:
/// - JWT token is missing
/// - JWT token has expired
/// - JWT token is invalid or tampered with
///
/// Recommended action: Attempt to refresh the token or redirect to login.
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

/// Exception thrown when access to a resource is forbidden (403)
///
/// This typically occurs when:
/// - User doesn't have permission to access the resource
/// - RLS policy denies access
/// - Account has been deactivated
///
/// Recommended action: Show appropriate error message to user.
class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

/// Exception thrown when a requested resource is not found (404)
///
/// This typically occurs when:
/// - Endpoint URL is incorrect
/// - Resource ID doesn't exist
/// - Table doesn't exist in database
///
/// Recommended action: Verify the request and show appropriate error.
class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

/// Exception thrown when request validation fails (400)
///
/// This typically occurs when:
/// - Invalid parameter values
/// - Missing required parameters
/// - Parameter format is incorrect (e.g., invalid UUID)
///
/// Recommended action: Fix the request parameters and retry.
class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 400);
}

/// Exception thrown when the server encounters an error (500)
///
/// This typically occurs when:
/// - Database connection fails
/// - RLS policy error
/// - Server-side bug or crash
///
/// Recommended action: Retry the request or show maintenance message.
class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

// ============================================================================
// Data Exceptions
// ============================================================================

/// Base class for data processing exceptions
///
/// Used for errors that occur during data parsing, validation,
/// or transformation on the server or client side.
class DataException extends AppException {
  DataException(super.message, [super.details]);
}

/// Exception thrown when JSON parsing fails
///
/// This typically occurs when:
/// - Response format is invalid
/// - Expected fields are missing
/// - Data types don't match expectations
///
/// Recommended action: Log the error and show generic error to user.
class ParseException extends DataException {
  ParseException(super.message);
}

/// Exception thrown when data validation fails
///
/// This typically occurs when:
/// - Data constraints are violated
/// - Business rules are not satisfied
/// - Data integrity checks fail
///
/// Recommended action: Show validation errors to user.
class InvalidDataException extends DataException {
  InvalidDataException(super.message);
}

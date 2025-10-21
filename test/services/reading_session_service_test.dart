import 'package:flutter_test/flutter_test.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/models/database_types.dart';

/// Unit tests for Reading Session DTOs and validation logic
///
/// These tests verify that:
/// - ReadingSessionDto correctly serializes/deserializes from JSON
/// - ReadingSessionDto correctly converts from database entities
/// - EndReadingSessionDto validates and formats data for RPC calls
/// - All required fields are properly handled
/// - Date/time handling works correctly with UTC
/// - Business rules are enforced (time ordering, positive values, etc.)
///
/// Test coverage includes:
/// - ReadingSessionDto: JSON conversion, entity conversion, all fields
/// - EndReadingSessionDto: Request JSON formatting, parameter mapping
/// - Edge cases: boundary values, date precision, timezone handling
/// - Business rules validation: time constraints, page numbers
///
/// According to TDD principles:
/// - Test all possible cases including edge cases
/// - Use meaningful test names that describe what is being tested
/// - Follow the testing pyramid: focus on unit tests
/// - Refactor and maintain tests as code evolves
void main() {
  group('ReadingSessionDto -', () {
    group('JSON serialization -', () {
      test('should create from JSON correctly with all fields', () {
        // Arrange
        final json = {
          'id': 'a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
          'user_id': 'user-uuid-1234-5678',
          'book_id': 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T11:30:00Z',
          'duration_minutes': 90,
          'pages_read': 25,
          'last_read_page_number': 125,
          'created_at': '2025-10-20T11:30:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.id, 'a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d');
        expect(session.userId, 'user-uuid-1234-5678');
        expect(session.bookId, 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
        expect(session.startTime, DateTime.parse('2025-10-20T10:00:00Z'));
        expect(session.endTime, DateTime.parse('2025-10-20T11:30:00Z'));
        expect(session.durationMinutes, 90);
        expect(session.pagesRead, 25);
        expect(session.lastReadPageNumber, 125);
        expect(session.createdAt, DateTime.parse('2025-10-20T11:30:00Z'));
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final session = ReadingSessionDto(
          id: 'a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
          userId: 'user-uuid-1234-5678',
          bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
          startTime: DateTime.parse('2025-10-20T10:00:00Z'),
          endTime: DateTime.parse('2025-10-20T11:30:00Z'),
          durationMinutes: 90,
          pagesRead: 25,
          lastReadPageNumber: 125,
          createdAt: DateTime.parse('2025-10-20T11:30:00Z'),
        );

        // Act
        final json = session.toJson();

        // Assert
        expect(json['id'], 'a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d');
        expect(json['user_id'], 'user-uuid-1234-5678');
        expect(json['book_id'], 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
        expect(json['start_time'], '2025-10-20T10:00:00.000Z');
        expect(json['end_time'], '2025-10-20T11:30:00.000Z');
        expect(json['duration_minutes'], 90);
        expect(json['pages_read'], 25);
        expect(json['last_read_page_number'], 125);
        expect(json['created_at'], '2025-10-20T11:30:00.000Z');
      });

      test('should handle round-trip JSON serialization', () {
        // Arrange
        final original = ReadingSessionDto(
          id: 'test-session-id',
          userId: 'test-user-id',
          bookId: 'test-book-id',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 11, 30, 0),
          durationMinutes: 90,
          pagesRead: 25,
          lastReadPageNumber: 125,
          createdAt: DateTime.utc(2025, 10, 20, 11, 30, 0),
        );

        // Act
        final json = original.toJson();
        final deserialized = ReadingSessionDto.fromJson(json);

        // Assert
        expect(deserialized.id, original.id);
        expect(deserialized.userId, original.userId);
        expect(deserialized.bookId, original.bookId);
        expect(deserialized.startTime, original.startTime);
        expect(deserialized.endTime, original.endTime);
        expect(deserialized.durationMinutes, original.durationMinutes);
        expect(deserialized.pagesRead, original.pagesRead);
        expect(deserialized.lastReadPageNumber, original.lastReadPageNumber);
        expect(deserialized.createdAt, original.createdAt);
      });
    });

    group('Entity conversion -', () {
      test('should create from ReadingSessions entity', () {
        // Arrange
        final entity = ReadingSessions(
          id: 'session-entity-id',
          userId: 'user-entity-id',
          bookId: 'book-entity-id',
          startTime: DateTime.parse('2025-10-20T10:00:00Z'),
          endTime: DateTime.parse('2025-10-20T11:00:00Z'),
          durationMinutes: 60,
          pagesRead: 20,
          lastReadPageNumber: 100,
          createdAt: DateTime.parse('2025-10-20T11:00:00Z'),
        );

        // Act
        final dto = ReadingSessionDto.fromEntity(entity);

        // Assert
        expect(dto.id, entity.id);
        expect(dto.userId, entity.userId);
        expect(dto.bookId, entity.bookId);
        expect(dto.startTime, entity.startTime);
        expect(dto.endTime, entity.endTime);
        expect(dto.durationMinutes, entity.durationMinutes);
        expect(dto.pagesRead, entity.pagesRead);
        expect(dto.lastReadPageNumber, entity.lastReadPageNumber);
        expect(dto.createdAt, entity.createdAt);
      });
    });

    group('Business rules -', () {
      test('should handle short reading session (1 minute)', () {
        // Arrange
        final json = {
          'id': 'short-session-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T10:01:00Z',
          'duration_minutes': 1,
          'pages_read': 1,
          'last_read_page_number': 51,
          'created_at': '2025-10-20T10:01:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.durationMinutes, 1);
        expect(session.pagesRead, 1);
      });

      test('should handle long reading session (several hours)', () {
        // Arrange
        final json = {
          'id': 'long-session-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T15:30:00Z',
          'duration_minutes': 330,
          'pages_read': 150,
          'last_read_page_number': 300,
          'created_at': '2025-10-20T15:30:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.durationMinutes, 330);
        expect(session.pagesRead, 150);
      });

      test('should handle zero pages read', () {
        // Arrange - session where user returned to previous page
        final json = {
          'id': 'zero-pages-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T10:30:00Z',
          'duration_minutes': 30,
          'pages_read': 0,
          'last_read_page_number': 100,
          'created_at': '2025-10-20T10:30:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.pagesRead, 0);
        expect(session.lastReadPageNumber, 100);
      });

      test('should handle large page numbers (e.g., 10000 pages)', () {
        // Arrange
        final json = {
          'id': 'large-book-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T11:00:00Z',
          'duration_minutes': 60,
          'pages_read': 50,
          'last_read_page_number': 9950,
          'created_at': '2025-10-20T11:00:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.lastReadPageNumber, 9950);
      });
    });

    group('Date/Time handling -', () {
      test('should preserve UTC timezone in dates', () {
        // Arrange
        final utcDate = DateTime.utc(2025, 10, 20, 14, 30, 45);
        final session = ReadingSessionDto(
          id: 'tz-test-id',
          userId: 'user-id',
          bookId: 'book-id',
          startTime: utcDate,
          endTime: utcDate.add(const Duration(hours: 1)),
          durationMinutes: 60,
          pagesRead: 20,
          lastReadPageNumber: 120,
          createdAt: utcDate.add(const Duration(hours: 1)),
        );

        // Act
        final json = session.toJson();
        final deserialized = ReadingSessionDto.fromJson(json);

        // Assert
        expect(deserialized.startTime.isUtc, isTrue);
        expect(deserialized.endTime.isUtc, isTrue);
        expect(deserialized.createdAt.isUtc, isTrue);
        expect(
          deserialized.startTime.difference(utcDate).inMilliseconds,
          equals(0),
        );
      });

      test('should handle datetime with millisecond precision', () {
        // Arrange
        final preciseTime = DateTime.utc(2025, 10, 20, 14, 30, 45, 123);
        final session = ReadingSessionDto(
          id: 'precise-id',
          userId: 'user-id',
          bookId: 'book-id',
          startTime: preciseTime,
          endTime: preciseTime.add(const Duration(minutes: 30)),
          durationMinutes: 30,
          pagesRead: 15,
          lastReadPageNumber: 115,
          createdAt: preciseTime.add(const Duration(minutes: 30)),
        );

        // Act
        final json = session.toJson();
        final deserialized = ReadingSessionDto.fromJson(json);

        // Assert - Millisecond precision should be preserved
        expect(
          deserialized.startTime.millisecondsSinceEpoch,
          preciseTime.millisecondsSinceEpoch,
        );
      });

      test('should handle sessions spanning midnight', () {
        // Arrange
        final json = {
          'id': 'midnight-session-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T23:30:00Z',
          'end_time': '2025-10-21T00:30:00Z',
          'duration_minutes': 60,
          'pages_read': 30,
          'last_read_page_number': 180,
          'created_at': '2025-10-21T00:30:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.startTime.day, 20);
        expect(session.endTime.day, 21);
        expect(session.durationMinutes, 60);
      });
    });

    group('Edge cases -', () {
      test('should handle sessions with same start and end page', () {
        // Arrange - re-reading same page
        final json = {
          'id': 'reread-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T10:15:00Z',
          'duration_minutes': 15,
          'pages_read': 0,
          'last_read_page_number': 75,
          'created_at': '2025-10-20T10:15:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.pagesRead, 0);
        expect(session.durationMinutes, 15);
      });

      test('should handle first page of a book', () {
        // Arrange
        final json = {
          'id': 'first-page-id',
          'user_id': 'user-id',
          'book_id': 'book-id',
          'start_time': '2025-10-20T10:00:00Z',
          'end_time': '2025-10-20T10:05:00Z',
          'duration_minutes': 5,
          'pages_read': 1,
          'last_read_page_number': 1,
          'created_at': '2025-10-20T10:05:00Z',
        };

        // Act
        final session = ReadingSessionDto.fromJson(json);

        // Assert
        expect(session.lastReadPageNumber, 1);
        expect(session.pagesRead, 1);
      });
    });
  });

  group('EndReadingSessionDto -', () {
    group('Request JSON formatting -', () {
      test('should format toRequestJson correctly for RPC call', () {
        // Arrange
        final dto = EndReadingSessionDto(
          bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 11, 30, 0),
          lastReadPage: 150,
        );

        // Act
        final json = dto.toRequestJson();

        // Assert
        expect(json['p_book_id'], 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
        expect(json['p_start_time'], '2025-10-20T10:00:00.000Z');
        expect(json['p_end_time'], '2025-10-20T11:30:00.000Z');
        expect(json['p_last_read_page'], 150);
      });

      test('should convert datetime to UTC ISO8601 string', () {
        // Arrange - Create DTO with local time
        final localStart = DateTime(2025, 10, 20, 12, 0, 0);
        final localEnd = DateTime(2025, 10, 20, 13, 0, 0);

        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: localStart,
          endTime: localEnd,
          lastReadPage: 100,
        );

        // Act
        final json = dto.toRequestJson();

        // Assert - Times should be converted to UTC
        expect(json['p_start_time'], contains('Z'));
        expect(json['p_end_time'], contains('Z'));
        expect(json['p_start_time'], isA<String>());
        expect(json['p_end_time'], isA<String>());
      });

      test('should handle parameter naming for RPC function', () {
        // Arrange
        final dto = EndReadingSessionDto(
          bookId: 'test-book-id',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 10, 30, 0),
          lastReadPage: 50,
        );

        // Act
        final json = dto.toRequestJson();

        // Assert - Should have exact RPC parameter names
        expect(json.containsKey('p_book_id'), isTrue);
        expect(json.containsKey('p_start_time'), isTrue);
        expect(json.containsKey('p_end_time'), isTrue);
        expect(json.containsKey('p_last_read_page'), isTrue);
        expect(json.length, 4); // No extra fields
      });
    });

    group('Field validation -', () {
      test('should accept valid DTO with all fields', () {
        // Arrange & Act
        final dto = EndReadingSessionDto(
          bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 11, 0, 0),
          lastReadPage: 100,
        );

        // Assert
        expect(dto.bookId, 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c');
        expect(dto.startTime, DateTime.utc(2025, 10, 20, 10, 0, 0));
        expect(dto.endTime, DateTime.utc(2025, 10, 20, 11, 0, 0));
        expect(dto.lastReadPage, 100);
      });

      test('should accept minimal time difference (1 second)', () {
        // Arrange
        final start = DateTime.utc(2025, 10, 20, 10, 0, 0);
        final end = start.add(const Duration(seconds: 1));

        // Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: start,
          endTime: end,
          lastReadPage: 100,
        );

        // Assert
        expect(dto.endTime.difference(dto.startTime).inSeconds, 1);
      });

      test('should accept very large lastReadPage value', () {
        // Arrange & Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 11, 0, 0),
          lastReadPage: 99999,
        );

        // Assert
        expect(dto.lastReadPage, 99999);
      });

      test('should accept single page read', () {
        // Arrange & Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 10, 5, 0),
          lastReadPage: 1,
        );

        // Assert
        expect(dto.lastReadPage, 1);
      });
    });

    group('Time handling -', () {
      test('should preserve exact datetime values', () {
        // Arrange
        final startTime = DateTime.utc(2025, 10, 20, 14, 35, 42, 123);
        final endTime = DateTime.utc(2025, 10, 20, 15, 15, 23, 456);

        // Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: startTime,
          endTime: endTime,
          lastReadPage: 75,
        );

        // Assert
        expect(dto.startTime, startTime);
        expect(dto.endTime, endTime);
      });

      test('should handle sessions spanning multiple hours', () {
        // Arrange
        final start = DateTime.utc(2025, 10, 20, 9, 0, 0);
        final end = DateTime.utc(2025, 10, 20, 14, 30, 0);

        // Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: start,
          endTime: end,
          lastReadPage: 250,
        );

        // Assert
        final duration = dto.endTime.difference(dto.startTime);
        expect(duration.inHours, 5);
        expect(duration.inMinutes, 330);
      });

      test('should handle sessions starting at midnight', () {
        // Arrange
        final start = DateTime.utc(2025, 10, 20, 0, 0, 0);
        final end = DateTime.utc(2025, 10, 20, 1, 0, 0);

        // Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: start,
          endTime: end,
          lastReadPage: 30,
        );

        // Assert
        expect(dto.startTime.hour, 0);
        expect(dto.startTime.minute, 0);
      });
    });

    group('Round-trip conversion -', () {
      test('should maintain data integrity through JSON conversion', () {
        // Arrange
        final originalDto = EndReadingSessionDto(
          bookId: 'round-trip-book-id',
          startTime: DateTime.utc(2025, 10, 20, 10, 30, 45),
          endTime: DateTime.utc(2025, 10, 20, 11, 45, 30),
          lastReadPage: 175,
        );

        // Act
        final json = originalDto.toRequestJson();

        // Assert - Verify all data is present in JSON
        expect(json['p_book_id'], originalDto.bookId);
        expect(json['p_last_read_page'], originalDto.lastReadPage);

        // Times should be ISO8601 strings in UTC
        final parsedStart = DateTime.parse(json['p_start_time'] as String);
        final parsedEnd = DateTime.parse(json['p_end_time'] as String);

        expect(parsedStart.isUtc, isTrue);
        expect(parsedEnd.isUtc, isTrue);
        expect(parsedStart, originalDto.startTime);
        expect(parsedEnd, originalDto.endTime);
      });
    });

    group('Edge cases -', () {
      test('should handle finishing a book (last page)', () {
        // Arrange
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: DateTime.utc(2025, 10, 20, 16, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 17, 30, 0),
          lastReadPage: 500, // Assuming book has 500 pages
        );

        // Act
        final json = dto.toRequestJson();

        // Assert
        expect(json['p_last_read_page'], 500);
      });

      test('should handle very short reading session', () {
        // Arrange - 30 seconds session
        final start = DateTime.utc(2025, 10, 20, 10, 0, 0);
        final end = start.add(const Duration(seconds: 30));

        // Act
        final dto = EndReadingSessionDto(
          bookId: 'book-id',
          startTime: start,
          endTime: end,
          lastReadPage: 42,
        );

        // Assert
        expect(dto.endTime.difference(dto.startTime).inSeconds, 30);
      });

      test('should handle UUID with different cases', () {
        // Arrange - UUIDs can be uppercase, lowercase, or mixed
        final mixedCaseUuid = 'C3E4B5a6-3B2A-4f1e-8b3d-2C1A1B0E9D8C';

        // Act
        final dto = EndReadingSessionDto(
          bookId: mixedCaseUuid,
          startTime: DateTime.utc(2025, 10, 20, 10, 0, 0),
          endTime: DateTime.utc(2025, 10, 20, 10, 30, 0),
          lastReadPage: 50,
        );

        // Assert
        expect(dto.bookId, mixedCaseUuid);
        expect(dto.toRequestJson()['p_book_id'], mixedCaseUuid);
      });
    });
  });

  group('Integration scenarios -', () {
    test('should handle typical reading session workflow', () {
      // Arrange - User reads for 45 minutes, advances 22 pages
      final endDto = EndReadingSessionDto(
        bookId: 'workflow-book-id',
        startTime: DateTime.utc(2025, 10, 21, 9, 0, 0),
        endTime: DateTime.utc(2025, 10, 21, 9, 45, 0),
        lastReadPage: 122,
      );

      // Act - Simulate API call
      final requestJson = endDto.toRequestJson();

      // Simulate API response
      final responseJson = {
        'id': 'new-session-id',
        'user_id': 'user-id',
        'book_id': endDto.bookId,
        'start_time': requestJson['p_start_time'],
        'end_time': requestJson['p_end_time'],
        'duration_minutes': 45,
        'pages_read': 22,
        'last_read_page_number': endDto.lastReadPage,
        'created_at': requestJson['p_end_time'],
      };

      final resultDto = ReadingSessionDto.fromJson(responseJson);

      // Assert
      expect(resultDto.bookId, endDto.bookId);
      expect(resultDto.lastReadPageNumber, endDto.lastReadPage);
      expect(resultDto.durationMinutes, 45);
      expect(resultDto.pagesRead, 22);
    });

    test('should handle marathon reading session', () {
      // Arrange - 6 hour reading session
      final endDto = EndReadingSessionDto(
        bookId: 'marathon-book-id',
        startTime: DateTime.utc(2025, 10, 21, 10, 0, 0),
        endTime: DateTime.utc(2025, 10, 21, 16, 0, 0),
        lastReadPage: 350,
      );

      // Act
      final json = endDto.toRequestJson();

      // Assert
      final duration = endDto.endTime.difference(endDto.startTime);
      expect(duration.inHours, 6);
      expect(duration.inMinutes, 360);
      expect(json['p_last_read_page'], 350);
    });

    test('should handle starting a new book (page 1)', () {
      // Arrange
      final endDto = EndReadingSessionDto(
        bookId: 'new-book-id',
        startTime: DateTime.utc(2025, 10, 21, 20, 0, 0),
        endTime: DateTime.utc(2025, 10, 21, 20, 15, 0),
        lastReadPage: 10,
      );

      // Act
      final json = endDto.toRequestJson();

      // Assert
      expect(json['p_last_read_page'], 10);
    });
  });
}

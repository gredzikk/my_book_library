import 'package:flutter_test/flutter_test.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/models/database_types.dart';

/// Unit tests for BookService-related DTOs and validation logic
///
/// These tests verify that:
/// - DTOs correctly serialize/deserialize from/to JSON
/// - Required fields are properly handled
/// - Optional fields work correctly
/// - toRequestJson methods filter null values properly
/// - Business rules are enforced in DTOs
///
/// Test coverage includes:
/// - BookListItemDto: JSON conversion, entity conversion
/// - BookDetailDto: Same as BookListItemDto (typedef)
/// - CreateBookDto: JSON conversion, request formatting
/// - UpdateBookDto: Partial updates, null handling
/// - Edge cases and validation
///
/// According to TDD principles:
/// - Test all possible cases including edge cases
/// - Use meaningful test names that describe what is being tested
/// - Follow the testing pyramid: focus on unit tests
void main() {
  group('BookListItemDto', () {
    test('should create from JSON correctly with all fields', () {
      // Arrange
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'user_id': 'user-123',
        'genre_id': '12345678-1234-1234-1234-123456789abc',
        'title': 'Hobbit',
        'author': 'J.R.R. Tolkien',
        'page_count': 310,
        'cover_url': 'https://example.com/cover.jpg',
        'isbn': '978-3-16-148410-0',
        'publisher': 'Allen & Unwin',
        'publication_year': 1937,
        'status': 'finished',
        'last_read_page_number': 310,
        'created_at': '2025-10-10T12:00:00Z',
        'updated_at': '2025-10-20T15:30:00Z',
        'genres': {'name': 'Fantastyka'},
      };

      // Act
      final book = BookListItemDto.fromJson(json);

      // Assert
      expect(book.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(book.userId, 'user-123');
      expect(book.genreId, '12345678-1234-1234-1234-123456789abc');
      expect(book.title, 'Hobbit');
      expect(book.author, 'J.R.R. Tolkien');
      expect(book.pageCount, 310);
      expect(book.coverUrl, 'https://example.com/cover.jpg');
      expect(book.isbn, '978-3-16-148410-0');
      expect(book.publisher, 'Allen & Unwin');
      expect(book.publicationYear, 1937);
      expect(book.status, BookStatus.finished);
      expect(book.lastReadPageNumber, 310);
      expect(book.genres?.name, 'Fantastyka');
    });

    test('should create from JSON correctly with minimal fields', () {
      // Arrange
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'user_id': 'user-123',
        'title': 'Test Book',
        'author': 'Test Author',
        'page_count': 200,
        'status': 'unread',
        'last_read_page_number': 0,
        'created_at': '2025-10-10T12:00:00Z',
        'updated_at': '2025-10-10T12:00:00Z',
      };

      // Act
      final book = BookListItemDto.fromJson(json);

      // Assert
      expect(book.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.pageCount, 200);
      expect(book.status, BookStatus.unread);
      expect(book.lastReadPageNumber, 0);
      expect(book.genreId, isNull);
      expect(book.coverUrl, isNull);
      expect(book.isbn, isNull);
      expect(book.publisher, isNull);
      expect(book.publicationYear, isNull);
      expect(book.genres, isNull);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final book = BookListItemDto(
        id: '550e8400-e29b-41d4-a716-446655440000',
        userId: 'user-123',
        genreId: '12345678-1234-1234-1234-123456789abc',
        title: 'Test Book',
        author: 'Test Author',
        pageCount: 300,
        coverUrl: 'https://example.com/cover.jpg',
        isbn: '978-3-16-148410-0',
        publisher: 'Test Publisher',
        publicationYear: 2024,
        status: BookStatus.in_progress,
        lastReadPageNumber: 150,
        createdAt: DateTime.parse('2025-10-10T12:00:00Z'),
        updatedAt: DateTime.parse('2025-10-20T15:30:00Z'),
        genres: const GenreEmbeddedDto(name: 'Thriller'),
      );

      // Act
      final json = book.toJson();

      // Assert
      expect(json['id'], '550e8400-e29b-41d4-a716-446655440000');
      expect(json['user_id'], 'user-123');
      expect(json['genre_id'], '12345678-1234-1234-1234-123456789abc');
      expect(json['title'], 'Test Book');
      expect(json['author'], 'Test Author');
      expect(json['page_count'], 300);
      expect(json['cover_url'], 'https://example.com/cover.jpg');
      expect(json['isbn'], '978-3-16-148410-0');
      expect(json['publisher'], 'Test Publisher');
      expect(json['publication_year'], 2024);
      expect(json['status'], 'in_progress');
      expect(json['last_read_page_number'], 150);
      // Genre is embedded as DTO object, not directly serialized to Map in BookListItemDto.toJson()
      expect(book.genres?.name, 'Thriller');
    });

    test('should handle all BookStatus enum values', () {
      final statuses = [
        BookStatus.unread,
        BookStatus.in_progress,
        BookStatus.finished,
        BookStatus.abandoned,
        BookStatus.planned,
      ];

      for (final status in statuses) {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'user_id': 'user-123',
          'title': 'Test',
          'author': 'Author',
          'page_count': 100,
          'status': status.name,
          'last_read_page_number': 0,
          'created_at': '2025-10-10T12:00:00Z',
          'updated_at': '2025-10-10T12:00:00Z',
        };

        final book = BookListItemDto.fromJson(json);
        expect(book.status, status);
      }
    });

    test('should preserve datetime precision in serialization', () {
      final now = DateTime.now().toUtc();
      final book = BookListItemDto(
        id: 'test-id',
        userId: 'user-id',
        title: 'Test',
        author: 'Author',
        pageCount: 100,
        status: BookStatus.unread,
        lastReadPageNumber: 0,
        createdAt: now,
        updatedAt: now,
      );

      final json = book.toJson();
      final deserialized = BookListItemDto.fromJson(json);

      // Datetimes should be equal (within millisecond precision)
      expect(deserialized.createdAt.difference(now).inMilliseconds, equals(0));
      expect(deserialized.updatedAt.difference(now).inMilliseconds, equals(0));
    });

    test('should handle book with null genre', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'user_id': 'user-123',
        'title': 'No Genre Book',
        'author': 'Author',
        'page_count': 100,
        'status': 'unread',
        'last_read_page_number': 0,
        'created_at': '2025-10-10T12:00:00Z',
        'updated_at': '2025-10-10T12:00:00Z',
        'genre_id': null,
        'genres': null,
      };

      final book = BookListItemDto.fromJson(json);
      expect(book.genreId, isNull);
      expect(book.genres, isNull);
    });
  });

  group('CreateBookDto', () {
    test('should create DTO with required fields only', () {
      // Arrange & Act
      const dto = CreateBookDto(
        title: 'New Book',
        author: 'New Author',
        pageCount: 250,
      );

      // Assert
      expect(dto.title, 'New Book');
      expect(dto.author, 'New Author');
      expect(dto.pageCount, 250);
      expect(dto.genreId, isNull);
      expect(dto.coverUrl, isNull);
      expect(dto.isbn, isNull);
      expect(dto.publisher, isNull);
      expect(dto.publicationYear, isNull);
    });

    test('should create DTO with all fields', () {
      // Arrange & Act
      const dto = CreateBookDto(
        title: 'Complete Book',
        author: 'Complete Author',
        pageCount: 400,
        genreId: '12345678-1234-1234-1234-123456789abc',
        coverUrl: 'https://example.com/cover.jpg',
        isbn: '978-3-16-148410-0',
        publisher: 'Test Publisher',
        publicationYear: 2024,
      );

      // Assert
      expect(dto.title, 'Complete Book');
      expect(dto.author, 'Complete Author');
      expect(dto.pageCount, 400);
      expect(dto.genreId, '12345678-1234-1234-1234-123456789abc');
      expect(dto.coverUrl, 'https://example.com/cover.jpg');
      expect(dto.isbn, '978-3-16-148410-0');
      expect(dto.publisher, 'Test Publisher');
      expect(dto.publicationYear, 2024);
    });

    test('should convert to request JSON with only required fields', () {
      // Arrange
      const dto = CreateBookDto(
        title: 'Minimal Book',
        author: 'Minimal Author',
        pageCount: 150,
      );

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['title'], 'Minimal Book');
      expect(json['author'], 'Minimal Author');
      expect(json['page_count'], 150);
      expect(json.containsKey('genre_id'), isFalse);
      expect(json.containsKey('cover_url'), isFalse);
      expect(json.containsKey('isbn'), isFalse);
      expect(json.containsKey('publisher'), isFalse);
      expect(json.containsKey('publication_year'), isFalse);
    });

    test('should convert to request JSON with all fields', () {
      // Arrange
      const dto = CreateBookDto(
        title: 'Full Book',
        author: 'Full Author',
        pageCount: 500,
        genreId: '12345678-1234-1234-1234-123456789abc',
        coverUrl: 'https://example.com/cover.jpg',
        isbn: '978-3-16-148410-0',
        publisher: 'Full Publisher',
        publicationYear: 2023,
      );

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['title'], 'Full Book');
      expect(json['author'], 'Full Author');
      expect(json['page_count'], 500);
      expect(json['genre_id'], '12345678-1234-1234-1234-123456789abc');
      expect(json['cover_url'], 'https://example.com/cover.jpg');
      expect(json['isbn'], '978-3-16-148410-0');
      expect(json['publisher'], 'Full Publisher');
      expect(json['publication_year'], 2023);
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      const dto = CreateBookDto(
        title: 'Serialization Test',
        author: 'Test Author',
        pageCount: 300,
        genreId: '12345678-1234-1234-1234-123456789abc',
        publicationYear: 2024,
      );

      // Act
      final json = dto.toJson();
      final deserialized = CreateBookDto.fromJson(json);

      // Assert
      expect(deserialized.title, dto.title);
      expect(deserialized.author, dto.author);
      expect(deserialized.pageCount, dto.pageCount);
      expect(deserialized.genreId, dto.genreId);
      expect(deserialized.publicationYear, dto.publicationYear);
    });

    test('should handle empty strings in optional fields', () {
      // Arrange
      const dto = CreateBookDto(
        title: 'Book',
        author: 'Author',
        pageCount: 100,
        isbn: '',
        publisher: '',
        coverUrl: '',
      );

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['isbn'], '');
      expect(json['publisher'], '');
      expect(json['cover_url'], '');
    });
  });

  group('UpdateBookDto', () {
    test('should create empty DTO', () {
      // Arrange & Act
      const dto = UpdateBookDto();

      // Assert
      expect(dto.title, isNull);
      expect(dto.author, isNull);
      expect(dto.pageCount, isNull);
      expect(dto.genreId, isNull);
      expect(dto.coverUrl, isNull);
      expect(dto.isbn, isNull);
      expect(dto.publisher, isNull);
      expect(dto.publicationYear, isNull);
      expect(dto.status, isNull);
      expect(dto.lastReadPageNumber, isNull);
    });

    test('should create DTO with single field', () {
      // Arrange & Act
      const dto = UpdateBookDto(title: 'Updated Title');

      // Assert
      expect(dto.title, 'Updated Title');
      expect(dto.author, isNull);
      expect(dto.pageCount, isNull);
    });

    test('should create DTO with multiple fields', () {
      // Arrange & Act
      const dto = UpdateBookDto(
        title: 'Updated Title',
        author: 'Updated Author',
        pageCount: 350,
        status: BookStatus.finished,
        lastReadPageNumber: 350,
      );

      // Assert
      expect(dto.title, 'Updated Title');
      expect(dto.author, 'Updated Author');
      expect(dto.pageCount, 350);
      expect(dto.status, BookStatus.finished);
      expect(dto.lastReadPageNumber, 350);
    });

    test('should convert empty DTO to empty request JSON', () {
      // Arrange
      const dto = UpdateBookDto();

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json, isEmpty);
    });

    test('should convert partial DTO to request JSON with only set fields', () {
      // Arrange
      const dto = UpdateBookDto(
        title: 'Partial Update',
        status: BookStatus.in_progress,
      );

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['title'], 'Partial Update');
      expect(json['status'], 'in_progress');
      expect(json.length, 2);
      expect(json.containsKey('author'), isFalse);
      expect(json.containsKey('page_count'), isFalse);
    });

    test('should handle clearing optional fields with empty strings', () {
      // Arrange
      const dto = UpdateBookDto(coverUrl: '', isbn: '', publisher: '');

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['cover_url'], isNull);
      expect(json['isbn'], isNull);
      expect(json['publisher'], isNull);
    });

    test('should handle status enum conversion', () {
      // Arrange
      const dto = UpdateBookDto(status: BookStatus.abandoned);

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json['status'], 'abandoned');
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      const dto = UpdateBookDto(
        title: 'Serialization Test',
        author: 'Test Author',
        pageCount: 300,
        status: BookStatus.finished,
        lastReadPageNumber: 300,
      );

      // Act
      final json = dto.toJson();
      final deserialized = UpdateBookDto.fromJson(json);

      // Assert
      expect(deserialized.title, dto.title);
      expect(deserialized.author, dto.author);
      expect(deserialized.pageCount, dto.pageCount);
      expect(deserialized.status, dto.status);
      expect(deserialized.lastReadPageNumber, dto.lastReadPageNumber);
    });

    test('should handle all status updates', () {
      final statuses = [
        BookStatus.unread,
        BookStatus.in_progress,
        BookStatus.finished,
        BookStatus.abandoned,
        BookStatus.planned,
      ];

      for (final status in statuses) {
        final dto = UpdateBookDto(status: status);
        final json = dto.toRequestJson();

        expect(json['status'], status.name);
      }
    });

    test('should update only title without affecting other fields', () {
      // Arrange
      const dto = UpdateBookDto(title: 'New Title Only');

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json.length, 1);
      expect(json['title'], 'New Title Only');
    });

    test('should update only status without affecting other fields', () {
      // Arrange
      const dto = UpdateBookDto(status: BookStatus.finished);

      // Act
      final json = dto.toRequestJson();

      // Assert
      expect(json.length, 1);
      expect(json['status'], 'finished');
    });

    test(
      'should update only last_read_page_number without affecting other fields',
      () {
        // Arrange
        const dto = UpdateBookDto(lastReadPageNumber: 150);

        // Act
        final json = dto.toRequestJson();

        // Assert
        expect(json.length, 1);
        expect(json['last_read_page_number'], 150);
      },
    );
  });

  group('GenreEmbeddedDto', () {
    test('should create from JSON correctly', () {
      // Arrange
      final json = {'name': 'Horror'};

      // Act
      final genre = GenreEmbeddedDto.fromJson(json);

      // Assert
      expect(genre.name, 'Horror');
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const genre = GenreEmbeddedDto(name: 'Kryminał');

      // Act
      final json = genre.toJson();

      // Assert
      expect(json['name'], 'Kryminał');
    });

    test('should handle all MVP genre names', () {
      final mvpGenres = [
        'Biografia',
        'Fantastyka',
        'Horror',
        'Kryminał',
        'Literatura faktu',
        'Literatura piękna',
        'Poradnik',
        'Przygodowa',
        'Romans',
        'Thriller',
        'Inne',
      ];

      for (final name in mvpGenres) {
        final genre = GenreEmbeddedDto(name: name);
        expect(genre.name, name);
        expect(genre.toJson()['name'], name);
      }
    });

    test('should handle genre name with special characters', () {
      const genre = GenreEmbeddedDto(name: 'Science Fiction & Fantasy');
      expect(genre.name, 'Science Fiction & Fantasy');
      expect(genre.toJson()['name'], 'Science Fiction & Fantasy');
    });
  });

  group('Edge Cases and Business Rules', () {
    test('should handle very long titles correctly', () {
      final longTitle = 'A' * 500;
      final dto = CreateBookDto(
        title: longTitle,
        author: 'Author',
        pageCount: 100,
      );

      expect(dto.title, longTitle);
      expect(dto.toRequestJson()['title'], longTitle);
    });

    test('should handle special characters in strings', () {
      const dto = CreateBookDto(
        title: 'Book with "quotes" and \'apostrophes\'',
        author: 'O\'Brien & Co.',
        pageCount: 200,
        publisher: 'Test & Sons',
      );

      final json = dto.toRequestJson();
      expect(json['title'], contains('"quotes"'));
      expect(json['author'], contains('O\'Brien'));
      expect(json['publisher'], contains('&'));
    });

    test('should handle very large page counts', () {
      const dto = CreateBookDto(
        title: 'Encyclopedia',
        author: 'Various',
        pageCount: 10000,
      );

      expect(dto.pageCount, 10000);
      expect(dto.toRequestJson()['page_count'], 10000);
    });

    test('should handle zero page count', () {
      const dto = CreateBookDto(
        title: 'Empty Book',
        author: 'No One',
        pageCount: 0,
      );

      expect(dto.pageCount, 0);
      expect(dto.toRequestJson()['page_count'], 0);
    });

    test('should handle progress at page 0 (start of book)', () {
      const dto = UpdateBookDto(
        status: BookStatus.in_progress,
        lastReadPageNumber: 0,
      );

      final json = dto.toRequestJson();
      expect(json['status'], 'in_progress');
      expect(json['last_read_page_number'], 0);
    });

    test('should handle finishing book at exact page count', () {
      const dto = UpdateBookDto(
        status: BookStatus.finished,
        lastReadPageNumber: 300,
      );

      final json = dto.toRequestJson();
      expect(json['status'], 'finished');
      expect(json['last_read_page_number'], 300);
    });

    test('should handle ISBN with hyphens', () {
      const dto = CreateBookDto(
        title: 'ISBN Test',
        author: 'Author',
        pageCount: 100,
        isbn: '978-3-16-148410-0',
      );

      expect(dto.isbn, '978-3-16-148410-0');
      expect(dto.toRequestJson()['isbn'], '978-3-16-148410-0');
    });

    test('should handle ISBN without hyphens', () {
      const dto = CreateBookDto(
        title: 'ISBN Test',
        author: 'Author',
        pageCount: 100,
        isbn: '9783161484100',
      );

      expect(dto.isbn, '9783161484100');
      expect(dto.toRequestJson()['isbn'], '9783161484100');
    });

    test('should handle very old publication years', () {
      const dto = CreateBookDto(
        title: 'Ancient Book',
        author: 'Historical Author',
        pageCount: 50,
        publicationYear: 1455, // Gutenberg Bible
      );

      expect(dto.publicationYear, 1455);
      expect(dto.toRequestJson()['publication_year'], 1455);
    });

    test('should handle future publication years', () {
      const dto = CreateBookDto(
        title: 'Upcoming Book',
        author: 'Modern Author',
        pageCount: 300,
        publicationYear: 2026,
      );

      expect(dto.publicationYear, 2026);
      expect(dto.toRequestJson()['publication_year'], 2026);
    });

    test('should handle URL with query parameters in coverUrl', () {
      const dto = CreateBookDto(
        title: 'Book with Complex Cover URL',
        author: 'Author',
        pageCount: 100,
        coverUrl: 'https://example.com/cover.jpg?size=large&format=webp',
      );

      expect(dto.coverUrl, contains('?'));
      expect(dto.coverUrl, contains('&'));
    });

    test(
      'should handle changing status from finished to in_progress (re-reading)',
      () {
        const dto = UpdateBookDto(
          status: BookStatus.in_progress,
          lastReadPageNumber: 0,
        );

        final json = dto.toRequestJson();
        expect(json['status'], 'in_progress');
        expect(json['last_read_page_number'], 0);
      },
    );

    test('should handle changing status from in_progress to abandoned', () {
      const dto = UpdateBookDto(status: BookStatus.abandoned);

      final json = dto.toRequestJson();
      expect(json['status'], 'abandoned');
    });

    test('should handle Unicode characters in title', () {
      const dto = CreateBookDto(
        title: 'Książka po polsku 📚',
        author: 'Jan Kowalski',
        pageCount: 200,
      );

      expect(dto.title, 'Książka po polsku 📚');
      expect(dto.toRequestJson()['title'], 'Książka po polsku 📚');
    });

    test(
      'should handle multiple books with same title but different authors',
      () {
        const dto1 = CreateBookDto(
          title: 'Common Title',
          author: 'Author One',
          pageCount: 100,
        );
        const dto2 = CreateBookDto(
          title: 'Common Title',
          author: 'Author Two',
          pageCount: 200,
        );

        expect(dto1.title, dto2.title);
        expect(dto1.author, isNot(dto2.author));
      },
    );

    test('should handle updating book from planned to in_progress', () {
      const dto = UpdateBookDto(
        status: BookStatus.in_progress,
        lastReadPageNumber: 1,
      );

      final json = dto.toRequestJson();
      expect(json['status'], 'in_progress');
      expect(json['last_read_page_number'], 1);
    });

    test('should handle resetting book progress to start', () {
      const dto = UpdateBookDto(
        status: BookStatus.in_progress,
        lastReadPageNumber: 0,
      );

      final json = dto.toRequestJson();
      expect(json['status'], 'in_progress');
      expect(json['last_read_page_number'], 0);
    });

    test('should handle book with very long author name', () {
      final longAuthor = 'First Middle1 Middle2 Middle3 Last-Name Jr. PhD';
      final dto = CreateBookDto(
        title: 'Academic Book',
        author: longAuthor,
        pageCount: 500,
      );

      expect(dto.author, longAuthor);
    });

    test('should handle book with very long publisher name', () {
      final longPublisher =
          'International University Press and Academic Publishing House Ltd.';
      final dto = CreateBookDto(
        title: 'Book',
        author: 'Author',
        pageCount: 300,
        publisher: longPublisher,
      );

      expect(dto.publisher, longPublisher);
    });
  });
}

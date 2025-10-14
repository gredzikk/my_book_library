import 'package:flutter_test/flutter_test.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/models/database_types.dart';

/// Unit tests for Genre-related DTOs and models
///
/// These tests verify that:
/// - GenreDto correctly serializes/deserializes from JSON
/// - GenreDto correctly converts from database entities
/// - All required fields are properly handled
void main() {
  group('GenreDto', () {
    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'f1e2d3c4-b5a6-7890-1234-567890abcdef',
        'name': 'Fantastyka',
        'created_at': '2025-10-10T12:00:00Z',
      };

      // Act
      final genre = GenreDto.fromJson(json);

      // Assert
      expect(genre.id, 'f1e2d3c4-b5a6-7890-1234-567890abcdef');
      expect(genre.name, 'Fantastyka');
      expect(genre.createdAt, DateTime.parse('2025-10-10T12:00:00Z'));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final genre = GenreDto(
        id: 'f1e2d3c4-b5a6-7890-1234-567890abcdef',
        name: 'Fantastyka',
        createdAt: DateTime.parse('2025-10-10T12:00:00Z'),
      );

      // Act
      final json = genre.toJson();

      // Assert
      expect(json['id'], 'f1e2d3c4-b5a6-7890-1234-567890abcdef');
      expect(json['name'], 'Fantastyka');
      expect(json['created_at'], '2025-10-10T12:00:00.000Z');
    });

    test('should create from Genres entity', () {
      // Arrange
      final entity = Genres(
        id: 'a9b8c7d6-e5f4-a3b2-c1d0-e9f8a7b6c5d4',
        name: 'Kryminał',
        createdAt: DateTime.parse('2025-10-10T12:00:00Z'),
      );

      // Act
      final dto = GenreDto.fromEntity(entity);

      // Assert
      expect(dto.id, entity.id);
      expect(dto.name, entity.name);
      expect(dto.createdAt, entity.createdAt);
    });

    test('should handle all genre names from MVP', () {
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
        final genre = GenreDto(
          id: 'test-id-$name',
          name: name,
          createdAt: DateTime.now(),
        );

        expect(genre.name, name);
        expect(genre.toJson()['name'], name);
      }
    });

    test('should preserve datetime precision in serialization', () {
      final now = DateTime.now().toUtc();
      final genre = GenreDto(id: 'test-id', name: 'Test Genre', createdAt: now);

      final json = genre.toJson();
      final deserialized = GenreDto.fromJson(json);

      // Datetimes should be equal (within millisecond precision)
      expect(deserialized.createdAt.difference(now).inMilliseconds, equals(0));
    });
  });
}

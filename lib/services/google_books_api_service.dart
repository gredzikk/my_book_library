// lib/services/google_books_service.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/types.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';
  final String? apiKey; // Opcjonalne, ale zwiększa limity

  GoogleBooksService({this.apiKey});

  /// Pobiera informacje o książce na podstawie ISBN
  Future<GoogleBookResult?> fetchBookByISBN(String isbn) async {
    try {
      // Czyść ISBN z myślników i spacji
      final cleanIsbn = isbn.replaceAll(RegExp(r'[-\s]'), '');

      // Konstruuj URL z filtrem ISBN
      final url = Uri.parse(
        '$_baseUrl/volumes?q=isbn:$cleanIsbn${apiKey != null ? '&key=$apiKey' : ''}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['totalItems'] > 0) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          return GoogleBookResult.fromJson(volumeInfo);
        }
      }

      return null; // Nie znaleziono książki
    } catch (e) {
      // Loguj błąd
      print('Error fetching book from Google Books API: $e');
      return null;
    }
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
    final isbn13 = industryIdentifiers!.firstWhere(
      (id) => id.type == 'ISBN_13',
      orElse: () => null,
    );
    if (isbn13 != null) return isbn13.identifier;

    final isbn10 = industryIdentifiers!.firstWhere(
      (id) => id.type == 'ISBN_10',
      orElse: () => null,
    );
    return isbn10?.identifier;
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

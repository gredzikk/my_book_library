// lib/services/google_books_service.dart

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';
import '../models/types.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';
  final String? apiKey; // Opcjonalne, ale zwiększa limity
  final Logger _logger = Logger('GoogleBooksService');
  GoogleBooksService({this.apiKey});

  /// Pobiera informacje o książce na podstawie ISBN
  ///
  /// Uwaga: Niektóre książki w Google Books API mają niekompletne dane.
  /// W przypadku braku istotnych pól (okładka, wydawca, liczba stron),
  /// rozważ użycie manualnego wprowadzania danych.
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
          _logger.info('Google Books API response for ISBN $cleanIsbn');
          final result = GoogleBookResult.fromJson(volumeInfo);

          // Log what data we got
          final missingFields = <String>[];
          if (result.publisher == null) missingFields.add('publisher');
          if (result.pageCount == null || result.pageCount == 0) {
            missingFields.add('pageCount');
          }
          if (result.imageLinks?.thumbnail == null &&
              result.imageLinks?.smallThumbnail == null) {
            missingFields.add('cover image');
          }

          if (missingFields.isNotEmpty) {
            _logger.warning(
              'Book found but missing data: ${missingFields.join(", ")}. '
              'Title: "${result.title}", Authors: ${result.authors?.join(", ") ?? "Unknown"}',
            );
          } else {
            _logger.info(
              'Book found with complete data - Title: ${result.title}, '
              'Publisher: ${result.publisher}, PageCount: ${result.pageCount}',
            );
          }

          return result;
        }
      }

      return null; // Nie znaleziono książki
    } catch (e) {
      // Loguj błąd
      _logger.severe('Error fetching book from Google Books API: $e');
      return null;
    }
  }
}

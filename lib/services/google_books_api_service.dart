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

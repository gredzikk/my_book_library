import 'package:my_book_library/services/google_books_api_service.dart';
import 'package:my_book_library/models/types.dart';

/// Mock implementation of Google Books API Service for E2E tests
/// Returns predefined fixtures instead of making real API calls
class MockGoogleBooksService extends GoogleBooksService {
  /// Map of ISBN to mock book data
  static final Map<String, GoogleBookResult> _mockBooks = {
    '9780134685991': const GoogleBookResult(
      title: 'Effective Java',
      authors: ['Joshua Bloch'],
      publisher: 'Addison-Wesley',
      publishedDate: '2018',
      pageCount: 412,
      categories: ['Computers', 'Programming'],
      imageLinks: ImageLinks(
        thumbnail:
            'https://books.google.com/books/content?id=BIpDDwAAQBAJ&printsec=frontcover&img=1&zoom=1',
      ),
      industryIdentifiers: [
        IndustryIdentifier(type: 'ISBN_10', identifier: '0134685997'),
        IndustryIdentifier(type: 'ISBN_13', identifier: '9780134685991'),
      ],
    ),
    '9780132350884': const GoogleBookResult(
      title: 'Clean Code',
      authors: ['Robert C. Martin'],
      publisher: 'Prentice Hall',
      publishedDate: '2008',
      pageCount: 464,
      categories: ['Computers', 'Software Engineering'],
      imageLinks: ImageLinks(
        thumbnail:
            'https://books.google.com/books/content?id=hjEFCAAAQBAJ&printsec=frontcover&img=1&zoom=1',
      ),
      industryIdentifiers: [
        IndustryIdentifier(type: 'ISBN_10', identifier: '0132350882'),
        IndustryIdentifier(type: 'ISBN_13', identifier: '9780132350884'),
      ],
    ),
    '9780201633610': const GoogleBookResult(
      title: 'Design Patterns',
      authors: [
        'Erich Gamma',
        'Richard Helm',
        'Ralph Johnson',
        'John Vlissides',
      ],
      publisher: 'Addison-Wesley',
      publishedDate: '1994',
      pageCount: 395,
      categories: ['Computers', 'Software Engineering'],
      imageLinks: ImageLinks(
        thumbnail:
            'https://books.google.com/books/content?id=6oHuKQe3TjQC&printsec=frontcover&img=1&zoom=1',
      ),
      industryIdentifiers: [
        IndustryIdentifier(type: 'ISBN_10', identifier: '0201633612'),
        IndustryIdentifier(type: 'ISBN_13', identifier: '9780201633610'),
      ],
    ),
    // Test book with missing data
    '9999999999999': const GoogleBookResult(
      title: 'Test Book Without Details',
      authors: ['Unknown Author'],
      publisher: null,
      publishedDate: null,
      pageCount: null,
      categories: null,
      imageLinks: null,
      industryIdentifiers: null,
    ),
  };

  @override
  Future<GoogleBookResult?> fetchBookByISBN(String isbn) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Clean ISBN (remove hyphens, spaces)
    final cleanIsbn = isbn.replaceAll(RegExp(r'[-\s]'), '');

    // Check if we have mock data for this ISBN
    if (_mockBooks.containsKey(cleanIsbn)) {
      print('[MockGoogleBooksService] Returning mock data for ISBN: $isbn');
      return _mockBooks[cleanIsbn];
    }

    // ISBN not found
    print('[MockGoogleBooksService] No mock data for ISBN: $isbn');
    return null;
  }

  /// Add custom mock book for specific test scenarios
  static void addMockBook(String isbn, GoogleBookResult book) {
    _mockBooks[isbn] = book;
  }

  /// Clear custom mock books (useful in tearDown)
  static void clearCustomMocks() {
    // Keep only the default mocks, remove any added during tests
    _mockBooks.removeWhere(
      (key, value) =>
          key != '9780134685991' &&
          key != '9780132350884' &&
          key != '9780201633610' &&
          key != '9999999999999',
    );
  }
}

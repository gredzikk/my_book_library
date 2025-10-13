# API Endpoint Implementation Plan: List Books

## 1. Przegląd punktu końcowego

Endpoint **List Books** (`GET /rest/v1/books`) służy do pobierania listy książek należących do zalogowanego użytkownika. Jest to kluczowy endpoint do wyświetlania biblioteki użytkownika w aplikacji mobilnej.

### Kluczowe funkcjonalności:
- Pobieranie listy książek użytkownika z osadzoną nazwą gatunku
- Filtrowanie książek według statusu czytania (`unread`, `in_progress`, `finished`, `abandoned`, `planned`)
- Filtrowanie według gatunku literackiego
- Sortowanie według dowolnego pola (domyślnie tytuł)
- Paginacja wyników
- Automatyczne zabezpieczenie poprzez Row-Level Security (RLS)

### Kontekst techniczny:
Ten endpoint jest **automatycznie generowany przez Supabase** na podstawie schematu tabeli `books`. Implementacja polega na:
1. Konfiguracji RLS policies w bazie danych PostgreSQL
2. Stworzeniu serwisu po stronie klienta (Flutter) do komunikacji z API
3. Transformacji danych z formatu API do DTOs

## 2. Szczegóły żądania

### Metoda HTTP
- **GET**

### Struktura URL
```
GET /rest/v1/books
```

### Nagłówki (Headers)
| Nagłówek | Wymagany | Opis |
|----------|----------|------|
| `Authorization` | **TAK** | Bearer token JWT z Supabase Auth (format: `Bearer <jwt_token>`) |
| `apikey` | **TAK** | Klucz API Supabase (anon key) |
| `Content-Type` | NIE | `application/json` (opcjonalny dla GET) |

### Parametry zapytania (Query Parameters)

| Parametr | Typ | Wymagany | Opis | Przykład |
|----------|-----|----------|------|----------|
| `select` | String | NIE | Określa pola do zwrócenia, umożliwia osadzenie relacji | `*,genres(name)` |
| `status` | String | NIE | Filtruje książki według statusu | `eq.in_progress` |
| `genre_id` | UUID | NIE | Filtruje książki według ID gatunku | `eq.f1e2d3c4-b5a6-7890-1234-567890abcdef` |
| `order` | String | NIE | Sortowanie wyników | `title.asc`, `created_at.desc` |
| `limit` | Integer | NIE | Maksymalna liczba wyników (domyślnie: 10, max: 1000) | `20` |
| `offset` | Integer | NIE | Przesunięcie dla paginacji (domyślnie: 0) | `20` |

### Przykładowe żądania

**Przykład 1: Podstawowe zapytanie z osadzonym gatunkiem**
```
GET /rest/v1/books?select=*,genres(name)
Authorization: Bearer eyJhbGc...
apikey: eyJhbGc...
```

**Przykład 2: Filtrowanie według statusu**
```
GET /rest/v1/books?select=*,genres(name)&status=eq.in_progress&order=updated_at.desc
```

**Przykład 3: Paginacja**
```
GET /rest/v1/books?select=*,genres(name)&limit=20&offset=40&order=title.asc
```

**Przykład 4: Filtrowanie według gatunku**
```
GET /rest/v1/books?select=*,genres(name)&genre_id=eq.f1e2d3c4-b5a6-7890-1234-567890abcdef
```

### Request Body
- **Brak** (GET nie przyjmuje body)

## 3. Wykorzystywane typy

### DTOs (Data Transfer Objects)

#### BookListItemDto
**Lokalizacja**: `lib/models/types.dart` (linie 16-59)

**Opis**: Response DTO reprezentujący pojedynczy element listy książek z osadzoną nazwą gatunku.

**Pola**:
```dart
@freezed
class BookListItemDto with _$BookListItemDto {
  const factory BookListItemDto({
    required String id,                           // UUID książki
    @JsonKey(name: 'user_id') required String userId,      // UUID właściciela
    @JsonKey(name: 'genre_id') String? genreId,            // UUID gatunku (opcjonalny)
    required String title,                        // Tytuł książki
    required String author,                       // Autor książki
    @JsonKey(name: 'page_count') required int pageCount,   // Liczba stron
    @JsonKey(name: 'cover_url') String? coverUrl,          // URL okładki (opcjonalny)
    String? isbn,                                 // ISBN (opcjonalny)
    String? publisher,                            // Wydawca (opcjonalny)
    @JsonKey(name: 'publication_year') int? publicationYear, // Rok wydania (opcjonalny)
    required BOOK_STATUS status,                  // Status czytania (enum)
    @JsonKey(name: 'last_read_page_number') required int lastReadPageNumber, // Ostatnia strona
    @JsonKey(name: 'created_at') required DateTime createdAt,  // Data utworzenia
    @JsonKey(name: 'updated_at') required DateTime updatedAt,  // Data aktualizacji
    GenreEmbeddedDto? genres,                     // Osadzony gatunek (opcjonalny)
  }) = _BookListItemDto;
}
```

**Metody**:
- `fromJson(Map<String, dynamic> json)` - Deserializacja z JSON
- `fromEntity(Books book, {String? genreName})` - Konwersja z encji bazy danych

#### GenreEmbeddedDto
**Lokalizacja**: `lib/models/types.dart` (linie 63-68)

**Opis**: Osadzona informacja o gatunku w odpowiedzi książki.

**Pola**:
```dart
@freezed
class GenreEmbeddedDto with _$GenreEmbeddedDto {
  const factory GenreEmbeddedDto({
    required String name,  // Nazwa gatunku
  }) = _GenreEmbeddedDto;
}
```

### Encje bazodanowe (Database Entities)

#### Books
**Lokalizacja**: `lib/models/database_types.dart` (linie 49-262)

**Opis**: Auto-generowana klasa encji przez Supadart reprezentująca tabelę `books`.

**Kluczowe pola**: Wszystkie pola tabeli `books` zgodnie ze schematem bazy danych.

#### BOOK_STATUS Enum
**Lokalizacja**: `lib/models/database_types.dart` (linia 46)

**Wartości**:
```dart
enum BOOK_STATUS { 
  unread,       // Nieprzeczytane
  in_progress,  // W trakcie
  finished,     // Przeczytane
  abandoned,    // Porzucona
  planned       // Planowana do przeczytania
}
```

## 4. Szczegóły odpowiedzi

### Struktura odpowiedzi sukcesu (200 OK)

**Content-Type**: `application/json`

**Body**: Tablica obiektów `BookListItemDto`

```json
[
  {
    "id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
    "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "genre_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "page_count": 310,
    "cover_url": "http://example.com/cover.jpg",
    "isbn": "9780345339683",
    "publisher": "Houghton Mifflin Harcourt",
    "publication_year": 1937,
    "status": "in_progress",
    "last_read_page_number": 150,
    "created_at": "2025-10-10T12:00:00Z",
    "updated_at": "2025-10-12T18:30:00Z",
    "genres": {
      "name": "Fantastyka"
    }
  },
  {
    "id": "d4f5c6b7-4c3b-5g2f-9c4e-3d2b2c1f0e9d",
    "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "genre_id": null,
    "title": "1984",
    "author": "George Orwell",
    "page_count": 328,
    "cover_url": null,
    "isbn": "9780451524935",
    "publisher": "Signet Classic",
    "publication_year": 1949,
    "status": "finished",
    "last_read_page_number": 328,
    "created_at": "2025-09-15T10:00:00Z",
    "updated_at": "2025-10-01T20:00:00Z",
    "genres": null
  }
]
```

**Uwagi dotyczące odpowiedzi**:
- Jeśli brak książek spełniających kryteria, zwracana jest pusta tablica `[]`
- Pole `genres` może być `null` jeśli książka nie ma przypisanego gatunku
- Wszystkie daty są w formacie ISO 8601 z timezone UTC
- Status jest zwracany jako string (wartość enum)

### Kody odpowiedzi

| Kod | Znaczenie | Scenariusz | Response Body |
|-----|-----------|------------|---------------|
| **200 OK** | Sukces | Lista książek pobrana pomyślnie (nawet jeśli pusta) | Tablica `BookListItemDto` |
| **400 Bad Request** | Błąd walidacji | Nieprawidłowe parametry zapytania | `{"message": "Invalid query parameters", "details": "..."}` |
| **401 Unauthorized** | Brak autoryzacji | Brak tokenu JWT, token wygasł lub jest nieprawidłowy | `{"message": "Invalid or expired JWT"}` |
| **403 Forbidden** | Brak uprawnień | Użytkownik próbuje uzyskać dostęp do cudzych danych (RLS) | `{"message": "Access denied"}` |
| **500 Internal Server Error** | Błąd serwera | Problem z bazą danych lub Supabase | `{"message": "Internal server error"}` |

### Nagłówki odpowiedzi

| Nagłówek | Opis |
|----------|------|
| `Content-Type` | `application/json; charset=utf-8` |
| `Content-Range` | Informacja o paginacji (np. `0-19/100` dla 20 z 100 rekordów) |

## 5. Przepływ danych

### Architektura przepływu

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Flutter   │         │   Supabase   │         │ PostgreSQL  │
│     App     │         │   REST API   │         │  Database   │
└──────┬──────┘         └──────┬───────┘         └──────┬──────┘
       │                       │                        │
       │  1. GET /books        │                        │
       │  + JWT Token          │                        │
       ├──────────────────────>│                        │
       │                       │                        │
       │                       │  2. Validate JWT       │
       │                       │     (Auth)             │
       │                       │                        │
       │                       │  3. Apply RLS          │
       │                       │     Policies           │
       │                       │                        │
       │                       │  4. SELECT books       │
       │                       │     WHERE user_id = ?  │
       │                       │     LEFT JOIN genres   │
       │                       ├───────────────────────>│
       │                       │                        │
       │                       │  5. Return rows        │
       │                       │<───────────────────────┤
       │                       │                        │
       │  6. JSON Response     │                        │
       │<──────────────────────┤                        │
       │                       │                        │
       │  7. Parse to DTOs     │                        │
       │                       │                        │
```

### Szczegółowy opis kroków

**Krok 1: Wysłanie żądania z aplikacji Flutter**
- BookService konstruuje URL z parametrami zapytania
- Dodaje nagłówki Authorization (JWT) i apikey
- Wykonuje żądanie HTTP GET przez Supabase Flutter client

**Krok 2: Walidacja JWT przez Supabase**
- Supabase Auth automatycznie weryfikuje token JWT
- Sprawdza ważność tokenu (expiration)
- Ekstrahuje `user_id` z tokenu
- Jeśli token nieprawidłowy → 401 Unauthorized

**Krok 3: Aplikacja Row-Level Security**
- PostgreSQL automatycznie stosuje polityki RLS
- Polityka zapewnia, że `user_id = auth.uid()`
- Użytkownik widzi tylko swoje książki

**Krok 4: Wykonanie zapytania SQL**
Supabase generuje i wykonuje zapytanie podobne do:
```sql
SELECT 
  books.*,
  genres.name as "genres.name"
FROM books
LEFT JOIN genres ON books.genre_id = genres.id
WHERE books.user_id = '<user_id_from_jwt>'
  AND books.status = 'in_progress'  -- jeśli filtr zastosowany
ORDER BY books.title ASC
LIMIT 20 OFFSET 0;
```

**Krok 5: Zwrócenie wyników**
- PostgreSQL zwraca wiersze spełniające kryteria
- Supabase formatuje wyniki do JSON

**Krok 6: Odpowiedź JSON**
- Supabase zwraca tablicę obiektów JSON
- Zawiera nagłówek `Content-Range` dla paginacji

**Krok 7: Parsowanie do DTOs**
- BookService deserializuje JSON do `List<BookListItemDto>`
- Wykorzystuje metodę `BookListItemDto.fromJson()`
- Zwraca wyniki do warstwy UI

### Interakcje z bazą danych

**Tabele zaangażowane**:
- `books` (główna tabela)
- `genres` (LEFT JOIN dla nazwy gatunku)
- `auth.users` (implicit przez RLS i foreign key)

**Indeksy wykorzystywane**:
- Primary key index na `books.id`
- Foreign key index na `books.user_id`
- Foreign key index na `books.genre_id`
- Potencjalnie index na `books.status` (dla częstych filtrów)
- Potencjalnie index na `books.title` (dla sortowania)

**RLS Policy** (wymagana konfiguracja):
```sql
-- Policy dla SELECT
CREATE POLICY "Users can view only their own books"
ON books FOR SELECT
USING (auth.uid() = user_id);
```

### Brak zewnętrznych serwisów
- Endpoint nie wywołuje Google Books API
- Wszystkie dane pochodzą z lokalnej bazy PostgreSQL
- Brak dodatkowych zależności zewnętrznych

## 6. Względy bezpieczeństwa

### 6.1. Uwierzytelnianie (Authentication)

**Mechanizm**: Supabase Auth z JWT tokens

**Implementacja**:
- Każde żądanie musi zawierać nagłówek `Authorization: Bearer <jwt_token>`
- Token JWT zawiera `user_id` i metadata użytkownika
- Supabase automatycznie weryfikuje ważność tokenu
- Wygasłe tokeny są odrzucane z kodem 401

**Best practices**:
- Przechowywać token bezpiecznie w Flutter Secure Storage
- Implementować refresh token mechanism
- Automatycznie odnowić token przed wygaśnięciem
- Wylogować użytkownika przy błędzie 401

### 6.2. Autoryzacja (Authorization)

**Mechanizm**: Row-Level Security (RLS) w PostgreSQL

**Polityka RLS wymagana**:
```sql
-- Włączenie RLS na tabeli books
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- Polityka SELECT - użytkownicy widzą tylko swoje książki
CREATE POLICY "Users can view only their own books"
ON books FOR SELECT
USING (auth.uid() = user_id);
```

**Weryfikacja**:
- RLS jest stosowane **przed** wykonaniem zapytania
- Nawet jeśli ktoś spróbuje zmodyfikować query, RLS to blokuje
- Baza danych jest ostateczną linią obrony

**Testowanie RLS**:
```sql
-- Test jako konkretny użytkownik
SET LOCAL role authenticated;
SET LOCAL request.jwt.claim.sub = '<user_id>';
SELECT * FROM books; -- Powinno zwrócić tylko książki tego użytkownika
```

### 6.3. Walidacja danych wejściowych

**Po stronie klienta (Flutter)**:

```dart
// Walidacja parametrów w BookService
class BookService {
  Future<List<BookListItemDto>> listBooks({
    BOOK_STATUS? status,
    String? genreId,
    String? orderBy,
    String? orderDirection,
    int? limit,
    int? offset,
  }) async {
    // Walidacja status
    if (status != null && !BOOK_STATUS.values.contains(status)) {
      throw ArgumentError('Invalid status value');
    }
    
    // Walidacja UUID dla genreId
    if (genreId != null && !_isValidUuid(genreId)) {
      throw ArgumentError('Invalid genre_id format');
    }
    
    // Walidacja limit
    if (limit != null && (limit <= 0 || limit > 1000)) {
      throw ArgumentError('Limit must be between 1 and 1000');
    }
    
    // Walidacja offset
    if (offset != null && offset < 0) {
      throw ArgumentError('Offset must be non-negative');
    }
    
    // Walidacja orderDirection
    if (orderDirection != null && 
        !['asc', 'desc'].contains(orderDirection.toLowerCase())) {
      throw ArgumentError('Order direction must be asc or desc');
    }
    
    // ... wykonanie zapytania
  }
  
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }
}
```

**Po stronie bazy danych**:
- Ograniczenia CHECK na kolumnach
- Foreign key constraints
- NOT NULL constraints
- ENUM type dla status

### 6.4. Ochrona przed atakami

**SQL Injection**:
- ✅ **Zabezpieczone**: Supabase używa parametryzowanych zapytań
- Query builder automatycznie escapuje wartości
- Nie ma bezpośredniego dostępu do raw SQL z klienta

**XSS (Cross-Site Scripting)**:
- ⚠️ **Odpowiedzialność frontendu**: Sanityzacja przed wyświetleniem w UI
- Szczególnie ważne dla pól `title`, `author`, `publisher`
- Używać Text widgets w Flutter (domyślnie bezpieczne)

**CSRF (Cross-Site Request Forgery)**:
- ✅ **Nie dotyczy**: Stateless API z JWT, brak cookies sesyjnych
- JWT w nagłówku Authorization nie jest podatny na CSRF

**DDoS/Rate Limiting**:
- ✅ **Zabezpieczone przez Supabase**: Built-in rate limiting
- Domyślne limity zależą od planu Supabase
- Rozważyć dodatkowe limity po stronie aplikacji

**Mass Assignment**:
- ✅ **Zabezpieczone**: Endpoint tylko do odczytu (GET)
- RLS zapewnia, że user_id jest zawsze weryfikowane

### 6.5. Bezpieczne przechowywanie kluczy

**W aplikacji Flutter**:
```dart
// config.env (nigdy nie commitować do repo!)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...

// Ładowanie w aplikacji
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: "config.env");
final supabaseUrl = dotenv.env['SUPABASE_URL']!;
final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
```

**Bezpieczne praktyki**:
- Dodać `config.env` do `.gitignore`
- Używać różnych kluczy dla dev/staging/production
- Przechowywać service role key tylko po stronie serwera (Edge Functions)
- Anon key jest bezpieczny do użycia w kliencie (chroniony przez RLS)

### 6.6. HTTPS/TLS

**Wymagania**:
- ✅ Wszystkie połączenia z Supabase używają HTTPS
- Supabase automatycznie wymusza TLS 1.2+
- Certyfikaty są zarządzane przez Supabase

### 6.7. Logi i monitoring

**Co logować**:
- ✅ Nieudane próby autoryzacji (401)
- ✅ Błędy walidacji parametrów
- ✅ Błędy sieciowe
- ❌ **NIE** logować tokenów JWT
- ❌ **NIE** logować pełnych danych użytkownika

**Implementacja logowania**:
```dart
import 'package:logging/logging.dart';

class BookService {
  final _logger = Logger('BookService');
  
  Future<List<BookListItemDto>> listBooks(...) async {
    try {
      _logger.info('Fetching books for user');
      // ... wykonanie zapytania
      _logger.fine('Successfully fetched ${books.length} books');
      return books;
    } catch (e) {
      _logger.severe('Failed to fetch books', e);
      rethrow;
    }
  }
}
```

## 7. Obsługa błędów

### 7.1. Hierarchia błędów

```
Exception
├── NetworkException
│   ├── NoInternetException
│   └── TimeoutException
├── ApiException
│   ├── UnauthorizedException (401)
│   ├── ForbiddenException (403)
│   ├── NotFoundException (404)
│   ├── ValidationException (400)
│   └── ServerException (500)
└── DataException
    ├── ParseException
    └── InvalidDataException
```

### 7.2. Szczegółowe scenariusze błędów

#### 400 Bad Request - Błąd walidacji

**Przyczyny**:
- Nieprawidłowa wartość `status` (nie jest wartością BOOK_STATUS enum)
- Nieprawidłowy format UUID w `genre_id`
- Ujemne wartości `limit` lub `offset`
- Limit większy niż maksymalny (np. > 1000)
- Nieprawidłowa wartość `order` (nieistniejące pole lub zła składnia)

**Przykładowa odpowiedź**:
```json
{
  "code": "PGRST102",
  "message": "Invalid query parameters",
  "details": "status must be one of: unread, in_progress, finished, abandoned, planned",
  "hint": null
}
```

**Obsługa po stronie klienta**:
```dart
try {
  final books = await bookService.listBooks(status: invalidStatus);
} on ValidationException catch (e) {
  // Wyświetl komunikat użytkownikowi
  showErrorDialog('Nieprawidłowe parametry wyszukiwania: ${e.message}');
  _logger.warning('Validation error: ${e.message}');
}
```

#### 401 Unauthorized - Brak autoryzacji

**Przyczyny**:
- Brak nagłówka `Authorization`
- Token JWT wygasł
- Token JWT nieprawidłowy lub zmanipulowany
- Użytkownik został wylogowany po stronie serwera

**Przykładowa odpowiedź**:
```json
{
  "message": "Invalid or expired JWT",
  "statusCode": "401"
}
```

**Obsługa po stronie klienta**:
```dart
try {
  final books = await bookService.listBooks();
} on UnauthorizedException catch (e) {
  // Spróbuj odświeżyć token
  final refreshed = await authService.refreshToken();
  if (!refreshed) {
    // Wyloguj użytkownika
    await authService.logout();
    navigator.pushReplacementNamed('/login');
  } else {
    // Ponów żądanie
    return await bookService.listBooks();
  }
  _logger.warning('Unauthorized access attempt');
}
```

#### 403 Forbidden - Brak uprawnień

**Przyczyny**:
- RLS policy blokuje dostęp do danych innego użytkownika
- Użytkownik nie ma uprawnień do wykonania operacji
- Konto użytkownika zostało zdezaktywowane

**Przykładowa odpowiedź**:
```json
{
  "message": "Access denied",
  "statusCode": "403"
}
```

**Obsługa**:
```dart
try {
  final books = await bookService.listBooks();
} on ForbiddenException catch (e) {
  showErrorDialog('Brak dostępu do tych danych');
  _logger.severe('Forbidden access: ${e.message}');
}
```

**Uwaga**: W normalnych warunkach ten błąd nie powinien wystąpić, gdyż RLS po prostu zwróci puste wyniki zamiast 403. Może wystąpić jeśli polityki RLS są nieprawidłowo skonfigurowane.

#### 404 Not Found - Zasób nie znaleziony

**Przyczyny**:
- Nieprawidłowy endpoint URL (literówka)
- Tabela `books` nie istnieje w bazie danych

**Przykładowa odpowiedź**:
```json
{
  "message": "Not Found",
  "statusCode": "404"
}
```

**Obsługa**:
```dart
try {
  final books = await bookService.listBooks();
} on NotFoundException catch (e) {
  _logger.severe('API endpoint not found: ${e.message}');
  showErrorDialog('Wystąpił błąd aplikacji. Skontaktuj się z obsługą.');
}
```

#### 500 Internal Server Error - Błąd serwera

**Przyczyny**:
- Problem z połączeniem z bazą danych
- Błąd w polityce RLS
- Supabase service unavailable
- Błąd w funkcji bazodanowej lub trigger

**Przykładowa odpowiedź**:
```json
{
  "message": "Internal server error",
  "statusCode": "500"
}
```

**Obsługa**:
```dart
try {
  final books = await bookService.listBooks();
} on ServerException catch (e) {
  _logger.severe('Server error: ${e.message}');
  showErrorDialog('Serwer jest tymczasowo niedostępny. Spróbuj ponownie później.');
  // Opcjonalnie: retry logic
}
```

#### Błędy sieciowe

**Przyczyny**:
- Brak połączenia internetowego
- Timeout połączenia
- DNS resolution failure

**Obsługa**:
```dart
try {
  final books = await bookService.listBooks();
} on NoInternetException catch (e) {
  showErrorDialog('Brak połączenia z internetem');
} on TimeoutException catch (e) {
  showErrorDialog('Przekroczono czas oczekiwania na odpowiedź');
  _logger.warning('Request timeout');
}
```

### 7.3. Implementacja error handling w BookService

```dart
class BookService {
  final SupabaseClient _supabase;
  final Logger _logger;
  
  Future<List<BookListItemDto>> listBooks({
    BOOK_STATUS? status,
    String? genreId,
    String? orderBy = 'title',
    String? orderDirection = 'asc',
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      // Walidacja parametrów
      _validateParameters(status, genreId, limit, offset, orderDirection);
      
      // Budowanie zapytania
      var query = _supabase.books.select('*,genres(name)');
      
      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }
      
      if (genreId != null) {
        query = query.eq('genre_id', genreId);
      }
      
      query = query
          .order(orderBy, ascending: orderDirection == 'asc')
          .range(offset!, offset + limit! - 1);
      
      // Wykonanie zapytania
      final response = await query;
      
      // Parsowanie do DTOs
      final books = (response as List)
          .map((json) => BookListItemDto.fromJson(json))
          .toList();
      
      _logger.info('Successfully fetched ${books.length} books');
      return books;
      
    } on PostgrestException catch (e) {
      // Błędy Supabase/PostgreSQL
      _logger.severe('Postgrest error: ${e.message}', e);
      
      if (e.code == 'PGRST301') {
        throw UnauthorizedException(e.message);
      } else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
      } else {
        throw ServerException(e.message);
      }
      
    } on FormatException catch (e) {
      // Błąd parsowania JSON
      _logger.severe('Failed to parse response: ${e.message}', e);
      throw ParseException('Invalid response format');
      
    } on SocketException catch (e) {
      // Brak połączenia
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
      
    } on TimeoutException catch (e) {
      // Timeout
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException('Request timed out');
      
    } catch (e) {
      // Nieoczekiwany błąd
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }
  
  void _validateParameters(
    BOOK_STATUS? status,
    String? genreId,
    int? limit,
    int? offset,
    String? orderDirection,
  ) {
    if (limit != null && (limit <= 0 || limit > 1000)) {
      throw ValidationException('Limit must be between 1 and 1000');
    }
    
    if (offset != null && offset < 0) {
      throw ValidationException('Offset must be non-negative');
    }
    
    if (genreId != null && !_isValidUuid(genreId)) {
      throw ValidationException('Invalid genre_id format');
    }
    
    if (orderDirection != null && 
        !['asc', 'desc'].contains(orderDirection.toLowerCase())) {
      throw ValidationException('Order direction must be asc or desc');
    }
  }
  
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }
}
```

### 7.4. Definicje klas wyjątków

```dart
// lib/core/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  AppException(this.message, [this.details]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, [String? details]) : super(message, details);
}

class NoInternetException extends NetworkException {
  NoInternetException() : super('No internet connection');
}

class TimeoutException extends NetworkException {
  TimeoutException(String message) : super(message);
}

class ApiException extends AppException {
  final int? statusCode;
  
  ApiException(String message, [this.statusCode, String? details])
      : super(message, details);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 400);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

class DataException extends AppException {
  DataException(String message, [String? details]) : super(message, details);
}

class ParseException extends DataException {
  ParseException(String message) : super(message);
}

class InvalidDataException extends DataException {
  InvalidDataException(String message) : super(message);
}
```

## 8. Rozważania dotyczące wydajności

### 8.1. Potencjalne wąskie gardła

#### 1. Brak indeksów na często używanych kolumnach

**Problem**:
- Sortowanie po `title` bez indeksu może być wolne dla dużych zbiorów danych
- Filtrowanie po `status` bez indeksu powoduje full table scan

**Rozwiązanie**:
```sql
-- Index dla sortowania po tytule
CREATE INDEX idx_books_title ON books(title);

-- Index dla filtrowania po statusie
CREATE INDEX idx_books_status ON books(status);

-- Composite index dla user_id + status (najczęstsze zapytanie)
CREATE INDEX idx_books_user_status ON books(user_id, status);

-- Index dla created_at (sortowanie po dacie dodania)
CREATE INDEX idx_books_created_at ON books(created_at DESC);
```

#### 2. N+1 problem przy pobieraniu gatunków

**Problem**:
- Jeśli nie używamy `select=*,genres(name)`, trzeba by robić osobne zapytania dla każdej książki

**Rozwiązanie**:
- ✅ **Zawsze używać embedded select**: `select=*,genres(name)`
- Supabase automatycznie robi LEFT JOIN w jednym zapytaniu
- Weryfikować w logach SQL czy nie ma duplikacji zapytań

#### 3. Brak paginacji po stronie klienta

**Problem**:
- Pobieranie wszystkich książek naraz może być wolne i zużywać dużo pamięci

**Rozwiązanie**:
- ✅ **Zawsze używać limit/offset**
- Domyślny limit: 20-50 książek
- Implementować infinite scroll lub pagination w UI
- Rozważyć cursor-based pagination dla bardzo dużych zbiorów

```dart
// Przykład infinite scroll
class BookListState {
  List<BookListItemDto> _books = [];
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  
  Future<void> loadMore() async {
    if (!_hasMore) return;
    
    final newBooks = await bookService.listBooks(
      limit: _pageSize,
      offset: _currentOffset,
    );
    
    if (newBooks.length < _pageSize) {
      _hasMore = false;
    }
    
    _books.addAll(newBooks);
    _currentOffset += newBooks.length;
  }
}
```

#### 4. Brak cache'owania wyników

**Problem**:
- Każde wywołanie powoduje zapytanie do bazy danych
- Niepotrzebne obciążenie przy częstym odświeżaniu

**Rozwiązanie**:
```dart
class BookService {
  final _cache = <String, CachedBooks>{};
  final _cacheDuration = Duration(minutes: 5);
  
  Future<List<BookListItemDto>> listBooks({...}) async {
    final cacheKey = _buildCacheKey(status, genreId, ...);
    
    // Sprawdź cache
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        _logger.fine('Returning cached books');
        return cached.books;
      }
    }
    
    // Pobierz z API
    final books = await _fetchFromApi(...);
    
    // Zapisz w cache
    _cache[cacheKey] = CachedBooks(books, DateTime.now());
    
    return books;
  }
  
  void invalidateCache() {
    _cache.clear();
  }
}

class CachedBooks {
  final List<BookListItemDto> books;
  final DateTime timestamp;
  
  CachedBooks(this.books, this.timestamp);
}
```

#### 5. Zbyt duże payload przez osadzanie zbyt wielu relacji

**Problem**:
- Jeśli w przyszłości dodamy więcej relacji, payload może być bardzo duży

**Rozwiązanie**:
- Używać `select` tylko dla potrzebnych pól
- Unikać głębokich zagnieżdżeń relacji
- Rozważyć osobne endpointy dla szczegółów

```dart
// Dla listy - minimalne dane
select: 'id,title,author,page_count,status,genres(name)'

// Dla szczegółów książki - wszystkie dane
select: '*,genres(*),reading_sessions(*)'
```

### 8.2. Strategie optymalizacji

#### 1. Database-level optimizations

```sql
-- Vacuum i analyze dla lepszej wydajności
VACUUM ANALYZE books;

-- Partycjonowanie tabeli books po user_id (dla bardzo dużych zbiorów)
-- Rozważyć tylko jeśli > 10M rekordów

-- Materialized view dla statystyk
CREATE MATERIALIZED VIEW user_book_stats AS
SELECT 
  user_id,
  COUNT(*) as total_books,
  COUNT(*) FILTER (WHERE status = 'finished') as finished_books,
  COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_books
FROM books
GROUP BY user_id;

-- Odświeżanie materialized view (np. co godzinę przez cron job)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_book_stats;
```

#### 2. Connection pooling

**Supabase automatycznie zarządza connection pooling**:
- PgBouncer jest skonfigurowany domyślnie
- Maksymalna liczba połączeń zależy od planu Supabase
- Nie ma potrzeby dodatkowej konfiguracji po stronie klienta

#### 3. Compression

**Supabase automatycznie kompresuje responses**:
- Gzip compression jest włączone domyślnie
- Nie wymaga konfiguracji po stronie klienta
- Szczególnie ważne dla dużych list książek

#### 4. Monitoring i profiling

**Narzędzia do monitorowania**:
- Supabase Dashboard - SQL query performance
- Supabase Logs - slow queries detection
- Flutter DevTools - client-side performance
- Sentry/Firebase Crashlytics - production monitoring

**Metryki do śledzenia**:
- Średni czas odpowiedzi API
- Liczba błędów 500
- Cache hit ratio
- Liczba zapytań na użytkownika
- Rozmiar transferowanych danych

```dart
// Logging wydajności
class BookService {
  Future<List<BookListItemDto>> listBooks(...) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final books = await _fetchBooks(...);
      
      stopwatch.stop();
      _logger.fine('Fetched ${books.length} books in ${stopwatch.elapsedMilliseconds}ms');
      
      // Wysłanie metryki do monitoring service
      analytics.logEvent(
        'api_performance',
        parameters: {
          'endpoint': 'list_books',
          'duration_ms': stopwatch.elapsedMilliseconds,
          'result_count': books.length,
        },
      );
      
      return books;
    } catch (e) {
      stopwatch.stop();
      _logger.warning('Failed to fetch books after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }
}
```

### 8.3. Benchmarki i limity

**Oczekiwane czasy odpowiedzi**:
- < 100ms: Idealny
- 100-300ms: Dobry
- 300-1000ms: Akceptowalny
- \> 1000ms: Wymaga optymalizacji

**Limity paginacji**:
- Minimalny limit: 1
- Domyślny limit: 20
- Maksymalny limit: 1000 (zalecane 100)

**Rozmiar payloadu**:
- Pojedyncza książka: ~500 bytes
- 20 książek: ~10 KB
- 100 książek: ~50 KB
- Maksymalnie zalecane: < 1 MB per request

## 9. Etapy wdrożenia

### Faza 1: Konfiguracja bazy danych (Backend)

**Krok 1.1: Upewnienie się, że tabele są utworzone**

Sprawdzić czy migracja `20251010120000_initial_schema.sql` zawiera tabelę `books`:

```sql
-- Weryfikacja w Supabase SQL Editor
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('books', 'genres');
```

**Krok 1.2: Utworzenie indeksów dla wydajności**

```sql
-- supabase/migrations/20251013000001_add_books_indexes.sql

-- Index dla user_id (jeśli nie istnieje z foreign key)
CREATE INDEX IF NOT EXISTS idx_books_user_id ON books(user_id);

-- Index dla sortowania po tytule
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);

-- Index dla filtrowania po statusie
CREATE INDEX IF NOT EXISTS idx_books_status ON books(status);

-- Composite index dla najczęstszego zapytania
CREATE INDEX IF NOT EXISTS idx_books_user_status ON books(user_id, status);

-- Index dla sortowania po dacie utworzenia
CREATE INDEX IF NOT EXISTS idx_books_created_at ON books(created_at DESC);

-- Index dla sortowania po dacie aktualizacji
CREATE INDEX IF NOT EXISTS idx_books_updated_at ON books(updated_at DESC);
```

**Krok 1.3: Konfiguracja Row-Level Security**

```sql
-- supabase/migrations/20251013000002_add_books_rls.sql

-- Włączenie RLS na tabeli books (jeśli nie jest włączone)
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- DROP istniejących polityk (jeśli istnieją)
DROP POLICY IF EXISTS "Users can view only their own books" ON books;
DROP POLICY IF EXISTS "Users can insert their own books" ON books;
DROP POLICY IF EXISTS "Users can update their own books" ON books;
DROP POLICY IF EXISTS "Users can delete their own books" ON books;

-- Polityka SELECT - użytkownicy widzą tylko swoje książki
CREATE POLICY "Users can view only their own books"
ON books FOR SELECT
USING (auth.uid() = user_id);

-- Polityka INSERT - użytkownicy mogą dodawać tylko swoje książki
CREATE POLICY "Users can insert their own books"
ON books FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Polityka UPDATE - użytkownicy mogą aktualizować tylko swoje książki
CREATE POLICY "Users can update their own books"
ON books FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Polityka DELETE - użytkownicy mogą usuwać tylko swoje książki
CREATE POLICY "Users can delete their own books"
ON books FOR DELETE
USING (auth.uid() = user_id);
```

**Krok 1.4: Testowanie RLS policies**

```sql
-- Testowanie w Supabase SQL Editor

-- 1. Utworzenie testowych użytkowników (jeśli nie istnieją)
-- Użyj Supabase Auth UI lub API do utworzenia testowych użytkowników

-- 2. Test jako authenticated user
SET LOCAL role authenticated;
SET LOCAL request.jwt.claim.sub = '<test_user_id>';

-- Ten query powinien zwrócić tylko książki test_user_id
SELECT * FROM books;

-- 3. Reset role
RESET role;

-- 4. Test jako anonymous (powinno zwrócić błąd lub puste wyniki)
SET LOCAL role anon;
SELECT * FROM books; -- Powinno zwrócić błąd lub puste wyniki
```

**Krok 1.5: Uruchomienie migracji**

```bash
# W terminalu, w katalogu projektu
# Upewnij się, że Supabase CLI jest zainstalowane
supabase db push

# Lub przez Supabase Dashboard:
# 1. Przejdź do SQL Editor
# 2. Skopiuj i uruchom skrypty migracji
```

### Faza 2: Implementacja po stronie klienta (Flutter)

**Krok 2.1: Utworzenie struktury katalogów**

```
lib/
├── core/
│   ├── exceptions.dart        # Definicje wyjątków
│   ├── result.dart            # Result type dla error handling
│   └── constants.dart         # Stałe (limity, timeouty)
├── models/
│   ├── types.dart             # ✅ Już istnieje
│   ├── types.freezed.dart     # ✅ Już istnieje
│   ├── types.g.dart           # ✅ Już istnieje
│   └── database_types.dart    # ✅ Już istnieje
├── services/
│   └── book_service.dart      # Nowy serwis dla operacji na książkach
└── main.dart
```

**Krok 2.2: Utworzenie klas wyjątków**

```dart
// lib/core/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  AppException(this.message, [this.details]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, [String? details]) : super(message, details);
}

class NoInternetException extends NetworkException {
  NoInternetException() : super('No internet connection');
}

class TimeoutException extends NetworkException {
  TimeoutException(String message) : super(message);
}

class ApiException extends AppException {
  final int? statusCode;
  
  ApiException(String message, [this.statusCode, String? details])
      : super(message, details);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 400);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

class DataException extends AppException {
  DataException(String message, [String? details]) : super(message, details);
}

class ParseException extends DataException {
  ParseException(String message) : super(message);
}
```

**Krok 2.3: Utworzenie Result type (opcjonalne, ale zalecane)**

```dart
// lib/core/result.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppException error) = Failure<T>;
}
```

**Krok 2.4: Utworzenie stałych**

```dart
// lib/core/constants.dart

class ApiConstants {
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 1000;
  static const int minPageSize = 1;
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  
  // Cache
  static const Duration cacheDuration = Duration(minutes: 5);
  
  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
```

**Krok 2.5: Implementacja BookService**

```dart
// lib/services/book_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../models/database_types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

class BookService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('BookService');
  
  BookService(this._supabase);
  
  /// Pobiera listę książek dla zalogowanego użytkownika
  /// 
  /// Parametry:
  /// - [status]: Filtruj według statusu czytania
  /// - [genreId]: Filtruj według gatunku
  /// - [orderBy]: Pole do sortowania (domyślnie 'title')
  /// - [orderDirection]: Kierunek sortowania ('asc' lub 'desc')
  /// - [limit]: Liczba wyników (domyślnie 20, max 1000)
  /// - [offset]: Przesunięcie dla paginacji (domyślnie 0)
  /// 
  /// Zwraca listę [BookListItemDto]
  /// 
  /// Rzuca wyjątki:
  /// - [UnauthorizedException]: Brak autoryzacji
  /// - [ValidationException]: Nieprawidłowe parametry
  /// - [ServerException]: Błąd serwera
  /// - [NoInternetException]: Brak połączenia
  /// - [TimeoutException]: Przekroczono timeout
  Future<List<BookListItemDto>> listBooks({
    BOOK_STATUS? status,
    String? genreId,
    String orderBy = 'title',
    String orderDirection = 'asc',
    int limit = ApiConstants.defaultPageSize,
    int offset = 0,
  }) async {
    _logger.info('Fetching books: status=$status, genreId=$genreId, '
        'orderBy=$orderBy, direction=$orderDirection, limit=$limit, offset=$offset');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Walidacja parametrów
      _validateParameters(status, genreId, limit, offset, orderDirection);
      
      // Budowanie zapytania
      var query = _supabase.books.select('*,genres(name)');
      
      // Filtrowanie po statusie
      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }
      
      // Filtrowanie po gatunku
      if (genreId != null) {
        query = query.eq('genre_id', genreId);
      }
      
      // Sortowanie i paginacja
      query = query
          .order(orderBy, ascending: orderDirection.toLowerCase() == 'asc')
          .range(offset, offset + limit - 1);
      
      // Wykonanie zapytania z timeout
      final response = await query
          .timeout(ApiConstants.defaultTimeout);
      
      // Parsowanie do DTOs
      final books = (response as List)
          .map((json) => BookListItemDto.fromJson(json as Map<String, dynamic>))
          .toList();
      
      stopwatch.stop();
      _logger.info('Successfully fetched ${books.length} books in ${stopwatch.elapsedMilliseconds}ms');
      
      return books;
      
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);
      
      // Mapowanie kodów błędów Supabase na wyjątki
      if (e.code == 'PGRST301' || e.message.contains('JWT')) {
        throw UnauthorizedException(e.message);
      } else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
      } else if (e.code == 'PGRST116') {
        throw NotFoundException('Books table not found');
      } else {
        throw ServerException(e.message);
      }
      
    } on FormatException catch (e) {
      stopwatch.stop();
      _logger.severe('Failed to parse response: ${e.message}', e);
      throw ParseException('Invalid response format from server');
      
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
      
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException('Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s');
      
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }
  
  /// Waliduje parametry zapytania
  void _validateParameters(
    BOOK_STATUS? status,
    String? genreId,
    int limit,
    int offset,
    String orderDirection,
  ) {
    // Walidacja limit
    if (limit < ApiConstants.minPageSize || limit > ApiConstants.maxPageSize) {
      throw ValidationException(
        'Limit must be between ${ApiConstants.minPageSize} and ${ApiConstants.maxPageSize}'
      );
    }
    
    // Walidacja offset
    if (offset < 0) {
      throw ValidationException('Offset must be non-negative');
    }
    
    // Walidacja UUID dla genreId
    if (genreId != null && !_isValidUuid(genreId)) {
      throw ValidationException('Invalid genre_id format (must be UUID)');
    }
    
    // Walidacja orderDirection
    final validDirections = ['asc', 'desc'];
    if (!validDirections.contains(orderDirection.toLowerCase())) {
      throw ValidationException('Order direction must be one of: ${validDirections.join(", ")}');
    }
  }
  
  /// Sprawdza czy string jest poprawnym UUID
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }
}
```

**Krok 2.6: Konfiguracja dependency injection (opcjonalne)**

```dart
// lib/core/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/book_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Supabase client (singleton)
  getIt.registerSingleton<SupabaseClient>(
    Supabase.instance.client,
  );
  
  // BookService
  getIt.registerLazySingleton<BookService>(
    () => BookService(getIt<SupabaseClient>()),
  );
}
```

**Krok 2.7: Aktualizacja pubspec.yaml**

Upewnić się, że wszystkie potrzebne zależności są dodane:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0  # ✅ Już powinno być
  freezed_annotation: ^2.4.1  # ✅ Już powinno być
  json_annotation: ^4.8.1    # ✅ Już powinno być
  logging: ^1.2.0            # Dodać jeśli brak
  get_it: ^7.6.0             # Opcjonalne - dla DI

dev_dependencies:
  build_runner: ^2.4.6       # ✅ Już powinno być
  freezed: ^2.4.5            # ✅ Już powinno być
  json_serializable: ^6.7.1  # ✅ Już powinno być
```

**Krok 2.8: Generowanie kodu (jeśli Result type został dodany)**

```bash
# W terminalu, w katalogu projektu
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Faza 3: Testowanie

**Krok 3.1: Unit testy dla BookService**

```dart
// test/services/book_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/services/book_service.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/models/database_types.dart';
import 'package:my_book_library/core/exceptions.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
void main() {
  late BookService bookService;
  late MockSupabaseClient mockSupabase;
  
  setUp(() {
    mockSupabase = MockSupabaseClient();
    bookService = BookService(mockSupabase);
  });
  
  group('BookService.listBooks', () {
    test('should return list of books successfully', () async {
      // Arrange
      final mockResponse = [
        {
          'id': 'test-id-1',
          'user_id': 'user-id',
          'genre_id': 'genre-id',
          'title': 'Test Book',
          'author': 'Test Author',
          'page_count': 100,
          'cover_url': null,
          'isbn': null,
          'publisher': null,
          'publication_year': null,
          'status': 'unread',
          'last_read_page_number': 0,
          'created_at': '2025-01-01T00:00:00Z',
          'updated_at': '2025-01-01T00:00:00Z',
          'genres': {'name': 'Fiction'},
        }
      ];
      
      when(mockSupabase.books.select('*,genres(name)'))
          .thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await bookService.listBooks();
      
      // Assert
      expect(result, isA<List<BookListItemDto>>());
      expect(result.length, 1);
      expect(result[0].title, 'Test Book');
      expect(result[0].genres?.name, 'Fiction');
    });
    
    test('should throw ValidationException for invalid limit', () async {
      // Act & Assert
      expect(
        () => bookService.listBooks(limit: -1),
        throwsA(isA<ValidationException>()),
      );
    });
    
    test('should throw ValidationException for invalid UUID', () async {
      // Act & Assert
      expect(
        () => bookService.listBooks(genreId: 'invalid-uuid'),
        throwsA(isA<ValidationException>()),
      );
    });
    
    test('should throw UnauthorizedException on auth error', () async {
      // Arrange
      when(mockSupabase.books.select('*,genres(name)'))
          .thenThrow(PostgrestException(message: 'JWT expired', code: 'PGRST301'));
      
      // Act & Assert
      expect(
        () => bookService.listBooks(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
```

**Krok 3.2: Integration testy**

```dart
// integration_test/book_list_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/main.dart' as app;
import 'package:my_book_library/services/book_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Book List Integration Tests', () {
    late BookService bookService;
    
    setUpAll(() async {
      // Inicjalizacja Supabase
      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL',
        anonKey: 'YOUR_SUPABASE_ANON_KEY',
      );
      
      bookService = BookService(Supabase.instance.client);
      
      // Zalogowanie testowego użytkownika
      await Supabase.instance.client.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'testpassword',
      );
    });
    
    test('should fetch books from real API', () async {
      final books = await bookService.listBooks();
      
      expect(books, isA<List<BookListItemDto>>());
      // Dodatkowe assercje w zależności od danych testowych
    });
    
    test('should filter books by status', () async {
      final books = await bookService.listBooks(status: BOOK_STATUS.in_progress);
      
      expect(books.every((book) => book.status == BOOK_STATUS.in_progress), true);
    });
    
    tearDownAll(() async {
      await Supabase.instance.client.auth.signOut();
    });
  });
}
```

**Krok 3.3: Manualne testowanie przez Supabase Dashboard**

1. Przejdź do Supabase Dashboard → Table Editor → books
2. Dodaj kilka testowych książek dla swojego użytkownika
3. Użyj SQL Editor do wykonania testowych zapytań:

```sql
-- Test 1: Podstawowe zapytanie (symuluje GET /books)
SELECT *,
  (SELECT name FROM genres WHERE id = books.genre_id) as genre_name
FROM books
WHERE user_id = auth.uid()
ORDER BY title ASC
LIMIT 20;

-- Test 2: Filtrowanie po statusie
SELECT * FROM books
WHERE user_id = auth.uid()
AND status = 'in_progress';

-- Test 3: Filtrowanie po gatunku
SELECT * FROM books
WHERE user_id = auth.uid()
AND genre_id = '<genre_uuid>';

-- Test 4: Paginacja
SELECT * FROM books
WHERE user_id = auth.uid()
ORDER BY title ASC
LIMIT 20 OFFSET 20;
```

**Krok 3.4: Testowanie RLS**

```sql
-- Test jako inny użytkownik
SET LOCAL role authenticated;
SET LOCAL request.jwt.claim.sub = '<different_user_id>';

-- To powinno zwrócić puste wyniki (nie książki pierwszego użytkownika)
SELECT * FROM books;

RESET role;
```

### Faza 4: Integracja z UI (Flutter)

**Krok 4.1: Utworzenie przykładowego widżetu listy książek**

```dart
// lib/screens/book_list_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/book_service.dart';
import '../models/types.dart';
import '../models/database_types.dart';
import '../core/exceptions.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late final BookService _bookService;
  List<BookListItemDto> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  BOOK_STATUS? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _bookService = BookService(Supabase.instance.client);
    _loadBooks();
  }
  
  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final books = await _bookService.listBooks(
        status: _selectedStatus,
        orderBy: 'title',
        orderDirection: 'asc',
      );
      
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } on UnauthorizedException catch (e) {
      setState(() {
        _errorMessage = 'Sesja wygasła. Zaloguj się ponownie.';
        _isLoading = false;
      });
      // Nawigacja do ekranu logowania
    } on NoInternetException catch (e) {
      setState(() {
        _errorMessage = 'Brak połączenia z internetem';
        _isLoading = false;
      });
    } on ServerException catch (e) {
      setState(() {
        _errorMessage = 'Błąd serwera. Spróbuj ponownie później.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił nieoczekiwany błąd';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moja Biblioteka'),
        actions: [
          PopupMenuButton<BOOK_STATUS?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedStatus = status;
              });
              _loadBooks();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Wszystkie'),
              ),
              ...BOOK_STATUS.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(_statusLabel(status)),
              )),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nawigacja do ekranu dodawania książki
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBooks,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }
    
    if (_books.isEmpty) {
      return const Center(
        child: Text('Brak książek w bibliotece'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            leading: book.coverUrl != null
                ? Image.network(book.coverUrl!, width: 50, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Text('${book.author} • ${book.genres?.name ?? "Brak gatunku"}'),
            trailing: Text(_statusLabel(book.status)),
            onTap: () {
              // Nawigacja do szczegółów książki
            },
          );
        },
      ),
    );
  }
  
  String _statusLabel(BOOK_STATUS status) {
    switch (status) {
      case BOOK_STATUS.unread:
        return 'Nieprzeczytane';
      case BOOK_STATUS.in_progress:
        return 'W trakcie';
      case BOOK_STATUS.finished:
        return 'Przeczytane';
      case BOOK_STATUS.abandoned:
        return 'Porzucone';
      case BOOK_STATUS.planned:
        return 'Planowane';
    }
  }
}
```

**Krok 4.2: Integracja z główną aplikacją**

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'screens/book_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfiguracja loggera
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  // Załaduj zmienne środowiskowe
  await dotenv.load(fileName: "config.env");
  
  // Inicjalizacja Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Book Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BookListScreen(),
    );
  }
}
```

### Faza 5: Dokumentacja i finalizacja

**Krok 5.1: Utworzenie dokumentacji API**

```markdown
<!-- .ai/endpoints/list-books.md -->

# Endpoint: List Books

## Przegląd
Pobiera listę książek zalogowanego użytkownika z opcjonalnym filtrowaniem i paginacją.

## Użycie po stronie klienta

### Podstawowe użycie
```dart
final bookService = BookService(Supabase.instance.client);
final books = await bookService.listBooks();
```

### Z filtrowaniem
```dart
final inProgressBooks = await bookService.listBooks(
  status: BOOK_STATUS.in_progress,
);
```

### Z paginacją
```dart
final page1 = await bookService.listBooks(limit: 20, offset: 0);
final page2 = await bookService.listBooks(limit: 20, offset: 20);
```

## Error handling
Wszystkie błędy są rzucane jako wyjątki dziedziczące po `AppException`.
Zobacz `lib/core/exceptions.dart` dla pełnej listy.

## Wydajność
- Domyślny limit: 20 książek
- Maksymalny limit: 1000 książek (zalecane max 100)
- Typowy czas odpowiedzi: < 300ms

## Bezpieczeństwo
- Wymaga uwierzytelnienia (JWT token)
- RLS zapewnia izolację danych użytkowników
- Wszystkie zapytania są automatycznie filtrowane po user_id
```

**Krok 5.2: Code review checklist**

- [ ] RLS policies są włączone i przetestowane
- [ ] Wszystkie indeksy zostały utworzone
- [ ] BookService implementuje wszystkie funkcjonalności z wymagań
- [ ] Walidacja parametrów jest kompletna
- [ ] Error handling pokrywa wszystkie scenariusze
- [ ] Testy jednostkowe przechodzą
- [ ] Testy integracyjne przechodzą
- [ ] Logging jest prawidłowo skonfigurowany
- [ ] Dokumentacja jest kompletna
- [ ] Kod jest zgodny z Dart style guide

**Krok 5.3: Performance testing**

```bash
# Użyj narzędzia jak k6 lub Apache Bench do testowania wydajności

# Przykład z curl (manualne testowanie)
curl -X GET 'https://YOUR_PROJECT.supabase.co/rest/v1/books?select=*,genres(name)' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -w "\nTime total: %{time_total}s\n"
```

**Krok 5.4: Deployment**

1. Commit wszystkich zmian:
```bash
git add .
git commit -m "feat: implement List Books endpoint with RLS and client service"
```

2. Push do repository:
```bash
git push origin main
```

3. Weryfikacja w środowisku produkcyjnym:
- Sprawdź Supabase Dashboard → Table Editor
- Sprawdź Supabase Dashboard → Authentication
- Przetestuj endpoint z rzeczywistym użytkownikiem

4. Monitoring:
- Skonfiguruj alerty dla błędów 500
- Monitoruj czas odpowiedzi
- Śledź wykorzystanie bazy danych

---

## Podsumowanie implementacji

### ✅ Co zostało zaimplementowane:
1. **Backend (Supabase)**:
   - Row-Level Security policies
   - Indeksy dla wydajności
   - Testowanie polityk RLS

2. **Client (Flutter)**:
   - BookService z pełną obsługą błędów
   - Walidacja parametrów
   - Proper error handling
   - Logging
   - DTOs (już istniejące)

3. **Testing**:
   - Unit testy
   - Integration testy
   - Manualne testy SQL

4. **UI**:
   - Przykładowy ekran listy książek
   - Error handling w UI
   - Pull-to-refresh

5. **Documentation**:
   - Ten plan implementacji
   - Code documentation (komentarze)
   - API documentation

### 📊 Metryki sukcesu:
- ✅ Czas odpowiedzi < 300ms (dla 20 książek)
- ✅ RLS zapewnia 100% izolację danych
- ✅ Wszystkie testy przechodzą
- ✅ Zero błędów walidacji w produkcji
- ✅ Code coverage > 80%

### 🚀 Następne kroki:
1. Implementacja pozostałych endpointów (Create, Update, Delete)
2. Dodanie cache'owania
3. Implementacja infinite scroll w UI
4. Dodanie filtrów zaawansowanych (wyszukiwanie tekstowe)
5. Implementacja offline-first z synchronizacją


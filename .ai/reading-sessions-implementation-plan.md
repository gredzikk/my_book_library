# API Endpoint Implementation Plan: Reading Sessions Resource

## 1. Przegląd punktów końcowych

Ten plan obejmuje implementację dwóch powiązanych endpointów dla zasobu **Reading Sessions** w aplikacji My Book Library:

### Endpoint 1: List Reading Sessions for a Book
Umożliwia pobranie historii wszystkich sesji czytania dla konkretnej książki należącej do uwierzytelnionego użytkownika. Sesje są zwracane w kolejności chronologicznej od najnowszej do najstarszej.

### Endpoint 2: End a Reading Session (RPC)
Kończy aktywną sesję czytania poprzez wywołanie funkcji PostgreSQL RPC. Funkcja atomowo:
- Tworzy rekord sesji czytania
- Aktualizuje postęp książki (`last_read_page_number`)
- Automatycznie zmienia status książki na `finished`, jeśli użytkownik przeczytał wszystkie strony

Oba endpointy są chronione przez Row Level Security (RLS) i wymagają uwierzytelnienia JWT.

---

## 2. Szczegóły żądań

### 2.1. List Reading Sessions for a Book

#### Metoda HTTP
`GET`

#### Struktura URL
```
/rest/v1/reading_sessions?book_id=eq.{book_id}&order=created_at.desc
```

#### Parametry zapytania

**Wymagane:**
- `book_id=eq.{book_id}` (UUID) - Filtr książki, dla której pobierane są sesje
  - Format: UUID v4 (np. `c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c`)
  - Walidacja: Sprawdzenie formatu UUID, weryfikacja dostępu przez RLS

**Opcjonalne:**
- `order=created_at.desc` - Sortowanie wyników
  - Format: `{column}.{direction}` gdzie direction = `asc` lub `desc`
  - Domyślnie: brak sortowania (kolejność nieokreślona)
  - Zalecane: `created_at.desc` (od najnowszej sesji)

**Przyszłe rozszerzenia (poza MVP):**
- `limit={n}` - Ograniczenie liczby wyników (paginacja)
- `offset={n}` - Przesunięcie dla paginacji
- `start_date=gte.{date}` - Filtrowanie po dacie rozpoczęcia

#### Nagłówki żądania
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

#### Request Body
Brak (metoda GET)

---

### 2.2. End a Reading Session (RPC)

#### Metoda HTTP
`POST`

#### Struktura URL
```
/rest/v1/rpc/end_reading_session
```

#### Parametry zapytania
Brak

#### Nagłówki żądania
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

#### Request Body
```json
{
  "p_book_id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
  "p_start_time": "2025-10-12T18:00:00Z",
  "p_end_time": "2025-10-12T18:30:00Z",
  "p_last_read_page": 150
}
```

**Struktura pól:**
- `p_book_id` (string, UUID, wymagany) - Identyfikator książki
- `p_start_time` (string, ISO 8601, wymagany) - Czas rozpoczęcia sesji w UTC
- `p_end_time` (string, ISO 8601, wymagany) - Czas zakończenia sesji w UTC
- `p_last_read_page` (integer, wymagany) - Numer ostatniej przeczytanej strony

**Reguły walidacji:**
- `p_end_time` musi być późniejszy niż `p_start_time`
- `p_last_read_page` musi być > 0
- `p_last_read_page` nie może przekraczać `page_count` książki
- Czasy nie mogą być w przyszłości (opcjonalna walidacja)

---

## 3. Wykorzystywane typy

### 3.1. DTOs z pliku `lib/models/types.dart`

#### ReadingSessionDto (Response DTO)
Używany w odpowiedzi GET `/reading_sessions`

```dart
@freezed
class ReadingSessionDto with _$ReadingSessionDto {
  const factory ReadingSessionDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'book_id') required String bookId,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'pages_read') required int pagesRead,
    @JsonKey(name: 'last_read_page_number') required int lastReadPageNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReadingSessionDto;

  factory ReadingSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionDtoFromJson(json);
}
```

**Mapowanie pól:**
- Wszystkie pola mapowane z snake_case (baza) na camelCase (Dart)
- DateTime pola parsowane automatycznie przez freezed
- `duration_minutes` i `pages_read` obliczane przez bazę danych

---

#### EndReadingSessionDto (Command DTO)
Używany w żądaniu POST `/rpc/end_reading_session`

```dart
@freezed
class EndReadingSessionDto with _$EndReadingSessionDto {
  const factory EndReadingSessionDto({
    @JsonKey(name: 'p_book_id') required String bookId,
    @JsonKey(name: 'p_start_time') required DateTime startTime,
    @JsonKey(name: 'p_end_time') required DateTime endTime,
    @JsonKey(name: 'p_last_read_page') required int lastReadPage,
  }) = _EndReadingSessionDto;

  factory EndReadingSessionDto.fromJson(Map<String, dynamic> json) =>
      _$EndReadingSessionDtoFromJson(json);

  const EndReadingSessionDto._();

  /// Convert to JSON for RPC call
  Map<String, dynamic> toRequestJson() {
    return {
      'p_book_id': bookId,
      'p_start_time': startTime.toUtc().toIso8601String(),
      'p_end_time': endTime.toUtc().toIso8601String(),
      'p_last_read_page': lastReadPage,
    };
  }
}
```

**Kluczowe cechy:**
- Prefiksy `p_` zgodne z konwencją parametrów funkcji PostgreSQL
- Metoda `toRequestJson()` konwertuje DateTime do ISO 8601 w UTC
- Wszystkie pola wymagane (brak optional fields)

---

### 3.2. Database Entity z pliku `lib/models/database_types.dart`

#### ReadingSessions (Database Entity)
Auto-generowana przez SupaDart, używana do konwersji z database response

```dart
class ReadingSessions implements SupadartClass<ReadingSessions> {
  final String id;
  final String userId;
  final String bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int pagesRead;
  final int lastReadPageNumber;
  final DateTime createdAt;

  // ... factory fromJson, toJson, insert, update methods
}
```

---

## 4. Szczegóły odpowiedzi

### 4.1. List Reading Sessions - Success Response

**Status Code:** `200 OK`

**Response Body:**
```json
[
  {
    "id": "e6f7a8b9-c0d1-e2f3-a4b5-c6d7e8f9a0b1",
    "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "book_id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
    "start_time": "2025-10-12T18:00:00Z",
    "end_time": "2025-10-12T18:30:00Z",
    "duration_minutes": 30,
    "pages_read": 25,
    "last_read_page_number": 150,
    "created_at": "2025-10-12T18:30:05Z"
  },
  {
    "id": "f7g8h9i0-j1k2-l3m4-n5o6-p7q8r9s0t1u2",
    "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "book_id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
    "start_time": "2025-10-11T20:00:00Z",
    "end_time": "2025-10-11T21:15:00Z",
    "duration_minutes": 75,
    "pages_read": 50,
    "last_read_page_number": 125,
    "created_at": "2025-10-11T21:15:10Z"
  }
]
```

**Charakterystyka odpowiedzi:**
- Array JSON (może być pusty `[]` jeśli brak sesji)
- Kolejność zależna od parametru `order` (zalecane: `created_at.desc`)
- Wszystkie daty w formacie ISO 8601 UTC

---

### 4.2. End Reading Session - Success Response

**Status Code:** `200 OK`

**Response Body (sesja utworzona):**
```json
"e6f7a8b9-c0d1-e2f3-a4b5-c6d7e8f9a0b1"
```
Zwraca UUID nowo utworzonej sesji jako string.

**Response Body (sesja nie utworzona):**
```json
null
```
Null zwracane gdy `pages_read = 0` (użytkownik nie przeczytał żadnej nowej strony).

---

### 4.3. Error Responses

#### 400 Bad Request
```json
{
  "code": "22023",
  "message": "Invalid last_read_page: exceeds page_count",
  "details": "p_last_read_page (250) cannot exceed book page_count (200)",
  "hint": null
}
```

**Scenariusze:**
- Nieprawidłowy UUID format w `book_id` lub `p_book_id`
- `p_end_time` <= `p_start_time`
- `p_last_read_page` > `page_count` książki
- `p_last_read_page` <= 0
- Książka nie istnieje lub nie należy do użytkownika

---

#### 401 Unauthorized
```json
{
  "code": "PGRST301",
  "message": "JWT token is missing or invalid",
  "details": null,
  "hint": null
}
```

**Scenariusze:**
- Brak nagłówka `Authorization`
- Nieprawidłowy JWT token
- Token wygasły
- Token nie zawiera poprawnego `auth.uid()`

---

#### 500 Internal Server Error
```json
{
  "code": "P0001",
  "message": "Function end_reading_session failed",
  "details": "Error in database function execution",
  "hint": "Check database logs"
}
```

**Scenariusze:**
- Błąd w funkcji RPC PostgreSQL
- Naruszenie constraint na poziomie bazy (np. CHECK constraint)
- Deadlock w bazie danych
- Przekroczenie limitów zasobów

---

## 5. Przepływ danych

### 5.1. Przepływ dla GET /reading_sessions

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │ 1. Call listReadingSessions(bookId)
       ▼
┌─────────────────────┐
│ ReadingSessionService│
│  - Validate bookId  │
│  - Build query      │
└──────┬──────────────┘
       │ 2. GET /reading_sessions?book_id=eq.{id}&order=created_at.desc
       ▼
┌─────────────────────┐
│   Supabase API      │
│   (PostgREST)       │
└──────┬──────────────┘
       │ 3. Check JWT + RLS
       ▼
┌─────────────────────┐
│  PostgreSQL DB      │
│  - Query with       │
│    user_id filter   │
│  - Apply RLS        │
└──────┬──────────────┘
       │ 4. Return rows
       ▼
┌─────────────────────┐
│   Supabase API      │
│  - Format as JSON   │
└──────┬──────────────┘
       │ 5. JSON Array
       ▼
┌─────────────────────┐
│ ReadingSessionService│
│  - Parse to DTOs    │
│  - Handle errors    │
└──────┬──────────────┘
       │ 6. Return List<ReadingSessionDto>
       ▼
┌─────────────┐
│   Flutter   │
│     App     │
└─────────────┘
```

**Kluczowe kroki:**
1. **Walidacja** - sprawdzenie formatu UUID, parametrów zapytania
2. **Query Building** - konstrukcja zapytania Supabase z filtrami i sortowaniem
3. **RLS Enforcement** - automatyczna weryfikacja `auth.uid() = user_id`
4. **Data Retrieval** - pobranie tylko rekordów należących do użytkownika
5. **Parsing** - konwersja JSON → ReadingSessionDto
6. **Error Handling** - mapowanie błędów Supabase na custom exceptions

---

### 5.2. Przepływ dla POST /rpc/end_reading_session

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │ 1. Call endReadingSession(dto)
       ▼
┌─────────────────────┐
│ ReadingSessionService│
│  - Validate DTO     │
│  - Check times      │
│  - Convert to JSON  │
└──────┬──────────────┘
       │ 2. POST /rpc/end_reading_session + JSON payload
       ▼
┌─────────────────────┐
│   Supabase API      │
│   (PostgREST RPC)   │
└──────┬──────────────┘
       │ 3. Check JWT
       ▼
┌─────────────────────────────────────────┐
│  PostgreSQL Function: end_reading_session│
│  BEGIN TRANSACTION                       │
│  ┌──────────────────────────────────┐  │
│  │ 1. Validate book ownership       │  │
│  │    (book.user_id = auth.uid())   │  │
│  │ 2. Validate last_read_page       │  │
│  │    (page <= book.page_count)     │  │
│  │ 3. Calculate duration & pages    │  │
│  │ 4. INSERT reading_session        │  │
│  │ 5. UPDATE book.last_read_page    │  │
│  │ 6. IF last_page = page_count     │  │
│  │    THEN status = 'finished'      │  │
│  │ 7. RETURN session_id             │  │
│  └──────────────────────────────────┘  │
│  COMMIT TRANSACTION                      │
└──────┬──────────────────────────────────┘
       │ 4. Return UUID or null
       ▼
┌─────────────────────┐
│   Supabase API      │
│  - Format response  │
└──────┬──────────────┘
       │ 5. JSON: "uuid" or null
       ▼
┌─────────────────────┐
│ ReadingSessionService│
│  - Parse response   │
│  - Handle errors    │
└──────┬──────────────┘
       │ 6. Return String? (session_id)
       ▼
┌─────────────┐
│   Flutter   │
│     App     │
└─────────────┘
```

**Kluczowe kroki:**
1. **Client-side Validation** - sprawdzenie poprawności dat, UUID, numerów stron
2. **RPC Call** - wywołanie funkcji PostgreSQL przez PostgREST
3. **Server-side Logic** - atomowe wykonanie wielu operacji w transakcji:
   - Weryfikacja właściciela książki
   - Walidacja postępu (czy nie przekracza page_count)
   - Obliczenie `duration_minutes` = EXTRACT(EPOCH FROM (end_time - start_time)) / 60
   - Obliczenie `pages_read` = last_read_page - book.last_read_page_number
   - Wstawienie rekordu reading_session
   - Aktualizacja book.last_read_page_number
   - Automatyczna zmiana statusu na 'finished' jeśli last_read_page = page_count
4. **Transaction Commit** - wszystkie zmiany zapisane atomowo lub wycofane w razie błędu
5. **Response** - zwrócenie UUID nowej sesji lub null (jeśli pages_read = 0)

---

## 6. Względy bezpieczeństwa

### 6.1. Uwierzytelnianie i Autoryzacja

#### JWT Authentication
- **Mechanizm:** Supabase Auth JWT token w nagłówku `Authorization: Bearer {token}`
- **Weryfikacja:** Automatyczna przez PostgREST przed wykonaniem zapytania
- **Timeout:** Token wygasa po określonym czasie (domyślnie 1h), wymaga refresh
- **Claims:** Token zawiera `sub` (user_id) używany w RLS policies

**Implementacja w Flutter:**
```dart
// Token automatycznie dołączany przez SupabaseClient
final response = await _supabase
  .from('reading_sessions')
  .select()
  .eq('book_id', bookId);
// Authorization header dodawany automatycznie
```

---

#### Row Level Security (RLS)

**Policy dla SELECT:**
```sql
CREATE POLICY "Users can view their own reading sessions"
  ON reading_sessions FOR SELECT
  USING (auth.uid() = user_id);
```

**Działanie:**
- Każde zapytanie SELECT automatycznie filtrowane: `WHERE user_id = auth.uid()`
- Użytkownik nie może zobaczyć sesji innych użytkowników nawet znając `book_id`
- Próba dostępu do cudzych danych zwraca pustą listę (nie błąd 403)

**Policy dla INSERT:**
```sql
CREATE POLICY "Users can insert their own reading sessions"
  ON reading_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**Działanie:**
- Funkcja RPC musi ustawić `user_id = auth.uid()` przy INSERT
- Próba wstawienia rekordu z innym `user_id` kończy się błędem

---

### 6.2. Walidacja Danych

#### Client-side Validation (Flutter Service)

**Przed wysłaniem żądania:**
```dart
void _validateEndSessionDto(EndReadingSessionDto dto) {
  // 1. Validate UUID format
  if (!_isValidUuid(dto.bookId)) {
    throw ValidationException('Invalid book_id format');
  }
  
  // 2. Validate time ordering
  if (dto.endTime.isBefore(dto.startTime) || 
      dto.endTime.isAtSameMomentAs(dto.startTime)) {
    throw ValidationException('end_time must be after start_time');
  }
  
  // 3. Validate last_read_page
  if (dto.lastReadPage <= 0) {
    throw ValidationException('last_read_page must be positive');
  }
  
  // 4. Validate times are not in future (optional)
  final now = DateTime.now().toUtc();
  if (dto.endTime.isAfter(now)) {
    throw ValidationException('end_time cannot be in the future');
  }
}
```

**Zalety:**
- Szybka informacja zwrotna dla użytkownika
- Zmniejszenie niepotrzebnych żądań do serwera
- Lepsze UX (walidacja przed wysłaniem formularza)

---

#### Server-side Validation (PostgreSQL Function)

**W funkcji RPC `end_reading_session`:**
```sql
CREATE OR REPLACE FUNCTION end_reading_session(
  p_book_id UUID,
  p_start_time TIMESTAMPTZ,
  p_end_time TIMESTAMPTZ,
  p_last_read_page INTEGER
) RETURNS UUID AS $$
DECLARE
  v_book RECORD;
  v_session_id UUID;
  v_pages_read INTEGER;
  v_duration_minutes INTEGER;
BEGIN
  -- 1. Validate book ownership and fetch book data
  SELECT * INTO v_book 
  FROM books 
  WHERE id = p_book_id AND user_id = auth.uid();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Book not found or access denied';
  END IF;
  
  -- 2. Validate last_read_page
  IF p_last_read_page > v_book.page_count THEN
    RAISE EXCEPTION 'last_read_page (%) exceeds page_count (%)', 
      p_last_read_page, v_book.page_count;
  END IF;
  
  IF p_last_read_page <= 0 THEN
    RAISE EXCEPTION 'last_read_page must be positive';
  END IF;
  
  -- 3. Validate time ordering (checked by constraint, but explicit here)
  IF p_end_time <= p_start_time THEN
    RAISE EXCEPTION 'end_time must be after start_time';
  END IF;
  
  -- 4. Calculate derived values
  v_duration_minutes := EXTRACT(EPOCH FROM (p_end_time - p_start_time)) / 60;
  v_pages_read := p_last_read_page - v_book.last_read_page_number;
  
  -- 5. Skip if no progress (optional logic)
  IF v_pages_read <= 0 THEN
    RETURN NULL; -- No session created
  END IF;
  
  -- 6. Insert reading session
  INSERT INTO reading_sessions (
    user_id, book_id, start_time, end_time, 
    duration_minutes, pages_read, last_read_page_number
  ) VALUES (
    auth.uid(), p_book_id, p_start_time, p_end_time,
    v_duration_minutes, v_pages_read, p_last_read_page
  ) RETURNING id INTO v_session_id;
  
  -- 7. Update book progress
  UPDATE books 
  SET last_read_page_number = p_last_read_page,
      status = CASE 
        WHEN p_last_read_page >= page_count THEN 'finished'::book_status
        WHEN status = 'unread' THEN 'in_progress'::book_status
        ELSE status
      END
  WHERE id = p_book_id;
  
  RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;
```

**Kluczowe walidacje:**
- Weryfikacja właściciela książki (`user_id = auth.uid()`)
- Sprawdzenie zakresu `last_read_page`
- Walidacja kolejności czasów
- Obliczenie `pages_read` - musi być > 0 (sesja z 0 stron jest pomijana)

---

### 6.3. Ochrona przed atakami

#### SQL Injection
- **Ochrona:** PostgREST używa parametryzowanych zapytań
- **Dodatkowo:** Wszystkie parametry RPC są typowane (UUID, INTEGER, TIMESTAMPTZ)
- **Nie ma ryzyka** wstrzyknięcia SQL przez parametry

#### Race Conditions
**Scenariusz:** Dwa jednoczesne wywołania `end_reading_session` dla tej samej książki

**Ochrona:**
```sql
-- Transakcja w PostgreSQL zapewnia izolację
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SELECT FOR UPDATE można dodać dla dodatkowej ochrony
SELECT * FROM books WHERE id = p_book_id FOR UPDATE;
-- ... reszta logiki
COMMIT;
```

**Alternatywa:** Optymistic locking z wersjonowaniem rekordu książki

#### Replay Attacks
**Scenariusz:** Wielokrotne wysłanie tego samego request body

**Ochrona:**
- UUID sesji generowane przez bazę (nie klient) - każde wywołanie tworzy nowy rekord
- Walidacja `pages_read` - drugi raz zwróci 0 (jeśli ta sama `last_read_page`)
- **Potencjalne rozwiązanie:** Dodanie `unique constraint` na (`book_id`, `start_time`, `end_time`)

#### Rate Limiting
**Implementacja:** Po stronie Supabase lub API Gateway
- Limit żądań na użytkownika/IP (np. 100 req/min)
- Ochrona przed DoS/DDoS
- Konfiguracja w Supabase Project Settings

---

### 6.4. Bezpieczeństwo danych wrażliwych

#### Przechowywanie JWT
**Flutter:**
```dart
// Token przechowywany bezpiecznie przez supabase_flutter
// Używa secure storage (Keychain iOS / Keystore Android)
await Supabase.instance.client.auth.signIn(...);
// Token automatycznie odświeżany przy wygaśnięciu
```

**Zasady:**
- Nie przechowywać tokena w SharedPreferences (niezabezpieczone)
- Nie logować tokena w konsoli
- Używać HTTPS dla wszystkich żądań

#### Eksponowanie danych
- `user_id` w response jest UUID (nie email/nazwa użytkownika)
- Brak wrażliwych pól w reading_sessions (tylko metryki czytania)
- RLS zapewnia, że użytkownik widzi tylko swoje dane

---

## 7. Obsługa błędów

### 7.1. Hierarchia wyjątków

**Wykorzystywane custom exceptions z `lib/core/exceptions.dart`:**

```dart
// Base exception
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

// Auth errors
class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) 
    : super(message ?? 'Authentication required');
}

// Validation errors
class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

// Not found errors
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

// Server errors
class ServerException extends AppException {
  ServerException(String message) : super(message);
}

// Network errors
class NoInternetException extends AppException {
  NoInternetException() : super('No internet connection');
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message);
}

// Parse errors
class ParseException extends AppException {
  ParseException(String message) : super(message);
}
```

---

### 7.2. Mapowanie błędów Supabase

**W ReadingSessionService:**

```dart
try {
  // API call
  final response = await _supabase.from('reading_sessions')...;
  return parseResponse(response);
  
} on PostgrestException catch (e) {
  _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);
  
  // JWT/Auth errors
  if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
    throw UnauthorizedException(e.message);
  }
  
  // Row not found (może wskazywać na brak dostępu przez RLS)
  else if (e.code == 'PGRST116') {
    throw NotFoundException('Resource not found');
  }
  
  // Query parameter errors (validation)
  else if (e.code?.startsWith('PGRST1') ?? false) {
    throw ValidationException(e.message);
  }
  
  // PostgreSQL constraint violations (22xxx codes)
  else if (e.code?.startsWith('22') ?? false) {
    throw ValidationException(_parseConstraintError(e.message));
  }
  
  // RPC function errors (P0001 - raised exception)
  else if (e.code == 'P0001') {
    // Parse custom error from RAISE EXCEPTION
    throw ValidationException(e.message);
  }
  
  // Generic server error
  else {
    throw ServerException(e.message);
  }
  
} on FormatException catch (e) {
  _logger.severe('Parse error: ${e.message}', e);
  throw ParseException('Invalid response format');
  
} on SocketException catch (e) {
  _logger.warning('Network error: ${e.message}');
  throw NoInternetException();
  
} on TimeoutException catch (e) {
  _logger.warning('Timeout: ${e.message}');
  throw TimeoutException('Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s');
  
} catch (e) {
  _logger.severe('Unexpected error: $e', e);
  throw ServerException('An unexpected error occurred');
}
```

---

### 7.3. Szczegółowe scenariusze błędów

#### GET /reading_sessions

| Scenariusz | Exception Type | HTTP Code | User Message |
|------------|----------------|-----------|--------------|
| Brak JWT token | UnauthorizedException | 401 | "Musisz być zalogowany" |
| Nieprawidłowy UUID book_id | ValidationException | 400 | "Nieprawidłowy identyfikator książki" |
| Książka nie istnieje | OK (pusta lista) | 200 | - |
| Książka należy do innego użytkownika | OK (pusta lista) | 200 | - |
| Błąd połączenia | NoInternetException | - | "Sprawdź połączenie internetowe" |
| Timeout | TimeoutException | - | "Żądanie przekroczyło czas oczekiwania" |
| Błąd bazy danych | ServerException | 500 | "Wystąpił problem z serwerem" |

**Uwaga:** RLS powoduje, że brak dostępu do książki zwraca pustą listę, nie błąd 404.

---

#### POST /rpc/end_reading_session

| Scenariusz | Exception Type | HTTP Code | User Message |
|------------|----------------|-----------|--------------|
| Brak JWT token | UnauthorizedException | 401 | "Musisz być zalogowany" |
| Nieprawidłowy UUID book_id | ValidationException | 400 | "Nieprawidłowy identyfikator książki" |
| end_time <= start_time | ValidationException | 400 | "Czas zakończenia musi być późniejszy niż rozpoczęcia" |
| last_read_page <= 0 | ValidationException | 400 | "Numer strony musi być większy od 0" |
| last_read_page > page_count | ValidationException | 400 | "Przekroczono liczbę stron książki" |
| Książka nie istnieje | ValidationException | 400 | "Książka nie została znaleziona" |
| Książka należy do innego użytkownika | ValidationException | 400 | "Brak dostępu do tej książki" |
| pages_read = 0 | OK (null response) | 200 | "Nie zapisano sesji (brak postępu)" |
| Błąd w funkcji RPC | ServerException | 500 | "Nie udało się zapisać sesji" |
| Constraint violation | ValidationException | 400 | "Nieprawidłowe dane sesji" |
| Błąd połączenia | NoInternetException | - | "Sprawdź połączenie internetowe" |
| Timeout | TimeoutException | - | "Żądanie przekroczyło czas oczekiwania" |

---

### 7.4. Logging i Monitoring

**W każdym wywołaniu API:**

```dart
Future<List<ReadingSessionDto>> listReadingSessions(String bookId) async {
  _logger.info('Fetching reading sessions for book: $bookId');
  
  final stopwatch = Stopwatch()..start();
  
  try {
    // ... API call
    
    stopwatch.stop();
    _logger.info('Successfully fetched ${sessions.length} sessions in ${stopwatch.elapsedMilliseconds}ms');
    return sessions;
    
  } catch (e) {
    stopwatch.stop();
    _logger.severe('Failed to fetch sessions after ${stopwatch.elapsedMilliseconds}ms', e);
    rethrow;
  }
}
```

**Log levels:**
- `INFO` - normalne operacje (rozpoczęcie/zakończenie żądania)
- `WARNING` - niefatalne problemy (timeout, brak internetu)
- `SEVERE` - błędy wymagające uwagi (błędy serwera, parse errors)

**Metryki do monitorowania:**
- Czas odpowiedzi API (p50, p95, p99)
- Częstotliwość błędów (error rate)
- Najczęstsze typy błędów
- Użycie przez użytkownika (liczba sesji na użytkownika)

---

## 8. Rozważania dotyczące wydajności

### 8.1. Indeksy bazy danych

**Istniejące indeksy (z db-plan.md):**

```sql
-- Dla zapytań filtrujących po book_id
CREATE INDEX idx_reading_sessions_book_id 
  ON reading_sessions(book_id);

-- Dla zapytań z sortowaniem
CREATE INDEX idx_reading_sessions_book_created 
  ON reading_sessions(book_id, created_at DESC);

-- Dla statystyk użytkownika
CREATE INDEX idx_reading_sessions_user_id 
  ON reading_sessions(user_id);

-- Dla zapytań analitycznych po czasie
CREATE INDEX idx_reading_sessions_end_time 
  ON reading_sessions(end_time);
```

**Query optimization dla GET /reading_sessions:**
```sql
-- To zapytanie wykorzysta idx_reading_sessions_book_created
SELECT * FROM reading_sessions
WHERE book_id = 'uuid-value'
  AND user_id = auth.uid()  -- dodane przez RLS
ORDER BY created_at DESC;

-- Execution plan: Index Scan using idx_reading_sessions_book_created
```

**Wskazówki:**
- Indeks `(book_id, created_at DESC)` jest optymalny dla najczęstszego zapytania
- RLS dodaje filtr `user_id` - może wymagać dodatkowego sprawdzenia
- Dla bardzo aktywnych użytkowników (>1000 sesji na książkę) rozważyć partycjonowanie

---

### 8.2. Caching (przyszłe rozszerzenie)

**Potencjalne strategie:**

#### Client-side caching
```dart
class ReadingSessionService {
  final Map<String, List<ReadingSessionDto>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheValidity = Duration(minutes: 5);
  
  Future<List<ReadingSessionDto>> listReadingSessions(
    String bookId, {
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh && _isCacheValid(bookId)) {
      _logger.info('Returning cached sessions for book: $bookId');
      return _cache[bookId]!;
    }
    
    // Fetch from API
    final sessions = await _fetchFromApi(bookId);
    
    // Update cache
    _cache[bookId] = sessions;
    _cacheTimestamps[bookId] = DateTime.now();
    
    return sessions;
  }
  
  bool _isCacheValid(String bookId) {
    if (!_cache.containsKey(bookId)) return false;
    final age = DateTime.now().difference(_cacheTimestamps[bookId]!);
    return age < _cacheValidity;
  }
}
```

**Uwagi:**
- Cache invalidation po `endReadingSession()` - dodaj nową sesję do cache lokalnie
- Rozważyć użycie dedykowanej biblioteki (Hive, Isar) dla persistent cache
- Cache tylko dla GET, nie dla POST

---

### 8.3. Paginacja (przyszłe rozszerzenie)

**Obecnie:** Brak limitu w specyfikacji MVP

**Zalecane dla produkcji:**
```dart
Future<List<ReadingSessionDto>> listReadingSessions(
  String bookId, {
  int limit = 50,
  int offset = 0,
}) async {
  // Validate pagination parameters
  if (limit < 1 || limit > 1000) {
    throw ValidationException('Limit must be between 1 and 1000');
  }
  
  // Query with range
  final query = _supabase
    .from('reading_sessions')
    .select()
    .eq('book_id', bookId)
    .order('created_at', ascending: false)
    .range(offset, offset + limit - 1);
  
  // ...
}
```

**Infinite scrolling w UI:**
```dart
// Load more sessions when user scrolls to bottom
void _loadMore() {
  if (_hasMore && !_isLoading) {
    setState(() => _offset += _limit);
    _fetchSessions();
  }
}
```

---

### 8.4. Optymalizacje RPC Function

**Unikanie zbędnych SELECT:**

```sql
-- Zamiast dwóch zapytań:
SELECT * FROM books WHERE id = p_book_id;
UPDATE books SET last_read_page_number = p_last_read_page WHERE id = p_book_id;

-- Użyj jednego z RETURNING:
UPDATE books 
SET last_read_page_number = p_last_read_page,
    status = CASE WHEN p_last_read_page >= page_count THEN 'finished'::book_status ELSE status END
WHERE id = p_book_id AND user_id = auth.uid()
RETURNING page_count INTO v_page_count;

IF NOT FOUND THEN
  RAISE EXCEPTION 'Book not found or access denied';
END IF;
```

**Connection pooling:**
- Supabase automatycznie zarządza connection pool
- Dla wysokiego obciążenia: zwiększyć `max_connections` w database settings

---

### 8.5. Timeout Configuration

**Client-side timeouts:**
```dart
class ApiConstants {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration rpcTimeout = Duration(seconds: 45); // RPC może trwać dłużej
}

// W service:
final response = await _supabase
  .rpc('end_reading_session', params: dto.toRequestJson())
  .timeout(ApiConstants.rpcTimeout);
```

**Server-side timeouts:**
- PostgreSQL `statement_timeout` - zapobiega długo działającym zapytaniom
- Supabase ma domyślne limity czasu dla RPC (zazwyczaj 60s)

---

### 8.6. Batch Operations (przyszłe)

**Scenariusz:** Synchronizacja wielu offline sesji

```dart
Future<List<String?>> endMultipleReadingSessions(
  List<EndReadingSessionDto> sessions,
) async {
  // Opcja 1: Sequential calls (prostsze, ale wolniejsze)
  final results = <String?>[];
  for (final session in sessions) {
    results.add(await endReadingSession(session));
  }
  return results;
  
  // Opcja 2: Parallel calls (szybsze, ale limit concurrent connections)
  return await Future.wait(
    sessions.map((session) => endReadingSession(session)),
  );
  
  // Opcja 3: Batch RPC function (najbardziej efektywne)
  // Wymaga dedykowanej funkcji PostgreSQL end_reading_sessions_batch
}
```

---

## 9. Etapy wdrożenia

### Krok 1: Przygotowanie środowiska

**1.1. Utworzenie funkcji RPC w Supabase**

Przejdź do Supabase Dashboard → SQL Editor i wykonaj:

```sql
CREATE OR REPLACE FUNCTION end_reading_session(
  p_book_id UUID,
  p_start_time TIMESTAMPTZ,
  p_end_time TIMESTAMPTZ,
  p_last_read_page INTEGER
) RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_book RECORD;
  v_session_id UUID;
  v_pages_read INTEGER;
  v_duration_minutes INTEGER;
  v_user_id UUID;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;
  
  -- Validate and fetch book data
  SELECT * INTO v_book 
  FROM books 
  WHERE id = p_book_id AND user_id = v_user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Book not found or access denied';
  END IF;
  
  -- Validate last_read_page
  IF p_last_read_page > v_book.page_count THEN
    RAISE EXCEPTION 'Invalid last_read_page: exceeds page_count (% > %)', 
      p_last_read_page, v_book.page_count;
  END IF;
  
  IF p_last_read_page <= 0 THEN
    RAISE EXCEPTION 'Invalid last_read_page: must be positive';
  END IF;
  
  -- Validate time ordering
  IF p_end_time <= p_start_time THEN
    RAISE EXCEPTION 'Invalid time range: end_time must be after start_time';
  END IF;
  
  -- Calculate derived values
  v_duration_minutes := CEIL(EXTRACT(EPOCH FROM (p_end_time - p_start_time)) / 60);
  v_pages_read := p_last_read_page - v_book.last_read_page_number;
  
  -- Skip if no progress
  IF v_pages_read <= 0 THEN
    RETURN NULL;
  END IF;
  
  -- Insert reading session
  INSERT INTO reading_sessions (
    user_id, 
    book_id, 
    start_time, 
    end_time, 
    duration_minutes, 
    pages_read, 
    last_read_page_number
  ) VALUES (
    v_user_id,
    p_book_id,
    p_start_time,
    p_end_time,
    v_duration_minutes,
    v_pages_read,
    p_last_read_page
  ) RETURNING id INTO v_session_id;
  
  -- Update book progress and status
  UPDATE books 
  SET 
    last_read_page_number = p_last_read_page,
    status = CASE 
      WHEN p_last_read_page >= page_count THEN 'finished'::book_status
      WHEN status = 'unread' THEN 'in_progress'::book_status
      ELSE status
    END,
    updated_at = NOW()
  WHERE id = p_book_id;
  
  RETURN v_session_id;
END;
$$;
```

**1.2. Weryfikacja funkcji**

Test w SQL Editor:
```sql
-- Test jako zalogowany użytkownik
SELECT end_reading_session(
  '<your-book-uuid>',
  '2025-10-13T10:00:00Z',
  '2025-10-13T10:30:00Z',
  50
);
```

---

### Krok 2: Utworzenie ReadingSessionService

**2.1. Utworzenie pliku serwisu**

Utwórz `lib/services/reading_session_service.dart`:

```dart
/// Service for managing reading session operations via Supabase REST API
///
/// This service provides methods for:
/// - Listing reading sessions for a specific book
/// - Ending a reading session (creating new session + updating book progress)
///
/// All operations are automatically protected by Row-Level Security (RLS),
/// ensuring users can only access their own data.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../models/database_types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

class ReadingSessionService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('ReadingSessionService');

  ReadingSessionService(this._supabase);

  // Implementation methods will be added in next steps
}
```

---

### Krok 3: Implementacja metody listReadingSessions

**3.1. Dodanie metody do ReadingSessionService**

```dart
  /// Fetches reading sessions for a specific book
  ///
  /// Returns a list of sessions sorted by creation date (newest first by default).
  /// RLS ensures only sessions belonging to the authenticated user are returned.
  ///
  /// **Parameters:**
  /// - [bookId]: UUID of the book to fetch sessions for (required)
  /// - [orderBy]: Field to sort by (default: 'created_at')
  /// - [ascending]: Sort direction (default: false = descending)
  ///
  /// **Returns:**
  /// List of [ReadingSessionDto], may be empty if no sessions exist
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid bookId format
  /// - [UnauthorizedException]: Authentication failed
  /// - [ServerException]: Database error
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request timeout
  ///
  /// **Example:**
  /// ```dart
  /// final sessions = await readingSessionService.listReadingSessions(
  ///   'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
  /// );
  /// ```
  Future<List<ReadingSessionDto>> listReadingSessions(
    String bookId, {
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    _logger.info(
      'Fetching reading sessions for book: $bookId, '
      'orderBy: $orderBy, ascending: $ascending',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Validate bookId format
      if (!_isValidUuid(bookId)) {
        throw ValidationException('Invalid book_id format (must be UUID)');
      }

      // Build query
      // RLS automatically adds: WHERE user_id = auth.uid()
      final query = _supabase
          .from('reading_sessions')
          .select()
          .eq('book_id', bookId)
          .order(orderBy, ascending: ascending);

      // Execute with timeout
      final response = await query.timeout(ApiConstants.defaultTimeout);

      // Parse response
      final sessions = (response as List)
          .map((json) =>
              ReadingSessionDto.fromJson(json as Map<String, dynamic>))
          .toList();

      stopwatch.stop();
      _logger.info(
        'Successfully fetched ${sessions.length} sessions in ${stopwatch.elapsedMilliseconds}ms',
      );

      return sessions;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);
      _handlePostgrestException(e);
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
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }
```

---

### Krok 4: Implementacja metody endReadingSession

**4.1. Dodanie metody do ReadingSessionService**

```dart
  /// Ends a reading session by calling the PostgreSQL RPC function
  ///
  /// This method atomically:
  /// 1. Creates a new reading_session record
  /// 2. Updates book.last_read_page_number
  /// 3. Automatically updates book.status to 'finished' if completed
  ///
  /// **Parameters:**
  /// - [dto]: EndReadingSessionDto with session details
  ///
  /// **Returns:**
  /// - UUID string of created session if successful
  /// - null if no progress was made (pages_read = 0)
  ///
  /// **Throws:**
  /// - [ValidationException]: Invalid input data
  /// - [UnauthorizedException]: Authentication failed
  /// - [ServerException]: RPC function error
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request timeout
  ///
  /// **Example:**
  /// ```dart
  /// final dto = EndReadingSessionDto(
  ///   bookId: 'book-uuid',
  ///   startTime: DateTime.now().subtract(Duration(minutes: 30)),
  ///   endTime: DateTime.now(),
  ///   lastReadPage: 150,
  /// );
  /// final sessionId = await readingSessionService.endReadingSession(dto);
  /// ```
  Future<String?> endReadingSession(EndReadingSessionDto dto) async {
    _logger.info(
      'Ending reading session for book: ${dto.bookId}, '
      'pages: ${dto.lastReadPage}',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Validate DTO before sending
      _validateEndSessionDto(dto);

      // Call RPC function
      final response = await _supabase.rpc(
        'end_reading_session',
        params: dto.toRequestJson(),
      ).timeout(ApiConstants.defaultTimeout);

      stopwatch.stop();

      // Parse response (UUID string or null)
      final sessionId = response as String?;

      if (sessionId != null) {
        _logger.info(
          'Successfully created reading session $sessionId in ${stopwatch.elapsedMilliseconds}ms',
        );
      } else {
        _logger.info(
          'No session created (no progress) in ${stopwatch.elapsedMilliseconds}ms',
        );
      }

      return sessionId;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('RPC error: ${e.message} (code: ${e.code})', e);
      _handlePostgrestException(e);
    } on SocketException catch (e) {
      stopwatch.stop();
      _logger.warning('No internet connection: ${e.message}');
      throw NoInternetException();
    } on TimeoutException catch (e) {
      stopwatch.stop();
      _logger.warning('Request timeout: ${e.message}');
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }
```

---

### Krok 5: Implementacja metod pomocniczych

**5.1. Dodanie walidacji i error handling**

```dart
  /// Validates EndReadingSessionDto before sending to API
  void _validateEndSessionDto(EndReadingSessionDto dto) {
    // Validate UUID format
    if (!_isValidUuid(dto.bookId)) {
      throw ValidationException('Invalid book_id format (must be UUID)');
    }

    // Validate time ordering
    if (dto.endTime.isBefore(dto.startTime) ||
        dto.endTime.isAtSameMomentAs(dto.startTime)) {
      throw ValidationException('end_time must be after start_time');
    }

    // Validate last_read_page
    if (dto.lastReadPage <= 0) {
      throw ValidationException('last_read_page must be positive');
    }

    // Optional: Validate times are not in future
    final now = DateTime.now().toUtc();
    if (dto.endTime.isAfter(now)) {
      throw ValidationException('end_time cannot be in the future');
    }

    if (dto.startTime.isAfter(now)) {
      throw ValidationException('start_time cannot be in the future');
    }
  }

  /// Checks if a string is a valid UUID (v4) format
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Handles PostgrestException and throws appropriate custom exception
  Never _handlePostgrestException(PostgrestException e) {
    // JWT/Auth errors
    if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
      throw UnauthorizedException(e.message);
    }
    // Resource not found
    else if (e.code == 'PGRST116') {
      throw NotFoundException('Resource not found');
    }
    // Query parameter errors
    else if (e.code?.startsWith('PGRST1') ?? false) {
      throw ValidationException(e.message);
    }
    // PostgreSQL constraint violations
    else if (e.code?.startsWith('22') ?? false) {
      throw ValidationException(_parseConstraintError(e.message));
    }
    // RPC function raised exception (P0001)
    else if (e.code == 'P0001') {
      throw ValidationException(e.message);
    }
    // Generic server error
    else {
      throw ServerException(e.message);
    }
  }

  /// Parses PostgreSQL constraint error messages to user-friendly format
  String _parseConstraintError(String message) {
    // Example: "new row for relation "reading_sessions" violates check constraint "check_end_after_start""
    if (message.contains('check_end_after_start')) {
      return 'End time must be after start time';
    }
    if (message.contains('pages_read')) {
      return 'Invalid pages_read value';
    }
    if (message.contains('duration_minutes')) {
      return 'Invalid session duration';
    }
    // Return original message if no specific pattern matched
    return message;
  }
```

---

### Krok 6: Testy jednostkowe

**6.1. Utworzenie pliku testowego**

Utwórz `test/services/reading_session_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/services/reading_session_service.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/core/exceptions.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
import 'reading_session_service_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late ReadingSessionService service;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    service = ReadingSessionService(mockSupabase);
  });

  group('listReadingSessions', () {
    const testBookId = 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c';

    test('returns list of sessions when successful', () async {
      // Arrange
      final mockResponse = [
        {
          'id': 'session-1',
          'user_id': 'user-1',
          'book_id': testBookId,
          'start_time': '2025-10-12T18:00:00Z',
          'end_time': '2025-10-12T18:30:00Z',
          'duration_minutes': 30,
          'pages_read': 25,
          'last_read_page_number': 150,
          'created_at': '2025-10-12T18:30:05Z',
        },
      ];

      final mockQuery = MockSupabaseQueryBuilder();
      when(mockSupabase.from('reading_sessions')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('book_id', testBookId)).thenReturn(mockQuery);
      when(mockQuery.order('created_at', ascending: false))
          .thenReturn(mockQuery);
      when(mockQuery.timeout(any)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await service.listReadingSessions(testBookId);

      // Assert
      expect(result, isA<List<ReadingSessionDto>>());
      expect(result.length, 1);
      expect(result.first.id, 'session-1');
      expect(result.first.bookId, testBookId);
    });

    test('throws ValidationException for invalid UUID', () async {
      // Act & Assert
      expect(
        () => service.listReadingSessions('invalid-uuid'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws UnauthorizedException when JWT is invalid', () async {
      // Arrange
      final mockQuery = MockSupabaseQueryBuilder();
      when(mockSupabase.from('reading_sessions')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('book_id', testBookId)).thenReturn(mockQuery);
      when(mockQuery.order('created_at', ascending: false))
          .thenReturn(mockQuery);
      when(mockQuery.timeout(any)).thenThrow(
        PostgrestException(message: 'JWT expired', code: 'PGRST301'),
      );

      // Act & Assert
      expect(
        () => service.listReadingSessions(testBookId),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('returns empty list when no sessions exist', () async {
      // Arrange
      final mockQuery = MockSupabaseQueryBuilder();
      when(mockSupabase.from('reading_sessions')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('book_id', testBookId)).thenReturn(mockQuery);
      when(mockQuery.order('created_at', ascending: false))
          .thenReturn(mockQuery);
      when(mockQuery.timeout(any)).thenAnswer((_) async => []);

      // Act
      final result = await service.listReadingSessions(testBookId);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('endReadingSession', () {
    test('returns session ID when successful', () async {
      // Arrange
      final dto = EndReadingSessionDto(
        bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
        startTime: DateTime.parse('2025-10-12T18:00:00Z'),
        endTime: DateTime.parse('2025-10-12T18:30:00Z'),
        lastReadPage: 150,
      );

      final mockRpc = MockSupabaseQueryBuilder();
      when(mockSupabase.rpc('end_reading_session', params: anyNamed('params')))
          .thenReturn(mockRpc);
      when(mockRpc.timeout(any))
          .thenAnswer((_) async => 'new-session-uuid');

      // Act
      final result = await service.endReadingSession(dto);

      // Assert
      expect(result, 'new-session-uuid');
    });

    test('returns null when no progress made', () async {
      // Arrange
      final dto = EndReadingSessionDto(
        bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
        startTime: DateTime.parse('2025-10-12T18:00:00Z'),
        endTime: DateTime.parse('2025-10-12T18:30:00Z'),
        lastReadPage: 100, // Same as current progress
      );

      final mockRpc = MockSupabaseQueryBuilder();
      when(mockSupabase.rpc('end_reading_session', params: anyNamed('params')))
          .thenReturn(mockRpc);
      when(mockRpc.timeout(any)).thenAnswer((_) async => null);

      // Act
      final result = await service.endReadingSession(dto);

      // Assert
      expect(result, isNull);
    });

    test('throws ValidationException when end_time before start_time', () {
      // Arrange
      final dto = EndReadingSessionDto(
        bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
        startTime: DateTime.parse('2025-10-12T19:00:00Z'),
        endTime: DateTime.parse('2025-10-12T18:00:00Z'), // Before start
        lastReadPage: 150,
      );

      // Act & Assert
      expect(
        () => service.endReadingSession(dto),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when last_read_page is zero', () {
      // Arrange
      final dto = EndReadingSessionDto(
        bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
        startTime: DateTime.parse('2025-10-12T18:00:00Z'),
        endTime: DateTime.parse('2025-10-12T18:30:00Z'),
        lastReadPage: 0, // Invalid
      );

      // Act & Assert
      expect(
        () => service.endReadingSession(dto),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when RPC raises exception', () async {
      // Arrange
      final dto = EndReadingSessionDto(
        bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
        startTime: DateTime.parse('2025-10-12T18:00:00Z'),
        endTime: DateTime.parse('2025-10-12T18:30:00Z'),
        lastReadPage: 500, // Exceeds page_count
      );

      final mockRpc = MockSupabaseQueryBuilder();
      when(mockSupabase.rpc('end_reading_session', params: anyNamed('params')))
          .thenReturn(mockRpc);
      when(mockRpc.timeout(any)).thenThrow(
        PostgrestException(
          message: 'Invalid last_read_page: exceeds page_count',
          code: 'P0001',
        ),
      );

      // Act & Assert
      expect(
        () => service.endReadingSession(dto),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

**6.2. Uruchomienie testów**

```bash
# Wygeneruj mocks
flutter pub run build_runner build

# Uruchom testy
flutter test test/services/reading_session_service_test.dart
```

---

### Krok 7: Integracja w aplikacji

**7.1. Rejestracja serwisu w Dependency Injection**

Jeśli używasz GetIt lub podobnego:

```dart
// lib/core/di.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/reading_session_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Supabase Client (singleton)
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  
  // Reading Session Service
  getIt.registerLazySingleton<ReadingSessionService>(
    () => ReadingSessionService(getIt<SupabaseClient>()),
  );
}
```

**7.2. Użycie w UI/BLoC/Provider**

Przykład użycia w BLoC:

```dart
// lib/blocs/reading_session_bloc.dart
class ReadingSessionBloc extends Bloc<ReadingSessionEvent, ReadingSessionState> {
  final ReadingSessionService _sessionService;
  
  ReadingSessionBloc(this._sessionService) : super(ReadingSessionInitial()) {
    on<LoadReadingSessions>(_onLoadSessions);
    on<EndReadingSession>(_onEndSession);
  }
  
  Future<void> _onLoadSessions(
    LoadReadingSessions event,
    Emitter<ReadingSessionState> emit,
  ) async {
    emit(ReadingSessionLoading());
    try {
      final sessions = await _sessionService.listReadingSessions(event.bookId);
      emit(ReadingSessionLoaded(sessions));
    } on UnauthorizedException {
      emit(ReadingSessionError('Please log in'));
    } on ValidationException catch (e) {
      emit(ReadingSessionError(e.message));
    } on NoInternetException {
      emit(ReadingSessionError('No internet connection'));
    } catch (e) {
      emit(ReadingSessionError('Failed to load sessions'));
    }
  }
  
  Future<void> _onEndSession(
    EndReadingSession event,
    Emitter<ReadingSessionState> emit,
  ) async {
    try {
      final sessionId = await _sessionService.endReadingSession(event.dto);
      
      if (sessionId != null) {
        emit(ReadingSessionEnded(sessionId));
      } else {
        emit(ReadingSessionError('No progress recorded'));
      }
    } on ValidationException catch (e) {
      emit(ReadingSessionError(e.message));
    } on UnauthorizedException {
      emit(ReadingSessionError('Please log in'));
    } catch (e) {
      emit(ReadingSessionError('Failed to save session'));
    }
  }
}
```

---

### Krok 8: Dokumentacja i przykłady użycia

**8.1. Aktualizacja README**

Dodaj sekcję do README.md:

```markdown
## Reading Session Management

### List Reading Sessions

```dart
final sessionService = getIt<ReadingSessionService>();

try {
  final sessions = await sessionService.listReadingSessions(
    bookId,
    orderBy: 'created_at',
    ascending: false, // Newest first
  );
  
  print('Found ${sessions.length} sessions');
  for (final session in sessions) {
    print('Session: ${session.durationMinutes} minutes, ${session.pagesRead} pages');
  }
} on ValidationException catch (e) {
  print('Invalid input: ${e.message}');
} on UnauthorizedException {
  print('Please log in');
} catch (e) {
  print('Error: $e');
}
```

### End Reading Session

```dart
final dto = EndReadingSessionDto(
  bookId: 'your-book-uuid',
  startTime: DateTime.now().subtract(Duration(minutes: 30)),
  endTime: DateTime.now(),
  lastReadPage: 150,
);

try {
  final sessionId = await sessionService.endReadingSession(dto);
  
  if (sessionId != null) {
    print('Session created: $sessionId');
  } else {
    print('No progress recorded');
  }
} on ValidationException catch (e) {
  print('Invalid data: ${e.message}');
} catch (e) {
  print('Error: $e');
}
```
```

**8.2. Utworzenie przykładowego pliku**

`lib/models/example_usage.dart` (rozszerz istniejący):

```dart
/// Example: List reading sessions for a book
Future<void> exampleListReadingSessions() async {
  final service = ReadingSessionService(Supabase.instance.client);
  
  final sessions = await service.listReadingSessions(
    'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
  );
  
  print('Found ${sessions.length} reading sessions');
  
  for (final session in sessions) {
    print('Session ${session.id}:');
    print('  Duration: ${session.durationMinutes} minutes');
    print('  Pages read: ${session.pagesRead}');
    print('  Last page: ${session.lastReadPageNumber}');
    print('  Date: ${session.createdAt}');
  }
}

/// Example: End a reading session
Future<void> exampleEndReadingSession() async {
  final service = ReadingSessionService(Supabase.instance.client);
  
  final dto = EndReadingSessionDto(
    bookId: 'c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c',
    startTime: DateTime.now().subtract(Duration(minutes: 45)),
    endTime: DateTime.now(),
    lastReadPage: 200,
  );
  
  try {
    final sessionId = await service.endReadingSession(dto);
    
    if (sessionId != null) {
      print('Reading session created: $sessionId');
      print('Book progress updated to page 200');
    } else {
      print('No session created (no progress made)');
    }
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  }
}
```

---

### Krok 9: Testy integracyjne (opcjonalne)

**9.1. Test z prawdziwym Supabase (test środowiskowy)**

Utwórz `test/integration/reading_session_integration_test.dart`:

```dart
@Tags(['integration'])
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/services/reading_session_service.dart';
import 'package:my_book_library/models/types.dart';

void main() {
  late ReadingSessionService service;
  late SupabaseClient supabase;
  
  setUpAll(() async {
    // Initialize Supabase with test credentials
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    
    supabase = Supabase.instance.client;
    
    // Sign in test user
    await supabase.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'test123',
    );
    
    service = ReadingSessionService(supabase);
  });
  
  tearDownAll(() async {
    await supabase.auth.signOut();
  });
  
  test('End-to-end: create session and fetch it', () async {
    // 1. Create a test book first (or use existing test data)
    final testBookId = 'your-test-book-uuid';
    
    // 2. End a reading session
    final dto = EndReadingSessionDto(
      bookId: testBookId,
      startTime: DateTime.now().subtract(Duration(minutes: 30)),
      endTime: DateTime.now(),
      lastReadPage: 50,
    );
    
    final sessionId = await service.endReadingSession(dto);
    expect(sessionId, isNotNull);
    
    // 3. Fetch sessions and verify
    final sessions = await service.listReadingSessions(testBookId);
    expect(sessions.any((s) => s.id == sessionId), isTrue);
    
    final createdSession = sessions.firstWhere((s) => s.id == sessionId);
    expect(createdSession.lastReadPageNumber, 50);
    expect(createdSession.pagesRead, greaterThan(0));
  }, skip: 'Requires live Supabase instance and test data');
}
```

**Uruchomienie:**
```bash
flutter test --tags integration
```

---

### Krok 10: Code Review i Deployment Checklist

**10.1. Checklist przed merge**

- [ ] Funkcja RPC `end_reading_session` utworzona w Supabase
- [ ] Funkcja przetestowana w SQL Editor
- [ ] ReadingSessionService zaimplementowany z pełną dokumentacją
- [ ] Wszystkie metody mają obsługę błędów
- [ ] Walidacja parametrów na poziomie klienta
- [ ] Testy jednostkowe napisane i przechodzą (coverage > 80%)
- [ ] Logging dodany do wszystkich kluczowych operacji
- [ ] Timeouty skonfigurowane dla wszystkich zapytań API
- [ ] DTOs prawidłowo mapowane (snake_case ↔ camelCase)
- [ ] Przykłady użycia dodane do dokumentacji
- [ ] RLS policies zweryfikowane (użytkownik widzi tylko swoje dane)
- [ ] Kod zgodny z linterem (flutter analyze bez błędów)
- [ ] README zaktualizowane z nowymi endpointami
- [ ] Integracja z UI/BLoC/Provider zaimplementowana (lub zaplanowana)

**10.2. Metryki do monitorowania po wdrożeniu**

- Średni czas odpowiedzi dla `listReadingSessions` (target: < 500ms)
- Średni czas odpowiedzi dla `endReadingSession` (target: < 1000ms)
- Error rate dla obu endpointów (target: < 1%)
- Liczba sesji tworzonych dziennie (metrika biznesowa)
- Procent sesji zwracających null (brak postępu)

---

## 10. Podsumowanie

Ten plan implementacji dostarcza kompleksowych wskazówek dla zespołu programistów do wdrożenia endpointów Reading Sessions. Kluczowe punkty:

### Zalety architektury:
- **Separacja warstw**: Service Layer oddzielony od UI i bazy danych
- **Atomowość**: RPC function zapewnia transakcyjne wykonanie operacji
- **Bezpieczeństwo**: RLS + JWT + walidacje na wielu poziomach
- **Obsługa błędów**: Szczegółowe mapowanie błędów na custom exceptions
- **Testowalność**: Mockable dependencies, comprehensive tests

### Najważniejsze zagrożenia:
- Race conditions przy jednoczesnych wywołaniach (mitigowane przez transakcje)
- Replay attacks (można dodać unique constraint)
- Performance przy dużej liczbie sesji (rozwiązane przez indeksy i paginację)

### Następne kroki po implementacji:
1. Integracja z UI (ekrany czytania książki)
2. Implementacja offline support (queue sesji do synchronizacji)
3. Dodanie paginacji do listReadingSessions
4. Rozbudowa o statystyki (tygodniowy czas czytania, streak)
5. Optymalizacja wydajności na podstawie metryk

Plan jest gotowy do wykonania przez zespół programistów zgodnie z określonymi krokami.


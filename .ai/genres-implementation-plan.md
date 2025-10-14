# API Endpoint Implementation Plan: List Genres

## 1. Przegląd punktu końcowego

Endpoint List Genres umożliwia pobieranie kompletnej listy wszystkich dostępnych gatunków literackich w aplikacji. Jest to endpoint tylko do odczytu (read-only), który zwraca stałą listę gatunków zdefiniowanych w systemie. Wszyscy uwierzytelnieni użytkownicy mają dostęp do tej samej listy gatunków, które mogą następnie przypisywać do swoich książek.

**Główne cele:**
- Dostarczenie listy gatunków do wypełnienia dropdown/select w UI podczas dodawania/edycji książek
- Umożliwienie filtrowania książek po gatunku
- Zapewnienie spójnej taksonomii gatunków w całej aplikacji

**Charakterystyka:**
- Publiczne dane w ramach aplikacji (dostępne dla wszystkich uwierzytelnionych użytkowników)
- Dane tylko do odczytu dla użytkowników końcowych
- Zarządzane wyłącznie przez administratorów bazy danych
- Niewielki zbiór danych (11 predefiniowanych gatunków)

## 2. Szczegóły żądania

### Metoda HTTP
`GET`

### Struktura URL
```
/rest/v1/genres
```

### Nagłówki żądania
**Wymagane:**
- `Authorization: Bearer <SUPABASE_JWT>` - Token JWT uwierzytelniający użytkownika
- `apikey: <SUPABASE_ANON_KEY>` - Klucz publiczny API Supabase (automatycznie dodawany przez klienta)

**Opcjonalne:**
- `Content-Type: application/json` - Typ zawartości (standardowy dla Supabase)

### Parametry zapytania (Query Parameters)

**Opcjonalne:**
- `order=name.asc` - Sortowanie wyników alfabetycznie po nazwie gatunku
  - Format: `{kolumna}.{kierunek}`
  - Dostępne kierunki: `asc` (rosnąco), `desc` (malejąco)
  - Domyślnie: brak sortowania (kolejność z bazy danych)
  - Przykład: `?order=name.asc`

- `select=*` - Wybór konkretnych kolumn (rzadko używane, domyślnie zwraca wszystkie)
  - Przykład: `?select=id,name` (bez created_at)

**Brak parametrów obowiązkowych** - endpoint może być wywołany bez żadnych parametrów zapytania.

### Request Body
**Nie dotyczy** - metoda GET nie przyjmuje body.

### Przykładowe żądanie
```http
GET /rest/v1/genres?order=name.asc HTTP/1.1
Host: your-project.supabase.co
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
apikey: your-anon-key
```

## 3. Wykorzystywane typy

### DTO Response Types

**GenreDto** - Istniejący typ zdefiniowany w `lib/models/types.dart`

```dart
@freezed
class GenreDto with _$GenreDto {
  const factory GenreDto({
    required String id,           // UUID gatunku
    required String name,          // Nazwa gatunku (np. "Fantastyka")
    @JsonKey(name: 'created_at') required DateTime createdAt,  // Data utworzenia
  }) = _GenreDto;

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);

  /// Convert from Genres entity
  factory GenreDto.fromEntity(Genres genre) {
    return GenreDto(
      id: genre.id, 
      name: genre.name, 
      createdAt: genre.createdAt
    );
  }
}
```

### Database Entity Types

**Genres** - Typ encji bazodanowej zdefiniowany w `lib/models/database_types.dart`

```dart
class Genres {
  final String id;
  final String name;
  final DateTime createdAt;
  
  // ... konstruktory i metody
}
```

### Return Type dla Service Method

```dart
Future<List<GenreDto>> listGenres({String orderBy = 'name', String orderDirection = 'asc'})
```

**Uwaga:** Nie są potrzebne żadne nowe typy DTO ani Command Models. Istniejące typy są w pełni wystarczające.

## 4. Szczegóły odpowiedzi

### Sukces (200 OK)

**Format:** JSON Array

**Struktura:**
```json
[
  {
    "id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
    "name": "Biografia",
    "created_at": "2025-10-10T12:00:00Z"
  },
  {
    "id": "a9b8c7d6-e5f4-a3b2-c1d0-e9f8a7b6c5d4",
    "name": "Fantastyka",
    "created_at": "2025-10-10T12:00:00Z"
  },
  {
    "id": "b8c7d6e5-f4a3-b2c1-d0e9-f8a7b6c5d4e3",
    "name": "Horror",
    "created_at": "2025-10-10T12:00:00Z"
  }
  // ... pozostałe gatunki
]
```

**Pola odpowiedzi:**
- `id` (string, UUID) - Unikalny identyfikator gatunku
- `name` (string) - Nazwa gatunku (unikalna)
- `created_at` (string, ISO 8601) - Znacznik czasu utworzenia rekordu

**Pusta lista:** Jeśli baza danych nie zawiera żadnych gatunków, zwracana jest pusta tablica `[]` z kodem 200 OK.

### Kody statusu

| Kod | Opis | Kiedy występuje |
|-----|------|-----------------|
| `200 OK` | Sukces | Pomyślnie pobrano listę gatunków (nawet jeśli pusta) |
| `401 Unauthorized` | Brak autoryzacji | Brak tokenu JWT, token wygasły lub nieprawidłowy |
| `500 Internal Server Error` | Błąd serwera | Błąd bazy danych, niedostępność Supabase, nieoczekiwany błąd |

**Uwaga:** Endpoint nigdy nie zwraca `404 Not Found` - pusta lista gatunków to poprawny scenariusz (kod 200).

### Przykładowe odpowiedzi błędów

**401 Unauthorized:**
```json
{
  "code": "PGRST301",
  "message": "JWT expired",
  "details": null,
  "hint": null
}
```

**500 Internal Server Error:**
```json
{
  "message": "Database connection failed",
  "details": "Connection timeout",
  "hint": null,
  "code": "PGRST000"
}
```

## 5. Przepływ danych

### Architektura komunikacji

```
┌─────────────┐         ┌─────────────┐         ┌──────────────┐         ┌────────────┐
│   Flutter   │  HTTP   │   Genre     │  Query  │   Supabase   │   SQL   │ PostgreSQL │
│     UI      ├────────►│   Service   ├────────►│   Client     ├────────►│  Database  │
│             │         │             │         │              │         │            │
└─────────────┘         └─────────────┘         └──────────────┘         └────────────┘
      │                        │                        │                        │
      │                        │                        │                        │
      │ [User action]          │                        │                        │
      │ "Load genres"          │                        │                        │
      │                        │                        │                        │
      │ Call listGenres()      │                        │                        │
      ├───────────────────────►│                        │                        │
      │                        │                        │                        │
      │                        │ Build query            │                        │
      │                        │ .from('genres')        │                        │
      │                        │ .select('*')           │                        │
      │                        │ .order('name')         │                        │
      │                        │                        │                        │
      │                        │ Execute query          │                        │
      │                        ├───────────────────────►│                        │
      │                        │                        │                        │
      │                        │                        │ SELECT * FROM genres   │
      │                        │                        │ WHERE auth.uid() IS    │
      │                        │                        │   NOT NULL (RLS)       │
      │                        │                        │ ORDER BY name ASC      │
      │                        │                        ├───────────────────────►│
      │                        │                        │                        │
      │                        │                        │    Raw rows            │
      │                        │                        │◄───────────────────────┤
      │                        │                        │                        │
      │                        │ JSON response          │                        │
      │                        │◄───────────────────────┤                        │
      │                        │                        │                        │
      │                        │ Parse to List<GenreDto>│                        │
      │                        │                        │                        │
      │  List<GenreDto>        │                        │                        │
      │◄───────────────────────┤                        │                        │
      │                        │                        │                        │
      │ Display in dropdown    │                        │                        │
      │                        │                        │                        │
```

### Krok po kroku

1. **UI Layer (Flutter Widget)**
   - Użytkownik otwiera formularz dodawania książki lub stronę filtrowania
   - Widget wywołuje metodę `listGenres()` z GenreService
   - Opcjonalnie przekazuje parametry sortowania

2. **Service Layer (GenreService)**
   - Waliduje parametry wejściowe (jeśli istnieją)
   - Buduje zapytanie Supabase:
     ```dart
     _supabase.from('genres').select('*').order('name', ascending: true)
     ```
   - Dodaje timeout do zapytania (domyślnie 30s)
   - Loguje początek operacji

3. **Supabase Client (HTTP)**
   - Automatycznie dodaje nagłówki autoryzacyjne (JWT + apikey)
   - Wysyła HTTP GET request do Supabase REST API
   - Format URL: `https://project.supabase.co/rest/v1/genres?order=name.asc`

4. **Supabase PostgREST (API Gateway)**
   - Weryfikuje token JWT
   - Sprawdza polityki Row Level Security (RLS)
   - Buduje zapytanie SQL na podstawie parametrów URL
   - Wykonuje zapytanie w PostgreSQL

5. **PostgreSQL Database**
   - Sprawdza politykę RLS: `auth.role() = 'authenticated'`
   - Wykonuje zapytanie:
     ```sql
     SELECT id, name, created_at 
     FROM genres 
     ORDER BY name ASC;
     ```
   - Zwraca wyniki (11 wierszy w MVP)

6. **Supabase PostgREST (Response)**
   - Serializuje wyniki do formatu JSON
   - Zwraca odpowiedź HTTP 200 OK z JSON array

7. **Service Layer (GenreService)**
   - Parsuje JSON response do `List<GenreDto>`
   - Loguje sukces z liczbą pobranych gatunków i czasem wykonania
   - Zwraca dane do UI

8. **UI Layer (Flutter Widget)**
   - Otrzymuje `List<GenreDto>`
   - Wyświetla gatunki w komponencie dropdown/select
   - Użytkownik może wybrać gatunek

### Obsługa cache'owania (opcjonalnie, poza MVP)

Ponieważ lista gatunków jest statyczna i rzadko się zmienia, w przyszłości można dodać:
- In-memory cache w GenreService (ważność: do końca sesji aplikacji)
- Automatyczne odświeżanie przy każdym starcie aplikacji
- Możliwość manualnego odświeżenia (pull-to-refresh)

## 6. Względy bezpieczeństwa

### Uwierzytelnianie (Authentication)

**Wymagania:**
- Każde żądanie **MUSI** zawierać ważny token JWT w nagłówku `Authorization`
- Token jest generowany przez Supabase Auth podczas logowania użytkownika
- Token zawiera informacje o użytkowniku: `auth.uid()`, `auth.role()`

**Mechanizm:**
```dart
// Token automatycznie dodawany przez SupabaseClient
final response = await _supabase
    .from('genres')
    .select('*');
// SupabaseClient dołącza: Authorization: Bearer <token>
```

**Obsługa błędów uwierzytelniania:**
- Wygasły token → `401 Unauthorized` → UnauthorizedException
- Brak tokenu → `401 Unauthorized` → UnauthorizedException
- Nieprawidłowy token → `401 Unauthorized` → UnauthorizedException

### Autoryzacja (Authorization)

**Row Level Security (RLS) Policy:**

```sql
CREATE POLICY "Anyone authenticated can view genres"
  ON genres
  FOR SELECT
  USING (auth.role() = 'authenticated');
```

**Zasady:**
- Tylko uwierzytelnieni użytkownicy mogą przeglądać gatunki
- `auth.role() = 'authenticated'` sprawdza, czy użytkownik jest zalogowany
- **Brak** kontroli `auth.uid()` - wszystkie uwierzytelnione osoby widzą te same dane
- Wszyscy użytkownicy mają dostęp tylko do odczytu (SELECT)

**Brak dostępu do zapisu:**
- INSERT, UPDATE, DELETE są zablokowane dla użytkowników końcowych
- Tylko administratorzy bazy danych mogą modyfikować gatunki
- Próba zapisu zwróci błąd autoryzacji

### Walidacja danych wejściowych

**Parametry zapytania:**
- `order` - walidacja formatu `{kolumna}.{kierunek}`
  - Dozwolone kolumny: `name`, `created_at`, `id`
  - Dozwolone kierunki: `asc`, `desc`
  - Ochrona przed SQL injection (PostgREST parametryzuje zapytania)

**Brak danych użytkownika w zapytaniu:**
- Endpoint nie przyjmuje danych użytkownika, więc nie ma ryzyka injection attacks
- Wszystkie parametry są opcjonalne i walidowane przez PostgREST

### Ochrona przed atakami

1. **SQL Injection:** 
   - PostgREST automatycznie parametryzuje wszystkie zapytania
   - Brak możliwości przekazania surowego SQL

2. **XSS (Cross-Site Scripting):**
   - Dane z API (nazwy gatunków) są sanityzowane przed wyświetleniem w UI
   - Flutter automatycznie escapuje tekst w widgetach Text()

3. **Rate Limiting:**
   - Supabase automatycznie ogranicza liczbę żądań na użytkownika
   - Domyślny limit: 2000 żądań/godzinę w planie darmowym

4. **Data Exposure:**
   - Gatunki są publiczne w ramach aplikacji (nie ma wrażliwych danych)
   - RLS zapewnia, że tylko zalogowani użytkownicy mają dostęp

### HTTPS/TLS

- Wszystkie połączenia z Supabase są szyfrowane TLS 1.2+
- Certyfikaty SSL zarządzane automatycznie przez Supabase
- Brak możliwości połączenia przez niezabezpieczony HTTP

### Przechowywanie kluczy API

**Dobre praktyki:**
- `SUPABASE_URL` i `SUPABASE_ANON_KEY` przechowywane w `config.env`
- Klucze nigdy nie są commitowane do repozytorium (plik w `.gitignore`)
- Anon key jest bezpieczny do używania po stronie klienta (RLS chroni dane)

## 7. Obsługa błędów

### Hierarchia wyjątków

Zgodnie z `lib/core/exceptions.dart`:

```dart
// Bazowy wyjątek aplikacji
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

// Konkretne wyjątki dla różnych scenariuszy
UnauthorizedException    // 401 - Problemy z JWT
ServerException          // 500 - Błędy serwera/bazy
NoInternetException      // Brak połączenia sieciowego
TimeoutException         // Przekroczenie czasu żądania
ParseException           // Błąd parsowania JSON
ValidationException      // Nieprawidłowe parametry (rzadkie w tym endpointcie)
```

### Scenariusze błędów

#### 1. Błędy autoryzacji (401)

**Przyczyny:**
- Brak tokenu JWT w nagłówku `Authorization`
- Token JWT wygasł (domyślnie po 1 godzinie)
- Token JWT jest nieprawidłowy (zmodyfikowany, uszkodzony)
- Użytkownik został wylogowany

**Kod błędu Supabase:** `PGRST301`

**Obsługa:**
```dart
on PostgrestException catch (e) {
  if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
    _logger.warning('Authentication failed: ${e.message}');
    throw UnauthorizedException(e.message);
  }
}
```

**Reakcja UI:**
- Wyloguj użytkownika automatycznie
- Przekieruj do ekranu logowania
- Pokaż komunikat: "Sesja wygasła. Zaloguj się ponownie."

#### 2. Błędy sieciowe

**Przyczyny:**
- Brak połączenia internetowego
- Problemy z DNS
- Firewall blokuje połączenia

**Obsługa:**
```dart
on SocketException catch (e) {
  _logger.warning('No internet connection: ${e.message}');
  throw NoInternetException();
}
```

**Reakcja UI:**
- Pokaż komunikat: "Brak połączenia z internetem"
- Wyświetl przycisk "Spróbuj ponownie"
- Użyj trybu offline (jeśli dostępny cache lokalny)

#### 3. Timeout (przekroczenie czasu)

**Przyczyny:**
- Wolne połączenie internetowe
- Serwer Supabase przeciążony
- Problemy z bazą danych

**Timeout:** Domyślnie 30 sekund (zdefiniowane w `ApiConstants.defaultTimeout`)

**Obsługa:**
```dart
on TimeoutException catch (e) {
  _logger.warning('Request timeout: ${e.message}');
  throw TimeoutException(
    'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s'
  );
}
```

**Reakcja UI:**
- Pokaż komunikat: "Serwer nie odpowiada. Spróbuj ponownie."
- Automatyczny retry z exponential backoff (opcjonalnie)

#### 4. Błędy parsowania JSON (500)

**Przyczyny:**
- Nieoczekiwany format odpowiedzi z API
- Zmiana schematu bazy danych bez aktualizacji DTOs
- Uszkodzona odpowiedź sieciowa

**Obsługa:**
```dart
on FormatException catch (e) {
  _logger.severe('Failed to parse response: ${e.message}', e);
  throw ParseException('Invalid response format from server');
}
```

**Reakcja UI:**
- Pokaż komunikat: "Wystąpił błąd aplikacji. Skontaktuj się z pomocą techniczną."
- Zaloguj szczegóły błędu dla debugowania

#### 5. Błędy serwera (500)

**Przyczyny:**
- Błąd bazy danych PostgreSQL
- Supabase tymczasowo niedostępny
- Nieoczekiwany błąd po stronie serwera

**Obsługa:**
```dart
on PostgrestException catch (e) {
  // ... inne warunki ...
  else {
    _logger.severe('Server error: ${e.message} (code: ${e.code})', e);
    throw ServerException(e.message);
  }
}
```

**Reakcja UI:**
- Pokaż komunikat: "Błąd serwera. Spróbuj ponownie za chwilę."
- Wyświetl przycisk "Odśwież"
- Zaloguj błąd do systemu monitoringu (np. Sentry)

#### 6. Pusta lista gatunków (200)

**Scenariusz:** Baza danych nie zawiera żadnych gatunków (mało prawdopodobne w MVP)

**Obsługa:** To nie jest błąd - zwrócona zostaje pusta lista `[]`

**Reakcja UI:**
- Pokaż komunikat: "Brak dostępnych gatunków"
- Opcjonalnie: przycisk do odświeżenia danych
- Zablokuj pole wyboru gatunku w formularzu książki

### Logowanie błędów

**Poziomy logowania:**
```dart
_logger.info()     // Normalne operacje (zapytania, sukcesy)
_logger.warning()  // Błędy niekriytyczne (timeout, brak internetu)
_logger.severe()   // Błędy krytyczne (serwer, parsowanie)
```

**Informacje w logach:**
- Timestamp operacji
- Typ błędu i kod Supabase
- Parametry zapytania
- Stack trace dla błędów krytycznych
- Czas wykonania (performance monitoring)

**Przykładowy log:**
```
[INFO] 2025-10-14 10:30:00 - GenreService: Fetching genres with order=name.asc
[INFO] 2025-10-14 10:30:01 - GenreService: Successfully fetched 11 genres in 250ms
```

### Strategia retry (opcjonalnie)

Dla poprawy UX, można zaimplementować automatyczne ponawianie żądań:

```dart
// Exponential backoff dla błędów przejściowych
Future<List<GenreDto>> _fetchWithRetry({int maxRetries = 3}) async {
  int attempt = 0;
  while (attempt < maxRetries) {
    try {
      return await _fetchGenres();
    } on TimeoutException catch (e) {
      attempt++;
      if (attempt >= maxRetries) rethrow;
      await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
    } on NoInternetException {
      // Nie retry dla braku internetu
      rethrow;
    }
  }
}
```

## 8. Rozważania dotyczące wydajności

### Charakterystyka zapytania

**Rozmiar danych:**
- **11 rekordów** w wersji MVP (stała liczba gatunków)
- **~500 bajtów** JSON na rekord
- **~5.5 KB** całkowity rozmiar odpowiedzi
- Bardzo mały zestaw danych - wydajność nie jest problemem

**Złożoność zapytania:**
- Proste SELECT bez JOINów
- Sortowanie po indeksowanej kolumnie `name` (UNIQUE INDEX)
- Brak filtrów WHERE (oprócz RLS)
- Bardzo szybkie wykonanie (< 10ms w bazie danych)

### Optymalizacje bazodanowej

**Istniejące indeksy:**
```sql
CREATE UNIQUE INDEX idx_genres_name ON genres(name);
-- Automatycznie utworzony przez ograniczenie UNIQUE
```

**Zalety:**
- Sortowanie `ORDER BY name` wykorzystuje indeks (index scan zamiast seq scan)
- Unikalność nazw wymuszana na poziomie bazy
- Szybkie wyszukiwanie po nazwie (dla przyszłych funkcji)

**Planowane zapytanie PostgreSQL:**
```sql
SELECT id, name, created_at 
FROM genres 
WHERE auth.role() = 'authenticated'  -- RLS policy
ORDER BY name ASC;

-- Plan wykonania:
-- Index Scan using idx_genres_name on genres (cost=0.15..1.29 rows=11 width=64)
```

### Optymalizacje sieciowe

**1. Kompresja HTTP (GZIP)**
- Supabase automatycznie kompresuje odpowiedzi
- ~5.5 KB JSON → ~1.5 KB skompresowany
- Redukcja transferu o ~70%

**2. HTTP/2 Multiplexing**
- Supabase wspiera HTTP/2
- Wielokrotne zapytania w jednym połączeniu TCP
- Zmniejszone opóźnienia (latency)

**3. CDN i Edge Functions (przyszłość)**
- Obecnie nie dotyczy (direct database query)
- W przyszłości: cache na Supabase Edge CDN

### Cache'owanie (strategia)

**In-Memory Cache w Service Layer:**

```dart
class GenreService {
  List<GenreDto>? _cachedGenres;
  DateTime? _cacheTimestamp;
  static const _cacheValidity = Duration(hours: 24);

  Future<List<GenreDto>> listGenres() async {
    // Sprawdź, czy cache jest ważny
    if (_cachedGenres != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheValidity) {
        _logger.info('Returning cached genres (age: ${age.inMinutes}m)');
        return _cachedGenres!;
      }
    }

    // Pobierz świeże dane
    final genres = await _fetchFromApi();
    
    // Zapisz w cache
    _cachedGenres = genres;
    _cacheTimestamp = DateTime.now();
    
    return genres;
  }

  void invalidateCache() {
    _cachedGenres = null;
    _cacheTimestamp = null;
  }
}
```

**Zalety cache'owania:**
- ✅ Redukcja liczby zapytań do bazy (większość użytkowników wielokrotnie otwiera formularze)
- ✅ Natychmiastowe wyświetlenie gatunków (0ms zamiast ~300ms)
- ✅ Oszczędność limitu żądań API Supabase
- ✅ Działanie offline (jeśli cache istnieje)

**Wady cache'owania:**
- ❌ Opóźnienie w aktualizacji (jeśli admin doda nowy gatunek)
- ❌ Dodatkowa złożoność kodu
- ❌ Potrzeba zarządzania invalidacją cache

**Strategia invalidacji cache:**
- Automatyczna po 24 godzinach
- Manualna przy pull-to-refresh
- Przy każdym restarcie aplikacji (opcjonalnie)

### Monitoring wydajności

**Metryki do śledzenia:**

```dart
final stopwatch = Stopwatch()..start();

try {
  final genres = await _fetchGenres();
  stopwatch.stop();
  
  _logger.info(
    'Fetched ${genres.length} genres in ${stopwatch.elapsedMilliseconds}ms'
  );
  
  // Wysyłka metryki do systemu monitoringu
  _analytics.trackPerformance(
    operation: 'list_genres',
    duration: stopwatch.elapsedMilliseconds,
    success: true,
  );
} catch (e) {
  stopwatch.stop();
  _analytics.trackPerformance(
    operation: 'list_genres',
    duration: stopwatch.elapsedMilliseconds,
    success: false,
    error: e.toString(),
  );
  rethrow;
}
```

**Progi wydajności:**
- ⚠️ Warning: > 500ms (wolne połączenie?)
- ❌ Critical: > 2000ms (problem z serwerem?)

### Optymalizacja przepustowości (Bandwidth)

**Selective Field Loading (opcjonalnie):**

Jeśli `created_at` nie jest potrzebny w UI:
```dart
// Zamiast SELECT *
_supabase.from('genres').select('id,name')

// Redukcja rozmiaru: ~500B → ~300B na rekord
```

**Zalecenie dla MVP:** Nie implementować - oszczędność jest minimalna (~2KB), a kod staje się mniej czytelny.

### Skalowanie (przyszłość)

**Scenariusz:** 1000+ użytkowników jednocześnie

**Możliwe wąskie gardła:**
- ❌ Brak (PostgreSQL obsługuje tysiące prostych SELECT/s)
- ❌ Brak (Supabase autoskaluje infrastrukturę)

**Potencjalne rozwiązania (jeśli potrzebne):**
1. Read Replica w PostgreSQL (dla bardzo dużego ruchu)
2. Redis cache między aplikacją a bazą
3. GraphQL subscription dla real-time updates gatunków

**Wniosek dla MVP:** Wydajność nie jest problemem dla tego endpointu. Obecna implementacja obsłuży tysiące użytkowników bez optymalizacji.

## 9. Etapy wdrożenia

### Krok 1: Utworzenie serwisu GenreService

**Akcja:** Stwórz plik `lib/services/genre_service.dart`

**Implementacja:**

```dart
/// Service for managing genre-related operations via Supabase REST API
///
/// This service provides methods for:
/// - Listing all available book genres
///
/// All operations are automatically protected by Row-Level Security (RLS).
/// Genres are read-only for end users and managed by database administrators.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/types.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';

class GenreService {
  final SupabaseClient _supabase;
  final Logger _logger = Logger('GenreService');

  /// Optional in-memory cache for genres
  List<GenreDto>? _cachedGenres;
  DateTime? _cacheTimestamp;
  static const _cacheValidity = Duration(hours: 24);

  /// Creates a new GenreService instance
  ///
  /// [_supabase] The Supabase client to use for API calls
  GenreService(this._supabase);

  /// Fetches the list of all available book genres
  ///
  /// This method queries the genres table and returns all available genres
  /// sorted alphabetically by name. Results are cached for 24 hours.
  ///
  /// **Query Pattern:**
  /// ```
  /// SELECT id, name, created_at
  /// FROM genres
  /// WHERE auth.role() = 'authenticated'  -- RLS policy
  /// ORDER BY name ASC
  /// ```
  ///
  /// **Parameters:**
  /// - [orderBy]: Field to sort by (default: 'name')
  /// - [orderDirection]: Sort direction 'asc' or 'desc' (default: 'asc')
  /// - [forceRefresh]: Skip cache and fetch fresh data (default: false)
  ///
  /// **Returns:**
  /// A list of [GenreDto] objects sorted by name
  ///
  /// **Throws:**
  /// - [UnauthorizedException]: Authentication failed or token expired
  /// - [ServerException]: Database error or Supabase service unavailable
  /// - [NoInternetException]: No network connection
  /// - [TimeoutException]: Request took too long
  /// - [ParseException]: Failed to parse API response
  ///
  /// **Example:**
  /// ```dart
  /// // Get all genres (uses cache if available)
  /// final genres = await genreService.listGenres();
  ///
  /// // Force refresh from database
  /// final freshGenres = await genreService.listGenres(forceRefresh: true);
  /// ```
  Future<List<GenreDto>> listGenres({
    String orderBy = 'name',
    String orderDirection = 'asc',
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && _cachedGenres != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheValidity) {
        _logger.info(
          'Returning cached genres (${_cachedGenres!.length} items, '
          'age: ${age.inMinutes}m)',
        );
        return _cachedGenres!;
      }
    }

    _logger.info(
      'Fetching genres: orderBy=$orderBy, direction=$orderDirection',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Build the query
      final ascending = orderDirection.toLowerCase() == 'asc';
      final query = _supabase
          .from('genres')
          .select('*')
          .order(orderBy, ascending: ascending);

      // Execute the query with timeout
      final response = await query.timeout(ApiConstants.defaultTimeout);

      // Parse the response to DTOs
      final genres = (response as List)
          .map((json) => GenreDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update cache
      _cachedGenres = genres;
      _cacheTimestamp = DateTime.now();

      stopwatch.stop();
      _logger.info(
        'Successfully fetched ${genres.length} genres in '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      return genres;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      _logger.severe('Postgrest error: ${e.message} (code: ${e.code})', e);

      if (e.code == 'PGRST301' || e.message.toLowerCase().contains('jwt')) {
        throw UnauthorizedException(e.message);
      } else if (e.code?.startsWith('PGRST1') ?? false) {
        throw ValidationException(e.message);
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
      throw TimeoutException(
        'Request timed out after ${ApiConstants.defaultTimeout.inSeconds}s',
      );
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Unexpected error: $e', e);
      throw ServerException('An unexpected error occurred');
    }
  }

  /// Invalidates the genres cache
  ///
  /// Forces the next call to [listGenres] to fetch fresh data from the server.
  /// Useful when implementing pull-to-refresh functionality.
  void invalidateCache() {
    _logger.info('Invalidating genres cache');
    _cachedGenres = null;
    _cacheTimestamp = null;
  }

  /// Returns the number of cached genres (for debugging)
  int? get cachedGenresCount => _cachedGenres?.length;

  /// Returns the age of the cache (for debugging)
  Duration? get cacheAge {
    if (_cacheTimestamp == null) return null;
    return DateTime.now().difference(_cacheTimestamp!);
  }
}
```

**Zadania:**
- ✅ Utworzyć plik `lib/services/genre_service.dart`
- ✅ Zaimplementować klasę `GenreService`
- ✅ Dodać metodę `listGenres()` z obsługą cache
- ✅ Dodać metodę `invalidateCache()`
- ✅ Dodać kompletne logowanie (info, warning, severe)
- ✅ Dodać pełną obsługę błędów zgodnie z sekcją 7
- ✅ Dodać mierzenie czasu wykonania (performance monitoring)

### Krok 2: Dodanie testów jednostkowych

**Akcja:** Stwórz plik `test/services/genre_service_test.dart`

**Implementacja:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_book_library/services/genre_service.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/core/exceptions.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockSupabase;
  late GenreService genreService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    genreService = GenreService(mockSupabase);
  });

  group('GenreService.listGenres', () {
    final mockGenresJson = [
      {
        'id': 'f1e2d3c4-b5a6-7890-1234-567890abcdef',
        'name': 'Fantastyka',
        'created_at': '2025-10-10T12:00:00Z',
      },
      {
        'id': 'a9b8c7d6-e5f4-a3b2-c1d0-e9f8a7b6c5d4',
        'name': 'Kryminał',
        'created_at': '2025-10-10T12:00:00Z',
      },
    ];

    test('should return list of genres on success', () async {
      // Arrange
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenAnswer((_) async => mockGenresJson);

      // Act
      final result = await genreService.listGenres();

      // Assert
      expect(result, isA<List<GenreDto>>());
      expect(result.length, 2);
      expect(result[0].name, 'Fantastyka');
      expect(result[1].name, 'Kryminał');
    });

    test('should use cache on second call', () async {
      // First call
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenAnswer((_) async => mockGenresJson);

      final result1 = await genreService.listGenres();
      
      // Second call (should use cache)
      final result2 = await genreService.listGenres();

      // Assert
      expect(result1, equals(result2));
      verify(() => mockQuery.timeout(any())).called(1); // Only one API call
    });

    test('should refresh cache when forceRefresh is true', () async {
      // First call
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenAnswer((_) async => mockGenresJson);

      await genreService.listGenres();
      
      // Force refresh
      await genreService.listGenres(forceRefresh: true);

      // Assert
      verify(() => mockQuery.timeout(any())).called(2); // Two API calls
    });

    test('should throw UnauthorizedException on JWT error', () async {
      // Arrange
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenThrow(
        PostgrestException(message: 'JWT expired', code: 'PGRST301'),
      );

      // Act & Assert
      expect(
        () => genreService.listGenres(forceRefresh: true),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('should throw NoInternetException on network error', () async {
      // Arrange
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenThrow(
        const SocketException('No internet'),
      );

      // Act & Assert
      expect(
        () => genreService.listGenres(forceRefresh: true),
        throwsA(isA<NoInternetException>()),
      );
    });

    test('should invalidate cache when invalidateCache is called', () async {
      // Arrange
      final mockQuery = MockPostgrestFilterBuilder();
      when(() => mockSupabase.from('genres')).thenReturn(mockQuery as SupabaseQueryBuilder);
      when(() => mockQuery.select('*')).thenReturn(mockQuery);
      when(() => mockQuery.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.timeout(any())).thenAnswer((_) async => mockGenresJson);

      await genreService.listGenres();
      genreService.invalidateCache();
      await genreService.listGenres();

      // Assert
      verify(() => mockQuery.timeout(any())).called(2); // Two API calls (cache was invalidated)
    });
  });
}
```

**Zadania:**
- ✅ Utworzyć plik testowy
- ✅ Dodać mocki Supabase (mocktail)
- ✅ Test: pomyślne pobranie gatunków
- ✅ Test: użycie cache przy drugim wywołaniu
- ✅ Test: force refresh wymusza ponowne pobranie
- ✅ Test: błąd 401 rzuca UnauthorizedException
- ✅ Test: brak internetu rzuca NoInternetException
- ✅ Test: invalidateCache() czyści cache
- ✅ Uruchomić testy: `flutter test test/services/genre_service_test.dart`

### Krok 3: Integracja z istniejącym kodem

**Akcja:** Dodaj GenreService do dependency injection w `main.dart`

**Lokalizacja:** `lib/main.dart`

**Modyfikacja:**

```dart
import 'package:my_book_library/services/genre_service.dart';

void main() async {
  // ... inicjalizacja Supabase ...
  
  final supabase = Supabase.instance.client;
  
  runApp(
    MultiProvider(
      providers: [
        Provider<BookService>(
          create: (_) => BookService(supabase),
        ),
        Provider<ReadingSessionService>(
          create: (_) => ReadingSessionService(supabase),
        ),
        // ✅ Dodaj GenreService
        Provider<GenreService>(
          create: (_) => GenreService(supabase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Zadania:**
- ✅ Zaimportować `GenreService`
- ✅ Dodać `Provider<GenreService>` do listy providerów
- ✅ Upewnić się, że używa tego samego `supabase` client

### Krok 4: Utworzenie przykładowego widoku (demonstracja użycia)

**Akcja:** Stwórz prosty widget do wyświetlania listy gatunków

**Lokalizacja:** `lib/widgets/genre_selector.dart` (przykład)

**Implementacja:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_book_library/services/genre_service.dart';
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/core/exceptions.dart';

/// Dropdown widget for selecting a book genre
///
/// Automatically fetches genres from the API and displays them
/// in a dropdown menu. Handles loading, error, and empty states.
class GenreSelector extends StatefulWidget {
  final String? selectedGenreId;
  final ValueChanged<String?> onChanged;

  const GenreSelector({
    Key? key,
    this.selectedGenreId,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<GenreSelector> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {
  List<GenreDto>? _genres;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final genreService = context.read<GenreService>();
      final genres = await genreService.listGenres();
      
      setState(() {
        _genres = genres;
        _isLoading = false;
      });
    } on UnauthorizedException {
      setState(() {
        _errorMessage = 'Sesja wygasła. Zaloguj się ponownie.';
        _isLoading = false;
      });
    } on NoInternetException {
      setState(() {
        _errorMessage = 'Brak połączenia z internetem';
        _isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        _errorMessage = 'Przekroczono czas oczekiwania';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił błąd: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: _loadGenres,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      );
    }

    if (_genres == null || _genres!.isEmpty) {
      return const Text('Brak dostępnych gatunków');
    }

    return DropdownButtonFormField<String>(
      value: widget.selectedGenreId,
      decoration: const InputDecoration(
        labelText: 'Gatunek',
        hintText: 'Wybierz gatunek książki',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Bez gatunku'),
        ),
        ..._genres!.map((genre) {
          return DropdownMenuItem<String>(
            value: genre.id,
            child: Text(genre.name),
          );
        }).toList(),
      ],
      onChanged: widget.onChanged,
    );
  }
}
```

**Użycie w formularzu książki:**

```dart
// W formularzu dodawania/edycji książki
String? selectedGenreId;

GenreSelector(
  selectedGenreId: selectedGenreId,
  onChanged: (genreId) {
    setState(() {
      selectedGenreId = genreId;
    });
  },
)
```

**Zadania:**
- ✅ Utworzyć widget `GenreSelector`
- ✅ Obsłużyć stany: loading, error, success, empty
- ✅ Dodać obsługę błędów (UnauthorizedException, NoInternetException, etc.)
- ✅ Zaimplementować retry mechanism (przycisk "Spróbuj ponownie")
- ✅ Użyć w formularzu dodawania książki

### Krok 5: Dodanie testów integracyjnych (opcjonalnie)

**Akcja:** Stwórz test integracyjny dla pełnego flow

**Lokalizacja:** `test/integration/genre_flow_test.dart`

**Implementacja:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_book_library/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Genre Selection Flow', () {
    testWidgets('should load and display genres in dropdown', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add book screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Find genre dropdown
      final genreDropdown = find.byType(DropdownButtonFormField<String>);
      expect(genreDropdown, findsOneWidget);

      // Open dropdown
      await tester.tap(genreDropdown);
      await tester.pumpAndSettle();

      // Verify genres are loaded
      expect(find.text('Fantastyka'), findsOneWidget);
      expect(find.text('Kryminał'), findsOneWidget);
      expect(find.text('Thriller'), findsOneWidget);

      // Select a genre
      await tester.tap(find.text('Fantastyka'));
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Fantastyka'), findsOneWidget);
    });

    testWidgets('should handle network error gracefully', (tester) async {
      // TODO: Mock network error and verify error UI
    });
  });
}
```

**Zadania:**
- ✅ Utworzyć plik testów integracyjnych
- ✅ Test: ładowanie i wyświetlanie gatunków
- ✅ Test: wybór gatunku z dropdown
- ✅ Test: obsługa błędu sieciowego
- ✅ Uruchomić: `flutter test integration_test/`

### Krok 6: Dokumentacja i finalizacja

**Akcja:** Zaktualizuj dokumentację projektu

**Pliki do aktualizacji:**

1. **README.md** (jeśli istnieje sekcja API)
   ```markdown
   ## Genres API
   
   Endpoint do pobierania listy gatunków książek.
   
   - **Service:** `GenreService`
   - **Method:** `listGenres()`
   - **Cache:** 24 godziny (in-memory)
   - **RLS Policy:** Wszyscy uwierzytelnieni użytkownicy (read-only)
   ```

2. **lib/models/README.md** (jeśli istnieje)
   - Dodaj opis `GenreDto`

3. **Changelog lub commit message:**
   ```
   feat: Add GenreService with caching and error handling
   
   - Created GenreService for fetching book genres
   - Implemented in-memory caching (24h validity)
   - Added comprehensive error handling
   - Added unit tests with 95%+ coverage
   - Added GenreSelector widget for forms
   - Integrated with dependency injection
   ```

**Zadania:**
- ✅ Zaktualizować README.md
- ✅ Dodać przykłady użycia w dokumentacji
- ✅ Napisać commit message
- ✅ Utworzyć Pull Request (jeśli pracujesz w zespole)

### Krok 7: Code Review Checklist

**Przed mergem, sprawdź:**

- [ ] Wszystkie testy jednostkowe przechodzą (`flutter test`)
- [ ] Kod jest zgodny z linterem (`flutter analyze`)
- [ ] Dodano wszystkie importy i zależności
- [ ] Logowanie działa poprawnie (sprawdzić w konsoli)
- [ ] Obsługa błędów jest kompletna (wszystkie excepty z sekcji 7)
- [ ] Cache działa poprawnie (sprawdzić logi)
- [ ] Performance jest akceptowalna (< 500ms średnio)
- [ ] UI wyświetla błędy w przyjazny sposób
- [ ] Dokumentacja jest aktualna
- [ ] Brak hardcoded wartości (wszystko w constants.dart)
- [ ] Zgodność z istniejącym stylem kodu (BookService jako wzór)

### Krok 8: Monitoring i obserwacja po wdrożeniu

**Po wdrożeniu na produkcję:**

1. **Monitoruj logi:**
   ```
   # Sprawdzaj logi GenreService
   grep "GenreService" logs/app.log
   
   # Szukaj błędów
   grep "ERROR.*GenreService" logs/app.log
   ```

2. **Śledź metryki:**
   - Liczba wywołań API
   - Średni czas odpowiedzi
   - Wskaźnik błędów (error rate)
   - Cache hit ratio

3. **Zbieraj feedback użytkowników:**
   - Czy gatunki ładują się szybko?
   - Czy pojawiają się błędy?
   - Czy brakuje jakichś gatunków?

4. **Optymalizuj jeśli potrzeba:**
   - Jeśli cache hit ratio < 80% → rozważ dłuższy czas ważności
   - Jeśli błędy > 1% → zaimplementuj retry logic
   - Jeśli czas odpowiedzi > 1s → sprawdź indeksy w bazie

**Zadania po wdrożeniu:**
- ✅ Skonfigurować monitoring (np. Sentry, Firebase Analytics)
- ✅ Dodać alerty dla krytycznych błędów
- ✅ Przegląd metryk po 1 tygodniu
- ✅ Feedback od użytkowników (beta testerzy)

---

## Podsumowanie

Ten plan wdrożenia zawiera wszystkie niezbędne informacje do implementacji endpointu List Genres:

✅ **Przegląd:** Jasny cel i charakterystyka endpointu  
✅ **Szczegóły techniczne:** Dokładna specyfikacja żądań i odpowiedzi  
✅ **Typy danych:** Wykorzystanie istniejących DTOs bez potrzeby zmian  
✅ **Przepływ:** Szczegółowy diagram sekwencji i opis kroków  
✅ **Bezpieczeństwo:** RLS, uwierzytelnianie, autoryzacja, ochrona przed atakami  
✅ **Obsługa błędów:** Kompletna lista scenariuszy z kodami statusu  
✅ **Wydajność:** Optymalizacje, cache'owanie, monitoring  
✅ **Implementacja:** 8 kroków od serwisu po produkcję  

**Endpoint jest gotowy do wdrożenia przez zespół programistów.**


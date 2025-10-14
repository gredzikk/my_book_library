# Genre API - Dokumentacja

## Przegląd

Genre API umożliwia pobieranie listy wszystkich dostępnych gatunków literackich w aplikacji. Jest to endpoint tylko do odczytu (read-only), który zwraca listę gatunków dostępnych dla wszystkich uwierzytelnionych użytkowników.

## Szybki start

### 1. Podstawowe użycie

```dart
import 'package:my_book_library/services/genre_service.dart';
import 'package:my_book_library/models/types.dart';

// Utwórz instancję serwisu
final genreService = GenreService(supabaseClient);

// Pobierz listę gatunków
final genres = await genreService.listGenres();

// Wyświetl gatunki
for (final genre in genres) {
  print('${genre.name} (${genre.id})');
}
```

### 2. Użycie z cache

```dart
// Pierwsze wywołanie - pobiera z API
final genres1 = await genreService.listGenres();

// Drugie wywołanie - zwraca z cache (szybsze!)
final genres2 = await genreService.listGenres();

// Wymuś odświeżenie z API
final freshGenres = await genreService.listGenres(forceRefresh: true);
```

### 3. Obsługa błędów

```dart
try {
  final genres = await genreService.listGenres();
  // Użyj gatunków
} on UnauthorizedException catch (e) {
  // Sesja wygasła - przekieruj do logowania
  print('Sesja wygasła: ${e.message}');
} on NoInternetException {
  // Brak internetu - pokaż komunikat
  print('Brak połączenia z internetem');
} on TimeoutException catch (e) {
  // Timeout - spróbuj ponownie
  print('Przekroczono czas: ${e.message}');
} on ServerException catch (e) {
  // Błąd serwera
  print('Błąd serwera: ${e.message}');
} catch (e) {
  // Inny błąd
  print('Nieoczekiwany błąd: $e');
}
```

## GenreService API

### Metody

#### `listGenres()`

Pobiera listę wszystkich dostępnych gatunków.

**Parametry:**
- `orderBy` (String, opcjonalny): Pole do sortowania (domyślnie: `'name'`)
- `orderDirection` (String, opcjonalny): Kierunek sortowania `'asc'` lub `'desc'` (domyślnie: `'asc'`)
- `forceRefresh` (bool, opcjonalny): Wymuś pobranie z API, pomijając cache (domyślnie: `false`)

**Zwraca:**
- `Future<List<GenreDto>>`: Lista gatunków

**Przykłady:**

```dart
// Domyślne sortowanie (alfabetycznie A-Z)
final genres = await genreService.listGenres();

// Sortowanie malejąco (Z-A)
final genresDesc = await genreService.listGenres(
  orderDirection: 'desc',
);

// Sortowanie po dacie utworzenia
final genresByDate = await genreService.listGenres(
  orderBy: 'created_at',
  orderDirection: 'desc',
);

// Wymuś odświeżenie z API
final freshGenres = await genreService.listGenres(
  forceRefresh: true,
);
```

#### `invalidateCache()`

Czyści cache gatunków, wymuszając pobranie świeżych danych przy następnym wywołaniu.

**Przykład:**

```dart
// Wyczyść cache
genreService.invalidateCache();

// Następne wywołanie pobierze świeże dane
final genres = await genreService.listGenres();
```

### Właściwości

#### `cachedGenresCount`

Zwraca liczbę gatunków w cache lub `null` jeśli cache jest pusty.

```dart
final count = genreService.cachedGenresCount;
print('Gatunków w cache: ${count ?? 0}');
```

#### `cacheAge`

Zwraca wiek cache jako `Duration` lub `null` jeśli cache jest pusty.

```dart
final age = genreService.cacheAge;
if (age != null) {
  print('Cache ma ${age.inMinutes} minut');
}
```

## GenreDto Model

### Struktura

```dart
class GenreDto {
  final String id;           // UUID gatunku
  final String name;         // Nazwa gatunku (np. "Fantastyka")
  final DateTime createdAt;  // Data utworzenia rekordu
}
```

### Przykład użycia

```dart
final genre = GenreDto(
  id: 'f1e2d3c4-b5a6-7890-1234-567890abcdef',
  name: 'Fantastyka',
  createdAt: DateTime.now(),
);

// Konwersja do JSON
final json = genre.toJson();
// {
//   "id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
//   "name": "Fantastyka",
//   "created_at": "2025-10-14T10:30:00.000Z"
// }

// Konwersja z JSON
final genreFromJson = GenreDto.fromJson(json);
```

## Komponenty UI

### GenreSelector Widget

Gotowy widget dropdown do wyboru gatunku w formularzach.

**Podstawowe użycie:**

```dart
import 'package:my_book_library/widgets/genre_selector.dart';

String? selectedGenreId;

GenreSelector(
  genreService: genreService,
  selectedGenreId: selectedGenreId,
  onChanged: (genreId) {
    setState(() {
      selectedGenreId = genreId;
    });
  },
)
```

**Zaawansowane użycie:**

```dart
GenreSelector(
  genreService: genreService,
  selectedGenreId: selectedGenreId,
  onChanged: (genreId) {
    setState(() {
      selectedGenreId = genreId;
    });
  },
  isRequired: true,              // Pole wymagane (walidacja)
  labelText: 'Wybierz gatunek',  // Niestandardowa etykieta
  hintText: 'Gatunek literacki', // Niestandardowy hint
)
```

**Funkcje widgetu:**
- ✅ Automatyczne pobieranie gatunków z API
- ✅ Obsługa stanów: loading, error, empty, success
- ✅ Przycisk "Spróbuj ponownie" przy błędach
- ✅ Walidacja formularza (opcjonalna)
- ✅ Opcja "Bez gatunku" dla pustej wartości
- ✅ Wykorzystuje cache dla wydajności

### Pełny przykład formularza

```dart
class BookForm extends StatefulWidget {
  final GenreService genreService;

  const BookForm({Key? key, required this.genreService}) : super(key: key);

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGenreId;
  String _title = '';
  String _author = '';

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Utwórz książkę z wybranym gatunkiem
      final bookDto = CreateBookDto(
        title: _title,
        author: _author,
        pageCount: 300,
        genreId: _selectedGenreId, // Może być null
      );
      
      // Zapisz w bazie...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Tytuł'),
            validator: (v) => v?.isEmpty ?? true ? 'Wymagane' : null,
            onSaved: (v) => _title = v!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Autor'),
            validator: (v) => v?.isEmpty ?? true ? 'Wymagane' : null,
            onSaved: (v) => _author = v!,
          ),
          GenreSelector(
            genreService: widget.genreService,
            selectedGenreId: _selectedGenreId,
            onChanged: (genreId) {
              setState(() => _selectedGenreId = genreId);
            },
          ),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}
```

## Cache i wydajność

### Strategia cache'owania

- **Czas ważności:** 24 godziny
- **Typ:** In-memory (dane tracone przy restarcie aplikacji)
- **Automatyczne:** Cache jest sprawdzany przy każdym wywołaniu `listGenres()`

### Kiedy cache jest używany?

```dart
// ✅ Cache jest używany
final genres1 = await genreService.listGenres();
await Future.delayed(Duration(minutes: 30));
final genres2 = await genreService.listGenres(); // Z cache!

// ❌ Cache NIE jest używany
final genres3 = await genreService.listGenres(forceRefresh: true);
genreService.invalidateCache();
final genres4 = await genreService.listGenres(); // Świeże dane
```

### Monitorowanie cache

```dart
// Sprawdź czy są dane w cache
if (genreService.cachedGenresCount != null) {
  print('Cache zawiera ${genreService.cachedGenresCount} gatunków');
  print('Cache ma ${genreService.cacheAge?.inMinutes} minut');
} else {
  print('Cache jest pusty');
}
```

## Kody błędów i obsługa

| Wyjątek | HTTP | Kiedy występuje | Jak obsłużyć |
|---------|------|-----------------|--------------|
| `UnauthorizedException` | 401 | Token JWT wygasł lub nieprawidłowy | Wyloguj użytkownika, przekieruj do logowania |
| `NoInternetException` | - | Brak połączenia sieciowego | Pokaż komunikat, udostępnij retry |
| `TimeoutException` | - | Serwer nie odpowiada (>30s) | Pokaż komunikat o timeout, retry |
| `ServerException` | 500 | Błąd bazy danych / serwera | Pokaż błąd, zaloguj do systemu monitoringu |
| `ParseException` | - | Nieprawidłowy format JSON | Błąd krytyczny - skontaktuj się z IT |

### Przykład kompleksowej obsługi

```dart
Future<void> loadGenresWithRetry() async {
  int attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    try {
      final genres = await genreService.listGenres();
      // Sukces
      setState(() => _genres = genres);
      return;
    } on TimeoutException {
      attempts++;
      if (attempts >= maxAttempts) {
        _showError('Nie można połączyć z serwerem');
        return;
      }
      await Future.delayed(Duration(seconds: 2 * attempts));
    } on NoInternetException {
      _showError('Sprawdź połączenie internetowe');
      return;
    } on UnauthorizedException {
      _redirectToLogin();
      return;
    } catch (e) {
      _showError('Wystąpił błąd: $e');
      return;
    }
  }
}
```

## Gatunki dostępne w MVP

Aplikacja zawiera następujące predefiniowane gatunki:

1. Biografia
2. Fantastyka
3. Horror
4. Kryminał
5. Literatura faktu
6. Literatura piękna
7. Poradnik
8. Przygodowa
9. Romans
10. Thriller
11. Inne

**Uwaga:** Lista gatunków jest tylko do odczytu i może być modyfikowana wyłącznie przez administratorów bazy danych.

## Bezpieczeństwo

### Row Level Security (RLS)

Wszystkie zapytania są chronione przez polityki RLS:

```sql
-- Tylko uwierzytelnieni użytkownicy mogą przeglądać gatunki
CREATE POLICY "Anyone authenticated can view genres"
  ON genres
  FOR SELECT
  USING (auth.role() = 'authenticated');
```

### Wymagania autoryzacji

- ✅ Każde żądanie wymaga ważnego tokenu JWT
- ✅ Token automatycznie dodawany przez `SupabaseClient`
- ✅ Brak możliwości modyfikacji gatunków przez użytkowników

## Testy

### Uruchomienie testów

```bash
# Wszystkie testy
flutter test

# Tylko testy Genre
flutter test test/services/genre_service_test.dart
```

### Przykładowy test

```dart
test('should create GenreDto from JSON', () {
  final json = {
    'id': 'test-id',
    'name': 'Fantastyka',
    'created_at': '2025-10-10T12:00:00Z',
  };

  final genre = GenreDto.fromJson(json);

  expect(genre.id, 'test-id');
  expect(genre.name, 'Fantastyka');
  expect(genre.createdAt, DateTime.parse('2025-10-10T12:00:00Z'));
});
```

## Migracje bazy danych

Gatunki są tworzone podczas inicjalizacji bazy danych:

```sql
-- Z pliku: supabase/migrations/20251010120000_initial_schema.sql
CREATE TABLE genres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wstaw domyślne gatunki
INSERT INTO genres (name) VALUES
  ('Biografia'),
  ('Fantastyka'),
  ('Horror'),
  -- ... pozostałe
```

## FAQ

### Jak często powinienem invalidować cache?

Cache jest ważny przez 24h. Invaliduj tylko gdy:
- Użytkownik manualnie odświeża listę (pull-to-refresh)
- Administrator dodał nowe gatunki (rzadkie)
- Występują problemy z cache'm

### Czy mogę dodawać własne gatunki?

Nie. Gatunki są zarządzane centralnie przez administratorów. To zapewnia spójność danych.

### Co jeśli API zwróci pustą listę?

To normalny scenariusz (kod 200). UI powinien wyświetlić komunikat "Brak dostępnych gatunków".

### Jak działa sortowanie?

```dart
// Po nazwie (alfabetycznie)
await genreService.listGenres(orderBy: 'name', orderDirection: 'asc');

// Po dacie utworzenia (najnowsze pierwsze)
await genreService.listGenres(orderBy: 'created_at', orderDirection: 'desc');
```

## Support

W razie problemów:
1. Sprawdź logi: `Logger('GenreService')`
2. Zweryfikuj połączenie z Supabase
3. Sprawdź ważność tokenu JWT
4. Skontaktuj się z zespołem dev

## Changelog

### v1.0.0 (2025-10-14)
- ✅ Implementacja GenreService z cache'owaniem
- ✅ Widget GenreSelector dla formularzy
- ✅ Pełna obsługa błędów
- ✅ Testy jednostkowe
- ✅ Dokumentacja API


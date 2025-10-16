# Add Book Feature

Feature do dodawania nowych książek do biblioteki użytkownika.

## Struktura

```
lib/features/add_book/
├── bloc/
│   ├── add_book_bloc.dart       # BLoC zarządzający stanem
│   ├── add_book_event.dart      # Definicje zdarzeń
│   ├── add_book_state.dart      # Definicje stanów
│   └── bloc.dart                # Barrel export
├── models/
│   └── add_book_form_view_model.dart  # ViewModel formularza
├── view/
│   ├── add_book_screen.dart     # Ekran wyboru metody
│   └── book_form_screen.dart    # Ekran formularza
├── widgets/
│   ├── isbn_input_field.dart    # Widget do wprowadzania ISBN
│   ├── scan_isbn_button.dart    # Przycisk skanowania (placeholder)
│   └── widgets.dart             # Barrel export
└── add_book.dart                # Główny barrel export

## Przepływ użytkownika

1. **AddBookScreen** - wybór metody:
   - Skanowanie kodu kreskowego ISBN (placeholder - wymaga mobile_scanner)
   - Ręczne wpisanie numeru ISBN
   - Dodanie książki ręcznie (bez ISBN)

2. **Wyszukiwanie po ISBN**:
   - Użytkownik wprowadza/skanuje ISBN
   - Aplikacja wysyła zapytanie do Google Books API
   - Po znalezieniu książki następuje automatyczna nawigacja do formularza z wypełnionymi danymi

3. **BookFormScreen** - formularz:
   - Wypełnianie/edycja danych książki
   - Walidacja pól
   - Zapisanie do bazy danych

## BLoC Events

- `FetchBookByIsbn(String isbn)` - wyszukiwanie książki w Google Books API
- `SaveBook(AddBookFormViewModel data, String? bookId)` - zapisywanie/aktualizacja książki
- `FetchGenres()` - pobieranie listy gatunków

## BLoC States

- `AddBookInitial` - stan początkowy
- `AddBookLoading` - ładowanie (z opcjonalnym komunikatem)
- `AddBookReady` - gotowy do wyświetlenia formularza (z gatunkami)
- `BookFound` - książka znaleziona w Google Books API
- `BookSaved` - książka zapisana pomyślnie
- `AddBookError` - błąd

## Walidacja formularza

### Pola wymagane:
- **Tytuł** - nie może być pusty
- **Autor** - nie może być pusty
- **Liczba stron** - musi być liczbą > 0

### Pola opcjonalne:
- Gatunek (dropdown z listy)
- URL okładki
- ISBN (walidacja formatu 10/13 cyfr)
- Wydawca
- Rok wydania (walidacja 4-cyfrowy rok)

## Integracja API

### Google Books API
- Endpoint: `GET https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}`
- Typ odpowiedzi: `GoogleBookResult`
- Konwersja do: `AddBookFormViewModel`

### Supabase
- **Create**: `POST /rest/v1/books` - CreateBookDto → BookListItemDto
- **Update**: `PATCH /rest/v1/books?id=eq.{id}` - UpdateBookDto → void
- **Genres**: `GET /rest/v1/genres` - Lista GenreDto

## Nawigacja

Używany jest standardowy Flutter Navigator:

```dart
// Z ekranu głównego do AddBookScreen
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => const AddBookScreen()),
);

// Z AddBookScreen do BookFormScreen (po znalezieniu książki)
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => BookFormScreen(
      bookData: bookData,
      genres: genres,
    ),
  ),
);

// Powrót do ekranu głównego po zapisie
Navigator.of(context).popUntil((route) => route.isFirst);
```

## Obsługa błędów

Wszystkie błędy są wyświetlane użytkownikowi przez SnackBar:
- Błędy sieci (NoInternetException)
- Timeout
- Błędy walidacji
- Błędy serwera
- Książka nie znaleziona w Google Books API

## Zależności

### Wymagane serwisy (z RepositoryProvider):
- `BookService` - operacje na książkach
- `GenreService` - pobieranie gatunków
- `GoogleBooksService` - wyszukiwanie po ISBN

### Biblioteki:
- `flutter_bloc` - zarządzanie stanem
- `supabase_flutter` - komunikacja z backendem
- `http` - zapytania HTTP (przez GoogleBooksService)

## Rozszerzenia (TODO)

### Skaner kodów kreskowych
Aby włączyć skanowanie ISBN:

1. Dodaj do `pubspec.yaml`:
```yaml
dependencies:
  mobile_scanner: ^5.0.0
```

2. Dodaj uprawnienia w `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

3. Dodaj w `Info.plist` (iOS):
```xml
<key>NSCameraUsageDescription</key>
<string>Potrzebny dostęp do kamery, aby skanować kody kreskowe ISBN</string>
```

4. Zaimplementuj logikę w `ScanIsbnButton._handleScan()` (kod przykładowy w komentarzach)

## Testowanie

TODO: Napisać testy jednostkowe dla:
- AddBookBloc (wszystkie scenariusze)
- AddBookFormViewModel (konwersje)
- Walidacja pól formularza

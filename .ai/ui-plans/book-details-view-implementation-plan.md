# Plan implementacji widoku BookDetails

## 1. Przegląd
Widok `BookDetails` stanowi centralny punkt interakcji użytkownika z pojedynczą książką w jego bibliotece. Jego celem jest prezentacja wyczerpujących informacji o książce, wizualizacja postępów w czytaniu oraz zapewnienie dostępu do kluczowych akcji, takich jak rozpoczynanie i kończenie sesji czytania, edycja danych czy usuwanie książki. Widok ten integruje dane z kilku endpointów API, aby dostarczyć spójne i aktualne informacje.

## 2. Routing widoku
Widok powinien być dostępny pod dynamiczną ścieżką, która zawiera unikalny identyfikator książki.

- **Ścieżka:** `/books/:id`
- **Przykład:** `/books/c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c`
- **Parametr:** `id` (UUID książki) będzie odczytywany z parametrów trasy w celu pobrania odpowiednich danych.

## 3. Struktura komponentów
Hierarchia widżetów zostanie zorganizowana w sposób modułowy, aby oddzielić logikę od prezentacji.

```
BookDetailsScreen (StatefulWidget, zarządzany przez BLoC)
├── AppBar
│   └── (Menu z opcjami "Edytuj" i "Usuń")
├── BlocProvider<BookDetailsBloc>
│   └── BlocBuilder<BookDetailsBloc, BookDetailsState>
│       ├── (Stan ładowania -> CircularProgressIndicator)
│       ├── (Stan błędu -> ErrorDisplayWidget)
│       └── SingleChildScrollView (dla stanu sukcesu)
│           ├── BookInfoHeader
│           ├── BookProgressIndicator
│           ├── BookActionButtons
│           └── ReadingSessionHistory
│               └── ListView
│                   └── ReadingSessionListItem (wiele)
```

## 4. Szczegóły komponentów

### `BookDetailsScreen`
- **Opis:** Główny widżet ekranu, odpowiedzialny za inicjalizację BLoC, obsługę zdarzeń cyklu życia i renderowanie odpowiedniego UI w zależności od stanu (`loading`, `success`, `failure`).
- **Główne elementy:** `Scaffold`, `AppBar`, `BlocProvider`, `BlocBuilder`.
- **Obsługiwane interakcje:** Inicjuje pobieranie danych przy wejściu na ekran.
- **Typy:** `BookDetailsState`.
- **Propsy:** `String bookId` (przekazany z routera).

### `BookInfoHeader`
- **Opis:** Prezentuje podstawowe, statyczne informacje o książce.
- **Główne elementy:** `Row` lub `Column` zawierający `Image` (okładka) oraz widżety `Text` dla tytułu, autora, gatunku, ISBN, wydawcy i roku wydania.
- **Obsługiwane interakcje:** Brak.
- **Typy:** `BookDetailDto`.
- **Propsy:** `final BookDetailDto book;`.

### `BookProgressIndicator`
- **Opis:** Wizualizuje postęp czytania.
- **Główne elementy:** `Column` zawierający `LinearProgressIndicator` oraz widżety `Text` wyświetlające postęp procentowo oraz w formacie "przeczytane/wszystkie strony".
- **Obsługiwane interakcje:** Brak.
- **Typy:** `BookDetailDto`.
- **Propsy:** `final BookDetailDto book;`.

### `BookActionButtons`
- **Opis:** Dynamicznie renderuje przyciski akcji w zależności od statusu książki.
- **Główne elementy:** `Row` z widżetami `ElevatedButton` lub `TextButton`.
  - Jeśli status to `not_started`: "Rozpocznij czytanie".
  - Jeśli status to `in_progress`: "Rozpocznij sesję".
  - Jeśli status to `finished`: "Przeczytaj ponownie".
  - Zawsze dostępny (w menu): "Oznacz jako przeczytaną".
- **Obsługiwane interakcje:** `onPressed` dla każdego przycisku, które wywołują odpowiednie zdarzenia w `BookDetailsBloc` lub nawigują do innych ekranów.
- **Typy:** `BOOK_STATUS`.
- **Propsy:** `final BookDetailDto book;`, `VoidCallback onStartSession;`, `VoidCallback onMarkAsRead;`.

### `ReadingSessionHistory`
- **Opis:** Wyświetla listę historycznych sesji czytania.
- **Główne elementy:** `Column` z nagłówkiem (`Text`) i `ListView.builder`. Obsługuje stan pusty, wyświetlając komunikat "Brak historii sesji".
- **Obsługiwane interakcje:** Przewijanie listy.
- **Typy:** `List<ReadingSessionDto>`.
- **Propsy:** `final List<ReadingSessionDto> sessions;`.

### `EndSessionDialog`
- **Opis:** Okno dialogowe do wprowadzania postępu po zakończeniu sesji.
- **Główne elementy:** `AlertDialog` z `TextFormField` do wprowadzenia numeru strony i przyciskami "Anuluj" / "Zapisz".
- **Obsługiwane interakcje:** Wprowadzanie tekstu, kliknięcie przycisków.
- **Obsługiwana walidacja:**
  - Wartość musi być liczbą całkowitą.
  - Wartość musi być większa niż poprzedni postęp (`last_read_page_number`).
  - Wartość nie może być większa niż całkowita liczba stron (`page_count`).
- **Typy:** `int` (aktualny postęp), `int` (całkowita liczba stron).
- **Propsy:** `int currentPages;`, `int totalPages;`, `Function(int newPage) onSave;`.

## 5. Typy
Do implementacji widoku wykorzystane zostaną istniejące DTO oraz nowe typy dla zarządzania stanem.

- **DTO (z `types.dart`):**
  - `BookDetailDto`: Do przechowywania szczegółów książki.
  - `ReadingSessionDto`: Do reprezentowania pojedynczej sesji w historii.
  - `UpdateBookDto`: Do wysyłania żądań aktualizacji książki.
  - `EndReadingSessionDto`: Do wysyłania żądania zakończenia sesji.

- **Modele Stanu (dla BLoC):**
  - `abstract class BookDetailsState {}`
  - `class BookDetailsInitial extends BookDetailsState {}`: Stan początkowy.
  - `class BookDetailsLoading extends BookDetailsState {}`: Trwa ładowanie danych.
  - `class BookDetailsSuccess extends BookDetailsState { final BookDetailDto book; final List<ReadingSessionDto> sessions; }`: Dane załadowane pomyślnie.
  - `class BookDetailsFailure extends BookDetailsState { final String error; }`: Wystąpił błąd podczas ładowania.
  - `class BookDetailsActionInProgress extends BookDetailsState {}`: Trwa wykonywanie akcji (np. usuwanie).
  - `class BookDetailsActionSuccess extends BookDetailsState { final String message; }`: Akcja zakończona sukcesem.
  - `class BookDetailsActionFailure extends BookDetailsState { final String error; }`: Akcja zakończona błędem.

## 6. Zarządzanie stanem
Zarządzanie stanem zostanie zrealizowane przy użyciu biblioteki `flutter_bloc`.

- **`BookDetailsBloc`:**
  - **Zależności:** `BookService`, `ReadingSessionService`.
  - **Zdarzenia (Events):**
    - `FetchBookDetails(String bookId)`: Pobiera szczegóły książki i jej sesje.
    - `MarkAsReadRequested()`: Oznacza książkę jako przeczytaną.
    - `DeleteRequested()`: Usuwa książkę.
    - `EndSessionConfirmed(EndReadingSessionDto dto)`: Kończy sesję czytania.
  - **Logika:** BLoC będzie reagował na zdarzenia, wywoływał odpowiednie metody serwisów, a następnie emitował stany (`Loading`, `Success`, `Failure`), na które `BlocBuilder` będzie przebudowywał interfejs użytkownika. `BlocListener` będzie używany do obsługi akcji jednorazowych, jak nawigacja czy wyświetlanie `SnackBar`.

## 7. Integracja API
Integracja z API Supabase będzie realizowana poprzez wstrzyknięte serwisy.

- **Pobieranie danych:**
  - Po wejściu na ekran, `BookDetailsBloc` wywoła równolegle:
    - `bookService.getBook(bookId)` -> `GET /rest/v1/books?id=eq.{id}`
    - `readingSessionService.listReadingSessions(bookId)` -> `GET /rest/v1/reading_sessions?book_id=eq.{id}`
  - **Odpowiedź:** `BookDetailDto` i `List<ReadingSessionDto>`.

- **Aktualizacja danych:**
  - **Ręczne oznaczenie jako przeczytana:**
    - `bookService.updateBook(bookId, dto)` -> `PATCH /rest/v1/books?id=eq.{id}`
    - **Żądanie:** `UpdateBookDto(status: BOOK_STATUS.finished, last_read_page_number: book.pageCount)`.
  - **Zakończenie sesji:**
    - `readingSessionService.endReadingSession(dto)` -> `POST /rest/v1/rpc/end_reading_session`
    - **Żądanie:** `EndReadingSessionDto`.

- **Usuwanie danych:**
  - `bookService.deleteBook(bookId)` -> `DELETE /rest/v1/books?id=eq.{id}`

## 8. Interakcje użytkownika
- **Wejście na ekran:** Użytkownik widzi wskaźnik ładowania, a następnie szczegóły książki.
- **Kliknięcie "Rozpocznij sesję":** Użytkownik jest przenoszony do ekranu aktywnej sesji.
- **Zakończenie sesji:** Użytkownikowi wyświetla się dialog, w którym wpisuje ostatnio przeczytaną stronę. Po zatwierdzeniu, UI jest odświeżane, a postęp i historia sesji zaktualizowane.
- **Kliknięcie "Oznacz jako przeczytaną":** Status książki i wskaźnik postępu natychmiast się aktualizują, a w tle wysyłane jest żądanie do API.
- **Kliknięcie "Usuń":** Użytkownik musi potwierdzić akcję w oknie dialogowym. Po potwierdzeniu jest przenoszony z powrotem do listy książek.
- **Kliknięcie "Edytuj":** Użytkownik jest przenoszony do formularza edycji danych książki.

## 9. Warunki i walidacja
- **Blokada edycji liczby stron:** W formularzu edycji, pole `page_count` będzie nieaktywne (`readOnly`), jeśli `book.status` to `in_progress`.
- **Walidacja w `EndSessionDialog`:**
  - Przycisk "Zapisz" jest nieaktywny, dopóki wprowadzone dane nie spełnią warunków: `isNumber`, `> currentPage`, `<= totalPages`.
  - Komunikaty o błędach (np. "Strona musi być większa niż X") są wyświetlane pod polem tekstowym w czasie rzeczywistym.
- **Widoczność przycisków akcji:** Komponent `BookActionButtons` będzie renderował odpowiednie przyciski na podstawie `book.status` otrzymanego w propsach.

## 10. Obsługa błędów
- **Błąd ładowania danych:** Na ekranie zostanie wyświetlony widżet z komunikatem błędu i przyciskiem "Spróbuj ponownie", który ponownie wywoła zdarzenie `FetchBookDetails`.
- **Błąd sieci podczas akcji:** `BlocListener` przechwyci stan `BookDetailsActionFailure` i wyświetli `SnackBar` z informacją o błędzie (np. "Brak połączenia z internetem. Spróbuj ponownie.").
- **Błąd walidacji serwera (400):** Podobnie jak błąd sieci, zostanie wyświetlony `SnackBar` z komunikatem zwróconym przez API.
- **Brak autoryzacji (401):** Globalny mechanizm obsługi błędów (np. interceptor HTTP) powinien automatycznie wylogować użytkownika.
- **Zasób nieznaleziony (404):** Zostanie potraktowany jako błąd ładowania i wyświetli stosowny komunikat na całym ekranie.

## 11. Kroki implementacji
1.  **Rozbudowa `BookService`:** Dodać brakujące metody: `Future<BookDetailDto> getBook(String id)`, `Future<void> updateBook(String id, UpdateBookDto dto)` oraz `Future<void> deleteBook(String id)`.
2.  **Stworzenie BLoC:** Zaimplementować `BookDetailsBloc` wraz z jego stanami i zdarzeniami.
3.  **Struktura ekranu:** Zbudować `BookDetailsScreen` z `BlocProvider` i `BlocBuilder` obsługującym stany `loading`, `failure` i `success`.
4.  **Implementacja komponentów:** Stworzyć bezstanowe widżety: `BookInfoHeader`, `BookProgressIndicator`, `BookActionButtons` i `ReadingSessionHistory` z `ReadingSessionListItem`.
5.  **Podłączenie danych:** Przekazać dane ze stanu `BookDetailsSuccess` do odpowiednich komponentów potomnych.
6.  **Implementacja akcji:**
    - Zaimplementować nawigację do ekranu edycji i aktywnej sesji.
    - Stworzyć `EndSessionDialog` i podłączyć jego logikę do BLoC.
    - Podłączyć akcje usuwania i oznaczania jako przeczytana do BLoC.
7.  **Obsługa błędów i akcji:** Dodać `BlocListener` do `BookDetailsScreen` w celu wyświetlania `SnackBar` po udanych lub nieudanych akcjach.
8.  **Routing:** Dodać nową ścieżkę `/books/:id` w konfiguracji routera aplikacji.
9.  **Testowanie:** Przetestować wszystkie ścieżki użytkownika, w tym przypadki brzegowe i obsługę błędów.

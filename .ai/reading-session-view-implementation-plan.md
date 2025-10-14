# Plan implementacji widoku Sesji Czytania

## 1. Przegląd
Widok Sesji Czytania to pełnoekranowy interfejs w aplikacji, który pozwala użytkownikowi na śledzenie czasu poświęconego na czytanie konkretnej książki. Widok wyświetla duży, czytelny stoper, podstawowe informacje o czytanej książce oraz przycisk do zakończenia sesji. Po zakończeniu sesji, użytkownik jest proszony o wprowadzenie postępu, który jest następnie zapisywany w systemie. Celem widoku jest motywowanie użytkownika do regularnego czytania poprzez wizualizację wysiłku i śledzenie postępów.

## 2. Routing widoku
Widok będzie dostępny pod ścieżką `/book/{bookId}/session`. Nawigacja do tego widoku nastąpi z ekranu szczegółów książki po naciśnięciu przycisku "Rozpocznij sesję". Widok powinien przyjmować obiekt `BookListItemDto` jako argument nawigacji, aby mieć natychmiastowy dostęp do danych książki.

## 3. Struktura komponentów
Struktura widoku będzie oparta na architekturze BLoC. Główny widżet `ReadingSessionScreen` będzie zarządzał stanem za pomocą `ReadingSessionBloc` i budował interfejs w zależności od aktualnego stanu.

```
ReadingSessionScreen (BLoCProvider<ReadingSessionBloc>)
└── Scaffold
    └── BlocListener<ReadingSessionBloc> (do obsługi nawigacji i dialogów)
        └── Padding
            └── Column (mainAxisAlignment: space-around)
                ├── BookInfoHeader (wyświetla dane książki)
                ├── StopwatchDisplay (wyświetla upływający czas)
                └── EndSessionButton (przycisk kończący sesję)
```
Dialog `EndSessionDialog` będzie wywoływany imperatywnie z `BlocListener` w odpowiedzi na odpowiedni stan bloka.

## 4. Szczegóły komponentów
### ReadingSessionScreen
- **Opis komponentu**: Główny, stanowy widżet (StatefulWidget) ekranu, który inicjalizuje i dostarcza `ReadingSessionBloc`. Subskrybuje zmiany stanu, aby przebudować UI oraz obsługiwać zdarzenia jednorazowe (side effects), takie jak nawigacja czy pokazywanie dialogów i `SnackBar`.
- **Główne elementy**: `Scaffold`, `BlocProvider`, `BlocListener`, `Column` z komponentami podrzędnymi.
- **Obsługiwane interakcje**: Inicjalizacja sesji po załadowaniu widoku.
- **Typy**: `BookListItemDto` (przyjmowany jako argument).
- **Propsy**: `book: BookListItemDto`.

### BookInfoHeader
- **Opis komponentu**: Prosty, bezstanowy widżet (StatelessWidget) wyświetlający okładkę, tytuł oraz autora książki.
- **Główne elementy**: `Column`, `Image.network`, `Text`.
- **Obsługiwane interakcje**: Brak.
- **Typy**: `BookListItemDto`.
- **Propsy**: `book: BookListItemDto`.

### StopwatchDisplay
- **Opis komponentu**: Widżet stanowy (StatefulWidget), który zarządza wewnętrznym `Timer`em do aktualizacji wyświetlanego czasu co sekundę. Oblicza różnicę między czasem startu a aktualnym czasem.
- **Główne elementy**: `Timer`, `Text` z formatowaniem czasu (HH:MM:SS).
- **Obsługiwane interakcje**: Brak.
- **Typy**: `DateTime` (czas startu).
- **Propsy**: `startTime: DateTime`.

### EndSessionButton
- **Opis komponentu**: Przycisk (`ElevatedButton`), który po naciśnięciu wysyła zdarzenie do `ReadingSessionBloc` w celu rozpoczęcia procesu kończenia sesji.
- **Główne elementy**: `ElevatedButton`, `Text`.
- **Obsługiwane interakcje**: `onPressed`.
- **Propsy**: `onPressed: VoidCallback`.

### EndSessionDialog
- **Opis komponentu**: Funkcja, która zwraca `AlertDialog` zawierający formularz do wprowadzenia postępu. Dialog jest zarządzany z poziomu `ReadingSessionScreen`.
- **Główne elementy**: `AlertDialog`, `TextField` (dla numeru strony), `TextButton` ("Zapisz"), `TextButton` ("Anuluj").
- **Obsługiwane interakcje**: Wprowadzanie tekstu, kliknięcie przycisków.
- **Obsługiwana walidacja**:
  - Wartość musi być liczbą całkowitą.
  - Wartość musi być większa niż `book.lastReadPageNumber`.
  - Wartość nie może być większa niż `book.pageCount`.
- **Typy**: `BookListItemDto` (do walidacji).
- **Propsy**: `book: BookListItemDto`, `onSave: Function(int newPage)`.

## 5. Typy
Do implementacji widoku wykorzystane zostaną istniejące typy DTO oraz nowe typy reprezentujące stan BLoC.

- **`BookListItemDto`**: Istniejący DTO z `types.dart`, zawiera wszystkie potrzebne dane książki.
- **`EndReadingSessionDto`**: Istniejący DTO z `types.dart`, używany do wysłania danych do API.
- **`ReadingSessionState` (State BLoC-a)**:
  - `status`: `enum { initial, inProgress, showDialog, submitting, success, failure }` - określa aktualny stan logiki widoku.
  - `book`: `BookListItemDto` - aktualnie czytana książka.
  - `startTime`: `DateTime` - czas rozpoczęcia sesji.
  - `errorMessage`: `String?` - opcjonalny komunikat błędu do wyświetlenia.

## 6. Zarządzanie stanem
Zarządzanie stanem będzie realizowane przy użyciu biblioteki `flutter_bloc`.

- **`ReadingSessionBloc`**:
  - **Zdarzenia (Events)**:
    - `SessionStarted(BookListItemDto book)`: Inicjalizuje sesję, ustawia `startTime` i `book`.
    - `EndSessionButtonTapped`: Zmienia stan na `showDialog`, aby UI mogło pokazać dialog.
    - `SessionFinished(int lastReadPage)`: Tworzy `EndReadingSessionDto`, wywołuje `ReadingSessionService`, obsługuje wynik operacji.
    - `DialogDismissed`: Przywraca stan `inProgress` po zamknięciu dialogu bez zapisu.
  - **Stany (States)**:
    - `ReadingSessionInitial`: Stan początkowy.
    - `ReadingSessionInProgress`: Sesja trwa, UI wyświetla stoper.
    - `ReadingSessionShowDialog`: Sygnalizuje UI konieczność pokazania `EndSessionDialog`.
    - `ReadingSessionSubmitting`: Trwa komunikacja z API, UI pokazuje wskaźnik ładowania.
    - `ReadingSessionSuccess`: Operacja zakończona sukcesem, UI powinno zainicjować nawigację powrotną.
    - `ReadingSessionFailure`: Wystąpił błąd, UI pokazuje komunikat.

## 7. Integracja API
Integracja z API będzie realizowana poprzez `ReadingSessionService`, który jest już zaimplementowany. `ReadingSessionBloc` będzie jedynym miejscem, które komunikuje się z tym serwisem.

- **Wywołanie**: `readingSessionService.endReadingSession(dto)`
- **Typ żądania**: `EndReadingSessionDto`
  ```dart
  const EndReadingSessionDto({
    required String bookId,
    required DateTime startTime,
    required DateTime endTime,
    required int lastReadPage,
  });
  ```
- **Typ odpowiedzi**: `Future<String?>` - UUID utworzonej sesji lub `null`, jeśli nie utworzono sesji (np. 0 przeczytanych stron).

## 8. Interakcje użytkownika
1.  **Start sesji**: Użytkownik naciska "Rozpocznij sesję" na ekranie szczegółów książki. Aplikacja nawiguje do `ReadingSessionScreen`, co wyzwala zdarzenie `SessionStarted` i uruchamia stoper.
2.  **Koniec sesji**: Użytkownik naciska "Zakończ sesję". Stoper wizualnie się zatrzymuje, a na ekranie pojawia się `EndSessionDialog`.
3.  **Wprowadzenie postępu**: Użytkownik wpisuje numer ostatnio przeczytanej strony. Pole tekstowe na bieżąco waliduje wprowadzoną wartość.
4.  **Zapis postępu**: Użytkownik naciska "Zapisz". Dialog jest zamykany, BLoC wysyła dane do API. Na ekranie może pojawić się wskaźnik ładowania. Po sukcesie aplikacja wraca do ekranu szczegółów. W razie błędu wyświetlany jest komunikat.
5.  **Anulowanie**: Użytkownik naciska "Anuluj" w dialogu. Dialog jest zamykany, a stoper wizualnie wznawia pracę.

## 9. Warunki i walidacja
Walidacja odbywa się w `EndSessionDialog` przed wysłaniem danych do BLoC.
- **Komponent**: `EndSessionDialog`.
- **Warunki**:
  1.  Wprowadzona wartość musi być poprawną liczbą całkowitą.
  2.  `nowa_strona > ostatnio_przeczytana_strona` (`newPage > book.lastReadPageNumber`).
  3.  `nowa_strona <= całkowita_liczba_stron` (`newPage <= book.pageCount`).
- **Wpływ na interfejs**: Przycisk "Zapisz" w dialogu jest nieaktywny (`disabled`), dopóki wszystkie warunki nie zostaną spełnione. W przypadku wprowadzenia nieprawidłowej wartości, pod polem tekstowym wyświetlany jest odpowiedni komunikat błędu.

## 10. Obsługa błędów
- **Błędy walidacji (front-end)**: Obsługiwane w `EndSessionDialog` poprzez wyświetlanie komunikatów o błędach i blokowanie przycisku zapisu.
- **Brak połączenia z internetem**: `ReadingSessionBloc` łapie `NoInternetException` i emituje stan `ReadingSessionFailure` z komunikatem "Brak połączenia z internetem". `BlocListener` wyświetla `SnackBar`.
- **Błędy serwera/API**: `ReadingSessionBloc` łapie `ValidationException`, `ServerException` itp. i emituje stan `ReadingSessionFailure` z odpowiednim komunikatem. `BlocListener` wyświetla `SnackBar`.
- **Anulowanie przez użytkownika**: Jeśli użytkownik zamknie aplikację w trakcie sesji, stan nie jest zapisywany. Po ponownym uruchomieniu sesja nie będzie kontynuowana (uproszczenie MVP).

## 11. Kroki implementacji
1.  **Struktura plików**: Utworzyć nowy folder `lib/features/reading_session/` z podfolderami `bloc/`, `view/` i `widgets/`.
2.  **BLoC**: Zaimplementować `ReadingSessionBloc`, `ReadingSessionEvent` i `ReadingSessionState` zgodnie z opisem w sekcji 6.
3.  **Komponenty UI**: Stworzyć bezstanowe widżety: `BookInfoHeader`, `EndSessionButton` oraz stanowy `StopwatchDisplay`.
4.  **Główny ekran**: Zaimplementować `ReadingSessionScreen`, który połączy BLoC z komponentami UI. Dodać `BlocProvider` i `BlocListener` do obsługi logiki.
5.  **Dialog**: Zaimplementować funkcję `showEndSessionDialog`, która będzie budować i wyświetlać `AlertDialog` z logiką walidacji.
6.  **Nawigacja**: Zaktualizować router aplikacji (np. `go_router`), aby dodać nową ścieżkę `/book/{bookId}/session` i obsługiwać nawigację do `ReadingSessionScreen`.
7.  **Integracja**: Połączyć akcję przycisku "Rozpocznij sesję" w widoku szczegółów książki z nawigacją do nowego ekranu.
8.  **Odświeżanie danych**: Zaimplementować mechanizm odświeżania danych na ekranie szczegółów książki po powrocie z `ReadingSessionScreen` (np. poprzez sprawdzanie wartości zwrotnej z `Navigator.pop`).
9.  **Testowanie**: Przetestować manualnie wszystkie ścieżki użytkownika, w tym przypadki błędów i walidacji.
10. **(Opcjonalnie po MVP)**: Zająć się implementacją logiki działającej w tle dla stopera i powiadomień (US-016) przy użyciu dedykowanych pakietów.

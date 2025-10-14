# Plan implementacji widoku dodawania książki (Add Book)

## 1. Przegląd

Widok "Add Book" umożliwia użytkownikowi dodanie nowej książki do swojej biblioteki. Proces ten jest kluczową funkcjonalnością aplikacji i oferuje dwie ścieżki:

1.  **Automatyczną**: Poprzez wprowadzenie lub zeskanowanie kodu ISBN. Aplikacja wysyła zapytanie do Google Books API, pobiera dane książki i wstępnie wypełnia formularz, który użytkownik może zweryfikować i zapisać.
2.  **Ręczną**: Użytkownik samodzielnie wypełnia formularz z danymi książki, takimi jak tytuł, autor i liczba stron.

Celem jest zapewnienie szybkiego, intuicyjnego i elastycznego sposobu na rozbudowę osobistej biblioteki.

## 2. Routing widoku

1.  **Ekran wyboru metody dodawania (`AddBookScreen`)**:
    *   **Ścieżka**: `/add-book`
    *   **Dostęp**: Inicjowany po naciśnięciu `FloatingActionButton` na ekranie głównym.
2.  **Ekran formularza książki (`BookFormScreen`)**:
    *   **Ścieżka**: `/add-book/form`
    *   **Dostęp**:
        *   Po pomyślnym znalezieniu książki przez ISBN (z przekazanymi danymi).
        *   Po wybraniu opcji "Dodaj ręcznie" (z pustym formularzem).
        *   W trybie edycji, z ekranu szczegółów książki (z wypełnionymi danymi istniejącej książki i `bookId`).

## 3. Struktura komponentów

```
- AddBookScreen (Scaffold)
  - AppBar
  - Column
    - ScanIsbnButton
    - IsbnInputField
    - Text("lub")
    - ElevatedButton("Dodaj ręcznie")

- BookFormScreen (Scaffold)
  - AppBar (tytuł dynamiczny: "Dodaj książkę" / "Edytuj książkę")
  - BlocBuilder<AddBookBloc, AddBookState>
    - Form
      - TextFormField (Tytuł)
      - TextFormField (Autor)
      - TextFormField (Liczba stron)
      - DropdownButtonFormField (Gatunek)
      - TextFormField (URL okładki)
      - TextFormField (ISBN)
      - TextFormField (Wydawca)
      - TextFormField (Rok wydania)
      - ElevatedButton("Zapisz")
    - (Opcjonalnie) CircularProgressIndicator w stanie ładowania
```

## 4. Szczegóły komponentów

### `AddBookScreen`

*   **Opis**: Ekran startowy przepływu dodawania książki, pozwalający użytkownikowi wybrać metodę: skanowanie/wpisanie ISBN lub dodanie ręczne.
*   **Główne elementy**:
    *   `ScanIsbnButton`: Przycisk otwierający widok kamery do skanowania kodu ISBN.
    *   `IsbnInputField`: Pole tekstowe z przyciskiem do ręcznego wprowadzenia numeru ISBN i wyszukania książki.
    *   Przycisk "Dodaj ręcznie": Nawiguje do `BookFormScreen` z pustymi danymi.
*   **Obsługiwane interakcje**:
    *   Naciśnięcie `ScanIsbnButton` -> uruchamia skaner.
    *   Wprowadzenie numeru ISBN i naciśnięcie przycisku szukania -> wywołuje zdarzenie `AddBookEvent.fetchBookByIsbn`.
    *   Naciśnięcie "Dodaj ręcznie" -> nawiguje do `BookFormScreen`.
*   **Typy**: `AddBookState` (do obsługi ładowania/błędów po wyszukaniu ISBN).
*   **Propsy**: Brak.

### `BookFormScreen`

*   **Opis**: Formularz do dodawania nowej lub edycji istniejącej książki. Pola mogą być wstępnie wypełnione danymi z Google Books API lub danymi edytowanej książki.
*   **Główne elementy**:
    *   `Form` z `GlobalKey<FormState>` do walidacji.
    *   Pola `TextFormField` dla wszystkich atrybutów książki.
    *   `DropdownButtonFormField` do wyboru gatunku z predefiniowanej listy.
    *   Przycisk "Zapisz".
*   **Obsługiwane interakcje**:
    *   Wypełnianie pól formularza.
    *   Naciśnięcie przycisku "Zapisz" -> waliduje formularz i wywołuje zdarzenie `AddBookEvent.saveBook`.
*   **Warunki walidacji**:
    *   `Tytuł`: Nie może być pusty.
    *   `Autor`: Nie może być pusty.
    *   `Liczba stron`: Musi być liczbą całkowitą, większą od 0. Pole jest zablokowane w trybie edycji, jeśli książka ma status "W trakcie".
    *   `Rok wydania`: Musi być poprawnym rokiem (np. 4-cyfrowa liczba).
*   **Typy**: `AddBookFormViewModel`, `CreateBookDto`, `UpdateBookDto`, `GenreDto`.
*   **Propsy**:
    *   `bookData` (`AddBookFormViewModel`): Opcjonalne dane do wstępnego wypełnienia formularza.
    *   `bookId` (`String?`): ID książki, jeśli jest w trybie edycji.

## 5. Typy

### `AddBookFormViewModel` (nowy typ)

Model widoku reprezentujący dane formularza. Jest pośrednikiem między DTO a widokiem, ułatwiając zarządzanie stanem formularza i konwersję danych.

*   **Pola**:
    *   `title`: `String`
    *   `author`: `String`
    *   `pageCount`: `int`
    *   `genreId`: `String?`
    *   `coverUrl`: `String?`
    *   `isbn`: `String?`
    *   `publisher`: `String?`
    *   `publicationYear`: `int?`
*   **Cel**: Przechowywanie danych wprowadzanych przez użytkownika w formularzu, niezależnie od tego, czy pochodzą z API, czy są wprowadzane ręcznie. Umożliwia łatwą konwersję do `CreateBookDto` lub `UpdateBookDto` przed wysłaniem do API.

### `GenreDto` (istniejący typ)

Używany do wypełnienia listy rozwijanej z gatunkami.

## 6. Zarządzanie stanem

Stanem całego przepływu będzie zarządzał `AddBookBloc` z biblioteki `flutter_bloc`.

*   **`AddBookEvent`**:
    *   `FetchBookByIsbn(String isbn)`: Rozpoczyna wyszukiwanie książki w Google Books API.
    *   `SaveBook(AddBookFormViewModel data, String? bookId)`: Zapisuje nową lub aktualizuje istniejącą książkę.
    *   `FetchGenres()`: Pobiera listę dostępnych gatunków.

*   **`AddBookState`**:
    *   `initial`: Stan początkowy.
    *   `loading`: Wyszukiwanie książki po ISBN lub zapisywanie danych.
    *   `genresLoaded(List<GenreDto> genres)`: Stan po pomyślnym załadowaniu gatunków.
    *   `bookFound(AddBookFormViewModel bookData)`: Stan po pomyślnym znalezieniu książki w Google Books API. Przekazuje dane do `BookFormScreen`.
    *   `bookSaved`: Stan po pomyślnym zapisaniu książki. Powoduje nawigację powrotną.
    *   `error(String message)`: Stan błędu (np. nie znaleziono książki, błąd walidacji, błąd sieci).

## 7. Integracja API

*   **Wyszukiwanie książki**:
    *   BLoC wywołuje `GoogleBooksApiService.searchByIsbn(isbn)`.
    *   **Typ odpowiedzi**: `GoogleBookResult`.
    *   Po otrzymaniu odpowiedzi, BLoC mapuje `GoogleBookResult` na `AddBookFormViewModel` i emituje stan `bookFound`.
*   **Pobieranie gatunków**:
    *   BLoC wywołuje metodę pobierającą gatunki (prawdopodobnie z `BookService` lub dedykowanego serwisu).
    *   **Typ odpowiedzi**: `List<GenreDto>`.
*   **Zapisywanie książki**:
    *   BLoC konwertuje `AddBookFormViewModel` na `CreateBookDto` (dla nowej książki) lub `UpdateBookDto` (dla edytowanej).
    *   Wywołuje `BookService.createBook(dto)` lub `BookService.updateBook(bookId, dto)`.
    *   **Typ żądania**: `CreateBookDto` / `UpdateBookDto`.
    *   **Typ odpowiedzi**: `BookListItemDto`.

## 8. Interakcje użytkownika

*   **Użytkownik skanuje/wpisuje ISBN**:
    1.  Aplikacja pokazuje wskaźnik ładowania.
    2.  Po znalezieniu książki, następuje nawigacja do `BookFormScreen` z wypełnionymi polami.
    3.  Jeśli książka nie zostanie znaleziona, wyświetlany jest komunikat błędu (np. `SnackBar`) z informacją i sugestią ręcznego dodania.
*   **Użytkownik wybiera dodawanie ręczne**:
    1.  Następuje nawigacja do `BookFormScreen` z pustymi polami.
*   **Użytkownik zapisuje formularz**:
    1.  Formularz jest walidowany. Jeśli wystąpią błędy, są one wyświetlane pod odpowiednimi polami.
    2.  Jeśli walidacja przejdzie pomyślnie, aplikacja pokazuje wskaźnik ładowania.
    3.  Po pomyślnym zapisie, użytkownik jest przenoszony z powrotem do ekranu głównego, a na nim wyświetlany jest komunikat potwierdzający (np. `SnackBar`).

## 9. Warunki i walidacja

*   **Wyszukiwanie ISBN**: Pole `IsbnInputField` powinno walidować format numeru ISBN (10 lub 13 cyfr) przed wysłaniem zapytania.
*   **Formularz `BookFormScreen`**:
    *   Pola `Tytuł` i `Autor` są wymagane.
    *   `Liczba stron` musi być dodatnią liczbą całkowitą.
    *   Walidacja odbywa się "na żywo" (po utracie fokusu przez pole) oraz przy próbie zapisu.
    *   Stan przycisku "Zapisz" może być nieaktywny, dopóki wymagane pola nie zostaną poprawnie wypełnione.

## 10. Obsługa błędów

*   **Nie znaleziono książki po ISBN**: `AddBookBloc` emituje stan `error` z komunikatem "Nie znaleziono książki dla podanego numeru ISBN". `AddBookScreen` wyświetla ten komunikat użytkownikowi.
*   **Błąd sieci podczas wyszukiwania/zapisu**: BLoC emituje stan `error` z ogólnym komunikatem o błędzie sieci. Widok wyświetla `SnackBar` lub dialog.
*   **Błąd walidacji z serwera (400 Bad Request)**: Jeśli serwer odrzuci dane, BLoC emituje stan `error` z komunikatem błędu, który jest wyświetlany na ekranie formularza.
*   **Brak połączenia z internetem**: Przed wykonaniem akcji sieciowej należy sprawdzić stan połączenia. Jeśli go nie ma, należy od razu wyświetlić stosowny komunikat, blokując próbę wysłania zapytania.

## 11. Kroki implementacji

1.  **Stworzenie struktury plików**: Utworzenie folderów i pustych plików dla BLoC, ekranów i widżetów w `lib/features/add_book/`.
2.  **Definicja BLoC**: Zaimplementowanie `AddBookEvent`, `AddBookState` oraz szkieletu `AddBookBloc`.
3.  **Implementacja `AddBookScreen`**: Zbudowanie interfejsu ekranu wyboru metody, na razie bez logiki.
4.  **Implementacja `BookFormScreen`**: Zbudowanie formularza z wszystkimi polami, bez logiki i walidacji.
5.  **Logika pobierania gatunków**: Zaimplementowanie w BLoC logiki do pobierania i udostępniania listy gatunków do formularza.
6.  **Logika wyszukiwania po ISBN**: Zaimplementowanie w BLoC obsługi zdarzenia `FetchBookByIsbn`, integracji z `GoogleBooksApiService` i emisji stanów `loading`, `bookFound` lub `error`.
7.  **Połączenie `AddBookScreen` z BLoC**: Podpięcie stanu BLoC do `AddBookScreen` w celu obsługi ładowania, błędów i nawigacji do formularza po znalezieniu książki.
8.  **Logika zapisu książki**: Zaimplementowanie w BLoC obsługi zdarzenia `SaveBook`, walidacji, konwersji `ViewModel` na `DTO` i integracji z `BookService`.
9.  **Połączenie `BookFormScreen` z BLoC**: Podpięcie stanu BLoC do `BookFormScreen` w celu obsługi zapisu, błędów oraz wstępnego wypełnienia danych. Zaimplementowanie walidacji formularza.
10. **Nawigacja**: Skonfigurowanie routera aplikacji (np. GoRouter) do obsługi nowych ścieżek i przekazywania parametrów.
11. **Implementacja skanera ISBN**: Zintegrowanie biblioteki do skanowania kodów kreskowych (np. `mobile_scanner`) i podłączenie jej wyniku do BLoC.
12. **Finalne poprawki i testy**: Dopracowanie UI, obsługa przypadków brzegowych i napisanie testów jednostkowych dla `AddBookBloc`.

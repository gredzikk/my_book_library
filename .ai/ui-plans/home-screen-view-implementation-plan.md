# Plan implementacji widoku Ekranu Głównego (Home Screen)

## 1. Przegląd
Ekran główny jest centralnym punktem aplikacji, zapewniającym użytkownikom przegląd ich osobistej biblioteki książek. Widok ten ma na celu umożliwienie szybkiego dostępu do kolekcji, łatwego dodawania nowych pozycji oraz filtrowania i sortowania listy w celu efektywnego zarządzania książkami. Implementuje również kluczowe mechanizmy UX, takie jak obsługa stanów ładowania, pustej listy oraz odświeżania danych.

## 2. Routing widoku
- **Ścieżka:** `/home`
- **Dostępność:** Widok dostępny po pomyślnym zalogowaniu użytkownika. Jest to domyślny ekran po autoryzacji.

## 3. Struktura komponentów
```
- HomeScreenView (Widget routingu, zarządza BLoC)
  - HomeScreenBlocProvider (Dostarcza BLoC do drzewa widgetów)
    - HomeScreenContent (Główny widget budujący UI na podstawie stanu BLoC)
      - Scaffold
        - AppBar
          - FilterSortButton (Przycisk otwierający modal z opcjami filtrowania/sortowania)
        - BlocBuilder<HomeScreenBloc, HomeScreenState>
          - (if state is Loading) -> LoadingSkeletonWidget
          - (if state is Empty) -> EmptyStateWidget
          - (if state is Success) ->
            - RefreshIndicator (Obsługa "pull-to-refresh")
              - BookGrid (Siatka z kafelkami książek)
                - BookGridTile (Pojedynczy kafelek reprezentujący książkę)
        - FloatingActionButton (Przycisk do dodawania nowej książki)
```

## 4. Szczegóły komponentów

### HomeScreenContent
- **Opis komponentu:** Główny widget odpowiedzialny za renderowanie interfejsu użytkownika w zależności od aktualnego stanu `HomeScreenBloc`. Zarządza wyświetlaniem szkieletu ładowania, stanu pustego lub siatki z książkami.
- **Główne elementy:** `Scaffold`, `AppBar` z tytułem i przyciskiem `FilterSortButton`, `FloatingActionButton` oraz `BlocBuilder` do dynamicznego renderowania treści.
- **Obsługiwane interakcje:**
  - Naciśnięcie `FilterSortButton` -> Otwiera modal filtrowania.
  - Naciśnięcie `FloatingActionButton` -> Nawiguje do ekranu dodawania książki.
  - Gest "pull-to-refresh" -> Wywołuje zdarzenie `LoadBooksEvent` z `forceRefresh: true`.
- **Typy:** `HomeScreenState`, `HomeScreenEvent`.
- **Propsy:** Brak (otrzymuje BLoC z kontekstu).

### BookGrid
- **Opis komponentu:** Widget wyświetlający listę książek w formie responsywnej siatki (`GridView`).
- **Główne elementy:** `GridView.builder`, który tworzy widgety `BookGridTile` dla każdej książki z listy.
- **Obsługiwane interakcje:**
  - Naciśnięcie na `BookGridTile` -> Nawiguje do ekranu szczegółów książki, przekazując jej ID.
- **Typy:** `List<BookListItemDto>`.
- **Propsy:** `List<BookListItemDto> books`.

### BookGridTile
- **Opis komponentu:** Kafelek reprezentujący pojedynczą książkę w siatce. Wyświetla okładkę, tytuł, autora i ikonę statusu.
- **Główne elementy:** `Card`, `Stack` (dla ikony statusu na okładce), `Image.network` (dla okładki), `Text` (dla tytułu i autora).
- **Obsługiwane interakcje:** Brak (obsługiwane przez rodzica `BookGrid`).
- **Typy:** `BookListItemDto`.
- **Propsy:** `BookListItemDto book`.

### FilterSortButton
- **Opis komponentu:** Przycisk w `AppBar`, który otwiera dolny panel (modal) z opcjami filtrowania (wg statusu, gatunku) i sortowania.
- **Główne elementy:** `IconButton`. Po naciśnięciu używa `showModalBottomSheet` do wyświetlenia formularza z opcjami.
- **Obsługiwane interakcje:**
  - Naciśnięcie przycisku -> Otwiera modal.
  - Zastosowanie filtrów w modalu -> Wywołuje zdarzenie `LoadBooksEvent` z nowymi parametrami filtrowania.
- **Typy:** `FilterSortOptions` (ViewModel).
- **Propsy:** Brak.

### LoadingSkeletonWidget
- **Opis komponentu:** Wyświetla szkielet UI (shimmer effect) podczas ładowania danych, symulując układ siatki z książkami.
- **Główne elementy:** `GridView` z zastępczymi, animowanymi kontenerami.
- **Propsy:** Brak.

### EmptyStateWidget
- **Opis komponentu:** Wyświetlany, gdy użytkownik nie ma żadnych książek w bibliotece. Zawiera komunikat i przycisk zachęcający do dodania pierwszej książki.
- **Główne elementy:** `Center`, `Column`, `Icon`, `Text`, `ElevatedButton`.
- **Obsługiwane interakcje:**
  - Naciśnięcie przycisku "Dodaj książkę" -> Nawiguje do ekranu dodawania książki.
- **Propsy:** Brak.

## 5. Typy

### `BookListItemDto`
- **Opis:** Istniejący typ DTO (Data Transfer Object) mapowany bezpośrednio z odpowiedzi API. Używany do przekazywania danych o książkach do komponentów UI.
- **Pola:** `id`, `title`, `author`, `coverUrl`, `status`, `genres`, etc. (zgodnie z `types.dart`).

### `FilterSortOptions` (ViewModel)
- **Opis:** Nowy typ (klasa) przechowujący aktualnie wybrane przez użytkownika opcje filtrowania i sortowania.
- **Pola:**
  - `BOOK_STATUS? status`: Filtr statusu książki.
  - `String? genreId`: Filtr ID gatunku.
  - `String orderBy`: Pole, po którym odbywa się sortowanie (np. 'title').
  - `String orderDirection`: Kierunek sortowania ('asc' lub 'desc').

## 6. Zarządzanie stanem

Zarządzanie stanem widoku będzie realizowane przy użyciu biblioteki BLoC (Business Logic Component).

- **`HomeScreenBloc`**: Główny BLoC widoku.
  - **Zdarzenia (`HomeScreenEvent`):**
    - `LoadBooksEvent({bool forceRefresh = false, FilterSortOptions? filters})`: Inicjuje ładowanie listy książek. `forceRefresh` wymusza odświeżenie danych z API. `filters` pozwala na zastosowanie nowych opcji filtrowania/sortowania.
  - **Stany (`HomeScreenState`):**
    - `HomeScreenInitial`: Stan początkowy.
    - `HomeScreenLoading`: Stan ładowania danych (UI pokazuje `LoadingSkeletonWidget`).
    - `HomeScreenSuccess(List<BookListItemDto> books)`: Dane załadowane pomyślnie (UI pokazuje `BookGrid`).
    - `HomeScreenEmpty`: Załadowano dane, ale lista książek jest pusta (UI pokazuje `EmptyStateWidget`).
    - `HomeScreenError(String message)`: Wystąpił błąd podczas ładowania (UI pokazuje komunikat błędu, np. w `SnackBar`).
  - **Logika:** `HomeScreenBloc` będzie korzystał z wstrzykniętej instancji `BookService` do pobierania danych. Będzie mapował zdarzenia na stany, obsługując logikę odświeżania, filtrowania i paginacji.

## 7. Integracja API
- **Endpoint:** `GET /rest/v1/books`
- **Implementacja:** Wykorzystana zostanie istniejąca metoda `listBooks` z klasy `BookService`.
- **Przepływ:**
  1. `HomeScreenBloc` otrzymuje `LoadBooksEvent`.
  2. Bloc wywołuje `bookService.listBooks()` z odpowiednimi parametrami (filtrowanie, sortowanie, paginacja) pobranymi ze stanu lub zdarzenia.
  3. **Żądanie:** `BookService` konstruuje żądanie GET do `/rest/v1/books` z parametrami takimi jak `select=*,genres(name)`, `status=eq.{status}`, `order=title.asc`.
  4. **Odpowiedź:** API zwraca tablicę obiektów JSON, którą `BookService` parsuje do `List<BookListItemDto>`.
  5. `HomeScreenBloc` emituje stan `HomeScreenSuccess` z otrzymaną listą książek lub `HomeScreenEmpty`, jeśli lista jest pusta.
  6. W przypadku błędu (np. `NoInternetException`, `ServerException`), `HomeScreenBloc` emituje stan `HomeScreenError`.

## 8. Interakcje użytkownika
- **Przeglądanie listy:** Użytkownik może przewijać siatkę z książkami.
- **Wejście w szczegóły:** Dotknięcie kafelka książki nawiguje do jej ekranu szczegółów.
- **Dodawanie książki:** Dotknięcie `FloatingActionButton` przenosi do ekranu dodawania nowej książki.
- **Odświeżanie danych:** Przeciągnięcie palcem w dół na liście (pull-to-refresh) powoduje ponowne załadowanie danych z serwera.
- **Filtrowanie i sortowanie:** Dotknięcie ikony filtra w `AppBar` otwiera modal, gdzie użytkownik może wybrać kryteria, a następnie zatwierdzić je, co powoduje ponowne załadowanie listy z nowymi parametrami.

## 9. Warunki i walidacja
- **Walidacja parametrów `listBooks`:** Odbywa się po stronie `BookService` (zgodnie z istniejącą implementacją `_validateListBooksParameters`). Obejmuje sprawdzanie limitu, offsetu, formatu UUID dla `genreId` oraz poprawności kierunku sortowania. Interfejs użytkownika powinien zapewniać poprawne wartości (np. poprzez wybór z predefiniowanej listy), aby uniknąć błędów walidacji.
- **Stan połączenia sieciowego:** `BookService` rzuca `NoInternetException`. `HomeScreenBloc` powinien przechwycić ten błąd i wyemitować stan `HomeScreenError` z odpowiednim komunikatem, który zostanie wyświetlony użytkownikowi (np. w `SnackBar`).

## 10. Obsługa błędów
- **Brak połączenia z internetem:** `SnackBar` z komunikatem "Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie."
- **Błąd serwera (5xx):** `SnackBar` z ogólnym komunikatem "Wystąpił błąd serwera. Spróbuj ponownie później."
- **Błąd autoryzacji (401):** Globalny mechanizm (interceptor HTTP lub logika w serwisie) powinien przechwycić ten błąd, wylogować użytkownika i przekierować go do ekranu logowania.
- **Pusta lista książek:** Nie jest to błąd, lecz stan. Zostanie obsłużony przez wyświetlenie dedykowanego widgetu `EmptyStateWidget`.
- **Błąd ładowania obrazka okładki:** Widget `Image.network` w `BookGridTile` powinien mieć zdefiniowany `errorBuilder`, który w przypadku błędu wyświetli zastępczy obrazek lub ikonę.

## 11. Kroki implementacji
1.  **Struktura plików:** Utworzenie nowej struktury folderów w `lib/features/home/` na pliki BLoC (`bloc/`), widoku (`view/`) i komponentów (`widgets/`).
2.  **Implementacja BLoC:** Stworzenie `HomeScreenBloc`, `HomeScreenState` i `HomeScreenEvent`. Zaimplementowanie logiki obsługi zdarzenia `LoadBooksEvent`, wstrzyknięcie i wykorzystanie `BookService`.
3.  **Implementacja widoku głównego:** Stworzenie `HomeScreenView` jako widgetu routingu oraz `HomeScreenContent` jako głównego widgetu UI. Dodanie `BlocProvider` i `BlocBuilder`.
4.  **Komponenty UI:** Implementacja widgetów `LoadingSkeletonWidget` i `EmptyStateWidget`.
5.  **Siatka książek:** Implementacja `BookGrid` oraz `BookGridTile` do wyświetlania danych ze stanu `HomeScreenSuccess`.
6.  **Nawigacja:** Podpięcie nawigacji do ekranu szczegółów (po kliknięciu kafelka) i do ekranu dodawania książki (z `FloatingActionButton`).
7.  **Filtrowanie i sortowanie:** Stworzenie `FilterSortButton` oraz modalu do wyboru opcji. Zdefiniowanie `FilterSortOptions` ViewModel. Podłączenie logiki do wysyłania `LoadBooksEvent` z nowymi filtrami.
8.  **Odświeżanie:** Zaimplementowanie logiki "pull-to-refresh" przy użyciu widgetu `RefreshIndicator`.
9.  **Obsługa błędów:** Dodanie logiki w `BlocBuilder` lub `BlocListener` do wyświetlania `SnackBar` w przypadku stanu `HomeScreenError`.
10. **Onboarding:** Integracja z biblioteką do onboardingu (np. `showcaseview`). Logika sprawdzająca, czy użytkownik jest nowy, powinna być wywołana w stanie `HomeScreenSuccess`, aby wskazać na istniejące elementy UI.
11. **Testy:** Napisanie testów jednostkowych dla `HomeScreenBloc` oraz testów widgetów dla kluczowych komponentów UI.

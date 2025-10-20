# Plan implementacji widoku profilu użytkownika

## 1. Przegląd
Widok profilu użytkownika to dedykowany ekran, który ma na celu dostarczenie zalogowanemu użytkownikowi podstawowych informacji o jego koncie i aktywności w aplikacji. Głównym celem jest wyświetlenie adresu e-mail, z którym powiązane jest konto, oraz podsumowania jego biblioteki w postaci łącznej liczby posiadanych książek. Widok ten stanowi podstawę do przyszłej rozbudowy o dodatkowe statystyki i ustawienia konta.

## 2. Routing widoku
- **Ścieżka:** `/profile`
- **Dostęp:** Widok będzie dostępny po nawigacji z ekranu głównego (`/home`). Nawigacja zostanie wywołana przez naciśnięcie nowego widżetu `IconButton` z ikoną `Icons.person` lub podobną, umieszczonego w `AppBar` obok tytułu strony.

## 3. Struktura komponentów
Struktura widoku będzie prosta i oparta na reużywalnych widżetach.

```
- ProfileScreen (Scaffold)
  - AppBar (z tytułem "Profil" i przyciskiem powrotu)
  - Padding
    - Column
      - UserInfoCard (Card)
        - ListTile (ikona, email użytkownika)
      - BookStatsCard (Card)
        - ListTile (ikona, statystyka liczby książek)
      - LogoutButton (ElevatedButton)
```

## 4. Szczegóły komponentów
### ProfileScreen
- **Opis komponentu:** Główny ekran (Scaffold) widoku profilu. Odpowiada za pobranie i przekazanie danych do komponentów podrzędnych oraz obsługę logiki (np. wylogowanie).
- **Główne elementy:** `Scaffold`, `AppBar`, `UserInfoCard`, `BookStatsCard`, `LogoutButton`.
- **Obsługiwane interakcje:**
  - Wylogowanie użytkownika po naciśnięciu przycisku.
- **Typy:** `ProfileViewModel`
- **Propsy:** Brak (jest to widok routowalny).

### UserInfoCard
- **Opis komponentu:** Widżet typu `Card` wyświetlający informacje o koncie użytkownika.
- **Główne elementy:** `Card`, `ListTile`, `Icon`, `Text`.
- **Obsługiwane interakcje:** Brak.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `ProfileViewModel`.
- **Propsy:** `final ProfileViewModel viewModel;`

### BookStatsCard
- **Opis komponentu:** Widżet typu `Card` wyświetlający statystyki dotyczące biblioteki książek.
- **Główne elementy:** `Card`, `ListTile`, `Icon`, `Text`, `CircularProgressIndicator` (w trakcie ładowania).
- **Obsługiwane interakcje:** Brak.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `ProfileViewModel`.
- **Propsy:** `final ProfileViewModel viewModel;`

### LogoutButton
- **Opis komponentu:** Przycisk `ElevatedButton` umożliwiający użytkownikowi wylogowanie się z aplikacji.
- **Główne elementy:** `ElevatedButton`, `Icon`, `Text`.
- **Obsługiwane interakcje:**
  - `onPressed`: wywołuje funkcję wylogowania.
- **Obsługiwana walidacja:** Brak.
- **Typy:** Brak.
- **Propsy:** `final VoidCallback onLogout;`

## 5. Typy
Do implementacji widoku wymagany będzie jeden nowy typ ViewModel.

### ProfileViewModel
- **Opis:** Model widoku przechowujący dane potrzebne do wyświetlenia na ekranie profilu.
- **Pola:**
  - `final String userEmail`: Adres e-mail aktualnie zalogowanego użytkownika.
  - `final int? bookCount`: Łączna liczba książek w bibliotece użytkownika. Może być `null` w trakcie ładowania lub w przypadku błędu.
  - `final bool isLoading`: Flaga informująca, czy dane (szczególnie `bookCount`) są w trakcie pobierania.
  - `final String? errorMessage`: Komunikat o błędzie, jeśli wystąpił problem z pobraniem danych.

## 6. Zarządzanie stanem
Zarządzanie stanem zostanie zrealizowane przy użyciu `StatefulWidget` dla `ProfileScreen`.

- **Zmienne stanu w `ProfileScreenState`:**
  - `ProfileViewModel _viewModel`: Przechowuje aktualny stan widoku.
  - `bool _isLoggingOut`: Flaga informująca o trwającym procesie wylogowywania.

- **Przepływ:**
  1. W `initState()` pobierany jest adres e-mail użytkownika z `Supabase.instance.client.auth.currentUser`.
  2. Inicjowany jest `_viewModel` ze stanem początkowym (`isLoading: true`, `bookCount: null`).
  3. Asynchronicznie wywoływana jest funkcja pobierająca liczbę książek z API.
  4. Po otrzymaniu odpowiedzi (sukces lub błąd), stan `_viewModel` jest aktualizowany za pomocą `setState()`, co powoduje przebudowanie interfejsu.
  5. Wciśnięcie przycisku wylogowania ustawia `_isLoggingOut` na `true`, wywołuje metodę `signOut()` z Supabase, a po jej zakończeniu nawiguje użytkownika do ekranu logowania.

## 7. Integracja API
Integracja będzie opierać się na kliencie Supabase.

- **Pobieranie adresu e-mail:**
  - **Metoda:** Synchronne odwołanie do sesji użytkownika.
  - **Kod:** `Supabase.instance.client.auth.currentUser?.email`
  - **Typ odpowiedzi:** `String?`

- **Pobieranie liczby książek:**
  - **Metoda:** Zapytanie `GET` do tabeli `books` z użyciem funkcji agregującej `count()`.
  - **Endpoint (logiczny):** `/rest/v1/books?select=count`
  - **Implementacja w Dart:**
    ```dart
    final response = await Supabase.instance.client
        .from('books')
        .select('id', const FetchOptions(count: CountOption.exact));
    // Liczba książek będzie w response.count
    ```
  - **Typ odpowiedzi (logiczny):** Obiekt z polem `count` typu `int`.

- **Wylogowanie:**
  - **Metoda:** Wywołanie metody `signOut` na kliencie Supabase Auth.
  - **Implementacja w Dart:** `await Supabase.instance.client.auth.signOut()`
  - **Typ odpowiedzi:** `void`

## 8. Interakcje użytkownika
- **Wejście na ekran profilu:**
  - Użytkownik klika ikonę profilu w `AppBar` na ekranie głównym.
  - Aplikacja nawiguje do `/profile`.
  - Wyświetla się ekran z widocznym `CircularProgressIndicator` w miejscu liczby książek.
  - Po załadowaniu danych wskaźnik postępu jest zastępowany liczbą książek.
- **Wylogowanie:**
  - Użytkownik klika przycisk "Wyloguj się".
  - Przycisk staje się nieaktywny, a na ekranie może pojawić się nakładka z `CircularProgressIndicator`.
  - Po pomyślnym wylogowaniu aplikacja nawiguje do ekranu logowania (`/login`).

## 9. Warunki i walidacja
- **Dostęp do widoku:** Widok profilu powinien być dostępny tylko dla zalogowanych użytkowników. Należy zabezpieczyć trasę, aby niezalogowany użytkownik został przekierowany do ekranu logowania.
- **Wyświetlanie danych:**
  - Adres e-mail jest wyświetlany, jeśli `currentUser` nie jest `null`. W przeciwnym razie (teoretyczny przypadek brzegowy) można wyświetlić komunikat błędu.
  - Liczba książek jest wyświetlana tylko wtedy, gdy `isLoading` jest `false` i `errorMessage` jest `null`.

## 10. Obsługa błędów
- **Błąd pobierania liczby książek:**
  - Jeśli zapytanie do Supabase o liczbę książek zakończy się niepowodzeniem (np. z powodu problemów z siecią lub uprawnieniami RLS), `errorMessage` w `_viewModel` zostanie ustawiony.
  - `BookStatsCard` wyświetli stosowny komunikat błędu zamiast liczby książek, np. "Nie udało się załadować statystyk".
- **Błąd wylogowania:**
  - W rzadkim przypadku, gdy operacja `signOut()` zwróci błąd, `_isLoggingOut` zostanie ustawione z powrotem na `false`, a użytkownikowi zostanie wyświetlony `SnackBar` z komunikatem o błędzie, np. "Wylogowanie nie powiodło się. Spróbuj ponownie.".
- **Brak zalogowanego użytkownika:**
  - Jeśli użytkownik jakimś cudem dotrze do tego widoku bez aktywnej sesji, ekran powinien wyświetlić centralny komunikat "Błąd: Brak aktywnej sesji użytkownika" i przycisk przekierowujący do ekranu logowania.

## 11. Kroki implementacji
1.  **Utworzenie plików:** Stwórz nowy folder `lib/features/profile/` a w nim plik `profile_screen.dart`.
2.  **Nawigacja:** W `AppBar` na ekranie głównym dodaj `IconButton`, który będzie nawigował do nowej trasy `/profile`. Zdefiniuj tę trasę w routerze aplikacji, mapując ją na `ProfileScreen`.
3.  **Struktura `ProfileScreen`:** Zaimplementuj `ProfileScreen` jako `StatefulWidget`. Dodaj `Scaffold` z `AppBar` i pustą `Column` w ciele.
4.  **Implementacja `ViewModel`:** Zdefiniuj klasę `ProfileViewModel` zgodnie z opisem w sekcji 5.
5.  **Zarządzanie stanem:** W `ProfileScreenState` zaimplementuj logikę z sekcji 6: pobieranie danych w `initState` i aktualizowanie stanu `_viewModel` za pomocą `setState`.
6.  **Implementacja widżetów:** Stwórz widżety `UserInfoCard`, `BookStatsCard` i `LogoutButton`. Przekaż do nich odpowiednie dane z `_viewModel` oraz callback `onLogout`.
7.  **Integracja API:** Zaimplementuj wywołania do Supabase w `ProfileScreenState` w celu pobrania liczby książek oraz obsługi wylogowania.
8.  **Obsługa stanu ładowania i błędów:** Upewnij się, że interfejs poprawnie reaguje na zmiany w `_viewModel.isLoading` i `_viewModel.errorMessage`, wyświetlając wskaźniki postępu lub komunikaty o błędach.
9.  **Stylowanie:** Dopracuj wygląd widżetów, dodając odpowiednie ikony, marginesy i style tekstu, aby zapewnić spójność z resztą aplikacji.
10. **Testowanie:** Przetestuj ręcznie wszystkie ścieżki: pomyślne załadowanie danych, błąd ładowania, proces wylogowania i błąd wylogowania.

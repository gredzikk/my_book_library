# Plan implementacji widoku uwierzytelniania

## 1. Przegląd
Celem jest wdrożenie ekranów logowania i rejestracji użytkownika w aplikacji. Widok ten umożliwi nowym użytkownikom założenie konta, a powracającym dostęp do ich biblioteki książek. Implementacja będzie oparta o standardowe, predefiniowane komponenty UI dostarczane przez bibliotekę `supabase_flutter_ui`, co zapewni szybkie i bezpieczne wdrożenie podstawowej funkcjonalności uwierzytelniania za pomocą adresu e-mail i hasła.

## 2. Routing widoku
Widok uwierzytelniania nie będzie posiadał stałej, nazwanej ścieżki. Zamiast tego, będzie on wyświetlany warunkowo jako ekran startowy aplikacji, gdy użytkownik nie jest zalogowany. Logika routingu będzie zarządzana przez komponent `AuthGate`, który nasłuchuje na zmiany stanu uwierzytelnienia i decyduje, czy pokazać `AuthScreen`, czy przekierować do głównej części aplikacji.

## 3. Struktura komponentów
Hierarchia komponentów będzie prosta, ponieważ opieramy się na gotowym rozwiązaniu.

```
main.dart
└── MaterialApp
    └── AuthGate (Widget nasłuchujący na stan autoryzacji)
        ├── AuthScreen (jeśli użytkownik niezalogowany)
        │   └── SupaEmailAuth (Predefiniowany widget UI z supabase_flutter_ui)
        └── AppNavigator (jeśli użytkownik zalogowany)
            ├── OnboardingScreen
            └── HomeScreen
```

## 4. Szczegóły komponentów
### `AuthGate`
- **Opis komponentu**: Jest to `StatefulWidget`, który działa jako brama autoryzacyjna. Subskrybuje strumień `onAuthStateChange` z klienta Supabase. Na podstawie otrzymywanych zdarzeń decyduje, który widok wyświetlić.
- **Główne elementy**: `StreamBuilder` lub `BlocListener` nasłuchujący na zmiany stanu. Logika warunkowa (np. `if/else` lub `switch`) renderująca odpowiedni ekran.
- **Obsługiwane interakcje**: Automatycznie reaguje na zmiany stanu sesji (logowanie, wylogowanie, odświeżenie tokenu).
- **Obsługiwana walidacja**: Brak.
- **Typy**: `AuthState` z `supabase_flutter`.
- **Propsy**: Brak.

### `AuthScreen`
- **Opis komponentu**: Prosty `StatelessWidget` będący kontenerem dla predefiniowanego formularza z biblioteki Supabase. Jego celem jest dostarczenie podstawowej struktury ekranu (np. `Scaffold`) i osadzenie w nim komponentu `SupaEmailAuth`.
- **Główne elementy**: `Scaffold`, `SupaEmailAuth`.
- **Obsługiwane interakcje**: Przekazuje zdarzenia `onSignIn`, `onSignUp` i `onError` z `SupaEmailAuth` do logiki biznesowej (np. `AuthCubit`).
- **Obsługiwana walidacja**: Delegowana do `SupaEmailAuth`.
- **Typy**: Brak.
- **Propsy**: Brak.

### `SupaEmailAuth` (komponent zewnętrzny)
- **Opis komponentu**: Predefiniowany komponent z pakietu `supabase_flutter_ui`. Renderuje kompletny interfejs do logowania i rejestracji za pomocą e-maila i hasła, w tym pola tekstowe, przyciski i obsługę błędów.
- **Główne elementy**: `TextFormField` dla e-maila i hasła, `ElevatedButton` do wysyłania formularza, `TextButton` do przełączania między logowaniem a rejestracją.
- **Obsługiwane interakcje**: Wprowadzanie tekstu, kliknięcie przycisków "Zaloguj się", "Zarejestruj się", przełączanie widoków.
- **Obsługiwana walidacja**: Wbudowana walidacja formatu adresu e-mail oraz minimalnej długości hasła (zgodnie z ustawieniami projektu Supabase, domyślnie 6 znaków).
- **Typy**: Wewnętrzne typy biblioteki.
- **Propsy**:
  - `onSignIn`: Callback wywoływany po pomyślnym zalogowaniu.
  - `onSignUp`: Callback wywoływany po pomyślnej rejestracji.
  - `onError`: Callback wywoływany w przypadku błędu.
  - `theme`: Opcjonalny `SupaEmailAuthTheme` do kastomizacji wyglądu.

## 5. Typy
Nie ma potrzeby definiowania nowych, niestandardowych typów DTO ani ViewModeli dla tego widoku. Będziemy korzystać z istniejących klas dostarczanych przez `supabase_flutter`:
- **`User`**: Reprezentuje uwierzytelnionego użytkownika. Zawiera m.in. `id`, `email`.
- **`Session`**: Reprezentuje sesję użytkownika. Zawiera `accessToken` (JWT) i `refreshToken`.
- **`AuthState`**: Reprezentuje zdarzenia w cyklu życia sesji (np. `signedIn`, `signedOut`).

## 6. Zarządzanie stanem
Zarządzanie stanem uwierzytelnienia zostanie zrealizowane przy użyciu `AuthCubit`.

- **Stan (`AuthState`)**:
  - `AuthInitial`: Stan początkowy.
  - `AuthLoading`: W trakcie operacji logowania/rejestracji.
  - `AuthSuccess(User user, bool isNewUser)`: Pomyślne uwierzytelnienie. `isNewUser` pozwala na rozróżnienie logowania od rejestracji w celu przekierowania.
  - `AuthFailure(String message)`: Błąd uwierzytelnienia.
  - `AuthSignedOut`: Użytkownik wylogowany.

- **Logika**:
  - `AuthCubit` będzie subskrybował strumień `supabase.auth.onAuthStateChange`.
  - Po otrzymaniu zdarzenia `signedIn`, Cubit wyemituje stan `AuthSuccess`. Należy zaimplementować logikę sprawdzającą, czy jest to nowa rejestracja (np. porównując `createdAt` i `lastSignInAt` obiektu `User`).
  - Po otrzymaniu zdarzenia `signedOut`, Cubit wyemituje stan `AuthSignedOut`.
  - Metody `signIn` i `signUp` w Cubicie będą opakowywać wywołania API, emitując stany `AuthLoading` i `AuthFailure`.

## 7. Integracja API
Integracja z Supabase Auth odbywa się za pośrednictwem biblioteki `supabase_flutter`.

- **Inicjalizacja**: Klient Supabase musi zostać zainicjalizowany w `main.dart` przy użyciu `Supabase.initialize()`.
- **Rejestracja**: Wywołanie `Supabase.instance.client.auth.signUp(email: email, password: password)`.
  - **Typ żądania**: `{ "email": "string", "password": "string" }`
  - **Typ odpowiedzi (sukces)**: `AuthResponse` (zawiera `Session` i `User`)
- **Logowanie**: Wywołanie `Supabase.instance.client.auth.signInWithPassword(email: email, password: password)`.
  - **Typ żądania**: `{ "email": "string", "password": "string" }`
  - **Typ odpowiedzi (sukces)**: `AuthResponse` (zawiera `Session` i `User`)
- **Wylogowanie**: Wywołanie `Supabase.instance.client.auth.signOut()`.

## 8. Interakcje użytkownika
- **Nowy użytkownik**: Wpisuje e-mail i hasło w formularzu rejestracji, klika "Zarejestruj się". Po pomyślnej operacji jest przekierowywany do ekranu onboardingu.
- **Powracający użytkownik**: Wpisuje e-mail i hasło w formularzu logowania, klika "Zaloguj się". Po pomyślnej operacji jest przekierowywany do ekranu głównego.
- **Błędne dane**: Użytkownik wprowadza niepoprawne dane. Pod formularzem wyświetlany jest komunikat o błędzie (np. "Invalid login credentials").
- **Przełączanie formularzy**: Użytkownik klika link "Masz już konto? Zaloguj się" (lub analogiczny), co powoduje zmianę widoku między formularzem rejestracji a logowania.

## 9. Warunki i walidacja
- **Format adresu e-mail**: Walidowany po stronie klienta przez `SupaEmailAuth` przy użyciu wyrażenia regularnego.
- **Długość hasła**: Walidowana po stronie klienta przez `SupaEmailAuth`. Musi mieć co najmniej 6 znaków (zgodnie z domyślnym ustawieniem Supabase).
- **Unikalność adresu e-mail**: Weryfikowana po stronie serwera przez Supabase podczas próby rejestracji. Jeśli e-mail jest zajęty, API zwraca błąd.

Wszystkie warunki są weryfikowane w komponencie `SupaEmailAuth`. W przypadku niespełnienia warunków walidacji po stronie klienta, przycisk wysłania formularza jest nieaktywny lub wyświetlany jest komunikat błędu pod polem.

## 10. Obsługa błędów
- **Błędy walidacji (np. niepoprawny e-mail, za krótkie hasło)**: Obsługiwane i wyświetlane bezpośrednio przez komponent `SupaEmailAuth`.
- **Błędy API (np. "Invalid login credentials", "User already registered")**: Supabase API zwraca błąd, który jest przechwytywany przez `SupaEmailAuth` i wyświetlany użytkownikowi w czytelnej formie.
- **Brak połączenia sieciowego**: Wywołanie API w `AuthCubit` powinno być opakowane w blok `try-catch`, aby przechwycić wyjątki związane z siecią (np. `SocketException`). W takim przypadku Cubit powinien wyemitować stan `AuthFailure` z komunikatem "Brak połączenia z internetem".
- **Błędy serwera (5xx)**: Podobnie jak błędy sieciowe, powinny być przechwytywane i obsługiwane przez emisję stanu `AuthFailure` z ogólnym komunikatem, np. "Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.".

## 11. Kroki implementacji
1.  **Dodanie zależności**: Upewnij się, że w pliku `pubspec.yaml` znajdują się pakiety `supabase_flutter` i `supabase_flutter_ui`.
2.  **Inicjalizacja Supabase**: W pliku `main.dart` zainicjalizuj klienta Supabase, podając `URL` i `Anon Key` z panelu projektu.
3.  **Stworzenie `AuthCubit`**: Zaimplementuj `AuthCubit` z opisanymi stanami (`AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailure`, `AuthSignedOut`) i logiką nasłuchiwania na `onAuthStateChange`.
4.  **Stworzenie `AuthGate`**: Zaimplementuj `AuthGate` jako `StatelessWidget`, który używa `BlocBuilder` lub `BlocListener` do reagowania na stany z `AuthCubit` i renderowania `AuthScreen` lub `AppNavigator`.
5.  **Stworzenie `AuthScreen`**: Zaimplementuj `AuthScreen`, który w `Scaffold` umieszcza widżet `SupaEmailAuth`. Skonfiguruj callbacki `onSignIn`, `onSignUp` i `onError`, aby komunikowały się z `AuthCubit`.
6.  **Konfiguracja przekierowań**: W `AuthGate`, po otrzymaniu stanu `AuthSuccess`, zaimplementuj logikę przekierowania: jeśli `isNewUser` jest `true`, nawiguj do `/onboarding`, w przeciwnym razie do `/home`.
7.  **Kastomizacja motywu (opcjonalnie)**: Jeśli domyślny wygląd `SupaEmailAuth` nie jest zadowalający, stwórz `SupaEmailAuthTheme` i przekaż go do widżetu, aby dostosować kolory, czcionki i style.
8.  **Testowanie**: Przetestuj wszystkie scenariusze:
    - Pomyślna rejestracja i przekierowanie.
    - Pomyślne logowanie i przekierowanie.
    - Próba rejestracji z zajętym adresem e-mail.
    - Próba logowania z błędnymi danymi.
    - Walidacja pól formularza.
    - Działanie aplikacji przy braku połączenia z internetem.
    - Proces wylogowania.

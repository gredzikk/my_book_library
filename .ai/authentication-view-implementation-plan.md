# Plan implementacji widoku Uwierzytelniania

> **Status**: ✅ **ZAIMPLEMENTOWANE** (14.10.2025)
> 
> Implementacja została zakończona zgodnie z planem. Szczegóły w dokumentacji: [`lib/screens/README_AUTHENTICATION.md`](../lib/screens/README_AUTHENTICATION.md)

## 1. Przegląd
Celem tego widoku jest obsługa procesu uwierzytelniania użytkowników, obejmującego zarówno rejestrację nowych kont, jak i logowanie istniejących użytkowników. Implementacja została oparta o pakiet `supabase_auth_ui` (wersja 0.5.5), który dostarcza gotowe komponenty do integracji z Supabase Auth, zgodnie z założeniami technicznymi projektu. Widok zapewnia walidację danych wejściowych i obsługę błędów, kierując użytkownika do odpowiedniej części aplikacji po pomyślnym uwierzytelnieniu.

## 2. Routing widoku
Widok uwierzytelniania nie będzie posiadał stałej, bezpośredniej ścieżki (route). Dostęp do niego będzie kontrolowany przez komponent `AuthGate`, który będzie renderowany jako główny widżet aplikacji. `AuthGate` będzie nasłuchiwał na zmiany stanu uwierzytelnienia w Supabase:
- Jeśli użytkownik **nie jest** zalogowany, zostanie wyświetlony widok `AuthenticationScreen`.
- Jeśli użytkownik **jest** zalogowany, zostanie przekierowany do głównego ekranu aplikacji (`HomeScreen`).

## 3. Struktura komponentów
Hierarchia komponentów będzie prosta i skupiona na wykorzystaniu gotowych rozwiązań.

```
MainApp
└── AuthGate (StatefulWidget)
    ├── (jeśli brak autoryzacji) -> AuthenticationScreen (StatelessWidget)
    │   └── SupaEmailAuth (z pakietu flutter_auth_ui)
    │       ├── (wewnętrzne) Pole email
    │       ├── (wewnętrzne) Pole hasła
    │       └── (wewnętrzne) Przyciski "Zaloguj" / "Zarejestruj"
    └── (jeśli jest autoryzacja) -> HomeScreen (lub OnboardingScreen)
```

## 4. Szczegóły komponentów
### `AuthGate`
- **Opis komponentu**: Jest to "strażnik" autoryzacji i główny punkt wejścia do aplikacji. Używa `StreamBuilder` do nasłuchiwania na strumień `Supabase.instance.client.auth.onAuthStateChange`. W zależności od otrzymanego stanu (zalogowany, wylogowany, etc.) decyduje, który widok wyświetlić.
- **Główne elementy**: `StreamBuilder`, `Scaffold` z `CircularProgressIndicator` na czas inicjalizacji.
- **Obsługiwane interakcje**: Brak bezpośrednich interakcji z użytkownikiem. Komponent reaguje wyłącznie na zmiany stanu autoryzacji.
- **Obsługiwana walidacja**: Brak.
- **Typy**: `Stream<AuthState>` (z `supabase_flutter`).
- **Propsy**: Brak.

### `AuthenticationScreen`
- **Opis komponentu**: Ekran zawierający formularze logowania i rejestracji. Jego głównym zadaniem jest wyrenderowanie i skonfigurowanie gotowego widżetu `SupaEmailAuth` z pakietu `flutter_auth_ui`.
- **Główne elementy**: `Scaffold`, `SupaEmailAuth`.
- **Obsługiwane interakcje**: Interakcje są w pełni obsługiwane przez wewnętrzną logikę `SupaEmailAuth`: wpisywanie tekstu, przełączanie między logowaniem a rejestracją, klikanie przycisków.
- **Obsługiwana walidacja**: Walidacja jest delegowana do `SupaEmailAuth`.
- **Typy**: Brak.
- **Propsy**: Brak.

## 5. Typy
Implementacja nie wymaga tworzenia nowych, niestandardowych typów ani ViewModeli. Będziemy korzystać z typów dostarczonych przez pakiety `supabase_flutter` i `gotrue`:
- **`User`**: Reprezentuje dane zalogowanego użytkownika.
- **`Session`**: Zawiera tokeny (JWT) i informacje o sesji.
- **`AuthException`**: Obiekt błędu zwracany przez Supabase w przypadku nieudanego uwierzytelnienia.

## 6. Zarządzanie stanem
Stan uwierzytelnienia użytkownika jest zarządzany globalnie i reaktywnie przez klienta Supabase. Komponent `AuthGate` subskrybuje strumień `onAuthStateChange`, który emituje nowe wartości za każdym razem, gdy użytkownik się zaloguje, wyloguje lub jego sesja wygaśnie.

Nie ma potrzeby stosowania dodatkowych narzędzi do zarządzania stanem (jak Provider, BLoC czy Riverpod) ani customowych hooków dla tej konkretnej funkcjonalności, ponieważ `StreamBuilder` w połączeniu z klientem Supabase w pełni realizuje wymagania.

## 7. Integracja API
Integracja z API Supabase Auth jest w całości hermetyzowana przez widżet `SupaEmailAuth`.
- **Rejestracja**: Widżet wewnętrznie wywołuje metodę `Supabase.instance.client.auth.signUp()`, wysyłając `email` i `password` użytkownika.
  - **Typ żądania**: `AuthCredentials` (email, password).
  - **Typ odpowiedzi (sukces)**: `AuthResponse` (zawierający `Session` i `User`).
- **Logowanie**: Widżet wewnętrznie wywołuje metodę `Supabase.instance.client.auth.signInWithPassword()`.
  - **Typ żądania**: `AuthCredentials` (email, password).
  - **Typ odpowiedzi (sukces)**: `AuthResponse` (zawierający `Session` i `User`).

Po pomyślnym zalogowaniu/rejestracji, klient Supabase automatycznie i bezpiecznie przechowuje sesję (w tym JWT). Wszystkie przyszłe zapytania do API bazy danych wykonywane za pomocą tego samego klienta (`Supabase.instance.client`) będą automatycznie zawierały poprawny nagłówek `Authorization`.

## 8. Interakcje użytkownika
- **Uruchomienie aplikacji**: Użytkownik widzi ekran logowania/rejestracji (`AuthenticationScreen`).
- **Wprowadzenie danych**: Użytkownik wpisuje swój email i hasło.
- **Próba logowania**:
  - **Sukces**: Użytkownik zostaje przekierowany na ekran główny (`HomeScreen`).
  - **Błąd**: Pod polem formularza pojawia się komunikat o błędzie (np. "Nieprawidłowe dane logowania").
- **Próba rejestracji**:
  - **Sukces**: Użytkownik zostaje zalogowany i przekierowany na ekran główny, skąd aplikacja powinna uruchomić przepływ onboardingu (zgodnie z `US-001`).
  - **Błąd**: Pod polem formularza pojawia się komunikat o błędzie (np. "Użytkownik o tym adresie email już istnieje", "Hasło jest zbyt słabe").

## 9. Warunki i walidacja
Walidacja odbywa się w czasie rzeczywistym i jest wbudowana w komponent `SupaEmailAuth`.
- **Email**: Musi mieć poprawny format adresu email. Komunikat błędu jest wyświetlany, jeśli format jest nieprawidłowy.
- **Hasło**:
  - Nie może być puste.
  - Musi spełniać wymagania siły hasła skonfigurowane w panelu Supabase (np. minimalna długość 6 znaków). Komunikat o błędzie informuje o niespełnieniu tych wymagań.
- **Stan interfejsu**: Przyciski "Zaloguj" / "Zarejestruj" są aktywne tylko wtedy, gdy pola nie są puste. Podczas komunikacji z API wyświetlany jest wskaźnik ładowania.

## 10. Obsługa błędów
Scenariusze błędów są obsługiwane przez widżet `SupaEmailAuth`, który wyświetla komunikaty zwrotne od API Supabase.
- **Nieprawidłowe dane logowania**: Wyświetlany jest komunikat "Invalid login credentials".
- **Email już istnieje (rejestracja)**: Wyświetlany jest komunikat "User already registered".
- **Brak połączenia z internetem**: Widżet powinien wyświetlić komunikat o błędzie sieciowym. Należy to zweryfikować podczas implementacji i w razie potrzeby użyć callbacku `onError`, aby wyświetlić globalny `SnackBar`.
- **Inne błędy serwera (5xx)**: Wyświetlany jest generyczny komunikat o nieoczekiwanym błędzie.

## 11. Kroki implementacji
1. **Dodanie zależności**: Dodaj pakiet `flutter_auth_ui` do pliku `pubspec.yaml` i uruchom `flutter pub get`.
2. **Inicjalizacja Supabase**: Upewnij się, że `Supabase.initialize()` jest poprawnie skonfigurowane w pliku `lib/main.dart`.
3. **Stworzenie `AuthGate`**:
   - Utwórz nowy plik `lib/widgets/auth_gate.dart`.
   - Zaimplementuj `StatefulWidget` o nazwie `AuthGate`.
   - W metodzie `build` użyj `StreamBuilder`, aby nasłuchiwać na `Supabase.instance.client.auth.onAuthStateChange`.
   - W zależności od `snapshot.hasData`, zwracaj `HomeScreen` lub `AuthenticationScreen`.
   - W `main.dart` ustaw `AuthGate` jako `home` w `MaterialApp`.
4. **Stworzenie `AuthenticationScreen`**:
   - Utwórz nowy plik dla ekranu, np. `lib/screens/authentication_screen.dart`.
   - Zaimplementuj `StatelessWidget`, który w `Scaffold` będzie zawierał widżet `SupaEmailAuth`.
   - Skonfiguruj `SupaEmailAuth` - przekaż ewentualne metadane lub callbacki, jeśli będą potrzebne (np. `onSignIn`, `onSignUp`).
5. **Dostosowanie wyglądu**: Zbadaj możliwości personalizacji `SupaEmailAuth`, aby dopasować jego wygląd (kolory, style pól tekstowych, przycisków) do motywu aplikacji, wykorzystując `ThemeData`.
6. **Obsługa przekierowania po rejestracji**: Zaimplementuj logikę w `HomeScreen` (lub w komponencie, do którego trafia użytkownik po zalogowaniu), która sprawdzi (np. w `SharedPreferences`), czy użytkownik odbył już onboarding. Jeśli nie, przekieruj go na ekran onboardingu.
7. **Testowanie**: Przetestuj manualnie wszystkie scenariusze:
   - Poprawna rejestracja i przekierowanie.
   - Błąd rejestracji (istniejący email, słabe hasło).
   - Poprawne logowanie i przekierowanie.
   - Błąd logowania (złe dane).
   - Działanie aplikacji w trybie offline.


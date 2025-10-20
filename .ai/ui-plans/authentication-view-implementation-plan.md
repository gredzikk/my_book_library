# Plan implementacji modułu Uwierzytelniania

> **Status**: 🟡 **DO ZIMPLEMENTOWANIA**
> 
> **Decyzja**: Rezygnacja z pakietu `supabase_auth_ui` na rzecz własnej implementacji w celu uzyskania pełnej kontroli nad UI/UX i zapewnienia zgodności z `auth-spec.md`.

## 1. Przegląd
Celem jest implementacja kompletnego modułu uwierzytelniania użytkowników, obejmującego rejestrację, logowanie, wylogowywanie oraz proces odzyskiwania hasła. Implementacja zostanie stworzona od podstaw, bez użycia zewnętrznych pakietów UI (takich jak `supabase_auth_ui`), aby zapewnić pełną zgodność z wymaganiami `prd.md` oraz specyfikacją techniczną `auth-spec.md`. Architektura będzie oparta na dedykowanych ekranach (widgetach) oraz centralnym serwisie `AuthService`, który będzie hermetyzował logikę komunikacji z Supabase.

## 2. Routing i nawigacja
Dostęp do chronionych części aplikacji będzie kontrolowany przez komponent `AuthGate`.
- `AuthGate` będzie nasłuchiwał na zmiany stanu uwierzytelnienia w Supabase.
- Jeśli użytkownik **nie jest** zalogowany, `AuthGate` wyświetli `LoginScreen`.
- Jeśli użytkownik **jest** zalogowany, zostanie przekierowany do `HomeScreen`.

Nawigacja pomiędzy ekranami autentykacji (`LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`) będzie realizowana za pomocą `Navigator.push()` i `Navigator.pop()`.

## 3. Struktura komponentów i plików
```
lib/
├── features/
│   └── auth/
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   └── forgot_password_screen.dart
│       ├── services/
│       │   └── auth_service.dart
│       └── widgets/
│           └── (opcjonalnie, np. custom_text_field.dart)
└── widgets/
    └── auth_gate.dart
```

Hierarchia widgetów:
```
MainApp
└── AuthGate (StatefulWidget)
    ├── (jeśli brak autoryzacji) -> LoginScreen (StatefulWidget)
    │   ├── Form
    │   │   ├── TextFormField (email)
    │   │   └── TextFormField (hasło)
    │   ├── ElevatedButton (Zaloguj)
    │   ├── TextButton (do RegisterScreen)
    │   └── TextButton (do ForgotPasswordScreen)
    └── (jeśli jest autoryzacja) -> HomeScreen
```

## 4. Szczegóły komponentów
### `AuthGate`
- **Opis**: "Strażnik" autoryzacji, punkt wejścia do aplikacji. Używa `StreamBuilder` do nasłuchiwania na `Supabase.instance.client.auth.onAuthStateChange`.
- **Logika**: Decyduje, czy wyświetlić `LoginScreen` czy `HomeScreen`.

### `AuthService` (`lib/features/auth/services/auth_service.dart`)
- **Opis**: Klasa hermetyzująca całą logikę komunikacji z Supabase Auth. Będzie implementować interfejs `IAuthService` dla zachowania czystości kodu i ułatwienia testowania.
- **Metody**:
    - `Stream<AuthState> get authStateChanges`
    - `User? get currentUser`
    - `Future<void> signUp({email, password})`
    - `Future<void> signInWithPassword({email, password})`
    - `Future<void> signOut()`
    - `Future<void> sendPasswordResetEmail({email})`
- **Obsługa błędów**: Metody będą opakowane w bloki `try-catch` do obsługi `AuthException` z Supabase.

### `LoginScreen` (`lib/features/auth/screens/login_screen.dart`)
- **Opis**: Ekran z formularzem logowania.
- **Elementy**: `Form` z `GlobalKey`, `TextFormField` dla emaila i hasła, `ElevatedButton` do wysłania formularza, `TextButton` do nawigacji.
- **Zarządzanie stanem**: Lokalny stan (za pomocą `StatefulWidget`) do zarządzania `TextEditingController`, stanem ładowania (`_isLoading`) i obsługą błędów formularza.
- **Logika**: Po walidacji i wciśnięciu przycisku wywołuje `authService.signInWithPassword()`.

### `RegisterScreen` (`lib/features/auth/screens/register_screen.dart`)
- **Opis**: Ekran z formularzem rejestracji.
- **Elementy**: `Form`, `TextFormField` dla emaila, hasła i potwierdzenia hasła, `ElevatedButton` do rejestracji.
- **Logika**: Waliduje zgodność haseł i siłę hasła po stronie klienta. Wywołuje `authService.signUp()`. Po sukcesie wyświetla `SnackBar` z informacją o konieczności potwierdzenia emaila i nawiguje z powrotem do `LoginScreen`.

### `ForgotPasswordScreen` (`lib/features/auth/screens/forgot_password_screen.dart`)
- **Opis**: Ekran do inicjowania procesu resetowania hasła.
- **Elementy**: `Form` z `TextFormField` dla emaila, `ElevatedButton` do wysłania linku.
- **Logika**: Wywołuje `authService.sendPasswordResetEmail()`. Po sukcesie wyświetla komunikat i nawiguje z powrotem do `LoginScreen`.

## 5. Typy
- Będziemy korzystać z typów dostarczonych przez `supabase_flutter`: `User`, `Session`, `AuthState`, `AuthException`.
- Możliwe jest stworzenie własnej klasy wyjątków, np. `DisplayableAuthException`, aby ułatwić wyświetlanie błędów w UI.

## 6. Zarządzanie stanem
- **Stan globalny (autentykacja)**: Zarządzany przez Supabase i nasłuchiwany w `AuthGate`.
- **Stan lokalny (formularze)**: Każdy ekran będzie `StatefulWidget` i będzie zarządzał swoim stanem (kontrolery, flagi ładowania, komunikaty o błędach) niezależnie.

## 7. Integracja API
Cała integracja z Supabase Auth zostanie zamknięta w `AuthService`. Widoki nie będą bezpośrednio komunikować się z Supabase, lecz za pośrednictwem serwisu. Zapewni to separację warstw i ułatwi ewentualne zmiany w przyszłości.

## 8. Interakcje użytkownika
- **Uruchomienie aplikacji**: Użytkownik widzi `LoginScreen`.
- **Nawigacja**: Może przejść do `RegisterScreen` lub `ForgotPasswordScreen`.
- **Logowanie/Rejestracja**:
  - **Sukces (logowanie)**: `AuthGate` wykrywa zmianę stanu i przełącza widok na `HomeScreen`.
  - **Sukces (rejestracja)**: Użytkownik widzi komunikat o wysłanym emailu i wraca do `LoginScreen`.
  - **Błąd**: Na ekranie pojawia się `SnackBar` z czytelnym komunikatem błędu.

## 9. Warunki i walidacja
- Walidacja będzie realizowana za pomocą właściwości `validator` w `TextFormField`.
- Sprawdzane będą:
  - Poprawność formatu email.
  - Minimalna długość hasła (zgodnie z `auth-spec.md`).
  - Zgodność haseł w `RegisterScreen`.
- Przyciski akcji będą nieaktywne lub będą pokazywać wskaźnik ładowania podczas operacji asynchronicznych.

## 10. Obsługa błędów
- `AuthService` będzie łapał `AuthException` i może rzucać dalej własne, bardziej specyficzne wyjątki.
- Ekrany (UI) będą łapać te wyjątki i wyświetlać użytkownikowi przyjazne komunikaty za pomocą `ScaffoldMessenger.of(context).showSnackBar()`.

## 11. Kroki implementacji
1.  **Usunięcie zależności**: Upewnij się, że pakiet `supabase_auth_ui` został usunięty z `pubspec.yaml`.
2.  **Stworzenie struktury plików**: Utwórz katalogi i puste pliki zgodnie z punktem 3.
3.  **Implementacja `AuthGate`**: Zaktualizuj istniejący `AuthGate`, aby w przypadku braku sesji wskazywał na `LoginScreen`.
4.  **Implementacja `AuthService`**:
    - Stwórz plik `lib/features/auth/services/auth_service.dart`.
    - Zdefiniuj interfejs `IAuthService`.
    - Stwórz klasę `AuthService` implementującą interfejs i metody komunikujące się z `Supabase.instance.client.auth`.
5.  **Implementacja `LoginScreen`**:
    - Stwórz `StatefulWidget` z formularzem.
    - Dodaj logikę walidacji i obsługę przycisku logowania.
    - Zintegruj z `AuthService`.
    - Dodaj nawigację do pozostałych ekranów.
6.  **Implementacja `RegisterScreen`**:
    - Stwórz `StatefulWidget` z formularzem rejestracji.
    - Dodaj walidację (w tym zgodność haseł).
    - Zintegruj z `AuthService`.
7.  **Implementacja `ForgotPasswordScreen`**:
    - Stwórz `StatefulWidget` z formularzem.
    - Zintegruj z `AuthService`.
8.  **Testowanie manualne**:
    - Scenariusz pomyślnej rejestracji (z weryfikacją email).
    - Scenariusz pomyślnego logowania.
    - Scenariusz resetowania hasła.
    - Obsługa błędów (nieprawidłowe dane, istniejący użytkownik, błędy sieci).
    - Działanie wylogowania.


# Specyfikacja Techniczna Modułu Autentykacji - My Book Library

## 1. Wprowadzenie

Niniejszy dokument opisuje architekturę i implementację modułu uwierzytelniania użytkowników w aplikacji "My Book Library". Specyfikacja bazuje na wymaganiach zawartych w `prd.md` (historyjki US-001, US-002, US-017, US-018) oraz na stosie technologicznym zdefiniowanym w `tech-stack.md`.

Celem jest zaprojektowanie bezpiecznego, skalowalnego i zgodnego z dobrymi praktykami systemu rejestracji, logowania, wylogowywania oraz odzyskiwania hasła przy użyciu **Flutter** na frontendzie i **Supabase** jako Backend-as-a-Service (BaaS).

## 2. Architektura Interfejsu Użytkownika (Frontend - Flutter)

### 2.1. Zarządzanie Stanem Autentykacji

Centralnym punktem architektury frontendu będzie globalny serwis/provider do zarządzania stanem autentykacji (`AuthService` lub `AuthProvider`). Będzie on nasłuchiwał na zmiany stanu zalogowania użytkownika w czasie rzeczywistym, korzystając z `Supabase.instance.client.auth.onAuthStateChange`.

**Główne zadania `AuthService`:**
- Udostępnianie strumienia (`Stream`) z aktualnym stanem użytkownika (`AuthState`).
- Przechowywanie obiektu zalogowanego użytkownika (`User`).
- Dostarczanie metod do logowania, rejestracji, wylogowywania i odzyskiwania hasła.

Na najwyższym poziomie drzewa widgetów (np. w `main.dart`) znajdzie się `StreamBuilder` lub `Consumer` (w zależności od użytego rozwiązania do zarządzania stanem, np. Provider, Riverpod), który będzie decydował, który ekran wyświetlić:
- **Stan `non-auth` (użytkownik niezalogowany):** Wyświetlanie `AuthGate` lub `LoginScreen`.
- **Stan `auth` (użytkownik zalogowany):** Wyświetlanie `HomeScreen` (główny ekran aplikacji).

### 2.2. Nowe Ekrany (Screens)

Należy utworzyć następujące ekrany w katalogu `lib/features/auth/screens/`:

- **`LoginScreen.dart`**:
    - **Komponenty:**
        - `TextFormField` dla adresu e-mail.
        - `TextFormField` dla hasła (z opcją ukrycia/pokazania).
        - `ElevatedButton` do wywołania logowania.
        - `TextButton` z nawigacją do `RegisterScreen` ("Nie masz konta? Zarejestruj się").
        - `TextButton` z nawigacją do `ForgotPasswordScreen` ("Zapomniałeś hasła?").
    - **Logika:**
        - Walidacja formularza (pola nie mogą być puste, e-mail musi mieć poprawny format).
        - Wywołanie metody `authService.signInWithPassword(email, password)`.
        - Obsługa stanu ładowania (np. `CircularProgressIndicator`).
        - Wyświetlanie komunikatów o błędach (np. "Nieprawidłowy e-mail lub hasło") za pomocą `SnackBar` lub podobnego mechanizmu.

- **`RegisterScreen.dart`**:
    - **Komponenty:**
        - `TextFormField` dla adresu e-mail.
        - `TextFormField` dla hasła.
        - `TextFormField` do potwierdzenia hasła.
        - `ElevatedButton` do wywołania rejestracji.
        - `TextButton` z nawigacją do `LoginScreen` ("Masz już konto? Zaloguj się").
    - **Logika:**
        - Walidacja formularza (pola wymagane, poprawność e-maila, hasła muszą być identyczne).
        - Implementacja wymagań co do siły hasła (np. min. 8 znaków).
        - Wywołanie metody `authService.signUp(email, password)`.
        - Po pomyślnej rejestracji, Supabase domyślnie wysyła e-mail weryfikacyjny. Należy poinformować użytkownika o konieczności potwierdzenia adresu e-mail. Aplikacja powinna przenieść go na ekran pośredni lub z powrotem do ekranu logowania z odpowiednim komunikatem.

- **`ForgotPasswordScreen.dart`**:
    - **Komponenty:**
        - `TextFormField` dla adresu e-mail.
        - `ElevatedButton` do wysłania linku resetującego.
    - **Logika:**
        - Walidacja pola e-mail.
        - Wywołanie metody `authService.sendPasswordResetEmail(email)`.
        - Wyświetlenie komunikatu o pomyślnym wysłaniu instrukcji na podany adres e-mail.

- **`UpdatePasswordScreen.dart`**:
    - Ekran, na który użytkownik jest przekierowywany po kliknięciu w link resetujący hasło. Supabase obsługuje to poprzez *deep linking*.
    - **Komponenty:**
        - `TextFormField` na nowe hasło.
        - `TextFormField` do potwierdzenia nowego hasła.
        - `ElevatedButton` do zatwierdzenia zmiany.
    - **Logika:**
        - Walidacja formularza.
        - Wywołanie metody `authService.updateUserPassword(newPassword)`.
        - Po pomyślnej zmianie, przekierowanie do `LoginScreen`.

### 2.3. Rozszerzenie Istniejących Komponentów

- **`ProfileScreen` (lub podobny ekran ustawień użytkownika):**
    - Należy dodać przycisk "Wyloguj się" (`ElevatedButton` lub `ListTile`).
    - Jego naciśnięcie wywoła metodę `authService.signOut()`.

### 2.4. Walidacja i Komunikaty Błędów

- **Walidacja po stronie klienta:** Użycie `validator` w `TextFormField` do sprawdzania formatu e-mail, długości hasła i zgodności haseł.
- **Komunikaty:**
    - "Pole nie może być puste."
    - "Wprowadź poprawny adres e-mail."
    - "Hasło musi mieć co najmniej 8 znaków."
    - "Hasła nie są zgodne."
    - "Nieprawidłowe dane logowania." (Błąd z Supabase)
    - "Użytkownik o tym adresie e-mail już istnieje." (Błąd z Supabase)
    - "Sprawdź swoją skrzynkę pocztową, aby dokończyć rejestrację."
    - "Instrukcje resetowania hasła zostały wysłane."

## 3. Logika Backendowa (Interakcja z Supabase)

Aplikacja Flutter będzie komunikować się bezpośrednio z auto-generowanym API Supabase za pomocą klienta `supabase-flutter`. Nie ma potrzeby tworzenia dodatkowej warstwy backendu.

### 3.1. Serwis `AuthService.dart`

Lokalizacja: `lib/features/auth/services/auth_service.dart`

Będzie to klasa-wrapper na kliencie Supabase, hermetyzująca logikę autentykacji.

```dart
// Kontrakt (uproszczony)
abstract class IAuthService {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  Future<void> signUp({required String email, required String password});
  Future<void> signInWithPassword({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> updateUserPassword({required String password});
}

class AuthService implements IAuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  // Implementacja metod interfejsu...
}
```

### 3.2. Modele Danych

- **`User` (z `supabase-flutter`):** Standardowy model użytkownika dostarczany przez Supabase, zawierający m.in. `id`, `email`.
- **`Profile` (tabela w Supabase):** Zgodnie z zaleceniami Supabase, warto stworzyć publiczną tabelę `profiles` do przechowywania publicznych danych użytkowników, która będzie połączona relacją z tabelą `auth.users`. Na potrzeby MVP może nie być konieczna, ale jest to dobra praktyka na przyszłość.

### 3.3. Obsługa Wyjątków

Metody w `AuthService` powinny opakowywać wywołania API Supabase w bloki `try-catch` i obsługiwać wyjątki `AuthException` rzucane przez `gotrue-dart`.

```dart
// Przykład obsługi błędów
try {
  await _auth.signInWithPassword(email: email, password: password);
} on AuthException catch (e) {
  // Logowanie błędu
  // Rzucenie dalej własnego, bardziej generycznego wyjątku lub
  // zwrócenie obiektu Result z błędem
  throw MyAuthException(e.message);
}
```

## 4. System Autentykacji (Supabase Auth)

### 4.1. Konfiguracja Supabase

1.  **Inicjalizacja `supabase-flutter`:** W `main.dart` należy zainicjalizować klienta Supabase, podając `SUPABASE_URL` i `SUPABASE_ANON_KEY`.
    ```dart
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    ```

2.  **Włączenie autentykacji e-mail/hasło:** W panelu Supabase -> Authentication -> Providers, należy upewnić się, że dostawca "Email" jest włączony.

3.  **Szablony e-mail:** W panelu Supabase -> Authentication -> Email Templates, można dostosować treść wiadomości wysyłanych podczas rejestracji ("Confirm your signup") i resetowania hasła ("Reset your password"). Należy upewnić się, że linki w szablonach poprawnie wskazują na schemat URL aplikacji (deep linking), aby umożliwić powrót do aplikacji.

### 4.2. Procesy Autentykacji

- **Rejestracja (`signUp`):**
    - Wywołanie `Supabase.instance.client.auth.signUp()`.
    - Supabase tworzy nowego użytkownika w tabeli `auth.users`.
    - Domyślnie wysyła e-mail weryfikacyjny. Tę opcję można wyłączyć w panelu Supabase, ale jest to zalecane ze względów bezpieczeństwa.

- **Logowanie (`signInWithPassword`):**
    - Wywołanie `Supabase.instance.client.auth.signInWithPassword()`.
    - Po pomyślnym zalogowaniu, `supabase-flutter` automatycznie zarządza sesją (JWT) i jej odświeżaniem. Stan zalogowania jest utrwalany na urządzeniu.

- **Wylogowywanie (`signOut`):**
    - Wywołanie `Supabase.instance.client.auth.signOut()`.
    - Sesja użytkownika jest usuwana z urządzenia.

- **Odzyskiwanie hasła:**
    1.  `sendPasswordResetEmail()`: Wywołanie `Supabase.instance.client.auth.resetPasswordForEmail()`. Supabase wysyła e-mail z unikalnym linkiem.
    2.  **Deep Link:** Użytkownik klika link, który otwiera aplikację na ekranie `UpdatePasswordScreen`.
    3.  `updateUser()`: Wywołanie `Supabase.instance.client.auth.updateUser()` z nowym hasłem.

### 4.3. Bezpieczeństwo - Row Level Security (RLS)

Zgodnie z wymaganiem `US-018` ("Użytkownik NIE MOŻE korzystać z funkcji aplikacji bez logowania"), wszystkie tabele przechowujące dane użytkownika (np. `books`, `reading_sessions`) muszą być chronione przez RLS.

**Przykładowa polityka RLS dla tabeli `books`:**

1.  **Włączenie RLS:** W edytorze SQL Supabase dla tabeli `books`:
    ```sql
    ALTER TABLE books ENABLE ROW LEVEL SECURITY;
    ```

2.  **Polityka `SELECT`:** Zezwalaj użytkownikowi na odczyt tylko jego własnych książek.
    ```sql
    CREATE POLICY "Allow individual read access"
    ON books FOR SELECT
    USING (auth.uid() = user_id);
    ```
    *Zakładając, że tabela `books` ma kolumnę `user_id` typu `uuid`, która przechowuje ID zalogowanego użytkownika.*

3.  **Polityka `INSERT`:** Zezwalaj zalogowanemu użytkownikowi na dodawanie książek we własnym imieniu.
    ```sql
    CREATE POLICY "Allow individual insert access"
    ON books FOR INSERT
    WITH CHECK (auth.uid() = user_id);
    ```

4.  **Polityki `UPDATE` i `DELETE`:** Analogicznie, zezwalaj na modyfikację i usuwanie tylko własnych rekordów.
    ```sql
    CREATE POLICY "Allow individual update access"
    ON books FOR UPDATE
    USING (auth.uid() = user_id);

    CREATE POLICY "Allow individual delete access"
    ON books FOR DELETE
    USING (auth.uid() = user_id);
    ```

Dzięki RLS, nawet jeśli anonimowy klucz API wycieknie, nieautoryzowany dostęp do danych będzie niemożliwy, ponieważ każde zapytanie jest wykonywane w kontekście zalogowanego użytkownika (lub anonimowo, jeśli nikt nie jest zalogowany).

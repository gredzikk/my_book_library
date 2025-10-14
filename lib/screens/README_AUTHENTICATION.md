# Implementacja Widoku Uwierzytelniania

## Przegląd
Widok uwierzytelniania został zaimplementowany zgodnie z planem implementacji, wykorzystując pakiet `supabase_auth_ui` do obsługi logowania i rejestracji użytkowników.

## Zrealizowane Komponenty

### 1. AuthGate (`lib/widgets/auth_gate.dart`)
**Rola**: Strażnik autoryzacji aplikacji

**Funkcjonalność**:
- Nasłuchuje na zmiany stanu uwierzytelnienia przez `StreamBuilder` i `Supabase.instance.client.auth.onAuthStateChange`
- Automatycznie przekierowuje użytkownika do:
  - `AuthenticationScreen` gdy użytkownik NIE jest zalogowany
  - `HomeScreen` gdy użytkownik JEST zalogowany
- Wyświetla wskaźnik ładowania podczas inicjalizacji

**Implementacja**:
```dart
StreamBuilder<AuthState>(
  stream: Supabase.instance.client.auth.onAuthStateChange,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final session = snapshot.hasData ? snapshot.data!.session : null;
    
    if (session != null) {
      return const HomeScreen();
    } else {
      return const AuthenticationScreen();
    }
  },
);
```

### 2. AuthenticationScreen (`lib/screens/authentication_screen.dart`)
**Rola**: Ekran logowania i rejestracji

**Funkcjonalność**:
- Wykorzystuje widżet `SupaEmailAuth` z pakietu `supabase_auth_ui`
- Obsługuje automatycznie:
  - Logowanie użytkownika
  - Rejestrację nowego użytkownika
  - Resetowanie hasła
  - Walidację danych (email, hasło)
  - Wyświetlanie błędów

**Kluczowe elementy**:
- **Lokalizacja PL**: Wszystkie teksty są po polsku dzięki `SupaEmailAuthLocalization`
- **Obsługa błędów**: Callback `onError` mapuje błędy Supabase na przyjazne komunikaty
- **UI/UX**: Logo aplikacji, tytuł i opis nad formularzem

**Mapowanie błędów**:
```dart
String _getErrorMessage(Object error) {
  if (error is AuthException) {
    switch (error.message.toLowerCase()) {
      case String msg when msg.contains('invalid login credentials'):
        return 'Nieprawidłowe dane logowania';
      case String msg when msg.contains('user already registered'):
        return 'Użytkownik o tym adresie email już istnieje';
      case String msg when msg.contains('password'):
        return 'Hasło nie spełnia wymagań (minimum 6 znaków)';
      case String msg when msg.contains('email'):
        return 'Nieprawidłowy format adresu email';
      default:
        return 'Błąd uwierzytelnienia: ${error.message}';
    }
  }
  
  if (error.toString().toLowerCase().contains('network')) {
    return 'Brak połączenia z internetem. Sprawdź swoje połączenie.';
  }
  
  return 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';
}
```

## Przepływ Użytkownika

### Logowanie
1. Użytkownik uruchamia aplikację
2. `AuthGate` sprawdza stan uwierzytelnienia
3. Jeśli nie zalogowany → wyświetla `AuthenticationScreen`
4. Użytkownik wprowadza email i hasło
5. Klika "Zaloguj się"
6. Po sukcesie → `AuthGate` automatycznie przekierowuje do `HomeScreen`
7. Po błędzie → wyświetla `SnackBar` z komunikatem

### Rejestracja
1. Na `AuthenticationScreen` użytkownik klika "Nie masz konta?"
2. `SupaEmailAuth` przełącza tryb na rejestrację
3. Użytkownik wprowadza email i hasło
4. Klika "Zarejestruj się"
5. Po sukcesie → użytkownik jest automatycznie zalogowany i przekierowany do `HomeScreen`
6. Po błędzie → wyświetla `SnackBar` z komunikatem

### Resetowanie hasła
1. Na ekranie logowania użytkownik klika "Zapomniałeś hasła?"
2. Wprowadza email
3. Klika "Wyślij link resetujący"
4. System wysyła email z linkiem do resetowania hasła

## Integracja z API Supabase

### Automatyczna obsługa przez `supabase_auth_ui`
Pakiet `supabase_auth_ui` wewnętrznie wywołuje:

**Rejestracja**:
- Metoda: `Supabase.instance.client.auth.signUp()`
- Parametry: email, password
- Odpowiedź: `AuthResponse` (Session + User)

**Logowanie**:
- Metoda: `Supabase.instance.client.auth.signInWithPassword()`
- Parametry: email, password
- Odpowiedź: `AuthResponse` (Session + User)

**Zarządzanie sesją**:
- JWT token jest automatycznie przechowywany bezpiecznie
- Wszystkie przyszłe zapytania do API automatycznie zawierają nagłówek `Authorization`

## Walidacja

### Wbudowana w `SupaEmailAuth`:
- **Email**: Musi mieć poprawny format adresu email
- **Hasło**: 
  - Nie może być puste
  - Minimum 6 znaków (konfigurowane w panelu Supabase)
- **Stan UI**: Przyciski aktywne tylko gdy pola wypełnione
- **Wskaźnik ładowania**: Podczas komunikacji z API

## Obsługa błędów

### Scenariusze:
1. **Nieprawidłowe dane logowania** → "Nieprawidłowe dane logowania"
2. **Email już istnieje** → "Użytkownik o tym adresie email już istnieje"
3. **Słabe hasło** → "Hasło nie spełnia wymagań (minimum 6 znaków)"
4. **Nieprawidłowy email** → "Nieprawidłowy format adresu email"
5. **Brak internetu** → "Brak połączenia z internetem. Sprawdź swoje połączenie."
6. **Inne błędy** → "Wystąpił nieoczekiwany błąd. Spróbuj ponownie."

Wszystkie błędy są wyświetlane jako czerwony `SnackBar` na dole ekranu.

## Użyte zależności

```yaml
dependencies:
  supabase_flutter: ^2.10.3    # Klient Supabase
  supabase_auth_ui: ^0.5.5     # Gotowe komponenty UI do uwierzytelniania
```

## Struktura plików

```
lib/
├── widgets/
│   └── auth_gate.dart              # Strażnik autoryzacji
├── screens/
│   ├── authentication_screen.dart   # Ekran logowania/rejestracji
│   └── home_screen.dart             # Ekran główny (po zalogowaniu)
└── main.dart                        # Punkt wejścia, inicjalizacja Supabase
```

## Zgodność z planem implementacji

✅ **Krok 1**: Dodanie zależności `supabase_auth_ui`  
✅ **Krok 2**: Inicjalizacja Supabase w `main.dart`  
✅ **Krok 3**: Stworzenie `AuthGate` z `StreamBuilder`  
✅ **Krok 4**: Stworzenie `AuthenticationScreen` z `SupaEmailAuth`  
✅ **Krok 5**: Dostosowanie wyglądu (logo, kolory, lokalizacja PL)  
✅ **Krok 6**: Obsługa błędów przez callback `onError`  
✅ **Krok 7**: Przygotowanie do onboardingu (TODO w `HomeScreen`)

## Następne kroki

Zgodnie z planem implementacji i user story US-001:

1. **Implementacja onboardingu**: Po pierwszej rejestracji użytkownik powinien przejść proces wyboru ulubionych gatunków
2. **Sprawdzanie stanu onboardingu**: W `HomeScreen` należy dodać logikę sprawdzającą czy użytkownik odbył onboarding (np. przez `SharedPreferences`)
3. **Przekierowanie**: Jeśli użytkownik nie odbył onboardingu → przekieruj na `OnboardingScreen`

## Testowanie

### Scenariusze do przetestowania manualnie:
- [ ] Poprawna rejestracja i automatyczne przekierowanie do `HomeScreen`
- [ ] Błąd rejestracji - istniejący email
- [ ] Błąd rejestracji - słabe hasło
- [ ] Poprawne logowanie i przekierowanie
- [ ] Błąd logowania - złe dane
- [ ] Resetowanie hasła
- [ ] Działanie w trybie offline (komunikat o braku połączenia)

### Testy automatyczne:
Aktualnie nie ma testów jednostkowych dla widoku uwierzytelniania, ponieważ `SupaEmailAuth` hermetyzuje całą logikę. W przyszłości można dodać testy integracyjne z użyciem `flutter_test` i mockowania klienta Supabase.


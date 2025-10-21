# Dokumentacja Testów Jednostkowych AuthService

## Przegląd

Ten plik zawiera kompleksowy zestaw testów jednostkowych dla `AuthService` z projektu My Book Library. Testy zostały przygotowane zgodnie z zasadami Test-Driven Development (TDD) i obejmują wszystkie kluczowe reguły biznesowe oraz przypadki brzegowe.

## Statystyki Pokrycia

- **Łączna liczba testów**: 44
- **Grupy testów**: 8
- **Metody testowane**: 6 głównych metod + właściwości
- **Status**: ✅ Wszystkie testy przechodzą pomyślnie

## Struktura Testów

### 1. **currentUser** (2 testy)
Testuje właściwość zwracającą aktualnie zalogowanego użytkownika.

**Przypadki testowe:**
- ✅ Zwraca użytkownika gdy jest zalogowany
- ✅ Zwraca `null` gdy użytkownik nie jest zalogowany

**Reguły biznesowe:**
- System musi poprawnie śledzić stan uwierzytelnienia
- Niezalogowany użytkownik = `null`

---

### 2. **signInWithPassword** (8 testów)
Testuje logowanie użytkownika za pomocą email i hasła.

**Przypadki testowe:**
- ✅ Pomyślne logowanie z poprawnymi danymi
- ✅ Przycinanie spacji z email przed logowaniem
- ✅ Błąd dla nieprawidłowych danych uwierzytelniających
- ✅ Błąd dla niepotwierdzonych adresów email
- ✅ Błąd dla niepoprawnego formatu email
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa limitowania żądań (rate limiting)
- ✅ Obsługa nieoczekiwanych błędów serwera

**Reguły biznesowe:**
- Email musi być w poprawnym formacie
- Hasło musi być podane
- Adres email musi być potwierdzony
- System musi zabezpieczać przed atakami brute-force (rate limiting)
- Wszystkie błędy są tłumaczone na język polski

**Wyjątki:**
- `UnauthorizedException` - błędne dane lub niepotwierdzony email
- `ValidationException` - niepoprawny format email lub rate limiting
- `NoInternetException` - brak połączenia
- `ServerException` - błąd serwera

---

### 3. **signUp** (7 testów)
Testuje rejestrację nowego użytkownika.

**Przypadki testowe:**
- ✅ Pomyślna rejestracja z poprawnymi danymi
- ✅ Przycinanie spacji z email przed rejestracją
- ✅ Błąd gdy użytkownik już istnieje
- ✅ Błąd dla zbyt słabego hasła
- ✅ Błąd dla niepoprawnego formatu email
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa nieoczekiwanych błędów

**Reguły biznesowe:**
- Email musi być unikalny w systemie
- Hasło musi mieć minimum 8 znaków
- Email musi być w poprawnym formacie
- Po rejestracji wysyłany jest email weryfikacyjny
- Redirect URL: `io.supabase.mybooklibrary://login-callback`

**Wyjątki:**
- `ValidationException` - email zajęty, słabe hasło, niepoprawny format
- `NoInternetException` - brak połączenia
- `ServerException` - błąd serwera

---

### 4. **signOut** (4 testy)
Testuje wylogowanie użytkownika.

**Przypadki testowe:**
- ✅ Pomyślne wylogowanie
- ✅ Obsługa błędu wylogowania
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa nieoczekiwanych błędów

**Reguły biznesowe:**
- Sesja użytkownika musi być poprawnie zakończona
- Lokalne dane sesji są czyszczone
- Błędy wylogowania nie blokują użytkownika

**Wyjątki:**
- `ServerException` - błąd podczas wylogowania
- `NoInternetException` - brak połączenia

---

### 5. **sendPasswordResetEmail** (5 testów)
Testuje wysyłanie emaila z linkiem do resetowania hasła.

**Przypadki testowe:**
- ✅ Pomyślne wysłanie emaila
- ✅ Przycinanie spacji z email
- ✅ Błąd dla niepoprawnego formatu email
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa nieoczekiwanych błędów

**Reguły biznesowe:**
- Email musi być w poprawnym formacie
- Link resetujący jest wysyłany nawet jeśli email nie istnieje (bezpieczeństwo)
- Redirect URL: `io.supabase.mybooklibrary://login-callback`

**Wyjątki:**
- `ValidationException` - niepoprawny format email
- `NoInternetException` - brak połączenia
- `ServerException` - błąd serwera

---

### 6. **updateUserPassword** (5 testów)
Testuje aktualizację hasła zalogowanego użytkownika.

**Przypadki testowe:**
- ✅ Pomyślna aktualizacja hasła
- ✅ Błąd gdy użytkownik nie jest zalogowany
- ✅ Błąd dla zbyt słabego hasła
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa nieoczekiwanych błędów

**Reguły biznesowe:**
- Użytkownik musi być zalogowany
- Nowe hasło musi mieć minimum 8 znaków
- Nie wymaga podania starego hasła (użytkownik już jest uwierzytelniony)

**Wyjątki:**
- `UnauthorizedException` - brak uwierzytelnienia
- `ValidationException` - zbyt słabe hasło
- `NoInternetException` - brak połączenia
- `ServerException` - błąd serwera

---

### 7. **resendConfirmationEmail** (6 testów)
Testuje ponowne wysłanie emaila weryfikacyjnego.

**Przypadki testowe:**
- ✅ Pomyślne wysłanie emaila
- ✅ Przycinanie spacji z email
- ✅ Błąd dla niepoprawnego formatu email
- ✅ Obsługa rate limiting
- ✅ Obsługa braku połączenia z internetem
- ✅ Obsługa nieoczekiwanych błędów

**Reguły biznesowe:**
- Email musi być w poprawnym formacie
- System chroni przed spamowaniem (rate limiting)
- Typ OTP: `OtpType.signup`
- Redirect URL: `io.supabase.mybooklibrary://login-callback`

**Wyjątki:**
- `ValidationException` - niepoprawny email lub rate limiting
- `NoInternetException` - brak połączenia
- `ServerException` - błąd serwera

---

### 8. **Edge Cases** (7 testów)
Testuje nietypowe przypadki brzegowe.

**Przypadki testowe:**
- ✅ Pusty email przy logowaniu
- ✅ Puste hasło przy logowaniu
- ✅ Email zawierający tylko białe znaki
- ✅ Błąd "session not found"
- ✅ Timeout sieci przy logowaniu
- ✅ Różne komunikaty błędów hasła
- ✅ Różne warianty komunikatu "użytkownik już zarejestrowany"

**Reguły biznesowe:**
- System musi gracefully obsługiwać niepoprawne dane wejściowe
- Wszystkie warianty komunikatów błędów są mapowane na polskie odpowiedniki
- Spacje są przycinane przed walidacją

---

## Mapowanie Błędów

System mapuje błędy Supabase na własne wyjątki z polskimi komunikatami:

| Błąd Supabase | Wyjątek Aplikacji | Polski Komunikat |
|---------------|-------------------|------------------|
| Invalid login credentials | `UnauthorizedException` | "Nieprawidłowy e-mail lub hasło" |
| Email not confirmed | `UnauthorizedException` | "Adres e-mail nie został potwierdzony..." |
| User already registered | `ValidationException` | "Użytkownik o tym adresie e-mail już istnieje" |
| Invalid email | `ValidationException` | "Wprowadź poprawny adres e-mail" |
| Password too weak | `ValidationException` | "Hasło musi mieć co najmniej 8 znaków" |
| Not authenticated | `UnauthorizedException` | "Musisz być zalogowany" |
| Rate limit | `ValidationException` | "Zbyt wiele prób. Spróbuj ponownie za chwilę" |
| Network/timeout | `NoInternetException` | - |
| Other errors | `ServerException` | Komunikat oryginalny |

---

## Technologie i Narzędzia

- **Framework testowy**: `flutter_test`
- **Biblioteka mockowania**: `mockito` v5.4.6
- **Generator mocków**: `build_runner`
- **Klient Supabase**: `supabase_flutter`

---

## Uruchomienie Testów

### Wszystkie testy
```bash
flutter test test/services/auth_service_test.dart
```

### Pojedyncza grupa testów
```bash
flutter test test/services/auth_service_test.dart --plain-name "signInWithPassword"
```

### Z pokryciem kodu
```bash
flutter test --coverage test/services/auth_service_test.dart
```

### Regeneracja mocków (po zmianach w interfejsach)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Najlepsze Praktyki TDD Zastosowane w Testach

### 1. **Meaningful Test Names**
Każdy test ma jasną nazwę opisującą testowaną funkcjonalność:
```dart
test('should throw UnauthorizedException for unconfirmed email', () async { ... });
```

### 2. **Arrange-Act-Assert Pattern**
Wszystkie testy używają struktury AAA:
```dart
// Arrange - przygotowanie danych testowych
final mockUser = MockUser();

// Act - wywołanie testowanej funkcji
await authService.signInWithPassword(...);

// Assert - sprawdzenie rezultatu
expect(result, equals(expected));
```

### 3. **Test All Possible Cases**
- Happy path (ścieżka pozytywna)
- Błędy walidacji
- Błędy sieciowe
- Błędy serwera
- Przypadki brzegowe (puste dane, białe znaki, itp.)

### 4. **Maintain Testing Pyramid**
- **Baza**: Testy jednostkowe (44 testy) ✅
- **Środek**: Testy widgetów (planowane)
- **Szczyt**: Testy integracyjne (planowane)

### 5. **Test Isolation**
Każdy test jest niezależny:
- `setUp()` przygotowuje świeże mocki
- Brak współdzielonego stanu między testami
- Każdy test może być uruchomiony osobno

---

## Przykłady Użycia w Kodzie Produkcyjnym

### Obsługa błędów w UI
```dart
try {
  await authService.signInWithPassword(
    email: emailController.text,
    password: passwordController.text,
  );
  // Przekieruj do home screen
} on UnauthorizedException catch (e) {
  // Pokaż błąd w formularzu
  showError(e.message);
} on ValidationException catch (e) {
  // Pokaż błąd walidacji
  showValidationError(e.message);
} on NoInternetException catch (_) {
  // Pokaż komunikat o braku internetu
  showNoInternetDialog();
} on ServerException catch (e) {
  // Pokaż ogólny błąd serwera
  showServerError(e.message);
}
```

---

## Pokrycie Kodu

Testy pokrywają:
- ✅ Wszystkie publiczne metody `AuthService`
- ✅ Wszystkie ścieżki błędów w `_handleAuthException`
- ✅ Obsługę błędów sieciowych
- ✅ Transformację wyjątków
- ✅ Logowanie operacji
- ✅ Walidację i czyszczenie danych wejściowych

**Szacowane pokrycie**: ~95% kodu `AuthService`

---

## Konserwacja Testów

### Kiedy aktualizować testy?

1. **Zmiana logiki biznesowej** - dodaj/zmień testy
2. **Nowe komunikaty błędów** - dodaj testy dla nowych przypadków
3. **Zmiana API Supabase** - zaktualizuj mocki
4. **Nowe wymagania bezpieczeństwa** - dodaj testy walidacji

### Refaktoryzacja

Jeśli testy stają się skomplikowane:
- Wydziel wspólne funkcje pomocnicze
- Użyj grup do lepszej organizacji
- Rozważ parametryzowane testy dla podobnych przypadków

---

## Podsumowanie

Ten zestaw testów zapewnia:
- ✅ **Wysoką jakość kodu** - każda funkcjonalność jest przetestowana
- ✅ **Bezpieczeństwo refaktoryzacji** - zmiany nie zepsują istniejącej funkcjonalności
- ✅ **Dokumentację zachowania** - testy pokazują jak system powinien działać
- ✅ **Szybkie wykrywanie regresji** - automatyczne testy po każdej zmianie
- ✅ **Pewność w deploymencie** - kod jest gotowy do produkcji

Wszystkie 44 testy przechodzą pomyślnie! 🎉

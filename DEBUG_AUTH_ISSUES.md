# Debugging Auth Issues - Instrukcje

## Problem
- Brak komunikatu błędu przy logowaniu niezarejestrowanego użytkownika
- Brak komunikatu po potwierdzeniu emaila na innym urządzeniu
- Logi Supabase pokazują błąd 400, ale aplikacja go nie wyświetla

## Kroki debugowania

### 1. Sprawdź logi aplikacji w czasie rzeczywistym

Uruchom aplikację z pełnymi logami:

```bash
# W terminalu
flutter run --verbose

# Lub z dodatkowymi logami dart
flutter run -v
```

### 2. Przefiltruj logi do AuthService i AuthBloc

W innym terminalu podczas działania aplikacji:

```bash
# Tylko logi auth
adb logcat | grep -E "(AuthService|AuthBloc)"

# Lub w flutter logs
flutter logs | grep -E "(AuthService|AuthBloc)"
```

### 3. Test Case: Niezarejestrowany użytkownik

**Krok po kroku:**

```
1. Otwórz aplikację
2. Przejdź do ekranu logowania
3. Wpisz email który NIE ISTNIEJE w bazie: test_nie_istnieje@example.com
4. Wpisz dowolne hasło: Test1234
5. Kliknij "Zaloguj"
6. Obserwuj logi - szukaj:
   - "Processing sign in request for: test_nie_istnieje@example.com"
   - "AuthException during sign in:"
   - "Sign in failed: unauthorized"
   - Komunikat błędu w SnackBar
```

**Oczekiwany rezultat:**
- ❌ Błąd w logach: "Invalid login credentials" lub "Invalid email or password"
- ✅ SnackBar: "Nieprawidłowy e-mail lub hasło"

**Jeśli nie ma SnackBara:**
- Sprawdź czy w logach jest "AuthException during sign in:"
- Jeśli TAK → problem w AuthBloc (nie emituje AuthError)
- Jeśli NIE → Supabase nie rzuca wyjątku (sprawdź response)

### 4. Test Case: Niezweryfikowany email

**Krok po kroku:**

```
1. Zarejestruj nowe konto: test_nowy@example.com
2. NIE KLIKAJ linku weryfikacyjnego w emailu
3. Spróbuj się zalogować tym samym emailem i hasłem
4. Obserwuj logi - szukaj:
   - "Processing sign in request for: test_nowy@example.com"
   - "AuthException during sign in:"
   - "Message: Email not confirmed" (lub podobne)
   - "Sign in failed: unauthorized - Adres e-mail nie został potwierdzony..."
```

**Oczekiwany rezultat:**
- ❌ Błąd w logach: "Email not confirmed"
- ✅ SnackBar: "Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową..."
- ✅ Przycisk "Wyślij ponownie" w SnackBar

### 5. Test Case: Potwierdzenie emaila na innym urządzeniu

**Krok po kroku:**

```
1. Zarejestruj konto na TELEFONIE: test_crossdevice@example.com
2. Otwórz email na KOMPUTERZE
3. Kliknij link weryfikacyjny NA KOMPUTERZE
4. Wróć do TELEFONU
5. Spróbuj się zalogować
6. Obserwuj logi - szukaj:
   - "Processing sign in request for: test_crossdevice@example.com"
   - "Sign in successful in XXms. User: XXX, Session: true"
   - Navigation do HomeScreen
```

**Oczekiwany rezultat:**
- ✅ Logowanie POWINNO ZADZIAŁAĆ (email został zweryfikowany w kroku 3)
- ✅ User powinien być przekierowany do HomeScreen

**Jeśli nie działa:**
- Sprawdź w Supabase Dashboard → Authentication → Users
- Znajdź użytkownika test_crossdevice@example.com
- Sprawdź kolumnę `email_confirmed_at`:
  - Jeśli NULL → weryfikacja nie zadziałała
  - Jeśli ma datę → weryfikacja OK, problem w aplikacji

### 6. Sprawdź szczegóły błędu w logach

**Dodano rozszerzone logowanie:**

```dart
// W auth_service.dart linia ~468
_logger.severe(
  'AuthException during $operation:\n'
  '  Message: ${e.message}\n'
  '  StatusCode: ${e.statusCode}\n'
  '  Error: $e',
);
```

**W logach szukaj:**

```
[ERROR:AuthService] AuthException during sign in:
  Message: Invalid login credentials
  StatusCode: 400
  Error: AuthException(message: Invalid login credentials, statusCode: 400)
```

### 7. Debug w kodzie

**Ustaw breakpoint w:**

1. `lib/features/auth/bloc/auth_bloc.dart` linia ~88:
   ```dart
   } on UnauthorizedException catch (e) {
     _logger.warning('Sign in failed: unauthorized - ${e.message}');
     emit(AuthError(e.message, previousState: const Unauthenticated())); // <- TUTAJ
   }
   ```

2. `lib/features/auth/screens/login_screen.dart` linia ~94:
   ```dart
   else if (state is AuthError) {
     // <- TUTAJ - czy to się wykonuje?
     final isEmailNotConfirmed = ...
   ```

### 8. Weryfikacja state w UI

**Dodaj tymczasowy debug widget:**

```dart
// W login_screen.dart, w builder:
builder: (context, state) {
  final isLoading = state is AuthLoading;
  
  // TYMCZASOWY DEBUG
  print('🔍 Current AuthState: ${state.runtimeType}');
  if (state is AuthError) {
    print('🔍 AuthError message: ${state.message}');
  }
  
  return Scaffold(...);
}
```

### 9. Sprawdź SnackBar nie jest ukryty

**Możliwe przyczyny:**

1. **Inny SnackBar go zakrywa** - zamknij poprzednie:
   ```dart
   ScaffoldMessenger.of(context).clearSnackBars();
   ScaffoldMessenger.of(context).showSnackBar(...);
   ```

2. **Context jest nieprawidłowy** - użyj globalKey:
   ```dart
   final scaffoldKey = GlobalKey<ScaffoldState>();
   Scaffold(
     key: scaffoldKey,
     ...
   )
   ```

3. **SnackBar jest wyświetlany ale szybko znika** - zwiększ duration:
   ```dart
   duration: const Duration(seconds: 10), // Dłuższy czas
   ```

### 10. Test komunikacji z Supabase

**Sprawdź czy Supabase odpowiada:**

```bash
# W terminalu
curl -X POST https://YOUR_PROJECT.supabase.co/auth/v1/token?grant_type=password \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"wrongpass"}'
```

**Oczekiwana odpowiedź:**
```json
{
  "error": "Invalid login credentials",
  "error_description": "Invalid login credentials",
  "status": 400
}
```

## Co zostało dodane w kodzie

### 1. Rozszerzone logowanie w AuthService
- Pełne szczegóły błędu (message, statusCode, error)
- Logi dla response z signInWithPassword

### 2. Dodatkowy pattern w _handleAuthException
- `'invalid email or password'` - na wypadek innych wersji błędu Supabase

### 3. Logi w signInWithPassword
- User ID i Session status po udanym logowaniu

## Checklist debugowania

- [ ] Logi pokazują "Processing sign in request"
- [ ] Logi pokazują "AuthException during sign in"
- [ ] Logi pokazują szczegóły błędu (Message, StatusCode)
- [ ] BLoC emituje AuthError state (logi: "Sign in failed: unauthorized")
- [ ] BlocConsumer listener otrzymuje AuthError (dodaj print)
- [ ] SnackBar jest wyświetlany (dodaj print przed showSnackBar)
- [ ] SnackBar jest widoczny na ekranie (nie zakryty przez inne elementy)

## Następne kroki jeśli problem persystuje

1. **Udostępnij logi** z flutter run podczas próby logowania
2. **Screenshot ekranu** podczas błędu (czy SnackBar w ogóle się pojawia?)
3. **Sprawdź Supabase Dashboard** → Authentication → Logs → Auth Logs
4. **Wersja pakietów** - sprawdź pubspec.lock:
   - supabase_flutter: ^?
   - flutter_bloc: ^?

## Quick Fix - Fallback na zawsze pokazuj błąd

**Jeśli nic nie działa, dodaj fallback:**

```dart
// W auth_bloc.dart w _onSignInRequested
} catch (e) {
  _logger.severe('Sign in failed: unexpected error - $e');
  
  // ZAWSZE pokaż błąd użytkownikowi
  emit(
    AuthError(
      e.toString(), // Pokaż surowy błąd
      previousState: const Unauthenticated(),
    ),
  );
}
```

Wtedy KAŻDY błąd będzie wyświetlony, nawet jeśli nie jest prawidłowo obsłużony.

# Test Authentication Flow - Quick Guide

## Dodano rozszerzone logowanie ✅

### W kodzie dodano:

1. **AuthService** - pełne szczegóły błędów:
   ```
   [ERROR:AuthService] AuthException during sign in:
     Message: Invalid login credentials
     StatusCode: 400
     Error: AuthException(...)
   ```

2. **AuthBloc** - potwierdzenie emit state:
   ```
   [INFO:AuthBloc] Sign in failed: unauthorized - Nieprawidłowy e-mail lub hasło
   [INFO:AuthBloc] Emitted AuthError state with message: Nieprawidłowy e-mail lub hasło
   ```

3. **LoginScreen** - debug state changes:
   ```
   🔍 LoginScreen - State changed to: AuthError
   🔍 LoginScreen - AuthError message: Nieprawidłowy e-mail lub hasło
   ❌ LoginScreen - Showing error SnackBar
   ```

## Jak przetestować

### 1. Uruchom aplikację z logami

```bash
flutter run
```

### 2. Test: Niezarejestrowany użytkownik

**Kroki:**
1. Otwórz ekran logowania
2. Email: `nieistniejacy@test.com`
3. Hasło: `Test1234`
4. Kliknij "Zaloguj"

**W konsoli powinieneś zobaczyć:**
```
[INFO:AuthBloc] Processing sign in request for: nieistniejacy@test.com
[INFO:AuthBloc] Emitting AuthLoading...
[INFO:AuthService] Attempting sign in for email: nieistniejacy@test.com
[ERROR:AuthService] AuthException during sign in:
  Message: Invalid login credentials
  StatusCode: 400
  Error: AuthException(message: Invalid login credentials)
[WARNING:AuthBloc] Sign in failed: unauthorized - Nieprawidłowy e-mail lub hasło
[INFO:AuthBloc] Emitted AuthError state with message: Nieprawidłowy e-mail lub hasło
🔍 LoginScreen - State changed to: AuthError
🔍 LoginScreen - AuthError message: Nieprawidłowy e-mail lub hasło
❌ LoginScreen - Showing error SnackBar
```

**Na ekranie powinieneś zobaczyć:**
- ✅ SnackBar z czerwonym tłem
- ✅ Tekst: "Nieprawidłowy e-mail lub hasło"
- ✅ Duration: 4 sekundy

### 3. Test: Niezweryfikowany email

**Kroki:**
1. Zarejestruj nowe konto (jeśli jeszcze nie masz)
2. NIE KLIKAJ linku weryfikacyjnego
3. Spróbuj się zalogować

**W konsoli powinieneś zobaczyć:**
```
[ERROR:AuthService] AuthException during sign in:
  Message: Email not confirmed
  StatusCode: 400
[WARNING:AuthBloc] Sign in failed: unauthorized - Adres e-mail nie został potwierdzony...
[INFO:AuthBloc] Emitted AuthError state with message: Adres e-mail nie został potwierdzony...
🔍 LoginScreen - AuthError message: Adres e-mail nie został potwierdzony...
❌ LoginScreen - Showing error SnackBar
```

**Na ekranie powinieneś zobaczyć:**
- ✅ SnackBar z czerwonym tłem
- ✅ Tekst: "Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową..."
- ✅ Przycisk: "Wyślij ponownie"
- ✅ Duration: 7 sekund

### 4. Test: Weryfikacja na innym urządzeniu

**Kroki:**
1. Zarejestruj konto NA TELEFONIE: `crossdevice@test.com`
2. Otwórz email NA KOMPUTERZE
3. Kliknij link weryfikacyjny NA KOMPUTERZE
4. Wróć DO TELEFONU
5. Spróbuj się zalogować

**W konsoli powinieneś zobaczyć:**
```
[INFO:AuthBloc] Processing sign in request for: crossdevice@test.com
[INFO:AuthService] Attempting sign in for email: crossdevice@test.com
[INFO:AuthService] Sign in successful in XXms. User: XXX-XXX-XXX, Session: true
[INFO:AuthBloc] Sign in successful for user: XXX-XXX-XXX
🔍 LoginScreen - State changed to: Authenticated
```

**Na ekranie powinieneś zobaczyć:**
- ✅ Przekierowanie do HomeScreen (AuthGate wykryje Authenticated state)

## Jeśli nie widzisz logów

### 1. Zwiększ verbose logging

```bash
flutter run -v
```

### 2. Sprawdź czy logging jest włączony

W `main.dart` powinno być:

```dart
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((record) {
  dev.log(
    record.message,
    time: record.time,
    level: record.level.value,
    name: record.loggerName,
  );
});
```

### 3. Dodaj breakpoint

W `lib/features/auth/bloc/auth_bloc.dart` linia ~88:
```dart
} on UnauthorizedException catch (e) {
  _logger.warning('Sign in failed: unauthorized - ${e.message}');
  emit(AuthError(e.message, previousState: const Unauthenticated()));
  _logger.info('Emitted AuthError state with message: ${e.message}'); // <- BREAKPOINT TUTAJ
}
```

## Możliwe problemy i rozwiązania

### Problem: Nie widzę SnackBara

**Rozwiązanie 1:** Sprawdź czy SnackBar nie jest zakryty
```dart
// Przed showSnackBar
ScaffoldMessenger.of(context).clearSnackBars();
```

**Rozwiązanie 2:** Zwiększ duration
```dart
duration: const Duration(seconds: 10), // Bardzo długo
```

**Rozwiązanie 3:** Sprawdź czy context jest prawidłowy
```dart
// Dodaj print przed showSnackBar
print('🔍 Context: ${context.widget}');
ScaffoldMessenger.of(context).showSnackBar(...);
```

### Problem: Logi pokazują błąd ale SnackBar nie pojawia się

**Prawdopodobna przyczyna:** AuthGate natychmiast nawiguje i zamyka LoginScreen

**Rozwiązanie:** Sprawdź czy AuthGate nie naviguje przed pokazaniem SnackBar:

```dart
// W lib/widgets/auth_gate.dart
BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
  builder: (context, state) {
    print('🔍 AuthGate - State: ${state.runtimeType}');
    
    // Podczas loading i error pokazuj AuthenticationScreen
    if (state is auth_bloc.AuthInitial || 
        state is auth_bloc.AuthLoading ||
        state is auth_bloc.AuthError) {  // <- WAŻNE: pokazuj auth screen podczas błędu
      return const AuthenticationScreen();
    }
    
    if (state is auth_bloc.Authenticated) {
      return const HomeScreenView();
    }
    
    return const AuthenticationScreen();
  },
)
```

### Problem: Błąd 400 w Supabase ale aplikacja nie pokazuje komunikatu

**Sprawdź:**

1. Czy błąd jest przechwytywany:
   ```
   [ERROR:AuthService] AuthException during sign in:
   ```
   - Jeśli TAK → problem w BLoC lub UI
   - Jeśli NIE → `signInWithPassword` nie rzuca wyjątku

2. Czy BLoC emituje AuthError:
   ```
   [INFO:AuthBloc] Emitted AuthError state with message: ...
   ```
   - Jeśli TAK → problem w UI listener
   - Jeśli NIE → wyjątek nie jest przechwycony w BLoC

3. Czy UI otrzymuje AuthError:
   ```
   🔍 LoginScreen - State changed to: AuthError
   ```
   - Jeśli TAK → problem z pokazaniem SnackBar
   - Jeśli NIE → BlocConsumer nie jest prawidłowo skonfigurowany

## Udostępnij wyniki

Jeśli problem persystuje, udostępnij:

1. **Pełne logi** z flutter run podczas próby logowania
2. **Screenshot** ekranu logowania podczas/po błędzie
3. **Logi z Supabase Dashboard:**
   - Authentication → Logs → Auth Logs
   - Znajdź odpowiedni timestamp
   - Skopiuj szczegóły błędu

## Dodatkowe debugowanie

### Sprawdź czy BlocConsumer jest prawidłowo skonfigurowany

Dodaj to na początku `build()` w LoginScreen:

```dart
@override
Widget build(BuildContext context) {
  // Debug - sprawdź czy mamy dostęp do AuthBloc
  final authBloc = context.read<auth_bloc.AuthBloc>();
  print('🔍 AuthBloc available: ${authBloc != null}');
  print('🔍 Current AuthBloc state: ${authBloc.state.runtimeType}');
  
  final theme = Theme.of(context);
  ...
}
```

### Sprawdź czy listener jest wywoływany

Dodaj counter:

```dart
int _listenerCallCount = 0;

// W listener:
listener: (context, state) {
  _listenerCallCount++;
  print('🔍 Listener called $_listenerCallCount times');
  print('🔍 State: ${state.runtimeType}');
  ...
}
```

To powinno pomóc zidentyfikować gdzie dokładnie problem występuje!

# Konfiguracja Email w Supabase - Troubleshooting

## Problem
- Rejestracja na już istniejącym emailu pokazuje sukces
- Email weryfikacyjny nie dochodzi  
- User rejestruje się na telefonie, potwierdza email na PC, wraca do telefonu i logowanie "nic nie robi"

## ✅ Rozwiązanie zaimplementowane

### 1. **Lepszy komunikat przy niezweryfikowanym emailu**
Gdy użytkownik próbuje się zalogować bez weryfikacji emaila:
- ❌ Poprzednio: "Nieprawidłowy e-mail lub hasło" (mylące!)
- ✅ Teraz: "Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową i kliknij link weryfikacyjny."

### 2. **Przycisk "Wyślij ponownie" w LoginScreen**
- Po próbie logowania na niezweryfikowane konto, SnackBar pokazuje przycisk **"Wyślij ponownie"**
- Kliknięcie przycisku → ponownie wysyła email weryfikacyjny
- Działa nawet jeśli user potwierdził email na innym urządzeniu!

## Przyczyny

### 1. **Poprawne zachowanie - Security by Design**
Supabase **celowo nie ujawnia** czy email jest już zarejestrowany:
- Przy ponownej rejestracji tego samego emaila → zwraca "sukces" 
- Email weryfikacyjny NIE jest wysyłany ponownie (zabezpieczenie przed spam)
- To normalne i bezpieczne zachowanie

**Jeśli użytkownik już istnieje:**
- Może się zalogować jeśli zweryfikował email wcześniej
- Jeśli zapomniał hasła → użyj "Przypomnij hasło"

### 2. **Konfiguracja Supabase Dashboard**

#### A. Włącz Email Confirmation
1. Otwórz **Supabase Dashboard** → Twój projekt
2. Przejdź do: **Authentication** → **Providers** → **Email**
3. Sprawdź ustawienia:
   - ✅ **Enable Email Confirmations** = ON
   - ✅ **Secure email change** = ON (opcjonalne)
   - ✅ **Enable Email OTP** = OFF (jeśli używasz link-based verification)

#### B. Skonfiguruj Redirect URLs
1. Przejdź do: **Authentication** → **URL Configuration**
2. W sekcji **Redirect URLs** dodaj:
   ```
   io.supabase.mybooklibrary://login-callback
   http://localhost:* (dla development)
   ```
3. Kliknij **Save**

#### C. Skonfiguruj Email Templates
1. Przejdź do: **Authentication** → **Email Templates**
2. Wybierz **Confirm signup**
3. Sprawdź czy w template jest:
   ```html
   <a href="{{ .ConfirmationURL }}">Potwierdź email</a>
   ```
4. Możesz dostosować polski template:
   ```html
   <h2>Potwierdź swoją rejestrację</h2>
   <p>Dziękujemy za rejestrację w MyBookLibrary!</p>
   <p>Kliknij poniższy przycisk, aby potwierdzić swój adres email:</p>
   <a href="{{ .ConfirmationURL }}">Potwierdź email</a>
   <p>Link jest ważny przez 24 godziny.</p>
   ```

#### D. Sprawdź SMTP Configuration
1. Przejdź do: **Project Settings** → **Auth** → **SMTP Settings**
2. Opcje:
   - **Supabase SMTP** (domyślne, limit ~3 emaile/godzinę w dev)
   - **Custom SMTP** (zalecane dla produkcji):
     - SendGrid
     - AWS SES
     - Mailgun
     - Twój własny SMTP

**Uwaga:** Supabase darmowy SMTP ma limity rate-limit. W produkcji użyj custom SMTP!

### 3. **Sprawdź Logi w Supabase**
1. Przejdź do: **Authentication** → **Users**
2. Znajdź użytkownika po emailu
3. Sprawdź kolumnę `email_confirmed_at`:
   - `NULL` = email nie został zweryfikowany
   - Data = email zweryfikowany

4. Przejdź do: **Logs** → **Auth Logs**
   - Szukaj eventów: `signup`, `confirmation_email_sent`
   - Sprawdź czy są błędy

### 4. **Testowanie Email Flow**

#### Test 1: Nowy użytkownik
```dart
// 1. Zarejestruj nowego użytkownika (nowy email!)
await authService.signUp(
  email: 'test_nowy@example.com',
  password: 'Test1234',
);

// 2. Sprawdź email (również SPAM!)
// 3. Kliknij link weryfikacyjny
// 4. Aplikacja powinna się otworzyć (deep link)
// 5. Zaloguj się tym samym emailem
```

#### Test 2: Istniejący użytkownik
```dart
// 1. Spróbuj zarejestrować się ponownie tym samym emailem
// Rezultat: Sukces (ale email NIE zostanie wysłany)

// 2. Zaloguj się istniejącym kontem:
await authService.signInWithPassword(
  email: 'test_nowy@example.com',
  password: 'Test1234',
);
// Jeśli email był wcześniej zweryfikowany → zaloguje
// Jeśli email NIE był zweryfikowany → błąd "Email not confirmed"
```

### 5. **Lokalna weryfikacja kodu**

#### Sprawdź AuthService (już naprawione ✅)
```dart
// W lib/features/auth/services/auth_service.dart
await _auth.signUp(
  email: email.trim(),
  password: password,
  emailRedirectTo: 'io.supabase.mybooklibrary://login-callback', // ✅ DODANE
);
```

#### Sprawdź AndroidManifest.xml (już skonfigurowane ✅)
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="io.supabase.mybooklibrary"
    android:host="login-callback" />
</intent-filter>
```

### 6. **Debugging Email Delivery**

#### Sprawdź folder SPAM
- Gmail często blokuje emaile z Supabase
- Dodaj `noreply@mail.app.supabase.io` do kontaktów

#### Test przez Supabase Dashboard
1. **Authentication** → **Users** → **Invite user**
2. Wpisz email i kliknij **Send invite**
3. Sprawdź czy ten email dochodzi

#### Logi w aplikacji
```bash
# Uruchom app z logami
flutter run --verbose

# Szukaj w logach:
# "Sign up successful"
# "Auth state changed"
```

## Rozwiązanie

### Dla nowych użytkowników:
1. ✅ Upewnij się że email jest **nowy** (nie był wcześniej rejestrowany)
2. ✅ Sprawdź folder SPAM
3. ✅ Poczekaj 1-2 minuty (delay w SMTP)
4. ✅ Sprawdź konfigurację w Supabase Dashboard (kroki powyżej)

### Dla istniejących użytkowników:
1. Zaloguj się bezpośrednio (jeśli email był wcześniej zweryfikowany)
2. Użyj "Forgot Password" jeśli nie pamiętasz hasła
3. Sprawdź w Supabase Dashboard czy `email_confirmed_at` jest ustawione

### W produkcji:
1. ✅ Skonfiguruj **Custom SMTP** (SendGrid, AWS SES, Mailgun)
2. ✅ Dodaj własny **Email Template** z brandingiem
3. ✅ Ustaw **Rate Limits** w Supabase
4. ✅ Monitoruj **Auth Logs** regularnie

## Następne kroki dla iOS

Dodaj do `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.mybooklibrary</string>
    </array>
  </dict>
</array>
```

## Pytania debugowania

1. **Czy używasz nowego emaila czy tego samego?**
   - Ten sam email → nie dostaniesz ponownie emaila (security)
   
2. **Czy sprawdziłeś SPAM?**
   - Supabase emaile często lądują w SPAM
   
3. **Czy w Supabase Dashboard widzisz użytkownika?**
   - Authentication → Users → szukaj po emailu
   
4. **Czy email_confirmed_at jest NULL?**
   - NULL = nie zweryfikowany
   - Data = zweryfikowany

5. **Czy redirect URL jest dodany w Supabase?**
   - Authentication → URL Configuration
   - `io.supabase.mybooklibrary://login-callback`

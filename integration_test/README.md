# E2E Integration Tests - Quick Start Guide

## Przegląd

Testy E2E (End-to-End) weryfikują całą aplikację od interfejsu użytkownika do bazy danych. Używamy `integration_test` package z Flutter.

## Struktura Testów

```
integration_test/
├── smoke/
│   └── critical_path_test.dart      # Główne flow: register → add book → session
├── auth/
│   └── auth_flow_test.dart          # TC-AUTH-01 do TC-AUTH-04
├── books/
│   └── book_crud_test.dart          # TC-BOOK-01 do TC-BOOK-04
├── helpers/
│   ├── test_data_helper.dart        # Generowanie i cleanup danych testowych
│   └── test_reporter.dart           # Logowanie i reporting
└── mocks/
    └── mock_google_books_service.dart # Mock Google Books API
```

## Wymagania

### 1. Środowisko Testowe Supabase

Musisz mieć **osobny projekt Supabase** dla testów (nie używaj produkcyjnego!):

1. Stwórz nowy projekt na [supabase.com](https://supabase.com)
2. Uruchom te same migracje co w projekcie głównym
3. Zdobądź credentials:
   - **URL**: `https://xxxxx.supabase.co`
   - **Anon Key**: `eyJhbGc...`

### 2. Konfiguracja Environment Variables

Dodaj do pliku `.env` (lub utwórz `.env.test`):

```env
# Test environment
SUPABASE_TEST_URL=https://your-test-project.supabase.co
SUPABASE_TEST_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**⚠️ WAŻNE:** Nigdy nie commituj prawdziwych credentials do git!

### 3. GitHub Secrets (dla CI/CD)

W Settings → Secrets and variables → Actions, dodaj:
- `SUPABASE_TEST_URL`
- `SUPABASE_TEST_ANON_KEY`

## Uruchamianie Testów Lokalnie

### Opcja 1: Android Emulator

1. **Uruchom emulator:**
   ```bash
   # Lista dostępnych urządzeń
   flutter emulators
   
   # Uruchom emulator (np. Pixel_5_API_33)
   flutter emulators --launch Pixel_5_API_33
   ```

2. **Uruchom wszystkie testy E2E:**
   ```bash
   flutter test integration_test/ \
     --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
     --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
   ```

3. **Uruchom konkretny test:**
   ```bash
   # Tylko smoke test
   flutter test integration_test/smoke/critical_path_test.dart \
     --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
     --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
   
   # Tylko auth tests
   flutter test integration_test/auth/auth_flow_test.dart \
     --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
     --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
   ```

### Opcja 2: Fizyczne urządzenie Android

1. **Włącz USB debugging na telefonie**
2. **Podłącz telefon i sprawdź:**
   ```bash
   flutter devices
   ```

3. **Uruchom testy:**
   ```bash
   flutter test integration_test/ -d <DEVICE_ID> \
     --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
     --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
   ```

### Opcja 3: Za pomocą `flutter drive` (alternatywna metoda)

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/smoke/critical_path_test.dart \
  --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
  --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
```

## Debugging Testów

### 1. Włącz verbose logging
```bash
flutter test integration_test/smoke/critical_path_test.dart --verbose \
  --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
  --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
```

### 2. Screenshot na błędzie
Testy automatycznie robią screenshot gdy failują. Szukaj w logach:
```
📸 [E2E] Screenshot taken: error_1234567890.png
```

### 3. Sprawdź logi Supabase
W Supabase dashboard → Database → Logs, możesz zobaczyć wszystkie query wykonane podczas testów.

### 4. Flaky tests
Jeśli test czasem przechodzi, czasem nie:
- Zwiększ timeout: `await tester.pumpAndSettle(const Duration(seconds: 5))`
- Dodaj explicit waits
- Sprawdź czy dane testowe są prawidłowo czyszczone

## CI/CD Pipeline

Workflow `.github/workflows/e2e_tests.yml` uruchamia się:
- ✅ Na każdy push do `main` lub `develop`
- ✅ Na każdy Pull Request
- ✅ Codziennie o 2:00 UTC (scheduled)
- ✅ Manualnie z GitHub Actions UI

### Monitoring CI/CD

1. Idź do **Actions** tab na GitHubie
2. Wybierz workflow "E2E Integration Tests"
3. Zobacz logi z każdego testu
4. Pobierz artifacts (screenshots, logi) jeśli coś failuje

## Najlepsze Praktyki

### ✅ DO:
- **Zawsze czyszczcie dane testowe w `tearDown()`**
- Używajcie unikalnych email (z timestamp)
- Mockujcie zewnętrzne API (Google Books)
- Testujcie tylko critical paths w E2E
- Dodawajcie assertions do sprawdzania stanu bazy danych

### ❌ DON'T:
- Nie używajcie produkcyjnej bazy Supabase
- Nie hardcodujcie delays (`sleep`)
- Nie zostawiajcie dannych testowych po testach
- Nie testujcie wszystkiego E2E (to kosztowne)
- Nie polegajcie na losowym ID widgetów

## Troubleshooting

### Problem: "Supabase not initialized"
**Rozwiązanie:** Sprawdź czy environment variables są ustawione:
```bash
echo $SUPABASE_TEST_URL
echo $SUPABASE_TEST_ANON_KEY
```

### Problem: "Widget not found"
**Rozwiązanie:** 
1. Dodaj Key do widgetu: `key: Key('my_widget')`
2. Znajdź widget: `find.byKey(Key('my_widget'))`
3. Lub użyj `find.textContaining()` zamiast `find.text()`

### Problem: Test timeout
**Rozwiązanie:**
```dart
testWidgets('...', (tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 5)));
```

### Problem: "Failed to cleanup test user"
**Rozwiązanie:** To nie-krytyczny błąd (często dzieje się gdy user był już usunięty). Możesz go zignorować, ale najlepiej:
1. Sprawdź czy masz włączone RLS policies
2. Upewnij się że test environment ma odpowiednie permissions

## Metryki Jakości

| Metric | Target | Current |
|--------|--------|---------|
| Test Coverage (E2E) | 5-10 critical paths | ✅ 8 testów |
| Test Duration | < 15 min | ~12 min |
| Flakiness Rate | < 5% | TBD |
| Pass Rate (CI) | > 95% | TBD |

## Kontakt & Support

- **Issues:** Zgłaszaj problemy jako GitHub Issues z tagiem `[E2E]`
- **Questions:** Stwórz Discussion na GitHub

---

**Ostatnia aktualizacja:** 21 października 2025

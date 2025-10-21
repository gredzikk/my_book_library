# E2E Testing Implementation - Next Steps Checklist

## ✅ Zrobione (Setup Complete)

- [x] Dodano `integration_test` i `bloc_test` do dependencies
- [x] Utworzono strukturę folderów dla testów E2E
- [x] Zaimplementowano `EnvConfig` dla różnych środowisk (dev/test/prod)
- [x] Utworzono `TestDataHelper` z metodami cleanup i seed
- [x] Utworzono `TestReporter` do logowania i raportowania
- [x] Zaimplementowano `MockGoogleBooksService`
- [x] Napisano **smoke test** - critical path (TC-SMOKE-01)
- [x] Napisano **auth flow tests** (TC-AUTH-01 do TC-AUTH-04)
- [x] Napisano **book CRUD tests** (TC-BOOK-01 do TC-BOOK-04)
- [x] Skonfigurowano GitHub Actions workflow dla CI/CD
- [x] Utworzono dokumentację (README, setup guide)

**Total:** 8 testów E2E pokrywających najważniejsze scenariusze

---

## 🚀 Do Zrobienia - Immediate Actions

### 1. Konfiguracja Test Environment (PRIORYTET 1) 🔴
**Czas:** ~30 minut

```bash
□ Stwórz nowy projekt Supabase dla testów
□ Skopiuj migracje SQL
□ Skonfiguruj RLS policies
□ Seed gatunki literackie
□ Pobierz credentials (URL + Anon Key)
□ Dodaj do .env lokalnie
□ Dodaj do GitHub Secrets
□ Przetestuj połączenie
```

**Dokumentacja:** `.ai/test-environment-setup.md`

---

### 2. Dodanie Key do UI Widgets (PRIORYTET 1) 🔴
**Czas:** ~1-2 godziny

Testy E2E potrzebują stabilnych selektorów. Dodaj `Key` do kluczowych widgetów:

**Login Screen:**
```dart
TextField(
  key: const Key('email_field'),
  // ...
)

TextField(
  key: const Key('password_field'),
  // ...
)

ElevatedButton(
  key: const Key('login_button'),
  // ...
)
```

**Registration Screen:**
```dart
TextField(key: const Key('register_email_field'))
TextField(key: const Key('register_password_field'))
TextField(key: const Key('register_confirm_password_field'))
ElevatedButton(key: const Key('register_submit_button'))
```

**Add Book Screen:**
```dart
TextField(key: const Key('book_title_field'))
TextField(key: const Key('book_author_field'))
TextField(key: const Key('book_pages_field'))
TextField(key: const Key('isbn_field'))
IconButton(key: const Key('isbn_search_button'), icon: Icon(Icons.search))
ElevatedButton(key: const Key('save_book_button'))
```

**Book Details Screen:**
```dart
IconButton(key: const Key('edit_book_button'), icon: Icon(Icons.edit))
IconButton(key: const Key('delete_book_button'), icon: Icon(Icons.delete))
ElevatedButton(key: const Key('start_session_button'))
```

**Reading Session Screen:**
```dart
ElevatedButton(key: const Key('end_session_button'))
TextField(key: const Key('last_page_field'))
ElevatedButton(key: const Key('confirm_session_button'))
```

**Lista plików do edycji:**
- `lib/features/auth/view/login_screen.dart`
- `lib/features/auth/view/register_screen.dart`
- `lib/features/add_book/view/add_book_screen.dart`
- `lib/features/book_detail/view/book_detail_screen.dart`
- `lib/features/reading_session/view/reading_session_screen.dart`

---

### 3. Pierwsze Uruchomienie Testów Lokalnie (PRIORYTET 2) 🟡
**Czas:** ~30 minut

```bash
# 1. Uruchom emulator
flutter emulators --launch Pixel_5_API_33

# 2. Sprawdź czy emulator działa
flutter devices

# 3. Uruchom smoke test
flutter test integration_test/smoke/critical_path_test.dart \
  --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
  --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY

# 4. Jeśli przechodzi, uruchom wszystkie
flutter test integration_test/
```

**Spodziewane problemy:**
- ❌ Widgets not found → Dodaj Keys (krok 2)
- ❌ Timeouts → Zwiększ timeout w testach
- ❌ Flaky tests → Dodaj `await tester.pumpAndSettle()`

---

### 4. Fix Issues Based on Test Results (PRIORYTET 2) 🟡
**Czas:** Zależnie od ilości błędów

Po pierwszym uruchomieniu:
```bash
□ Przeanalizuj błędy z logów
□ Popraw selektory widgetów
□ Dostosuj timeouty
□ Sprawdź czy dane testowe są czyszczone
□ Re-run testy
```

**Debug tips:**
```bash
# Verbose output
flutter test integration_test/smoke/ --verbose

# Screenshot na błędzie
# Automatycznie w TestReporter.takeScreenshot()
```

---

### 5. Weryfikacja CI/CD Pipeline (PRIORYTET 3) 🟢
**Czas:** ~15 minut

```bash
□ Push zmian do branch
□ Stwórz Pull Request
□ Sprawdź czy GitHub Actions się uruchamia
□ Zweryfikuj logi z testów
□ Jeśli fail, pobierz artifacts (screenshots)
```

**Workflow:** `.github/workflows/e2e_tests.yml`

---

## 📋 Opcjonalne Rozszerzenia (Future Sprints)

### 6. Dodatkowe Testy E2E 🟢
**Priorytet:** Niski  
**Czas:** 2-3 dni

Rozszerz pokrycie o:
```dart
□ TC-SESSION-01: Full reading session flow
□ TC-SESSION-02: Mark book as read automatically
□ TC-UI-01: Filter books by status
□ TC-UI-02: Sort books
□ Password reset flow
□ Email confirmation flow (jeśli włączone)
```

---

### 7. Visual Regression Testing 🟢
**Priorytet:** Niski  
**Czas:** 1 dzień

```bash
# Install golden_toolkit
flutter pub add golden_toolkit --dev

# Create golden tests
integration_test/goldens/
  └── screenshot_tests.dart
```

**Use case:** Upewnić się że UI nie zmienia się nieoczekiwanie

---

### 8. Performance Monitoring 🟢
**Priorytet:** Niski  
**Czas:** 1 dzień

Dodaj do testów:
```dart
final stopwatch = Stopwatch()..start();
// ... perform action
stopwatch.stop();
TestReporter.logPerformance('Book creation', stopwatch.elapsed);

expect(stopwatch.elapsed, lessThan(Duration(seconds: 3)));
```

---

### 9. Test Flakiness Monitoring 🟢
**Priorytet:** Niski  
**Czas:** On-going

Track w CI/CD:
- Ile razy test failuje vs przechodzi
- Average execution time
- Most flaky tests

**Tool:** GitHub Actions + custom script lub [Flaky Test Tracker](https://github.com/marketplace/actions/flaky-tests-tracker)

---

### 10. Cross-Platform Testing 🟢
**Priorytet:** Niski (gdy dodajemy iOS)  
**Czas:** 2 dni

```yaml
# .github/workflows/e2e_tests_ios.yml
- name: Run E2E Tests on iOS Simulator
  run: |
    xcrun simctl boot "iPhone 14 Pro"
    flutter test integration_test/ -d iPhone
```

---

## 📊 Success Metrics (Tracking)

Po implementacji, śledź te metryki:

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| E2E Test Count | 8-10 | 8 | ✅ |
| Critical Path Coverage | 100% | 100% | ✅ |
| CI Pass Rate | >95% | TBD | ⏳ |
| Test Duration (CI) | <15 min | TBD | ⏳ |
| Flakiness Rate | <5% | TBD | ⏳ |
| Code Coverage (E2E) | 60-70% | TBD | ⏳ |

**Monitoring:** GitHub Actions insights + custom dashboard

---

## 🎯 Priorytety na Dziś/Jutro

### Dzisiaj (3-4 godziny):
1. ✅ ~~Setup test environment Supabase~~ → **DO TERAZ**
2. ✅ Dodaj Keys do UI widgets → **KLUCZOWE**
3. ✅ Uruchom testy lokalnie → **WERYFIKACJA**

### Jutro (2-3 godziny):
4. Fix issues z pierwszego uruchomienia
5. Sprawdź CI/CD pipeline
6. Review i merge do main

### Następny tydzień:
7. Monitor flakiness przez kilka dni
8. Dodaj brakujące testy (jeśli potrzebne)
9. Dokumentacja lessons learned

---

## 📚 Przydatne Komendy

```bash
# Quick test pojedynczego pliku
flutter test integration_test/smoke/critical_path_test.dart

# All tests with coverage
flutter test integration_test/ --coverage

# Specific device
flutter test integration_test/ -d emulator-5554

# Verbose logging
flutter test integration_test/ --verbose

# Keep app running after test (debug)
flutter drive --target=integration_test/smoke/critical_path_test.dart --keep-app-running
```

---

## 🆘 Support & Resources

- **Documentation:** `integration_test/README.md`
- **Setup Guide:** `.ai/test-environment-setup.md`
- **Issues:** GitHub Issues z tagiem `[E2E]`
- **Questions:** GitHub Discussions

**Team Contact:**
- QA Lead: [Twój kontakt]
- DevOps: [Kontakt do CI/CD]

---

**Ostatnia aktualizacja:** 21 października 2025  
**Next Review:** Po pierwszym uruchomieniu testów

# Setup Test Environment - Supabase Configuration

## Cel

Ten dokument opisuje jak skonfigurować **oddzielny projekt Supabase** specjalnie dla testów E2E, aby nie zanieczyszczać danych produkcyjnych.

## Krok 1: Stwórz Nowy Projekt Supabase

1. Zaloguj się na [supabase.com](https://supabase.com)
2. Kliknij **"New Project"**
3. Nazwij projekt: `my-book-library-test`
4. Wybierz region (najlepiej taki sam jak produkcja)
5. Ustaw silne hasło dla database
6. Kliknij **"Create new project"**

⏱️ **Czas oczekiwania:** ~2 minuty na setup

## Krok 2: Skopiuj Migracje

Musisz odtworzyć tę samą strukturę bazy danych co w projekcie głównym.

### Opcja A: Przez Supabase Dashboard

1. W projekcie testowym, idź do **SQL Editor**
2. Skopiuj wszystkie SQL z `supabase/migrations/` z głównego projektu
3. Wykonaj je po kolei (w kolejności timestampów)

### Opcja B: Przez Supabase CLI (zalecane)

```bash
# Zainstaluj Supabase CLI jeśli nie masz
npm install -g supabase

# Link do projektu testowego
supabase link --project-ref <TEST_PROJECT_REF>

# Push migracji
supabase db push
```

## Krok 3: Skonfiguruj Row Level Security (RLS)

Upewnij się, że wszystkie tabele mają włączony RLS i policies:

```sql
-- W SQL Editor wykonaj:

-- Włącz RLS na wszystkich tabelach
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions ENABLE ROW LEVEL SECURITY;

-- Policy dla profiles (każdy user widzi tylko swój profil)
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Policy dla books (każdy user widzi tylko swoje książki)
CREATE POLICY "Users can view own books" ON books
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own books" ON books
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own books" ON books
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own books" ON books
  FOR DELETE USING (auth.uid() = user_id);

-- Policy dla reading_sessions
CREATE POLICY "Users can view own sessions" ON reading_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON reading_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy dla genres (public read)
CREATE POLICY "Anyone can view genres" ON genres
  FOR SELECT USING (true);
```

## Krok 4: Seed Genres (jeśli potrzebne)

Dodaj podstawowe gatunki literackie:

```sql
INSERT INTO genres (name) VALUES
  ('Fantasy'),
  ('Science Fiction'),
  ('Thriller'),
  ('Romance'),
  ('Mystery'),
  ('Historical Fiction'),
  ('Non-Fiction'),
  ('Biography')
ON CONFLICT (name) DO NOTHING;
```

## Krok 5: Skonfiguruj Auth Settings

1. W dashboardzie Supabase, idź do **Authentication → Settings**
2. **Email Auth:**
   - ✅ Enable Email provider
   - ✅ Confirm email: **DISABLED** (dla testów!)
   - ⚠️ W produkcji ZAWSZE włączaj potwierdzenie email

3. **Email Templates:**
   - Możesz zostawić defaultowe (nie będą używane w testach)

4. **URL Configuration:**
   - Site URL: `http://localhost`
   - Redirect URLs: `http://localhost`

## Krok 6: Pobierz Credentials

W dashboardzie, idź do **Settings → API**:

1. **Project URL:** 
   ```
   https://xxxxxxxxxxxxx.supabase.co
   ```
   
2. **Anon Public Key:**
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh...
   ```

3. **Service Role Key (OPCJONALNIE):**
   - Potrzebny tylko do usuwania userów w cleanup
   - ⚠️ **NIGDY** nie commituj do git!

## Krok 7: Konfiguracja w Projekcie

### Lokalnie (.env)

Stwórz lub edytuj plik `.env`:

```env
# Development/Production
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...

# Test Environment
SUPABASE_TEST_URL=https://your-test-project.supabase.co
SUPABASE_TEST_ANON_KEY=eyJhbGc...

# Optional: Service role for cleanup
SUPABASE_TEST_SERVICE_ROLE_KEY=eyJhbGc...
```

### GitHub Secrets

W repozytorium GitHub:
1. Idź do **Settings → Secrets and variables → Actions**
2. Kliknij **"New repository secret"**
3. Dodaj:

| Name | Value |
|------|-------|
| `SUPABASE_TEST_URL` | `https://xxxxx.supabase.co` |
| `SUPABASE_TEST_ANON_KEY` | `eyJhbGc...` |

## Krok 8: Weryfikacja Setup

### Test 1: Sprawdź połączenie

```bash
# Zainstaluj dependencies
flutter pub get

# Uruchom prosty test połączenia
flutter test integration_test/smoke/critical_path_test.dart \
  --dart-define=SUPABASE_TEST_URL=$SUPABASE_TEST_URL \
  --dart-define=SUPABASE_TEST_ANON_KEY=$SUPABASE_TEST_ANON_KEY
```

### Test 2: Sprawdź RLS Policies

W Supabase SQL Editor:

```sql
-- Test jako anonimowy użytkownik
SET ROLE anon;

-- To powinno zwrócić 0 (nie widzisz cudzych danych)
SELECT COUNT(*) FROM books;

-- Reset
RESET ROLE;
```

## Maintenance Test Environment

### Czyszczenie Danych (Regularnie)

Testowe dane mogą się kumulować jeśli cleanup failuje. Co tydzień:

```sql
-- ⚠️ TYLKO W TEST ENVIRONMENT!

-- Usuń wszystkie reading sessions
DELETE FROM reading_sessions;

-- Usuń wszystkie books
DELETE FROM books;

-- Usuń wszystkie profiles (oprócz admin)
DELETE FROM profiles WHERE email LIKE '%@e2etest.com';

-- W Authentication → Users, możesz ręcznie usunąć starych userów
```

### Monitoring

Śledź te metryki:
- **Liczba userów:** Nie powinna przekraczać ~50 (cleanup działa)
- **Liczba books:** Powinna być bliska 0 między testami
- **Database size:** < 100MB

## Troubleshooting

### Problem: "relation does not exist"
**Przyczyna:** Migracje nie zostały wykonane
**Rozwiązanie:** Powtórz Krok 2

### Problem: "new row violates RLS policy"
**Przyczyna:** RLS policies są zbyt restrykcyjne lub błędne
**Rozwiązanie:** Sprawdź Krok 3, upewnij się że policies używają `auth.uid()`

### Problem: "JWT expired"
**Przyczyna:** Stary anon key
**Rozwiązanie:** Pobierz świeży key z Settings → API

### Problem: "Too many users created"
**Przyczyna:** Cleanup nie działa
**Rozwiązanie:** 
1. Ręcznie usuń userów w Dashboard
2. Sprawdź czy `TestDataHelper.cleanupTestUser()` jest wywoływany w `tearDown()`

## Security Checklist

- [ ] Test environment jest osobnym projektem
- [ ] Test credentials NIE SĄ w git
- [ ] Confirm email jest WYŁĄCZONY (tylko w test!)
- [ ] RLS policies są włączone na wszystkich tabelach
- [ ] Service role key (jeśli używany) jest w GitHub Secrets, nie w kodzie

## Dodatkowe Zasoby

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli)
- [Flutter Integration Test Guide](https://docs.flutter.dev/testing/integration-tests)

---

**Potrzebujesz pomocy?** Otwórz Issue na GitHub z tagiem `[Test Environment]`

**Ostatnia aktualizacja:** 21 października 2025

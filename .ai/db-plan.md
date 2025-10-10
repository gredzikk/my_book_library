# Schemat Bazy Danych PostgreSQL - My Book Library

## 1. Lista Tabel

### 1.1. Tabela `genres`
Przechowuje listę gatunków literackich dostępnych w aplikacji.

| Kolumna | Typ Danych | Ograniczenia | Opis |
|---------|-----------|--------------|------|
| `id` | `UUID` | `PRIMARY KEY, DEFAULT gen_random_uuid()` | Unikalny identyfikator gatunku |
| `name` | `TEXT` | `NOT NULL, UNIQUE` | Nazwa gatunku (np. "Fantastyka", "Kryminał") |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT NOW()` | Data utworzenia rekordu |

**Wartości początkowe:**
- Fantastyka
- Science Fiction
- Kryminał
- Thriller
- Romans
- Horror
- Literatura faktu
- Biografia
- Poradnik
- Poezja
- Klasyka

---

### 1.2. Tabela `books`
Główna tabela przechowująca informacje o książkach użytkowników.

| Kolumna | Typ Danych | Ograniczenia | Opis |
|---------|-----------|--------------|------|
| `id` | `UUID` | `PRIMARY KEY, DEFAULT gen_random_uuid()` | Unikalny identyfikator książki |
| `user_id` | `UUID` | `NOT NULL, REFERENCES auth.users(id) ON DELETE CASCADE` | Identyfikator właściciela książki |
| `genre_id` | `UUID` | `REFERENCES genres(id) ON DELETE SET NULL` | Identyfikator gatunku książki |
| `title` | `TEXT` | `NOT NULL` | Tytuł książki |
| `author` | `TEXT` | `NOT NULL` | Autor książki |
| `page_count` | `INTEGER` | `NOT NULL, CHECK (page_count > 0)` | Całkowita liczba stron w książce |
| `cover_url` | `TEXT` | | URL do okładki książki (pobrane z Google Books API) |
| `isbn` | `TEXT` | | Numer ISBN książki |
| `publisher` | `TEXT` | | Wydawnictwo |
| `publication_year` | `INTEGER` | `CHECK (publication_year > 1000 AND publication_year <= EXTRACT(YEAR FROM NOW()))` | Rok wydania książki |
| `status` | `book_status` | `NOT NULL, DEFAULT 'unread'` | Status czytania książki (ENUM) |
| `last_read_page_number` | `INTEGER` | `NOT NULL, DEFAULT 0, CHECK (last_read_page_number >= 0)` | Numer ostatniej przeczytanej strony |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT NOW()` | Data dodania książki do biblioteki |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT NOW()` | Data ostatniej modyfikacji rekordu |

**Typ ENUM `book_status`:**
```sql
CREATE TYPE book_status AS ENUM (
  'unread',       -- Nieprzeczytane
  'in_progress',  -- W trakcie
  'finished',     -- Przeczytane
  'abandoned',    -- Porzucona (poza MVP)
  'planned'       -- Planowana do przeczytania (poza MVP)
);
```

**Ograniczenia dodatkowe:**
- `CHECK (last_read_page_number <= page_count)` - numer ostatniej przeczytanej strony nie może przekraczać całkowitej liczby stron

---

### 1.3. Tabela `reading_sessions`
Przechowuje historię wszystkich sesji czytania dla każdej książki.

| Kolumna | Typ Danych | Ograniczenia | Opis |
|---------|-----------|--------------|------|
| `id` | `UUID` | `PRIMARY KEY, DEFAULT gen_random_uuid()` | Unikalny identyfikator sesji |
| `user_id` | `UUID` | `NOT NULL, REFERENCES auth.users(id) ON DELETE CASCADE` | Identyfikator użytkownika prowadzącego sesję |
| `book_id` | `UUID` | `NOT NULL, REFERENCES books(id) ON DELETE CASCADE` | Identyfikator książki, której dotyczy sesja |
| `start_time` | `TIMESTAMPTZ` | `NOT NULL` | Czas rozpoczęcia sesji czytania |
| `end_time` | `TIMESTAMPTZ` | `NOT NULL` | Czas zakończenia sesji czytania |
| `duration_minutes` | `INTEGER` | `NOT NULL, CHECK (duration_minutes >= 0)` | Czas trwania sesji w minutach |
| `pages_read` | `INTEGER` | `NOT NULL, CHECK (pages_read > 0)` | Liczba stron przeczytanych podczas sesji |
| `last_read_page_number` | `INTEGER` | `NOT NULL, CHECK (last_read_page_number > 0)` | Numer ostatniej strony przeczytanej w tej sesji |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL, DEFAULT NOW()` | Data utworzenia rekordu |

**Ograniczenia dodatkowe:**
- `CHECK (end_time > start_time)` - czas zakończenia musi być późniejszy niż czas rozpoczęcia
- `CHECK (pages_read > 0)` - sesja musi obejmować co najmniej jedną przeczytaną stronę

---

### 1.4. Tabela `auth.users`
Tabela zarządzana przez Supabase Auth (nie tworzymy jej ręcznie). Przechowuje dane uwierzytelniające użytkowników.

**Kluczowe kolumny wykorzystywane w aplikacji:**
- `id` (UUID) - unikalny identyfikator użytkownika
- `email` (TEXT) - adres e-mail użytkownika
- `created_at` (TIMESTAMPTZ) - data rejestracji konta

---

## 2. Relacje między Tabelami

### 2.1. Relacja `auth.users` ↔ `books`
**Typ:** Jeden-do-wielu (One-to-Many)
- Jeden użytkownik może mieć wiele książek w swojej bibliotece
- Każda książka należy do dokładnie jednego użytkownika
- **Klucz obcy:** `books.user_id` → `auth.users.id`
- **Reguła CASCADE:** `ON DELETE CASCADE` - usunięcie użytkownika powoduje automatyczne usunięcie wszystkich jego książek

### 2.2. Relacja `genres` ↔ `books`
**Typ:** Jeden-do-wielu (One-to-Many)
- Jeden gatunek może być przypisany do wielu książek
- Każda książka może mieć przypisany maksymalnie jeden gatunek (opcjonalnie)
- **Klucz obcy:** `books.genre_id` → `genres.id`
- **Reguła SET NULL:** `ON DELETE SET NULL` - usunięcie gatunku nie usuwa książek, tylko zeruje pole `genre_id`

### 2.3. Relacja `books` ↔ `reading_sessions`
**Typ:** Jeden-do-wielu (One-to-Many)
- Jedna książka może mieć wiele sesji czytania
- Każda sesja czytania dotyczy dokładnie jednej książki
- **Klucz obcy:** `reading_sessions.book_id` → `books.id`
- **Reguła CASCADE:** `ON DELETE CASCADE` - usunięcie książki automatycznie usuwa wszystkie powiązane sesje czytania

### 2.4. Relacja `auth.users` ↔ `reading_sessions`
**Typ:** Jeden-do-wielu (One-to-Many)
- Jeden użytkownik może mieć wiele sesji czytania
- Każda sesja czytania należy do dokładnie jednego użytkownika
- **Klucz obcy:** `reading_sessions.user_id` → `auth.users.id`
- **Reguła CASCADE:** `ON DELETE CASCADE` - usunięcie użytkownika usuwa wszystkie jego sesje

---

## 3. Indeksy

Indeksy zostały zaprojektowane w celu optymalizacji najczęstszych zapytań w aplikacji.

### 3.1. Indeksy w tabeli `books`

```sql
-- Indeks na user_id - dla szybkiego pobierania książek danego użytkownika
CREATE INDEX idx_books_user_id ON books(user_id);

-- Indeks złożony na (user_id, status) - dla filtrowania książek po statusie
CREATE INDEX idx_books_user_status ON books(user_id, status);

-- Indeks na genre_id - dla szybkiego filtrowania książek po gatunku
CREATE INDEX idx_books_genre_id ON books(genre_id);

-- Indeks na isbn - dla szybkiego wyszukiwania książek po numerze ISBN
CREATE INDEX idx_books_isbn ON books(isbn) WHERE isbn IS NOT NULL;
```

**Uzasadnienie:**
- `idx_books_user_id` - każde zapytanie o listę książek filtruje po `user_id`
- `idx_books_user_status` - często używane filtrowanie po statusie książki (np. pokazanie tylko książek "W trakcie")
- `idx_books_genre_id` - filtrowanie biblioteki po gatunku (funkcja z PRD)
- `idx_books_isbn` - sprawdzanie, czy książka z danym ISBN już istnieje w bibliotece użytkownika

### 3.2. Indeksy w tabeli `reading_sessions`

```sql
-- Indeks na book_id - dla szybkiego pobierania historii sesji danej książki
CREATE INDEX idx_reading_sessions_book_id ON reading_sessions(book_id);

-- Indeks na user_id - dla szybkiego pobierania wszystkich sesji użytkownika
CREATE INDEX idx_reading_sessions_user_id ON reading_sessions(user_id);

-- Indeks na (book_id, created_at DESC) - dla sortowania sesji chronologicznie
CREATE INDEX idx_reading_sessions_book_created ON reading_sessions(book_id, created_at DESC);

-- Indeks na end_time - dla zapytań analitycznych (np. sesje w danym przedziale czasu)
CREATE INDEX idx_reading_sessions_end_time ON reading_sessions(end_time);
```

**Uzasadnienie:**
- `idx_reading_sessions_book_id` - wyświetlanie historii sesji dla konkretnej książki
- `idx_reading_sessions_user_id` - obliczanie statystyk użytkownika (np. tygodniowe zaangażowanie)
- `idx_reading_sessions_book_created` - sortowanie sesji od najnowszej do najstarszej
- `idx_reading_sessions_end_time` - przyszłe zapytania analityczne o sesje w określonym okresie

### 3.3. Indeksy w tabeli `genres`

```sql
-- Unikalny indeks na name - zapewnia brak duplikatów nazw gatunków
CREATE UNIQUE INDEX idx_genres_name ON genres(name);
```

**Uwaga:** Indeks ten jest automatycznie tworzony przez ograniczenie `UNIQUE` na kolumnie `name`.

---

## 4. Zasady PostgreSQL (Row Level Security - RLS)

Zabezpieczenia na poziomie wiersza (RLS) zapewniają, że użytkownicy mają dostęp wyłącznie do swoich własnych danych.

### 4.1. Włączenie RLS dla tabel

```sql
-- Włączenie RLS dla tabeli books
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- Włączenie RLS dla tabeli reading_sessions
ALTER TABLE reading_sessions ENABLE ROW LEVEL SECURITY;

-- Włączenie RLS dla tabeli genres
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
```

---

### 4.2. Polityki RLS dla tabeli `books`

#### Polityka SELECT (odczyt)
```sql
CREATE POLICY "Users can view their own books"
  ON books
  FOR SELECT
  USING (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą przeglądać tylko te książki, których są właścicielami.

#### Polityka INSERT (dodawanie)
```sql
CREATE POLICY "Users can insert their own books"
  ON books
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą dodawać nowe książki wyłącznie do swojej biblioteki.

#### Polityka UPDATE (edycja)
```sql
CREATE POLICY "Users can update their own books"
  ON books
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą edytować wyłącznie swoje własne książki.

#### Polityka DELETE (usuwanie)
```sql
CREATE POLICY "Users can delete their own books"
  ON books
  FOR DELETE
  USING (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą usuwać wyłącznie swoje własne książki.

---

### 4.3. Polityki RLS dla tabeli `reading_sessions`

#### Polityka SELECT (odczyt)
```sql
CREATE POLICY "Users can view their own reading sessions"
  ON reading_sessions
  FOR SELECT
  USING (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą przeglądać tylko swoje własne sesje czytania.

#### Polityka INSERT (dodawanie)
```sql
CREATE POLICY "Users can insert their own reading sessions"
  ON reading_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą dodawać sesje czytania tylko dla swoich książek.

#### Polityka UPDATE (edycja)
```sql
CREATE POLICY "Users can update their own reading sessions"
  ON reading_sessions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą edytować wyłącznie swoje własne sesje czytania.

#### Polityka DELETE (usuwanie)
```sql
CREATE POLICY "Users can delete their own reading sessions"
  ON reading_sessions
  FOR DELETE
  USING (auth.uid() = user_id);
```
**Opis:** Użytkownicy mogą usuwać wyłącznie swoje własne sesje czytania.

---

### 4.4. Polityki RLS dla tabeli `genres`

#### Polityka SELECT (odczyt)
```sql
CREATE POLICY "Anyone authenticated can view genres"
  ON genres
  FOR SELECT
  USING (auth.role() = 'authenticated');
```
**Opis:** Wszyscy uwierzytelnieni użytkownicy mogą przeglądać listę gatunków (dane publiczne w ramach aplikacji).

#### Polityki INSERT/UPDATE/DELETE
Tabela `genres` jest tylko do odczytu dla użytkowników aplikacji. Operacje zapisu są zarezerwowane dla administratorów bazy danych.

```sql
-- Brak polityk INSERT, UPDATE, DELETE dla zwykłych użytkowników
-- Tylko administratorzy mogą zarządzać gatunkami za pomocą narzędzi administracyjnych
```

---

## 5. Triggery i Funkcje

### 5.1. Automatyczna aktualizacja `updated_at` w tabeli `books`

```sql
-- Funkcja do aktualizacji kolumny updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger wywołujący funkcję przed każdą aktualizacją rekordu
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON books
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Opis:** Automatycznie aktualizuje znacznik czasu `updated_at` w tabeli `books` przy każdej modyfikacji rekordu.

---

### 5.2. Automatyczna walidacja `last_read_page_number` vs `page_count` (opcjonalnie)

Chociaż decyzja była, aby logikę biznesową implementować w aplikacji, można dodać dodatkową walidację na poziomie bazy danych:

```sql
-- Constraint sprawdzający spójność last_read_page_number
ALTER TABLE books
  ADD CONSTRAINT check_last_read_page_valid
  CHECK (last_read_page_number <= page_count);
```

**Opis:** Zapewnia, że numer ostatniej przeczytanej strony nie przekracza całkowitej liczby stron w książce.

---

## 6. Dodatkowe Uwagi i Decyzje Projektowe

### 6.1. Wybór typu UUID jako klucza głównego
**Uzasadnienie:**
- Lepsze bezpieczeństwo - niemożliwe do przewidzenia identyfikatory
- Możliwość generowania kluczy po stronie klienta przed wysłaniem do bazy
- Unikanie kolizji w systemach rozproszonych
- Zgodność z domyślnym typem używanym przez Supabase Auth

### 6.2. Użycie TIMESTAMPTZ zamiast TIMESTAMP
**Uzasadnienie:**
- `TIMESTAMPTZ` przechowuje znaczniki czasu wraz ze strefą czasową
- Umożliwia prawidłowe wyświetlanie czasu użytkownikom w różnych strefach czasowych
- Eliminuje problemy z czasem letnim/zimowym

### 6.3. Przechowywanie `duration_minutes` zamiast obliczania dynamicznie
**Uzasadnienie:**
- Uproszczone zapytania - nie trzeba za każdym razem obliczać różnicy między `start_time` a `end_time`
- Lepsza wydajność przy agregacjach (np. suma czasu czytania w tygodniu)
- Możliwość ręcznej korekty czasu trwania sesji (jeśli będzie taka potrzeba w przyszłości)

### 6.4. Osobna tabela `genres` zamiast ENUM
**Uzasadnienie:**
- Łatwiejsza rozbudowa - dodawanie nowych gatunków bez modyfikacji typu w bazie
- Możliwość przechowywania dodatkowych metadanych gatunków w przyszłości (np. ikona, opis)
- Ułatwienie przyszłej migracji do relacji wiele-do-wielu (książka może mieć wiele gatunków)
- Gatunki mogą być tłumaczone na różne języki (przyszłe wymaganie)

### 6.5. Brak pola `progress_percentage` w tabeli `books`
**Uzasadnienie:**
- Wartość procentowa jest obliczana dynamicznie: `(last_read_page_number / page_count) * 100`
- Unikanie redundancji danych i potencjalnych niespójności
- Zmniejszenie ryzyka błędów synchronizacji między `last_read_page_number` a `progress_percentage`

### 6.6. Pole `last_read_page_number` w obu tabelach
**Wyjaśnienie:**
- W tabeli `books`: przechowuje bieżący postęp czytania książki (stan aktualny)
- W tabeli `reading_sessions`: przechowuje stan po zakończeniu konkretnej sesji (dane historyczne)
- Pozwala na:
  - Szybkie odczytanie aktualnego postępu bez skanowania historii sesji
  - Pełną rekonstrukcję historii postępów czytania z tabeli sesji
  - Walidację spójności danych (ostatnia sesja powinna mieć `last_read_page_number` równy wartości w tabeli `books`)

### 6.7. Blokowanie edycji `page_count` dla książek "W trakcie"
**Implementacja:**
Ta logika będzie zaimplementowana w warstwie aplikacji (Flutter), a nie w bazie danych, ponieważ:
- Reguła biznesowa może się zmieniać
- Łatwiejsze testowanie i debugowanie
- Lepsza separacja warstw aplikacji

### 6.8. Strategia `ON DELETE CASCADE`
**Uzasadnienie:**
- Usunięcie użytkownika automatycznie usuwa wszystkie jego dane (zgodność z RODO)
- Usunięcie książki automatycznie usuwa wszystkie powiązane sesje czytania (integralność danych)
- Uproszczenie logiki aplikacji - nie trzeba ręcznie zarządzać usuwaniem powiązanych rekordów

### 6.9. Brak `soft delete`
**Decyzja:**
W wersji MVP nie implementujemy mechanizmu "miękkiego usuwania" (soft delete). Usunięte dane są trwale kasowane z bazy. Jeśli w przyszłości pojawi się potrzeba archiwizacji usuniętych danych, można dodać:
- Kolumnę `deleted_at` typu `TIMESTAMPTZ`
- Modyfikację polityk RLS, aby filtrować usunięte rekordy

### 6.10. Normalizacja bazy danych
**Poziom:** 3NF (Trzecia Postać Normalna)
- Wszystkie kolumny są atomowe
- Brak zależności częściowych (wszystkie atrybuty zależą od pełnego klucza głównego)
- Brak zależności przechodnich (np. `progress_percentage` nie jest przechowywany, ponieważ zależy od `last_read_page_number`)

### 6.11. Przyszła rozbudowa schematu (poza MVP)
Potencjalne rozszerzenia schematu w przyszłych iteracjach:
- Tabela `book_notes` - notatki i cytaty z książek
- Tabela `reading_goals` - cele czytelnicze (np. przeczytanie 50 książek w roku)
- Tabela `book_ratings` - oceny książek przez użytkowników
- Tabela `book_genres` (junction table) - relacja wiele-do-wielu między książkami a gatunkami
- Tabela `friendships` - relacje między użytkownikami (funkcje społecznościowe)
- Tabela `book_recommendations` - rekomendacje książek dla użytkowników
- Dodanie pól `description` i `language` w tabeli `books`

---

## 7. Skrypt SQL do Inicjalizacji Bazy Danych

Poniżej znajduje się kompletny skrypt SQL gotowy do wykonania w Supabase:

```sql
-- =====================================================
-- My Book Library - Database Schema
-- PostgreSQL + Supabase
-- =====================================================

-- 1. Utworzenie typu ENUM dla statusów książek
CREATE TYPE book_status AS ENUM (
  'unread',
  'in_progress',
  'finished',
  'abandoned',
  'planned'
);

-- 2. Utworzenie tabeli genres
CREATE TABLE genres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Wstawienie domyślnych gatunków
INSERT INTO genres (name) VALUES
  ('Fantastyka'),
  ('Science Fiction'),
  ('Kryminał'),
  ('Thriller'),
  ('Romans'),
  ('Horror'),
  ('Literatura faktu'),
  ('Biografia'),
  ('Poradnik'),
  ('Poezja'),
  ('Klasyka');

-- 3. Utworzenie tabeli books
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  genre_id UUID REFERENCES genres(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  page_count INTEGER NOT NULL CHECK (page_count > 0),
  cover_url TEXT,
  isbn TEXT,
  publisher TEXT,
  publication_year INTEGER CHECK (publication_year > 1000 AND publication_year <= EXTRACT(YEAR FROM NOW())),
  status book_status NOT NULL DEFAULT 'unread',
  last_read_page_number INTEGER NOT NULL DEFAULT 0 CHECK (last_read_page_number >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT check_last_read_page_valid CHECK (last_read_page_number <= page_count)
);

-- 4. Utworzenie tabeli reading_sessions
CREATE TABLE reading_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes >= 0),
  pages_read INTEGER NOT NULL CHECK (pages_read > 0),
  last_read_page_number INTEGER NOT NULL CHECK (last_read_page_number > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT check_end_after_start CHECK (end_time > start_time)
);

-- 5. Utworzenie indeksów
-- Indeksy dla tabeli books
CREATE INDEX idx_books_user_id ON books(user_id);
CREATE INDEX idx_books_user_status ON books(user_id, status);
CREATE INDEX idx_books_genre_id ON books(genre_id);
CREATE INDEX idx_books_isbn ON books(isbn) WHERE isbn IS NOT NULL;

-- Indeksy dla tabeli reading_sessions
CREATE INDEX idx_reading_sessions_book_id ON reading_sessions(book_id);
CREATE INDEX idx_reading_sessions_user_id ON reading_sessions(user_id);
CREATE INDEX idx_reading_sessions_book_created ON reading_sessions(book_id, created_at DESC);
CREATE INDEX idx_reading_sessions_end_time ON reading_sessions(end_time);

-- 6. Utworzenie funkcji i triggerów
-- Funkcja do automatycznej aktualizacji updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger dla tabeli books
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON books
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 7. Włączenie Row Level Security (RLS)
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;

-- 8. Utworzenie polityk RLS dla tabeli books
CREATE POLICY "Users can view their own books"
  ON books FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own books"
  ON books FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own books"
  ON books FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own books"
  ON books FOR DELETE
  USING (auth.uid() = user_id);

-- 9. Utworzenie polityk RLS dla tabeli reading_sessions
CREATE POLICY "Users can view their own reading sessions"
  ON reading_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reading sessions"
  ON reading_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reading sessions"
  ON reading_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reading sessions"
  ON reading_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- 10. Utworzenie polityk RLS dla tabeli genres
CREATE POLICY "Anyone authenticated can view genres"
  ON genres FOR SELECT
  USING (auth.role() = 'authenticated');

-- =====================================================
-- Koniec skryptu inicjalizacyjnego
-- =====================================================
```

---

## 8. Diagramy

### 8.1. Diagram ERD (Entity Relationship Diagram)

```
┌─────────────────┐
│   auth.users    │
│  (Supabase)     │
├─────────────────┤
│ id (PK)         │
│ email           │
│ created_at      │
└────────┬────────┘
         │
         │ 1:N
         │
    ┌────▼──────────────────────────────┐
    │                                   │
┌───▼─────────────┐            ┌───────▼──────────────┐
│     books       │            │  reading_sessions    │
├─────────────────┤            ├──────────────────────┤
│ id (PK)         │ 1:N        │ id (PK)              │
│ user_id (FK)    ├───────────►│ user_id (FK)         │
│ genre_id (FK)   │            │ book_id (FK)         │
│ title           │            │ start_time           │
│ author          │            │ end_time             │
│ page_count      │            │ duration_minutes     │
│ cover_url       │            │ pages_read           │
│ isbn            │            │ last_read_page_number│
│ publisher       │            │ created_at           │
│ publication_year│            └──────────────────────┘
│ status          │
│ last_read_page_number
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │
         │ N:1
         │
┌────────▼────────┐
│     genres      │
├─────────────────┤
│ id (PK)         │
│ name (UNIQUE)   │
│ created_at      │
└─────────────────┘
```

### 8.2. Opis relacji:
- **auth.users → books**: Jeden użytkownik może mieć wiele książek
- **auth.users → reading_sessions**: Jeden użytkownik może mieć wiele sesji czytania
- **books → reading_sessions**: Jedna książka może mieć wiele sesji czytania
- **genres → books**: Jeden gatunek może być przypisany do wielu książek

---

## Podsumowanie

Schemat bazy danych został zaprojektowany z myślą o:
- **Bezpieczeństwie**: RLS zapewnia, że użytkownicy mają dostęp tylko do swoich danych
- **Wydajności**: Indeksy na kluczowych kolumnach przyspieszają najczęstsze zapytania
- **Integralności**: Klucze obce i ograniczenia CHECK zapobiegają niespójnościom danych
- **Skalowalności**: Struktura pozwala na łatwą rozbudowę o nowe funkcje
- **Zgodności z PRD**: Wszystkie wymagania funkcjonalne z dokumentu PRD są obsługiwane

Schemat jest gotowy do implementacji w Supabase i stanowi solidną podstawę dla MVP aplikacji My Book Library.

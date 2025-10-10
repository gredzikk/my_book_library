<conversation_summary>
<decisions>
1. Zostanie utworzona osobna tabela `genres` na potrzeby przechowywania gatunków książek.
2. Na potrzeby MVP, książka będzie mogła mieć przypisany tylko jeden gatunek (relacja jeden-do-wielu między gatunkami a książkami).
3. Typ danych `ENUM` dla statusu książki będzie zawierał wartości: `unread`, `in_progress`, `finished`, `abandoned`, `planned`.
4. Tabela `reading_sessions` będzie przechowywać `start_time`, `end_time`, `duration_minutes` (czas trwania w minutach) oraz `last_read_page_number`.
5. Zostaną zaimplementowane zasady bezpieczeństwa na poziomie wiersza (RLS): użytkownicy mają pełny dostęp (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) tylko do swoich książek i sesji. Tabela `genres` jest publicznie dostępna do odczytu dla wszystkich uwierzytelnionych użytkowników.
6. Zostaną utworzone indeksy w tabeli `books` na kolumnach `user_id` oraz `(user_id, status)`, a w tabeli `reading_sessions` na `book_id` oraz `user_id`.
7. Logika biznesowa, taka jak blokowanie edycji liczby stron czy walidacja numeru ostatniej przeczytanej strony, zostanie zaimplementowana w warstwie aplikacji, a nie w bazie danych.
8. Procentowy postęp czytania nie będzie przechowywany w bazie danych; będzie obliczany dynamicznie w aplikacji.
9. Domyślnym statusem dla nowo dodanej książki będzie `unread`, a domyślna wartość dla `last_read_page_number` to `0`.
10. Kluczowe kolumny w tabelach (`user_id`, `title`, `author`, `page_count`, `status` w `books` oraz `user_id`, `book_id`, `start_time`, `end_time`, `duration_minutes`, `pages_read` w `reading_sessions`) będą miały ograniczenie `NOT NULL`.
11. Relacja między tabelą `books` a `reading_sessions` będzie miała zdefiniowaną regułę `ON DELETE CASCADE`, co oznacza, że usunięcie książki spowoduje automatyczne usunięcie wszystkich powiązanych z nią sesji.
</decisions>

<matched_recommendations>
1. Utworzenie osobnej tabeli `genres` w celu ułatwienia przyszłej rozbudowy do relacji wiele-do-wielu.
2. Zastosowanie niestandardowego typu `ENUM` w PostgreSQL dla statusów książek w celu zapewnienia spójności i wydajności danych.
3. Jawne przechowywanie czasu rozpoczęcia (`start_time`), zakończenia (`end_time`) i czasu trwania (`duration_minutes`) w tabeli `reading_sessions` w celu uproszczenia zapytań.
4. Zaimplementowanie polityk RLS w celu zapewnienia, że użytkownicy mogą uzyskać dostęp tylko do swoich danych.
5. Utworzenie indeksów na kluczach obcych i często filtrowanych kolumnach w celu optymalizacji wydajności zapytań.
6. Zastosowanie `ON DELETE CASCADE` w kluczach obcych w celu zachowania integralności referencyjnej danych.
7. Zdefiniowanie ograniczeń `NOT NULL` dla kluczowych atrybutów w celu zapewnienia kompletności danych.
8. Ustawienie wartości domyślnych dla statusu książki i ostatniej przeczytanej strony w celu uproszczenia logiki aplikacji.
</matched_recommendations>

<database_planning_summary>
Na podstawie analizy wymagań produktu (PRD) i przeprowadzonej dyskusji, schemat bazy danych PostgreSQL dla MVP aplikacji "My Book Library" został zaplanowany w następujący sposób:

**Kluczowe Encje i Relacje:**
1.  **`users`**: Encja dostarczana przez Supabase Auth, przechowująca dane uwierzytelniające. Jest niejawnie powiązana z innymi tabelami poprzez `user_id`.
2.  **`genres`**: Tabela przechowująca unikalne nazwy gatunków literackich.
3.  **`books`**: Główna tabela przechowująca informacje o książkach.
    *   Relacja **jeden-do-wielu** z tabelą `users` (jeden użytkownik może mieć wiele książek).
    *   Relacja **wiele-do-jednego** z tabelą `genres` (wiele książek może należeć do jednego gatunku).
4.  **`reading_sessions`**: Tabela przechowująca historię sesji czytelniczych dla każdej książki.
    *   Relacja **wiele-do-jednego** z tabelą `books` (jedna książka może mieć wiele sesji czytelniczych).
    *   Relacja **jeden-do-wielu** z tabelą `users` (jeden użytkownik może mieć wiele sesji).

**Schemat i Typy Danych:**
*   **Tabela `genres`**: `id` (klucz główny), `name` (unikalny, `text`, `NOT NULL`).
*   **Tabela `books`**: `id` (klucz główny), `user_id` (klucz obcy do `auth.users`, `NOT NULL`), `genre_id` (klucz obcy do `genres`), `title` (`text`, `NOT NULL`), `author` (`text`, `NOT NULL`), `page_count` (`integer`, `NOT NULL`), `cover_url` (`text`), `isbn` (`text`), `status` (typ `book_status` `ENUM`, `NOT NULL`, domyślnie `'unread'`), `last_read_page_number` (`integer`, domyślnie `0`).
*   **Tabela `reading_sessions`**: `id` (klucz główny), `user_id` (klucz obcy, `NOT NULL`), `book_id` (klucz obcy do `books` z `ON DELETE CASCADE`, `NOT NULL`), `start_time` (`timestamptz`, `NOT NULL`), `end_time` (`timestamptz`, `NOT NULL`), `duration_minutes` (`integer`, `NOT NULL`), `pages_read` (`integer`, `NOT NULL`).
*   **Typ `book_status`**: `CREATE TYPE book_status AS ENUM ('unread', 'in_progress', 'finished', 'abandoned', 'planned');`

**Bezpieczeństwo i Skalowalność:**
*   **Bezpieczeństwo**: Dostęp do danych będzie chroniony za pomocą RLS na poziomie bazy danych. Użytkownicy będą mogli operować wyłącznie na swoich danych, co jest realizowane przez polityki sprawdzające `user_id = auth.uid()`. Tabela `genres` będzie publicznie dostępna do odczytu.
*   **Wydajność**: W celu optymalizacji zapytań zostaną utworzone indeksy na kolumnach `user_id` i `status` w tabeli `books` oraz `book_id` i `user_id` w tabeli `reading_sessions`.

**Integralność Danych:**
*   Integralność danych będzie zapewniona przez użycie kluczy obcych, ograniczeń `NOT NULL` oraz reguły `ON DELETE CASCADE` dla sesji czytelniczych, co zapobiegnie pozostawianiu osieroconych rekordów.
</database_planning_summary>

<unresolved_issues>
Brak nierozwiązanych kwestii. Plan bazy danych jest kompletny i gotowy do implementacji w postaci skryptu SQL dla MVP.
</unresolved_issues>
</conversation_summary>

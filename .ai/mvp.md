## Główny problem

Użytkownicy posiadający fizyczne i cyfrowe książki potrzebują scentralizowanego i prostego narzędzia do zarządzania swoją kolekcją, śledzenia postępów w czytaniu oraz wizualizacji swoich nawyków czytelniczych.

## Najmniejszy zestaw funkcjonalności

- Rejestracja i logowanie użytkownika (za pomocą Supabase/Firebase Auth).
- Dodawanie książki ręcznie (tytuł, autor).
- Dodawanie książki poprzez skanowanie kodu ISBN lub ręczne wpisanie ISBN, wykorzystując Google Books API do pobrania metadanych.
- Wyświetlanie listy wszystkich posiadanych książek.
- Możliwość zmiany statusu książki (do wyboru tylko: Nieprzeczytane, W trakcie, Przeczytane).
- Edycja i usuwanie pozycji.
- Możliwość rozpoczęcia i zakończenia sesji czytania dla książki o statusie "W trakcie".
- Rejestracja czasu trwania sesji (start/stop) oraz liczby przeczytanych stron na koniec sesji.
- Wyświetlanie historii sesji dla danej książki.
- Ostateczna wersja PRD i Specyfikacji Technicznej.
- Co najmniej jeden test integracyjny (np. sprawdzenie procesu Logowanie -> Dodanie książki).
- Skonfigurowany Pipeline CI/CD (budowanie i uruchamianie testów na platformie CI).

## Co NIE wchodzi w zakres MVP

- Udawanie znajomych i ich zarządzanie.
- Udostępnianie sesji czytania w trybie "live".
- Ustawienia prywatności (wszystko jest domyślnie prywatne w MVP).
- Lista życzeń (Wishlist).
- Zaawansowane statusy (np. Porzucone, licznik Ile razy przeczytano).
- Dodawanie notatek/uwag do sesji.
- Zaawansowane statystyki i wykresy.
- rekomendacje AI
- powiadomienia przypominające o czytaniu danego dnia lub serii
- Publiczne wdrożenie pod URL (powinno być zrobione w fazie II, aby uzyskać wyróżnienie, ale nie jest w MVP dla zaliczenia).

## Kryteria sukcesu

- 90% użytkowników ma wypełnione preferencje gatunkowe w swoim profilu
- 90% użytkowników czyta co najmniej jedną książkę miesięcznie
- 50% użytkowników tworzy społeczności wokół gatunku/serii/autora

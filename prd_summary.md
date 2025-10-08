<conversation_summary>
<decisions>
1.  **Platforma:** MVP będzie rozwijane wyłącznie na platformę Android.
2.  **Onboarding:** Aplikacja będzie zawierać krótki onboarding, który zaprezentuje kluczowe funkcje: dodawanie książki, rozpoczynanie sesji czytania i zmianę statusu książki.
3.  **Dodawanie książki:** Wymagane pola do manualnego dodania książki to autor, tytuł i ilość stron. Gatunek jest pobierany z Google Books API; jeśli go brakuje, użytkownik może wybrać go z predefiniowanej listy.
4.  **Obsługa API:** W przypadku, gdy Google Books API nie zwróci danych dla podanego numeru ISBN, aplikacja wyświetli stosowny komunikat i przekieruje użytkownika do ekranu edycji, aby mógł uzupełnić dane ręcznie.
5.  **Status książki:** Domyślnym statusem dla nowo dodanej książki jest "Nieprzeczytane". Status zmienia się na "Przeczytane" automatycznie, gdy suma przeczytanych stron osiągnie całkowitą liczbę stron książki. Dodany zostanie również przycisk "całość", pozwalający na natychmiastowe oznaczenie książki jako przeczytanej z podaniem daty.
6.  **Edycja książki:** Możliwość edycji całkowitej liczby stron zostanie zablokowana dla książek, które mają status "W trakcie".
7.  **Sesje czytania:** Sesja jest rozpoczynana i kończona przez dedykowany przycisk. Czas trwania jest obliczany na podstawie różnicy między czasem zakończenia i rozpoczęcia. Zamknięcie aplikacji nie przerywa sesji. Po godzinie od zamknięcia aplikacji z aktywną sesją, wysyłane jest powiadomienie; kliknięcie go przenosi z powrotem do ekranu sesji. Sesje z zerową liczbą przeczytanych stron nie są zapisywane w historii.
8.  **Historia sesji:** Widok historii dla danej książki będzie zawierał datę zakończenia sesji, jej czas trwania oraz liczbę przeczytanych stron.
9.  **Główny ekran (Lista książek):** Książki będą wyświetlane w widoku kafelkowym (grid). Każdy kafelek będzie zawierał okładkę jako tło, tytuł książki oraz (dla książek "W trakcie") procentowy wskaźnik postępu. Lista będzie sortowana alfabetycznie z możliwością filtrowania po statusie i gatunku.
10. **Usuwanie książki:** Proces usuwania książki z biblioteki będzie wymagał od użytkownika dodatkowego potwierdzenia.
11. **Testy:** Zostaną przygotowane dwa osobne scenariusze testu integracyjnego: jeden dla dodawania książki manualnie, drugi dla dodawania przez ISBN API.
</decisions>

<matched_recommendations>
1.  Skupienie się na jednej platformie (Android) w celu szybszego wdrożenia i zebrania opinii zwrotnych w ramach MVP.
2.  Wprowadzenie krótkiego, interaktywnego onboardingu skupionego na kluczowych akcjach użytkownika.
3.  Zapewnienie płynnego przejścia do ręcznego formularza w przypadku, gdy API nie zwróci danych, aby nie blokować użytkownika.
4.  Wprowadzenie walidacji uniemożliwiającej zapisanie sesji z zerową liczbą przeczytanych stron.
5.  Automatyzacja zmiany statusu książki na "Przeczytane" po osiągnięciu ostatniej strony, z dodatkowym monitem gratulacyjnym.
6.  Zablokowanie edycji kluczowych danych (liczba stron) po rozpoczęciu śledzenia postępów w celu zapewnienia integralności danych.
7.  Zastosowanie widoku siatki (kafelków) z okładkami i wskaźnikami postępu w celu stworzenia atrakcyjnego wizualnie i informacyjnego interfejsu.
8.  Wymaganie od użytkownika potwierdzenia przed usunięciem książki, aby zapobiec przypadkowej utracie danych o postępach.
9.  Stworzenie dwóch oddzielnych scenariuszy testów integracyjnych w celu dokładnego przetestowania obu ścieżek dodawania książek.
10. Wyświetlanie kluczowych informacji w historii sesji: daty, czasu trwania i liczby przeczytanych stron.
</matched_recommendations>

<prd_planning_summary>
### a. Główne wymagania funkcjonalne produktu
- **Uwierzytelnianie:** Rejestracja i logowanie użytkowników za pomocą Firebase Auth.
- **Zarządzanie biblioteką:**
    - Dodawanie książki manualnie (tytuł, autor, ilość stron, gatunek z predefiniowanej listy).
    - Dodawanie książki przez skanowanie/wpisanie ISBN z wykorzystaniem Google Books API.
    - Edycja i usuwanie książek (z potwierdzeniem).
- **Wyświetlanie biblioteki:**
    - Widok kafelkowy z okładkami, tytułami i wskaźnikiem postępu.
    - Sortowanie alfabetyczne.
    - Filtrowanie po statusie ("Nieprzeczytane", "W trakcie", "Przeczytane") i gatunku.
- **Śledzenie postępów:**
    - Zmiana statusu książki.
    - Rozpoczynanie i kończenie sesji czytania.
    - Automatyczne obliczanie czasu trwania sesji.
    - Rejestrowanie liczby przeczytanych stron na koniec sesji (z walidacją).
    - Przycisk "całość" do szybkiego oznaczania książek jako przeczytanych.
- **Historia:** Wyświetlanie historii sesji dla każdej książki (data, czas, strony).
- **Onboarding:** Krótki przewodnik po kluczowych funkcjach aplikacji dla nowych użytkowników.

### b. Kluczowe historie użytkownika i ścieżki korzystania
1.  **Nowy użytkownik:** Jako nowy użytkownik, chcę przejść przez krótki samouczek, aby szybko zrozumieć, jak dodawać książki i śledzić swoje postępy w czytaniu.
2.  **Dodawanie książki:** Jako użytkownik, chcę zeskanować kod ISBN mojej fizycznej książki, aby aplikacja automatycznie pobrała wszystkie jej dane i dodała ją do mojej cyfrowej biblioteki, oszczędzając mój czas.
3.  **Śledzenie czytania:** Jako użytkownik, chcę móc rozpocząć "sesję czytania", kiedy siadam do książki, a po zakończeniu zapisać, ile stron przeczytałem, aby móc śledzić swoje postępy.
4.  **Przeglądanie kolekcji:** Jako użytkownik, chcę na pierwszy rzut oka zobaczyć wszystkie moje książki, wiedzieć, które z nich aktualnie czytam i jaki jest mój postęp, aby łatwiej zdecydować, co chcę czytać dalej.

### c. Ważne kryteria sukcesu i sposoby ich mierzenia
- **Cel 1: 90% nowych użytkowników dodaje co najmniej 3 książki w pierwszym tygodniu.**
    - **Sposób pomiaru:** Analityka śledząca liczbę książek dodanych przez nowego użytkownika w ciągu 7 dni od rejestracji.
    - **Wspierające funkcje:** Szybki proces dodawania książki przez skaner ISBN, przejrzysty onboarding pokazujący tę funkcję.
- **Cel 2: 75% użytkowników rejestruje co najmniej jedną sesję czytania tygodniowo.**
    - **Sposób pomiaru:** Analityka zliczająca unikalnych użytkowników, którzy zarejestrowali co najmniej jedną sesję w danym tygodniu.
    - **Wspierające funkcje:** Prosty i intuicyjny mechanizm startu/stopu sesji, wizualne wskaźniki postępu motywujące do dalszego czytania.

</prd_planning_summary>

<unresolved_issues>
1.  **Predefiniowana lista gatunków:** Należy zdefiniować, jakie konkretnie gatunki znajdą się na liście do wyboru przez użytkownika, gdy API Google Books nie dostarczy tej informacji.
2.  **Przycisk "całość":** Należy szczegółowo określić jego działanie. Czy po jego naciśnięciu tworzona jest jakaś symboliczna, ostatnia sesja? Jak zachowuje się w przypadku książki, która nigdy nie miała statusu "W trakcie"?
3.  **Powiadomienie o sesji:** Należy jednoznacznie potwierdzić, co dzieje się, gdy użytkownik zignoruje (nie kliknie, a odrzuci) powiadomienie o trwającej sesji. Czy sesja jest automatycznie anulowana bez zapisu?
4.  **Ekran sesji:** Interfejs i dokładna interakcja użytkownika z ekranem aktywnej sesji czytania wymagają zdefiniowania (np. wygląd timera, rozmieszczenie przycisków).
</unresolved_issues>
</conversation_summary>
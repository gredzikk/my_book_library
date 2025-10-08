# Dokument wymagań produktu (PRD) - My Book Library
## 1. Przegląd produktu
My Book Library to mobilna aplikacja na platformę Android, stworzona z myślą o miłośnikach książek. Jej głównym celem jest dostarczenie prostego i scentralizowanego narzędzia do zarządzania osobistą biblioteką, obejmującą zarówno fizyczne, jak i cyfrowe egzemplarze. Aplikacja umożliwia użytkownikom łatwe dodawanie książek, śledzenie postępów w czytaniu poprzez rejestrowanie sesji oraz wizualizację swoich nawyków czytelniczych. Dzięki integracji z Google Books API, proces katalogowania jest szybki i w dużej mierze zautomatyzowany. MVP (Minimum Viable Product) koncentruje się na kluczowych funkcjonalnościach, które rozwiązują podstawowe problemy użytkowników, odkładając bardziej zaawansowane funkcje społeczne i analityczne na późniejsze etapy rozwoju.

## 2. Problem użytkownika
Czytelnicy, którzy posiadają zbiory książek w różnych formatach (fizyczne i cyfrowe), borykają się z brakiem jednego, wygodnego miejsca do zarządzania swoją kolekcją. Prowadzi to do problemów takich jak:
- Trudności w śledzeniu, które książki zostały przeczytane, które są w trakcie czytania, a które dopiero czekają w kolejce.
- Brak motywacji do regularnego czytania z powodu niewidocznych postępów.
- Czasochłonne i manualne katalogowanie posiadanych tytułów.
- Brak wglądu w swoje nawyki czytelnicze, takie jak tempo czytania czy liczba przeczytanych książek w danym okresie.

My Book Library adresuje te problemy, oferując intuicyjną platformę do katalogowania książek, monitorowania postępów i analizy aktywności czytelniczej, co ma na celu uporządkowanie domowej biblioteki i zwiększenie zaangażowania w czytanie.

## 3. Wymagania funkcjonalne
- 3.1. Uwierzytelnianie użytkownika
  - Rejestracja nowego konta użytkownika.
  - Logowanie do istniejącego konta.
  - System oparty na Supabase Auth.
- 3.2. Zarządzanie biblioteką książek
  - Dodawanie książki poprzez skanowanie kodu ISBN lub ręczne jego wprowadzenie.
  - Automatyczne pobieranie metadanych książki (okładka, tytuł, autor, rok wydania, liczba stron, wydawnictwo) z Google Books API.
  - Ręczne dodawanie książki z podaniem co najmniej tytułu, autora i liczby stron.
  - Edycja danych istniejącej książki.
  - Usuwanie książki z biblioteki (wymagane potwierdzenie).
- 3.3. Śledzenie postępów w czytaniu
  - Przypisywanie książkom jednego z trzech statusów: "Nieprzeczytane", "W trakcie", "Przeczytane".
  - Rozpoczynanie i kończenie sesji czytania dla książek o statusie "W trakcie".
  - Rejestrowanie liczby przeczytanych stron po zakończeniu każdej sesji.
  - Automatyczne obliczanie i zapisywanie czasu trwania sesji.
- 3.4. Wyświetlanie danych
  - Ekran główny z listą wszystkich książek w widoku kafelkowym (grid).
  - Wyświetlanie okładki, tytułu oraz procentowego wskaźnika postępu na kafelku książki.
  - Możliwość filtrowania listy książek po statusie oraz gatunku.
  - Sortowanie alfabetyczne listy książek.
  - Dedykowany ekran z historią wszystkich sesji czytania dla wybranej książki.
- 3.5. Onboarding
  - Krótki samouczek dla nowych użytkowników, prezentujący kluczowe funkcje aplikacji.
- 3.6. Powiadomienia
  - Powiadomienie push informujące o aktywnej sesji czytania, jeśli aplikacja zostanie zamknięta na dłużej niż godzinę.
- 3.7. Wymagania techniczne
  - Aplikacja przeznaczona wyłącznie na platformę Android w ramach MVP.
  - Co najmniej jeden test integracyjny weryfikujący kluczowy przepływ (np. logowanie -> dodanie książki).
  - Skonfigurowany pipeline CI/CD do automatycznego budowania i testowania aplikacji.

## 4. Granice produktu
### W zakresie MVP:
- Pełna funkcjonalność opisana w sekcji "Wymagania funkcjonalne".
- Uwierzytelnianie użytkowników za pomocą Supabase Auth.
- Integracja z Google Books API do pobierania danych o książkach.
- Zapisywanie danych użytkownika (biblioteka, sesje) w bazie danych (np. Firestore).
- Podstawowy interfejs użytkownika zgodny z wytycznymi projektowymi dla platformy Android.
- Wszystkie dane użytkownika są prywatne i nie są udostępniane innym.

### Poza zakresem MVP:
- Funkcje społecznościowe (listy znajomych, udostępnianie postępów).
- Udostępnianie sesji czytania w czasie rzeczywistym.
- Zaawansowane ustawienia prywatności.
- Funkcjonalność listy życzeń (wishlist).
- Rozbudowane statusy książek (np. "Porzucona", "Przeczytana wielokrotnie").
- Dodawanie notatek lub cytatów do sesji czytania.
- Zaawansowane statystyki, wykresy i wizualizacje nawyków czytelniczych.
- Rekomendacje książek oparte na AI.
- Powiadomienia przypominające o czytaniu lub motywujące do utrzymania serii.
- Wdrożenie publiczne aplikacji pod adresem URL.
- Wsparcie dla platform innych niż Android (iOS, Web).

## 5. Historyjki użytkowników
### Uwierzytelnianie i Onboarding
- ID: US-001
- Tytuł: Rejestracja nowego użytkownika
- Opis: Jako nowy użytkownik, chcę móc założyć konto w aplikacji przy użyciu adresu e-mail i hasła, aby móc zacząć budować swoją bibliotekę.
- Kryteria akceptacji:
  - Formularz rejestracji zawiera pola na adres e-mail i hasło.
  - Walidacja sprawdza poprawność formatu adresu e-mail.
  - Wymagania co do siły hasła są jasno określone i walidowane.
  - Po pomyślnej rejestracji użytkownik jest automatycznie zalogowany i przekierowany do ekranu onboardingu.
  - W przypadku błędu (np. zajęty e-mail) wyświetlany jest czytelny komunikat.

- ID: US-002
- Tytuł: Logowanie użytkownika
- Opis: Jako zarejestrowany użytkownik, chcę móc zalogować się na swoje konto, aby uzyskać dostęp do mojej biblioteki książek.
- Kryteria akceptacji:
  - Formularz logowania zawiera pola na adres e-mail i hasło.
  - Po pomyślnym zalogowaniu użytkownik jest przekierowany do ekranu głównego z listą książek.
  - W przypadku podania błędnych danych wyświetlany jest odpowiedni komunikat.

- ID: US-003
- Tytuł: Onboarding dla nowych użytkowników
- Opis: Jako nowy użytkownik, po pierwszym zalogowaniu chcę zobaczyć krótki samouczek, który pokaże mi, jak dodać książkę i jak rozpocząć sesję czytania.
- Kryteria akceptacji:
  - Onboarding uruchamia się automatycznie tylko raz, po pierwszej rejestracji/logowaniu.
  - Samouczek składa się z maksymalnie 3-4 ekranów.
  - Prezentuje kluczowe funkcje: dodawanie książki (ręczne i przez ISBN) oraz rozpoczynanie sesji.
  - Użytkownik może pominąć onboarding w dowolnym momencie.

### Zarządzanie biblioteką
- ID: US-004
- Tytuł: Dodawanie książki przez ISBN
- Opis: Jako użytkownik, chcę dodać nową książkę do mojej biblioteki, wpisując lub skanując jej kod ISBN, aby aplikacja automatycznie pobrała jej dane.
- Kryteria akceptacji:
  - Użytkownik ma możliwość ręcznego wpisania numeru ISBN.
  - Aplikacja wysyła zapytanie do Google Books API z podanym numerem ISBN.
  - Jeśli książka zostanie znaleziona, pola formularza (tytuł, autor, liczba stron, okładka, rok wydania, wydawnictwo, gatunek) są automatycznie uzupełniane.
  - Użytkownik może zatwierdzić dodanie książki. Po dodaniu książka ma domyślny status "Nieprzeczytane".

- ID: US-005
- Tytuł: Obsługa braku wyników z API
- Opis: Jako użytkownik, po wpisaniu numeru ISBN, który nie został znaleziony w Google Books API, chcę otrzymać stosowny komunikat i możliwość ręcznego dodania książki.
- Kryteria akceptacji:
  - Aplikacja wyświetla komunikat "Nie znaleziono książki dla podanego numeru ISBN".
  - Użytkownik jest przekierowywany do pustego formularza dodawania książki, aby mógł uzupełnić dane manualnie.

- ID: US-006
- Tytuł: Ręczne dodawanie książki
- Opis: Jako użytkownik, chcę móc ręcznie dodać książkę, podając jej tytuł, autora i liczbę stron, gdy nie mam numeru ISBN lub API go nie znajduje.
- Kryteria akceptacji:
  - Formularz dodawania książki zawiera pola: tytuł, autor, liczba stron.
  - Pola tytuł, autor i liczba stron są wymagane.
  - Dostępne jest opcjonalne pole wyboru gatunku z predefiniowanej listy (Fantastyka, Science Fiction, Kryminał, Thriller, Romans, Horror, Literatura faktu, Biografia, Poradnik, Poezja, Klasyka).
  - Po dodaniu książka pojawia się na liście z domyślnym statusem "Nieprzeczytane".

- ID: US-007
- Tytuł: Edycja danych książki
- Opis: Jako użytkownik, chcę móc edytować informacje o książce w mojej bibliotece, aby poprawić ewentualne błędy lub uzupełnić brakujące dane.
- Kryteria akceptacji:
  - Z widoku szczegółów książki mogę przejść do trybu edycji.
  - Mogę modyfikować wszystkie pola (tytuł, autor, liczba stron, etc.).
  - Edycja liczby stron jest zablokowana, jeśli książka ma status "W trakcie".
  - Zapisane zmiany są widoczne w całej aplikacji.

- ID: US-008
- Tytuł: Usuwanie książki
- Opis: Jako użytkownik, chcę móc usunąć książkę z mojej biblioteki, ponieważ już jej nie posiadam lub dodałem ją przez pomyłkę.
- Kryteria akceptacji:
  - W widoku szczegółów książki znajduje się opcja jej usunięcia.
  - Przed ostatecznym usunięciem aplikacja wyświetla okno dialogowe z prośbą o potwierdzenie.
  - Po potwierdzeniu książka oraz cała jej historia sesji zostają trwale usunięte.

### Przeglądanie i śledzenie postępów
- ID: US-009
- Tytuł: Przeglądanie biblioteki
- Opis: Jako użytkownik, chcę widzieć wszystkie moje książki na jednym ekranie w formie siatki, aby mieć szybki przegląd mojej kolekcji.
- Kryteria akceptacji:
  - Ekran główny wyświetla książki w formie kafelków (grid).
  - Każdy kafelek pokazuje okładkę książki, jej tytuł.
  - Dla książek o statusie "W trakcie" na kafelku widoczny jest procentowy wskaźnik postępu.
  - Domyślnie lista jest sortowana alfabetycznie według tytułów.

- ID: US-010
- Tytuł: Filtrowanie biblioteki
- Opis: Jako użytkownik, chcę móc filtrować moją listę książek według statusu (Nieprzeczytane, W trakcie, Przeczytane) i gatunku, aby łatwiej znaleźć to, czego szukam.
- Kryteria akceptacji:
  - Na ekranie głównym dostępne są opcje filtrowania.
  - Mogę wybrać jeden lub więcej statusów do wyświetlenia.
  - Mogę wybrać jeden gatunek z listy, aby zobaczyć tylko pasujące książki.
  - Aktywne filtry są wyraźnie oznaczone.

- ID: US-011
- Tytuł: Rozpoczynanie sesji czytania
- Opis: Jako użytkownik, chcę móc rozpocząć sesję czytania dla książki, którą aktualnie czytam, aby aplikacja zaczęła mierzyć czas.
- Kryteria akceptacji:
  - W widoku szczegółów książki o statusie "W trakcie" znajduje się przycisk "Rozpocznij sesję".
  - Naciśnięcie przycisku zmienia status książki na "W trakcie" (jeśli był "Nieprzeczytane") i przenosi do ekranu aktywnej sesji.
  - Na ekranie sesji widoczny jest stoper, który zaczyna odliczać czas.

- ID: US-012
- Tytuł: Kończenie sesji czytania
- Opis: Jako użytkownik, po zakończeniu czytania chcę zatrzymać sesję i wprowadzić liczbę przeczytanych stron, aby zapisać swoje postępy.
- Kryteria akceptacji:
  - Na ekranie aktywnej sesji znajduje się przycisk "Zakończ sesję".
  - Po jego naciśnięciu stoper się zatrzymuje, a użytkownik jest proszony o wprowadzenie numeru ostatniej przeczytanej strony.
  - Aplikacja waliduje, czy wprowadzona liczba stron jest większa od poprzedniego postępu i mniejsza lub równa całkowitej liczbie stron książki.
  - Sesja z zerową liczbą przeczytanych stron nie jest zapisywana.
  - Po zapisaniu sesji postęp w czytaniu książki jest aktualizowany.

- ID: US-013
- Tytuł: Automatyczna zmiana statusu na "Przeczytane"
- Opis: Jako użytkownik, chcę, aby aplikacja automatycznie zmieniła status książki na "Przeczytane", gdy liczba przeczytanych stron osiągnie całkowitą liczbę stron książki.
- Kryteria akceptacji:
  - Po zakończeniu sesji, jeśli suma przeczytanych stron jest równa całkowitej liczbie stron, status książki automatycznie zmienia się na "Przeczytane".
  - Aplikacja może wyświetlić komunikat gratulacyjny.

- ID: US-014
- Tytuł: Ręczne oznaczenie książki jako przeczytanej
- Opis: Jako użytkownik, chcę mieć możliwość szybkiego oznaczenia książki jako przeczytanej, bez konieczności rejestrowania sesji, np. dla książek przeczytanych w przeszłości.
- Kryteria akceptacji:
  - W widoku szczegółów książki znajduje się przycisk "Oznacz jako przeczytaną".
  - Po jego naciśnięciu status książki zmienia się na "Przeczytane", a postęp na 100%.
  - Działanie to nie tworzy nowej sesji w historii.

- ID: US-015
- Tytuł: Przeglądanie historii sesji
- Opis: Jako użytkownik, chcę móc zobaczyć historię wszystkich moich sesji czytania dla konkretnej książki, aby śledzić swoje tempo i regularność.
- Kryteria akceptacji:
  - W widoku szczegółów książki jest dostęp do historii sesji.
  - Lista sesji jest posortowana chronologicznie (od najnowszej).
  - Każdy element listy pokazuje datę zakończenia sesji, jej czas trwania oraz liczbę stron przeczytanych w tej sesji.

- ID: US-016
- Tytuł: Powiadomienie o aktywnej sesji
- Opis: Jako użytkownik, jeśli zamknę aplikację z aktywną sesją czytania, chcę po godzinie otrzymać powiadomienie przypominające, aby nie zapomnieć jej zakończyć.
- Kryteria akceptacji:
  - Jeśli sesja jest aktywna, a aplikacja działa w tle przez ponad godzinę, system wysyła powiadomienie push.
  - Kliknięcie w powiadomienie przenosi użytkownika z powrotem do ekranu aktywnej sesji.
  - Odrzucenie powiadomienia nie przerywa sesji; stoper nadal działa w tle.

## 6. Metryki sukcesu
### Kluczowe wskaźniki wydajności (KPI)
- KPI 1: Aktywacja użytkownika
  - Metryka: Procent nowych użytkowników, którzy dodają co najmniej 3 książki do swojej biblioteki w ciągu pierwszego tygodnia od rejestracji.
  - Cel: 90%
  - Sposób pomiaru: Analityka w aplikacji śledząca liczbę książek dodanych przez każdego nowego użytkownika w ciągu 7 dni od daty utworzenia konta.
- KPI 2: Zaangażowanie użytkownika
  - Metryka: Procent aktywnych użytkowników, którzy rejestrują co najmniej jedną sesję czytania w tygodniu.
  - Cel: 75%
  - Sposób pomiaru: Analityka w aplikacji zliczająca unikalnych użytkowników, którzy zapisali co najmniej jedną sesję czytania (z >0 przeczytanymi stronami) w danym tygodniu.

### Jakościowe miary sukcesu
- Pozytywne recenzje i oceny w sklepie Google Play, ze szczególnym uwzględnieniem komentarzy na temat łatwości użytkowania i motywującego wpływu aplikacji.
- Opinie zwrotne od użytkowników zbierane za pomocą ankiet w aplikacji, wskazujące na wysoką satysfakcję z kluczowych funkcji (dodawanie książek, śledzenie sesji).
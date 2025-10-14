<conversation_summary>
<decisions>
1.  Przepływ dodawania książki: Zaimplementowany zostanie jeden główny przycisk "Dodaj książkę", który otwiera ekran z opcjami skanowania ISBN lub dodawania ręcznego.
2.  Filtrowanie i sortowanie: Na ekranie głównym zostanie umieszczona ikona filtra, otwierająca panel z opcjami filtrowania i sortowania.
3.  Aktywna sesja czytania: Będzie sygnalizowana przez stałe powiadomienie systemowe (foreground service) ze stoperem.
4.  Edycja liczby stron: Pole będzie wizualnie wyłączone (wyszarzone), gdy książka ma status "W trakcie".
5.  Stany ładowania: Podczas ładowania danych zostanie wyświetlony "page skeleton" z prostym wskaźnikiem postępu.
6.  Obsługa wygaśnięcia tokenu (401): Aplikacja automatycznie wyloguje użytkownika i przekieruje go do ekranu logowania.
7.  Ekran aktywnej sesji: Będzie zawierał duży stoper, informacje o książce i przycisk "Zakończ sesję", który otwiera dialog do wpisania ostatniej przeczytanej strony.
8.  Zmiana statusu książki: Status automatycznie zmieni się na "W trakcie" po rozpoczęciu pierwszej sesji czytania.
9.  Ręczne dodawanie sesji: Zostanie dodana opcja dodawania sesji archiwalnej z przeszłości.
10. Obsługa braku internetu: Aplikacja będzie sprawdzać połączenie i informować użytkownika komunikatem `SnackBar`.
11. Stan pusty: Na ekranie głównym, przy braku książek, zostanie wyświetlony komunikat z przyciskiem do dodania pierwszej pozycji.
12. Historia sesji: Będzie wyświetlana jako lista na ekranie szczegółów książki.
13. Onboarding: Zostanie zaimplementowany jako 4-krokowy samouczek z wizualnym wyróżnieniem kluczowych elementów.
14. Utrwalanie filtrów: Wybrane filtry będą zapisywane lokalnie i zostanie dodany przycisk "Wyczyść filtry".
15. Wizualizacja statusu książki: Do reprezentacji statusu na kafelkach zostaną użyte ikony.
16. Walidacja "na żywo": Pola w formularzach będą walidowane po stronie klienta.
17. Obsługa błędów walidacji: Komunikaty o błędach będą wyświetlane bezpośrednio pod odpowiednimi polami.
18. Dialog potwierdzenia usunięcia: Usunięcie książki będzie wymagało potwierdzenia w oknie dialogowym.
19. Przekierowanie po dodaniu książki: Użytkownik zostanie przeniesiony na ekran główny z komunikatem `SnackBar`.
20. Skaner ISBN: Będzie pełnoekranową nakładką z wyraźnym obszarem skanowania i przyciskiem anulowania.
21. Nieznaleziony ISBN: Aplikacja poinformuje o tym użytkownika za pomocą widocznego okna dialogowego.
22. Odświeżanie listy: Zostanie dodana funkcja "pull-to-refresh".
23. Ponowne czytanie książki: Aplikacja pozwoli na ponowne rozpoczęcie czytania książki, która ma już status "Przeczytana".
</decisions>
<matched_recommendations>
1.  **Przepływ dodawania książki**: Zostanie zaimplementowany jeden główny przycisk "Dodaj książkę" (np. Floating Action Button), który otwiera ekran z opcjami "Skanuj ISBN" i "Dodaj ręcznie". Po pobraniu danych z API (lub od razu przy dodawaniu ręcznym) użytkownik jest przenoszony do formularza w celu weryfikacji lub uzupełnienia danych.
2.  **Stany ładowania i błędu**: Każdy widok wykonujący operacje sieciowe zaimplementuje trzy stany: stan ładowania (z widżetem "page skeleton" i `CircularProgressIndicator`), stan błędu (z komunikatem i przyciskiem "Spróbuj ponownie") oraz stan sukcesu (wyświetlający dane).
3.  **Obsługa autoryzacji**: W przypadku otrzymania statusu 401 Unauthorized, aplikacja automatycznie usunie token, wyczyści stan i przekieruje użytkownika do ekranu logowania.
4.  **Ekran szczegółów książki**: Będzie zawierał okładkę, tytuł, wskaźnik postępu, przyciski akcji ("Rozpocznij sesję", menu z opcjami edycji, usunięcia, oznaczenia jako przeczytanej, dodania sesji archiwalnej) oraz przewijaną listę historii sesji.
5.  **Onboarding**: Zostanie zrealizowany przy użyciu biblioteki typu `showcaseview`, która wyróżnia poszczególne elementy interfejsu, prowadząc użytkownika przez kluczowe funkcje w 3-4 krokach.
6.  **Walidacja formularzy**: Walidacja pól (np. tytuł, autor, liczba stron) będzie odbywać się "na żywo" po stronie klienta, z komunikatami o błędach wyświetlanymi bezpośrednio pod polami.
7.  **Aktywna sesja i powiadomienia**: Aktywna sesja czytania będzie sygnalizowana przez stałe powiadomienie systemowe (foreground service) zawierające tytuł książki, stoper oraz przycisk do zakończenia sesji.
8.  **Dodawanie sesji archiwalnej**: Użytkownik będzie mógł dodać sesję z przeszłości poprzez formularz z polami daty, czasu trwania i ostatnio przeczytanej strony.
9.  **Obsługa braku połączenia**: Aplikacja proaktywnie sprawdzi stan sieci i poinformuje użytkownika o jego braku za pomocą `SnackBar`, blokując akcje wymagające połączenia.
10. **Odświeżanie danych**: Użytkownicy będą mogli manualnie odświeżyć listę książek za pomocą gestu "pull-to-refresh".
</matched_recommendations>
<ui_architecture_planning_summary>
### Podsumowanie Planowania Architektury UI

Na podstawie przeprowadzonych dyskusji, architektura UI dla MVP aplikacji "My Book Library" została zdefiniowana w następujący sposób:

#### a. Główne wymagania dotyczące architektury UI
Interfejs użytkownika będzie prosty, intuicyjny i skoncentrowany na kluczowych funkcjonalnościach. Architektura musi wspierać stany ładowania, błędu i pustego widoku, a także zapewniać natychmiastową informację zwrotną poprzez walidację po stronie klienta. Kluczowe jest również zapewnienie spójnego doświadczenia użytkownika poprzez utrwalanie stanu filtrów i proaktywną obsługę problemów z siecią.

#### b. Kluczowe widoki, ekrany i przepływy użytkownika
1.  **Ekran główny**: Widok siatki (`GridView`) z kafelkami reprezentującymi książki. Wyposażony w `FloatingActionButton` do dodawania książek, opcje filtrowania/sortowania w `AppBar` oraz obsługę gestu "pull-to-refresh". Wyświetla stan pusty lub szkielet ładowania.
2.  **Ekran szczegółów książki**: Prezentuje pełne informacje o książce, wskaźnik postępu, historię sesji w formie listy (`ListView`) oraz główne przyciski akcji.
3.  **Przepływ dodawania książki**: Inicjowany z ekranu głównego, prowadzi do ekranu wyboru (skanowanie/ręcznie), następnie do skanera ISBN (widok kamery z nakładką) lub bezpośrednio do formularza edycji/dodawania.
4.  **Ekran sesji czytania**: Pełnoekranowy widok z dużym stoperem, informacjami o książce i przyciskiem zakończenia, który otwiera dialog do wprowadzenia postępu.
5.  **Ekrany uwierzytelniania**: Standardowe ekrany logowania i rejestracji dostarczane przez Supabase Auth.
6.  **Onboarding**: Sekwencja 3-4 ekranów (`PageView`) z wizualnym przewodnikiem po kluczowych funkcjach.

#### c. Strategia integracji z API i zarządzania stanem
-   **Zarządzanie stanem**: Każdy widok odpowiedzialny za pobieranie danych będzie zarządzał swoim stanem (ładowanie, błąd, sukces). Do ładowania używane będą widżety "page skeleton".
-   **Integracja z API**:
    -   **Błędy**: Błędy walidacji (400) będą wyświetlane przy konkretnych polach formularzy. Błędy serwera (500) i sieciowe będą obsługiwane globalnie za pomocą `SnackBar`.
    -   **Autoryzacja**: Globalny interceptor HTTP będzie przechwytywał odpowiedzi 401, co spowoduje wylogowanie użytkownika i przekierowanie do ekranu logowania.
    -   **Optymalizacja**: Aplikacja będzie proaktywnie sprawdzać połączenie sieciowe przed wykonaniem żądania.

#### d. Kwestie dotyczące responsywności, dostępności i bezpieczeństwa
-   **Responsywność**: Układ siatki na ekranie głównym powinien dostosowywać liczbę kolumn do szerokości ekranu.
-   **Dostępność**: Zapewniona zostanie czytelność poprzez wyraźne komunikaty o błędach i statusach. Onboarding pomoże nowym użytkownikom zrozumieć aplikację.
-   **Bezpieczeństwo**: Kluczowym mechanizmem jest obsługa wygaśnięcia tokenu JWT i bezpieczne przekierowanie do ponownego logowania.

</ui_architecture_planning_summary>
<unresolved_issues>
1.  **Licznik przeczytań**: Pojawiła się sugestia dodania do tabeli `books` licznika informującego, ile razy dana książka została przeczytana w całości. Wymaga to modyfikacji schematu bazy danych i logiki API/aplikacji, aby inkrementować licznik po ponownym osiągnięciu 100% postępu. Należy podjąć decyzję, czy ta funkcja ma wejść w skład MVP.
</unresolved_issues>
</conversation_summary>

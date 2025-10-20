
# Plan Testów dla Aplikacji "My Book Library"

**Wersja dokumentu:** 1.0
**Data:** 20.10.2025
**Autor:** GitHub Copilot (jako Inżynier QA)

---

## 1. Wprowadzenie i cele testowania

### 1.1. Wprowadzenie
Niniejszy dokument opisuje kompleksowy plan testów dla aplikacji mobilnej "My Book Library" w wersji MVP na platformę Android. Aplikacja, zbudowana przy użyciu frameworka Flutter, ma na celu umożliwienie użytkownikom katalogowania książek, śledzenia postępów w czytaniu i zarządzania osobistą biblioteką. Plan ten obejmuje strategię, zakres, zasoby i harmonogram działań testowych mających na celu zapewnienie najwyższej jakości produktu końcowego.

### 1.2. Cele testowania
Główne cele procesu testowania to:
- **Weryfikacja zgodności funkcjonalnej:** Upewnienie się, że wszystkie funkcje aplikacji działają zgodnie z wymaganiami opisanymi w dokumencie PRD (Product Requirements Document).
- **Zapewnienie stabilności i niezawodności:** Identyfikacja i eliminacja błędów, które mogłyby prowadzić do awarii aplikacji lub utraty danych.
- **Ocena użyteczności (UX/UI):** Sprawdzenie, czy interfejs użytkownika jest intuicyjny, spójny i zgodny z wytycznymi projektowymi.
- **Weryfikacja integracji z usługami zewnętrznymi:** Potwierdzenie poprawnej komunikacji z API Supabase (dla autentykacji) oraz Google Books API (dla danych o książkach).
- **Zapewnienie bezpieczeństwa:** Weryfikacja podstawowych mechanizmów bezpieczeństwa związanych z uwierzytelnianiem i autoryzacją dostępu do danych użytkownika.

---

## 2. Zakres testów

### 2.1. Funkcjonalności w zakresie testów
Testom poddane zostaną wszystkie funkcjonalności zdefiniowane w PRD dla wersji MVP, w tym:
- **Moduł uwierzytelniania:** Rejestracja, logowanie, wylogowywanie, obsługa błędów, odzyskiwanie hasła.
- **Onboarding:** Proces wprowadzający dla nowych użytkowników.
- **Zarządzanie biblioteką:**
    - Dodawanie książek (ręczne, przez skanowanie/wpisanie ISBN).
    - Edycja i usuwanie książek.
    - Automatyczne pobieranie danych z Google Books API.
- **Śledzenie postępów:**
    - Rozpoczynanie i kończenie sesji czytania.
    - Zapisywanie postępów (liczba stron).
    - Zmiana statusu książki ("Nieprzeczytane", "W trakcie", "Przeczytane").
- **Wyświetlanie danych:**
    - Ekran główny z siatką książek.
    - Filtrowanie i sortowanie listy książek.
    - Ekran szczegółów książki z historią sesji.
- **Powiadomienia:** Przypomnienie o aktywnej sesji czytania.

### 2.2. Funkcjonalności poza zakresem testów
Wszystkie funkcje wymienione w PRD jako "Poza zakresem MVP" nie będą objęte testami w tej fazie, m.in. funkcje społecznościowe, zaawansowane statystyki, wsparcie dla iOS/Web.

---

## 3. Typy testów do przeprowadzenia

Proces testowania zostanie podzielony na kilka poziomów, aby zapewnić kompleksowe pokrycie.

### 3.1. Testy jednostkowe (Unit Tests)
- **Cel:** Weryfikacja poprawności działania pojedynczych funkcji, metod i klas w izolacji od reszty aplikacji.
- **Zakres:**
    - Logika biznesowa w BLoC/Cubit (przejścia stanów w odpowiedzi na zdarzenia).
    - Funkcje pomocnicze i walidatory (np. walidacja formatu e-mail, siły hasła).
    - Logika serwisów (`AuthService`, `BookService`) z zamockowanymi zależnościami (API).
    - Mapowanie modeli danych (DTO).

### 3.2. Testy widżetów (Widget Tests)
- **Cel:** Weryfikacja, czy poszczególne widżety (komponenty UI) renderują się poprawnie i reagują na interakcje użytkownika.
- **Zakres:**
    - Testowanie pojedynczych ekranów (`LoginScreen`, `HomeScreenContent`) z zamockowanymi danymi.
    - Weryfikacja poprawności renderowania elementów UI w różnych stanach (np. ładowanie, błąd, dane).
    - Testowanie formularzy i pól tekstowych.

### 3.3. Testy integracyjne (Integration Tests)
- **Cel:** Weryfikacja współpracy pomiędzy różnymi modułami aplikacji oraz integracji z usługami zewnętrznymi.
- **Zakres:**
    - Pełne przepływy użytkownika (np. rejestracja -> logowanie -> dodanie książki -> rozpoczęcie sesji).
    - Integracja z Supabase (autentykacja) przy użyciu testowego projektu backendowego.
    - Integracja z Google Books API (mockowane odpowiedzi serwera w celu zapewnienia determinizmu testów).

### 3.4. Testy manualne (UAT - User Acceptance Testing)
- **Cel:** Ręczna weryfikacja aplikacji pod kątem zgodności z oczekiwaniami użytkownika końcowego i ogólnej użyteczności.
- **Zakres:**
    - Wykonanie scenariuszy testowych opisanych w sekcji 4.
    - Testy eksploracyjne w celu znalezienia nieprzewidzianych błędów.
    - Weryfikacja spójności wizualnej i przepływów nawigacji.

---

## 4. Scenariusze testowe dla kluczowych funkcjonalności

| ID Scenariusza | Funkcjonalność | Opis krokow | Oczekiwany rezultat | Priorytet |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-01** | Rejestracja | 1. Otwórz aplikację. 2. Przejdź do ekranu rejestracji. 3. Wprowadź poprawne dane (e-mail, hasło). 4. Zaakceptuj. | Użytkownik zostaje zarejestrowany, zalogowany i przekierowany do ekranu onboardingu. | **Krytyczny** |
| **TC-AUTH-02** | Logowanie | 1. Otwórz aplikację. 2. Przejdź do ekranu logowania. 3. Wprowadź dane istniejącego użytkownika. 4. Zaloguj się. | Użytkownik zostaje zalogowany i przekierowany do ekranu głównego. | **Krytyczny** |
| **TC-AUTH-03** | Błędne logowanie | 1. Otwórz ekran logowania. 2. Wprowadź nieprawidłowe hasło. 3. Spróbuj się zalogować. | Wyświetlony zostaje komunikat o błędnych danych logowania. | **Wysoki** |
| **TC-BOOK-01** | Dodawanie książki (ISBN) | 1. Zaloguj się. 2. Przejdź do dodawania książki. 3. Wpisz prawidłowy numer ISBN. 4. Zatwierdź automatycznie uzupełnione dane. | Książka zostaje dodana do biblioteki i pojawia się na ekranie głównym. | **Krytyczny** |
| **TC-BOOK-02** | Dodawanie książki (ręczne) | 1. Zaloguj się. 2. Przejdź do dodawania książki. 3. Wybierz opcję ręcznego dodawania. 4. Wypełnij wymagane pola. 5. Zapisz. | Książka zostaje dodana do biblioteki. | **Wysoki** |
| **TC-BOOK-03** | Usuwanie książki | 1. Zaloguj się. 2. Wejdź w szczegóły istniejącej książki. 3. Wybierz opcję "Usuń". 4. Potwierdź usunięcie. | Książka znika z listy na ekranie głównym. | **Wysoki** |
| **TC-SESSION-01** | Pełny cykl czytania | 1. Zaloguj się. 2. Wybierz książkę ze statusem "Nieprzeczytane". 3. Rozpocznij sesję czytania. 4. Po chwili zakończ sesję, podając numer strony. | Status książki zmienia się na "W trakcie", a postęp jest zaktualizowany. Sesja jest widoczna w historii. | **Krytyczny** |
| **TC-SESSION-02** | Zakończenie książki | 1. Wybierz książkę "W trakcie". 2. Rozpocznij i zakończ sesję, podając jako ostatnią stronę całkowitą liczbę stron książki. | Status książki automatycznie zmienia się na "Przeczytane". Postęp wynosi 100%. | **Wysoki** |
| **TC-UI-01** | Filtrowanie listy | 1. Zaloguj się. 2. Na ekranie głównym wybierz filtr "Przeczytane". | Na liście widoczne są tylko książki o statusie "Przeczytane". | **Średni** |

---

## 5. Środowisko testowe

- **Platforma:** Android (wersje 10-14).
- **Urządzenia:**
    - Emulator Androida (Pixel 6 API 33) do testów automatycznych i deweloperskich.
    - Co najmniej dwa różne fizyczne urządzenia z Androidem do testów manualnych (UAT), np. Samsung, Xiaomi.
- **Backend:** Dedykowany, odizolowany projekt Supabase na potrzeby testów E2E, aby nie zanieczyszczać danych produkcyjnych.
- **Infrastruktura CI/CD:** GitHub Actions do automatycznego uruchamiania testów jednostkowych i widgetowych po każdym pushu do repozytorium.

---

## 6. Narzędzia do testowania

- **Testy jednostkowe/widgetowe:** `flutter_test`, `bloc_test`, `mockito`.
- **Testy integracyjne:** `integration_test`.
- **Zarządzanie zadaniami i błędami:** GitHub Issues.
- **CI/CD:** GitHub Actions.
- **Backend (do testów):** Dedykowany projekt Supabase.

---

## 7. Harmonogram testów

Proces testowania będzie prowadzony równolegle z procesem deweloperskim zgodnie z metodyką Agile.

- **Sprint 1-4 (Rozwój):**
    - **Ciągłe:** Tworzenie i uruchamianie testów jednostkowych i widgetowych przez deweloperów.
    - **Koniec każdego sprintu:** Sesja testów manualnych (UAT) dla funkcjonalności zaimplementowanych w danym sprincie.
- **Sprint 5 (Stabilizacja):**
    - **Tydzień 1:** Pełna regresja manualna całej aplikacji. Intensywne testy eksploracyjne.
    - **Tydzień 2:** Poprawki błędów znalezionych w fazie regresji i testy potwierdzające.
- **Wydanie:** Po pomyślnym przejściu wszystkich kryteriów akceptacji.

---

## 8. Kryteria akceptacji testów

### 8.1. Kryteria wejścia (rozpoczęcia testów)
- Dostępna jest stabilna, możliwa do zbudowania wersja aplikacji.
- Wszystkie funkcjonalności przewidziane do testów w danym cyklu są zaimplementowane.
- Dokumentacja (PRD) jest kompletna i zatwierdzona.

### 8.2. Kryteria wyjścia (zakończenia testów i wydania)
- **100%** testów automatycznych (jednostkowych, widgetowych, integracyjnych) kończy się sukcesem.
- **Brak błędów krytycznych i wysokich:** Wszystkie zidentyfikowane błędy o priorytecie krytycznym i wysokim muszą zostać naprawione i pomyślnie przetestowane.
- **Akceptowalna liczba błędów o niskim priorytecie:** Ewentualne błędy o niskim priorytecie mogą zostać przeniesione do backlogu na kolejne iteracje po akceptacji przez Product Ownera.
- Pomyślne ukończenie wszystkich scenariuszy testowych UAT.

---

## 9. Role i odpowiedzialności w procesie testowania

- **Deweloperzy:**
    - Odpowiedzialni za tworzenie i utrzymanie testów jednostkowych i widgetowych.
    - Naprawianie błędów zgłoszonych przez zespół QA/testerów.
- **Inżynier QA / Tester:**
    - Tworzenie i utrzymanie planu testów.
    - Projektowanie i wykonywanie scenariuszy testów manualnych (UAT).
    - Prowadzenie testów eksploracyjnych i regresji.
    - Raportowanie błędów i weryfikacja poprawek.
- **Product Owner:**
    - Definiowanie wymagań i kryteriów akceptacji.
    - Udział w testach UAT i ostateczna akceptacja produktu.
    - Priorytetyzacja naprawy błędów.

---

## 10. Procedury raportowania błędów

Każdy zidentyfikowany błąd musi zostać zaraportowany w systemie GitHub Issues i zawierać następujące informacje:
- **Tytuł:** Krótki, zwięzły opis problemu.
- **Opis:**
    - **Kroki do odtworzenia:** Numerowana lista czynności prowadzących do wystąpienia błędu.
    - **Obserwowany rezultat:** Co się stało.
    - **Oczekiwany rezultat:** Co powinno się stać.
- **Środowisko:** Wersja aplikacji, model urządzenia, wersja Androida.
- **Załączniki:** Zrzuty ekranu, nagrania wideo, logi.
- **Priorytet:** Krytyczny, Wysoki, Średni, Niski.
- **Etykiety:** np. `bug`, `ui`, `auth`.

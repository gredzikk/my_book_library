# Plan implementacji widoku Onboarding

## 1. Przegląd
Widok Onboarding to interaktywny samouczek, który ma na celu wprowadzenie nowych użytkowników w kluczowe funkcjonalności aplikacji "My Book Library". Zostanie zrealizowany jako sekwencja 3-4 kroków, które podświetlają najważniejsze elementy interfejsu użytkownika na ekranie głównym. Celem jest szybkie i intuicyjne zaprezentowanie, jak dodać książkę i jak rozpocząć śledzenie postępów w czytaniu, zgodnie z wymaganiami PRD i historyjką użytkownika US-003. Samouczek uruchomi się automatycznie tylko raz, po pierwszym zalogowaniu, a użytkownik będzie miał możliwość jego pominięcia.

## 2. Routing widoku
Onboarding nie jest osobnym ekranem/widokiem z dedykowaną ścieżką. Jest to nakładka (overlay) inicjowana i wyświetlana warunkowo nad ekranem głównym (`/home`). Logika decyzyjna o jego wyświetleniu zostanie uruchomiona zaraz po pomyślnym zalogowaniu i przekierowaniu użytkownika na ekran główny.

## 3. Struktura komponentów
Do implementacji zostanie wykorzystana biblioteka `showcaseview`, która pozwala na podświetlanie konkretnych widżetów. Struktura będzie oparta na integracji z istniejącym `HomeScreen`.

```
- main.dart
  - OnboardingCubitProvider // Dostarcza Cubit do drzewa widżetów
    - AuthStateListener // Nasłuchuje na zmiany stanu autentykacji
      - OnboardingWrapper // Sprawdza, czy uruchomić onboarding
        - HomeScreen // Główny ekran aplikacji
          - Showcase // Widżet z biblioteki `showcaseview`
            - Scaffold
              - AppBar (z GlobalKey dla kroku 1)
              - FloatingActionButton (z GlobalKey dla kroku 2)
              - BookGrid
                - BookTile (z GlobalKey dla kroku 3)
```

## 4. Szczegóły komponentów
### `OnboardingCubit` (BLoC)
- **Opis komponentu:** Cubit zarządzający stanem i logiką onboardingu. Odpowiada za sprawdzenie, czy samouczek powinien być wyświetlony, oraz za zapisanie informacji o jego ukończeniu.
- **Główne elementy:** Wykorzystuje serwis `OnboardingService` do komunikacji z pamięcią trwałą urządzenia.
- **Obsługiwane zdarzenia:**
  - `checkOnboardingStatus()`: Sprawdza w pamięci urządzenia, czy onboarding był już wyświetlony.
  - `markOnboardingAsCompleted()`: Zapisuje w pamięci, że onboarding został ukończony.
- **Warunki walidacji:** Brak.
- **Typy:** `OnboardingState`.
- **Propsy:** Brak.

### `OnboardingWrapper` (Widget)
- **Opis komponentu:** Widżet stanowy, który opakowuje `HomeScreen`. Nasłuchuje na zmiany w `OnboardingCubit` i decyduje o uruchomieniu `Showcase`.
- **Główne elementy:** `BlocListener` na `OnboardingCubit`, `Showcase` (z biblioteki `showcaseview`).
- **Obsługiwane interakcje:**
  - Po otrzymaniu stanu `OnboardingState.show`, uruchamia `Showcase.withWidget()`.
- **Warunki walidacji:** Brak.
- **Typy:** `OnboardingState`.
- **Propsy:** `child` (widżet do opakowania, w tym przypadku `HomeScreen`).

### `OnboardingService` (Service)
- **Opis komponentu:** Klasa serwisowa, która stanowi abstrakcję dla operacji na pamięci trwałej (`shared_preferences`).
- **Główne elementy:** Metody `getOnboardingStatus` i `setOnboardingCompleted`.
- **Obsługiwane interakcje:** Brak.
- **Warunki walidacji:** Brak.
- **Typy:** `Future<bool>`, `Future<void>`.
- **Propsy:** Brak.

## 5. Typy
### `OnboardingState`
Szczegółowy opis stanu używanego przez `OnboardingCubit` do zarządzania przepływem.

```dart
@freezed
class OnboardingState with _$OnboardingState {
  // Stan początkowy, proces sprawdzania nie został jeszcze zakończony.
  const factory OnboardingState.initial() = _Initial;

  // Stan wskazujący, że samouczek powinien zostać wyświetlony.
  const factory OnboardingState.show() = _Show;

  // Stan wskazujący, że samouczek został już wcześniej ukończony.
  const factory OnboardingState.completed() = _Completed;
}
```

## 6. Zarządzanie stanem
Zarządzanie stanem onboardingu zostanie zrealizowane przy użyciu `OnboardingCubit` (wzorzec BLoC).

1.  **Inicjalizacja:** `OnboardingCubit` jest dostarczany do drzewa widżetów nad `HomeScreen`.
2.  **Sprawdzenie statusu:** Po zalogowaniu, `OnboardingWrapper` wywołuje metodę `checkOnboardingStatus()` w `OnboardingCubit`.
3.  **Logika:** Cubit, za pomocą `OnboardingService`, odczytuje z `shared_preferences` flagę `has_onboarding_been_shown`.
    - Jeśli flaga jest `false` lub nie istnieje, Cubit emituje stan `OnboardingState.show`.
    - Jeśli flaga jest `true`, Cubit emituje stan `OnboardingState.completed`.
4.  **Reakcja UI:** `OnboardingWrapper` nasłuchuje na stany. W przypadku `OnboardingState.show`, inicjuje i wyświetla `Showcase`.
5.  **Ukończenie:** Po zakończeniu lub pominięciu samouczka, UI wywołuje metodę `markOnboardingAsCompleted()`, która aktualizuje flagę w `shared_preferences` i emituje stan `OnboardingState.completed`.

## 7. Integracja API
Integracja z API nie jest wymagana. Operacje odbywają się lokalnie na urządzeniu. `OnboardingService` będzie korzystał z pakietu `shared_preferences` do trwałego zapisu flagi.

- **Odczyt:** `final prefs = await SharedPreferences.getInstance(); bool status = prefs.getBool('has_onboarding_been_shown') ?? false;`
- **Zapis:** `final prefs = await SharedPreferences.getInstance(); await prefs.setBool('has_onboarding_been_shown', true);`

## 8. Interakcje użytkownika
- **Automatyczne uruchomienie:** Samouczek startuje automatycznie po pierwszym logowaniu, gdy `HomeScreen` jest gotowy.
- **Nawigacja po krokach:** Użytkownik klika na podświetlony obszar lub przycisk "Dalej", aby przejść do kolejnego kroku samouczka.
- **Pominięcie samouczka:** Użytkownik może w dowolnym momencie kliknąć przycisk "Pomiń" lub ikonę zamknięcia, co zakończy samouczek i zapisze jego stan jako ukończony.
- **Zakończenie samouczka:** Po ostatnim kroku samouczek zamyka się, a jego stan jest zapisywany jako ukończony.

## 9. Warunki i walidacja
- **Główny warunek:** Wyświetlenie samouczka jest uzależnione od flagi `has_onboarding_been_shown` przechowywanej w `shared_preferences`.
- **Komponent:** `OnboardingCubit` jest odpowiedzialny za weryfikację tego warunku.
- **Wpływ na stan interfejsu:**
  - Jeśli `has_onboarding_been_shown` jest `false`, `OnboardingWrapper` uruchamia nakładkę `Showcase`.
  - Jeśli `has_onboarding_been_shown` jest `true`, `OnboardingWrapper` nie renderuje niczego poza swoim `child` (`HomeScreen`).

## 10. Obsługa błędów
- **Problem:** Błąd odczytu/zapisu z/do `shared_preferences`.
- **Strategia obsługi:**
  - **Przy odczycie:** W przypadku błędu, aplikacja przyjmie domyślną, bezpieczną wartość `false` (nie ukończono). Oznacza to, że samouczek zostanie wyświetlony. Jest to niska uciążliwość dla użytkownika w porównaniu do ryzyka, że nowy użytkownik nigdy nie zobaczy samouczka. Błąd zostanie zarejestrowany w systemie logowania.
  - **Przy zapisie:** Jeśli zapis się nie powiedzie, samouczek zostanie wyświetlony ponownie przy następnym uruchomieniu aplikacji. Podobnie jak wyżej, jest to akceptowalna niedogodność. Błąd zostanie zalogowany.

## 11. Kroki implementacji
1.  **Dodanie zależności:** Dodaj pakiet `showcaseview` i `shared_preferences` do pliku `pubspec.yaml`.
2.  **Implementacja `OnboardingService`:** Stwórz klasę z metodami `getOnboardingStatus` i `setOnboardingCompleted`, które będą operować na `shared_preferences`.
3.  **Implementacja `OnboardingState` i `OnboardingCubit`:** Stwórz pliki dla stanu i cubita zgodnie z definicją w sekcji 5 i 6. Zaimplementuj logikę w cubicie, wykorzystując `OnboardingService`.
4.  **Integracja z `HomeScreen`:**
    - Zadeklaruj `GlobalKey` dla każdego elementu UI, który ma być podświetlony (np. `AppBar`, `FloatingActionButton`, pierwszy `BookTile`).
    - Owiń `HomeScreen` w `Showcase` wewnątrz `OnboardingWrapper`.
5.  **Implementacja `OnboardingWrapper`:**
    - Stwórz `StatefulWidget`, który w `initState` wywołuje `context.read<OnboardingCubit>().checkOnboardingStatus()`.
    - Użyj `BlocListener`, aby nasłuchiwać na `OnboardingState.show` i w odpowiedzi wywołać `ShowCaseWidget.of(context).startShowCase(...)`.
    - Przekaż listę kluczy (`GlobalKey`) do `startShowCase`.
6.  **Dostarczenie `OnboardingCubit`:** W głównym pliku aplikacji (`main.dart` lub w pliku z routingiem) owiń `MaterialApp` lub `HomeScreen` w `BlocProvider<OnboardingCubit>`.
7.  **Konfiguracja kroków `Showcase`:** Zdefiniuj treść (tytuł, opis) dla każdego kroku samouczka, przypisując je do odpowiednich `GlobalKey`.
8.  **Obsługa zakończenia/pominięcia:** W konfiguracji `Showcase` podepnij wywołanie `context.read<OnboardingCubit>().markOnboardingAsCompleted()` do callbacków `onFinish` i `onCancel`.
9.  **Testowanie:** Sprawdź ręcznie następujące scenariusze:
    - Pierwsze logowanie: samouczek się uruchamia.
    - Pominięcie samouczka: po ponownym uruchomieniu samouczek się nie pojawia.
    - Ukończenie samouczka: po ponownym uruchomieniu samouczek się nie pojawia.
    - Wylogowanie i zalogowanie na to samo konto: samouczek się nie pojawia.

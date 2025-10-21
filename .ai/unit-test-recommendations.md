# Rekomendacje testów jednostkowych dla My Book Library

**Data utworzenia:** 21 października 2025  
**Cel dokumentu:** Identyfikacja komponentów wymagających testów jednostkowych z uzasadnieniem priorytetów

---

## Podsumowanie wykonawcze

Na podstawie analizy projektu zidentyfikowano **27 kluczowych obszarów** wymagających pokrycia testami jednostkowymi. Projekt posiada złożoną logikę biznesową, wielowarstwową architekturę oraz krytyczne operacje związane z bezpieczeństwem użytkownika.

**Priorytet testowania:**
- 🔴 **Krytyczny** (9 elementów) - bezpieczeństwo, autoryzacja, integralność danych
- 🟡 **Wysoki** (11 elementów) - logika biznesowa, zarządzanie stanem
- 🟢 **Średni** (7 elementów) - walidacje, transformacje danych

---

## 1. Serwisy - Warstwa dostępu do danych

### 🔴 1.1 AuthService (Krytyczny)

**Lokalizacja:** `lib/features/auth/services/auth_service.dart`

**Dlaczego testować:**
- Zarządza bezpieczeństwem całej aplikacji
- Obsługuje wrażliwe dane (hasła, tokeny JWT)
- Błędy mogą prowadzić do naruszeń bezpieczeństwa
- Złożona logika obsługi błędów Supabase Auth

**Co testować:**

```dart
✅ signInWithPassword()
   - poprawne dane → zwraca użytkownika
   - błędne hasło → UnauthorizedException
   - niepotwierdzony email → UnauthorizedException z odpowiednim komunikatem
   - nieistniejący użytkownik → UnauthorizedException
   - brak internetu → NoInternetException
   - nieprawidłowy format email → ValidationException

✅ signUp()
   - poprawne dane → sukces, wysłany email weryfikacyjny
   - istniejący email → ValidationException
   - słabe hasło → ValidationException
   - nieprawidłowy format email → ValidationException
   - brak internetu → NoInternetException

✅ signOut()
   - poprawne wylogowanie → czyści sesję
   - błąd serwera → ServerException

✅ sendPasswordResetEmail()
   - poprawny email → email wysłany
   - nieprawidłowy email → ValidationException
   - nieistniejący użytkownik → nie rzuca błędem (security by obscurity)

✅ updateUserPassword()
   - zalogowany użytkownik, dobre hasło → sukces
   - niezalogowany → UnauthorizedException
   - słabe hasło → ValidationException

✅ resendConfirmationEmail()
   - poprawny email → email wysłany ponownie
   - nieprawidłowy email → ValidationException
```

**Strategia mockowania:**
- Mock `SupabaseClient` i `GoTrueClient`
- Mock odpowiedzi API z różnymi kodami błędów
- Testy izolowane (bez prawdziwych połączeń sieciowych)

---

### 🟡 1.2 BookService (Wysoki priorytet)

**Lokalizacja:** `lib/services/book_service.dart`

**Dlaczego testować:**
- Główna logika biznesowa aplikacji
- Złożone query z filtrowaniem, sortowaniem i paginacją
- Transformacje między formatami DTO
- Walidacja UUID i parametrów
- Obsługa RLS (Row-Level Security)

**Co testować:**

```dart
✅ listBooks()
   - bez filtrów → zwraca wszystkie książki użytkownika
   - filtr status → zwraca tylko książki o danym statusie
   - filtr genre → zwraca tylko książki danego gatunku
   - sortowanie asc/desc → prawidłowa kolejność
   - paginacja (limit/offset) → prawidłowe strony
   - nieprawidłowy genreId → ValidationException
   - limit > 1000 → ValidationException
   - brak autoryzacji → UnauthorizedException
   - pusta lista → zwraca []

✅ getBook()
   - istniejąca książka → zwraca BookDetailDto z gatunkiem
   - nieistniejąca książka → NotFoundException
   - książka innego użytkownika → NotFoundException (RLS)
   - nieprawidłowy UUID → ValidationException

✅ createBook()
   - poprawne dane → tworzy książkę, zwraca ID
   - brak wymaganych pól → ValidationException
   - nieprawidłowy genreId → ValidationException
   - liczba stron <= 0 → ValidationException

✅ updateBook()
   - poprawne dane → aktualizuje książkę
   - nieistniejąca książka → NotFoundException
   - książka innego użytkownika → NotFoundException
   - nieprawidłowe dane → ValidationException

✅ deleteBook()
   - istniejąca książka → usuwa książkę
   - nieistniejąca książka → NotFoundException
   - książka innego użytkownika → NotFoundException

✅ markBookAsRead()
   - książka in_progress → zmienia na read, ustawia 100% progress
   - książka already read → nie zmienia stanu
```

**Uwagi implementacyjne:**
- Mock Supabase PostgrestFilterBuilder
- Testy walidacji UUID
- Testy transformacji DTO ↔ Database entities

---

### 🟡 1.3 ReadingSessionService (Wysoki priorytet)

**Lokalizacja:** `lib/services/reading_session_service.dart`

**Dlaczego testować:**
- Złożona transakcja: tworzenie sesji + update książki
- Kalkulacja postępu czytania (procent przeczytanych stron)
- Logika "zero progress" (nie tworzy sesji gdy lastReadPage === currentPage)
- Walidacja czasów (startTime < endTime)

**Co testować:**

```dart
✅ listReadingSessions()
   - poprawny bookId → zwraca posortowane sesje
   - nieprawidłowy UUID → ValidationException
   - pusta lista → []
   - sortowanie ascending/descending

✅ endReadingSession()
   - normalny postęp → tworzy sesję, aktualizuje książkę
   - zero postępu (lastPage === currentPage) → zwraca null, nie tworzy sesji
   - startTime > endTime → ValidationException
   - lastReadPage > totalPages → ValidationException
   - lastReadPage < currentPage → ValidationException
   - nieistniejąca książka → NotFoundException
   - kalkulacja progress_percent = (lastReadPage / totalPages) * 100
   - zmiana statusu: not_started → in_progress
   - zmiana statusu: in_progress → in_progress (update page)
   - automatyczne ustawienie status=read gdy lastPage === totalPages
```

**Kluczowe scenariusze:**
- Edge case: książka 1-stronicowa
- Edge case: długa sesja (np. 5 godzin)
- Edge case: ostatnia strona książki → auto-mark as read

---

### 🟡 1.4 GoogleBooksService (Średni priorytet)

**Lokalizacja:** `lib/services/google_books_api_service.dart`

**Dlaczego testować:**
- Integracja z zewnętrznym API
- Parsowanie JSON z Google Books API
- Transformacja do własnego modelu danych
- Obsługa timeoutów i błędów HTTP

**Co testować:**

```dart
✅ fetchBookByISBN()
   - poprawny ISBN-10 → zwraca GoogleBookResult
   - poprawny ISBN-13 → zwraca GoogleBookResult
   - ISBN z myślnikami/spacjami → czyści i szuka
   - nieistniejący ISBN → zwraca null
   - błąd sieci → zwraca null
   - timeout → zwraca null
   - nieprawidłowa odpowiedź JSON → zwraca null
   - brak pola volumeInfo → zwraca null
```

**Mock strategy:**
- Mock `http.Client`
- Przygotuj przykładowe odpowiedzi JSON z Google Books API
- Test edge cases z brakującymi polami

---

### 🟡 1.5 GenreService (Średni priorytet)

**Lokalizacja:** `lib/services/genre_service.dart`

**Dlaczego testować:**
- Prosta logika, ale krytyczna dla spójności danych
- Cache layer (jeśli zaimplementowany)
- Transformacja GenreDto

**Co testować:**

```dart
✅ listGenres()
   - zwraca posortowaną listę gatunków
   - pusta baza → zwraca []
   - brak autoryzacji → UnauthorizedException
   - sortowanie alfabetyczne
```

---

## 2. BLoCs - Zarządzanie stanem

### 🔴 2.1 AuthBloc (Krytyczny)

**Lokalizacja:** `lib/features/auth/bloc/auth_bloc.dart`

**Dlaczego testować:**
- Zarządza globalnym stanem autoryzacji
- Koordynuje między UI a AuthService
- Obsługuje auth state stream z Supabase
- Mapowanie wyjątków na user-friendly komunikaty

**Co testować:**

```dart
✅ SignInRequested event
   - sukces → emituje [AuthLoading, Authenticated]
   - błąd autoryzacji → emituje [AuthLoading, AuthError, Unauthenticated]
   - brak internetu → emituje [AuthLoading, AuthError] z odpowiednim komunikatem

✅ SignUpRequested event
   - sukces → emituje [AuthLoading, SignUpSuccess]
   - duplikat email → emituje [AuthLoading, AuthError]

✅ SignOutRequested event
   - sukces → emituje [AuthLoading, Unauthenticated]
   - błąd → emituje [AuthLoading, AuthError]

✅ PasswordResetRequested event
   - sukces → emituje [AuthLoading, PasswordResetEmailSent]
   - błąd → emituje [AuthLoading, AuthError]

✅ PasswordUpdateRequested event
   - sukces → emituje [AuthLoading, PasswordUpdateSuccess]
   - niezalogowany → emituje [AuthLoading, AuthError]

✅ ConfirmationEmailResendRequested event
   - sukces → emituje [AuthLoading, ConfirmationEmailResent]
   - błąd → emituje [AuthLoading, AuthError]

✅ AuthStatusChecked event
   - zalogowany użytkownik → emituje Authenticated
   - niezalogowany → emituje Unauthenticated

✅ AuthErrorCleared event
   - czyści błąd, przywraca previousState
```

**Test strategy:**
- Mock AuthService
- Użyj `bloc_test` package
- Testy async event handling
- Testy subscription lifecycle (setup/dispose)

---

### 🟡 2.2 HomeScreenBloc (Wysoki priorytet)

**Lokalizacja:** `lib/features/home/bloc/home_screen_bloc.dart`

**Dlaczego testować:**
- Główny ekran aplikacji
- Zarządzanie filtrami i sortowaniem
- Obsługa refresh (pull-to-refresh)
- Przechowuje stan filtrów między wywołaniami

**Co testować:**

```dart
✅ LoadBooksEvent
   - sukces z książkami → emituje [HomeScreenLoading, HomeScreenSuccess]
   - pusta lista → emituje [HomeScreenLoading, HomeScreenEmpty]
   - z filtrami → przekazuje filtry do BookService
   - zachowuje poprzednie filtry jeśli nie podano nowych
   - błąd sieci → emituje [HomeScreenLoading, HomeScreenError]
   - błąd autoryzacji → emituje [HomeScreenLoading, HomeScreenError]

✅ RefreshBooksEvent
   - używa cached filters
   - emituje ten sam flow co LoadBooksEvent
```

**State machine testing:**
```
Initial → Loading → Success (with books)
Initial → Loading → Empty (no books)
Initial → Loading → Error
Success → Loading → Success (after refresh)
```

---

### 🟡 2.3 AddBookBloc (Wysoki priorytet)

**Lokalizacja:** `lib/features/add_book/bloc/add_book_bloc.dart`

**Dlaczego testować:**
- Integracja z Google Books API
- Cache layer dla gatunków
- Obsługa tworzenia i edycji książki
- Transformacje ViewModel ↔ DTO

**Co testować:**

```dart
✅ FetchBookByIsbn event
   - znaleziono książkę → emituje [AddBookLoading, BookFound/AddBookReady]
   - nie znaleziono → emituje [AddBookLoading, AddBookError]
   - używa cached genres jeśli dostępne
   - błąd sieci → emituje [AddBookLoading, AddBookError]

✅ SaveBook event (create)
   - poprawne dane → emituje [AddBookLoading, BookSaved]
   - błąd walidacji → emituje [AddBookLoading, AddBookError]
   - błąd sieci → emituje [AddBookLoading, AddBookError]

✅ SaveBook event (update)
   - poprawne dane → emituje [AddBookLoading, BookSaved]
   - nieistniejąca książka → emituje [AddBookLoading, AddBookError]

✅ FetchGenres event
   - sukces → emituje [AddBookLoading, AddBookReady] + cache genres
   - używa cache jeśli dostępne (nie odpytuje ponownie)
   - błąd → emituje [AddBookLoading, AddBookError]
```

---

### 🟡 2.4 BookDetailsBloc (Wysoki priorytet)

**Lokalizacja:** `lib/features/book_detail/bloc/book_details_bloc.dart`

**Dlaczego testować:**
- Koordynuje wiele operacji (fetch book + sessions)
- Obsługuje akcje użytkownika (mark as read, delete)
- Cache layer dla optymizacji
- Parallel data fetching

**Co testować:**

```dart
✅ FetchBookDetails event
   - sukces → emituje [BookDetailsLoading, BookDetailsSuccess]
   - parallel fetch (book + sessions)
   - cache book i sessions dla akcji
   - nieistniejąca książka → emituje [BookDetailsLoading, BookDetailsFailure]
   - błąd sieci → emituje [BookDetailsLoading, BookDetailsFailure]

✅ MarkAsReadRequested event
   - sukces → emituje [BookDetailsActionInProgress, BookDetailsSuccess]
   - zachowuje cached sessions
   - błąd → emituje [BookDetailsActionInProgress, BookDetailsActionFailure]

✅ DeleteBookRequested event
   - emituje BookDetailsDeleteConfirmation (wymaga potwierdzenia)

✅ DeleteBookConfirmed event
   - sukces → emituje [BookDetailsActionInProgress, BookDetailsDeleted]
   - błąd → emituje [BookDetailsActionInProgress, BookDetailsActionFailure]

✅ EndSessionConfirmed event
   - sukces → refresh book details
   - błąd → emituje error state
```

---

### 🟡 2.5 ReadingSessionBloc (Wysoki priorytet)

**Lokalizacja:** `lib/features/reading_session/bloc/reading_session_bloc.dart`

**Dlaczego testować:**
- Zarządza stopwatch'em sesji czytania
- Koordynuje dialog z API call
- Walidacja input użytkownika

**Co testować:**

```dart
✅ SessionStarted event
   - inicjalizuje sesję z bookId i startTime
   - emituje ReadingSessionState(status: inProgress)

✅ EndSessionButtonTapped event
   - zmienia status na showDialog
   - nie wywołuje API (tylko zmienia stan)

✅ SessionFinished event
   - poprawne dane → wywołuje API, emituje success
   - zero progress → emituje success z komunikatem
   - błąd API → emituje failure z errorMessage

✅ DialogDismissed event
   - wraca do stanu inProgress
```

**State flow testing:**
```
initial → inProgress (SessionStarted)
inProgress → showDialog (EndSessionButtonTapped)
showDialog → submitting → success (SessionFinished)
showDialog → inProgress (DialogDismissed/cancel)
```

---

### 🟢 2.6 OnboardingCubit (Średni priorytet)

**Lokalizacja:** `lib/features/onboarding/cubit/onboarding_cubit.dart`

**Dlaczego testować:**
- Prostszy od BLoC, ale zarządza user experience
- Interakcja z SharedPreferences/Storage

**Co testować:**

```dart
✅ checkOnboardingStatus()
   - pierwszy launch → emituje show
   - ukończony onboarding → emituje hide

✅ markOnboardingAsCompleted()
   - zapisuje w storage
   - emituje completed
   - następne checkStatus → hide
```

---

## 3. Modele i transformacje danych

### 🟡 3.1 DTO Classes (Wysoki priorytet)

**Lokalizacja:** `lib/models/types.dart`

**Dlaczego testować:**
- Freezed/JSON serialization może zawierać błędy
- Transformacje między formatami
- Walidacja constrain'tów biznesowych

**Co testować:**

```dart
✅ BookListItemDto
   - fromJson() z pełnymi danymi
   - fromJson() z opcjonalnymi nullami (genre, coverUrl)
   - toJson() round-trip
   - fromDbEntity() z Supabase Books

✅ BookDetailDto
   - fromJson() z embeddowanym genre
   - obsługa null genre (książka bez gatunku)
   - kalkulacja progress_percent

✅ CreateBookDto / UpdateBookDto
   - toJson() z wszystkimi polami
   - walidacja wymaganych pól
   - obsługa null dla opcjonalnych pól

✅ EndReadingSessionDto
   - toJson() transformacja DateTime
   - walidacja startTime < endTime
   - walidacja lastReadPage >= 0

✅ GoogleBookResult
   - fromJson() z volumeInfo
   - obsługa brakujących pól (authors, publisher, etc.)
   - wyciąganie ISBN-10 i ISBN-13 z industryIdentifiers
```

---

### 🟡 3.2 ViewModels (Wysoki priorytet)

**Lokalizacja:** `lib/features/add_book/models/add_book_form_view_model.dart`

**Dlaczego testować:**
- Transformacje między różnymi warstwami
- Logika konwersji (GoogleBook → ViewModel → DTO)

**Co testować:**

```dart
✅ AddBookFormViewModel.fromGoogleBook()
   - mapuje wszystkie pola
   - obsługa null fields
   - wyciąga pierwszy gatunek z categories

✅ toCreateBookDto()
   - konwertuje wszystkie pola
   - obsługa null dla opcjonalnych
   - walidacja biznesowa

✅ toUpdateBookDto()
   - podobnie jak create, ale może być częściowe
```

---

## 4. Walidatory i business logic helpers

### 🟢 4.1 Form validators (Średni priorytet)

**Lokalizacja:** Rozproszone w `features/*/view/*.dart`

**Dlaczego testować:**
- Duplikacja logiki walidacji w różnych ekranach
- Łatwe do ekstrakcji do utility class
- Krytyczne dla UX (user feedback)

**Kandydaci do testowania (po refactorze do utility):**

```dart
✅ EmailValidator
   - prawidłowy email → null (no error)
   - puste pole → komunikat błędu
   - nieprawidłowy format → komunikat błędu
   - edge cases: "test@", "@example.com", "test @example.com"

✅ PasswordValidator
   - >= 8 znaków → null
   - < 8 znaków → komunikat błędu
   - puste pole → komunikat błędu

✅ PasswordMatchValidator
   - hasła identyczne → null
   - hasła różne → komunikat błędu

✅ PageCountValidator
   - liczba > 0 → null
   - liczba <= 0 → komunikat błędu
   - tekst niebędący liczbą → komunikat błędu
   - puste pole → komunikat błędu

✅ YearValidator
   - 4-cyfrowy rok (1000-obecnie+1) → null
   - nieprawidłowy rok → komunikat błędu
   - puste pole → null (opcjonalne)
```

**Rekomendacja refactoringu:**
```dart
// lib/core/validators.dart
class Validators {
  static String? validateEmail(String? value) { ... }
  static String? validatePassword(String? value) { ... }
  static String? validatePasswordMatch(String? value, String password) { ... }
  static String? validatePageCount(String? value) { ... }
  static String? validateYear(String? value) { ... }
}
```

---

### 🟢 4.2 Constants i configuration (Niski priorytet)

**Lokalizacja:** `lib/core/constants.dart`

**Co testować:**
```dart
✅ BOOK_STATUS enum values
✅ Default pagination limits
✅ Timeout durations
```

---

## 5. Exceptions i error handling

### 🟡 5.1 Custom Exceptions (Wysoki priorytet)

**Lokalizacja:** `lib/core/exceptions.dart`

**Dlaczego testować:**
- Hierarchia wyjątków
- Komunikaty error'ów
- Mapowanie Supabase errors → custom exceptions

**Co testować:**

```dart
✅ Exception hierarchy
   - ValidationException extends AppException
   - UnauthorizedException extends AppException
   - etc.

✅ Error messages
   - każdy wyjątek ma sensowny message
   - message jest user-friendly (po polsku)

✅ Factory methods (jeśli są)
   - Exception.fromSupabaseError()
   - Exception.fromHttpStatusCode()
```

---

## 6. Strategia implementacji testów

### 6.1 Priorytetyzacja (w kolejności)

1. **Sprint 1 - Bezpieczeństwo** (2-3 dni)
   - ✅ AuthService (wszystkie metody)
   - ✅ AuthBloc (wszystkie eventy)

2. **Sprint 2 - Core business logic** (3-4 dni)
   - ✅ BookService (CRUD + listBooks)
   - ✅ ReadingSessionService
   - ✅ HomeScreenBloc

3. **Sprint 3 - Feature BLoCs** (2-3 dni)
   - ✅ AddBookBloc
   - ✅ BookDetailsBloc
   - ✅ ReadingSessionBloc

4. **Sprint 4 - Data transformations** (2 dni)
   - ✅ DTOs (wszystkie typy)
   - ✅ ViewModels

5. **Sprint 5 - Utilities** (1 dzień)
   - ✅ Validators (po refactorze)
   - ✅ Exceptions
   - ✅ GoogleBooksService

### 6.2 Narzędzia i dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0        # Testing BLoCs
  mocktail: ^1.0.0         # Modern mocking (null-safe)
  fake_async: ^1.3.0       # Testing time-dependent code
  http_mock_adapter: ^0.6.0 # Mocking HTTP requests
```

### 6.3 Test structure template

```dart
// test/services/book_service_test.dart
void main() {
  group('BookService', () {
    late MockSupabaseClient mockSupabase;
    late BookService bookService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      bookService = BookService(mockSupabase);
    });

    group('listBooks', () {
      test('returns list of books when API call succeeds', () async {
        // Arrange
        final mockData = [...];
        when(() => mockSupabase.from('books').select(...))
            .thenAnswer((_) async => mockData);

        // Act
        final result = await bookService.listBooks();

        // Assert
        expect(result, isA<List<BookListItemDto>>());
        expect(result.length, equals(2));
        verify(() => mockSupabase.from('books').select(...)).called(1);
      });

      test('throws ValidationException when genreId is invalid', () async {
        // Arrange
        const invalidGenreId = 'not-a-uuid';

        // Act & Assert
        expect(
          () => bookService.listBooks(genreId: invalidGenreId),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
```

### 6.4 Metryki sukcesu

**Docelowe pokrycie (coverage):**
- Services: **90%+** (krytyczna logika)
- BLoCs: **85%+** (state management)
- DTOs: **80%+** (transformacje)
- Validators: **95%+** (prosta logika, łatwa do 100%)
- Ogólne pokrycie projektu: **75%+**

**Uruchomienie testów:**
```bash
# Wszystkie testy
flutter test

# Z coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Konkretny plik
flutter test test/services/auth_service_test.dart

# Z verbose output
flutter test --reporter expanded
```

---

## 7. Dodatkowe rekomendacje

### 7.1 Integration tests (opcjonalnie)

Po unit testach warto dodać kilka kluczowych integration tests:

```dart
✅ Auth flow end-to-end
   - Sign up → Email verification → Sign in → Sign out

✅ Book CRUD flow
   - Create book → View details → Update → Delete

✅ Reading session flow
   - Start session → End session → View history
```

### 7.2 Widget tests (opcjonalnie)

Wybrane widgety z złożoną logiką UI:

```dart
✅ AuthGate - routing based on auth state
✅ HomeScreenContent - różne stany (loading, empty, success, error)
✅ BookFormScreen - form validation
```

### 7.3 Golden tests (opcjonalnie)

Snapshot testing dla kluczowych ekranów:
- LoginScreen
- HomeScreen (różne stany)
- BookDetailScreen

---

## 8. Podsumowanie

### Dlaczego te testy są ważne?

1. **Bezpieczeństwo** - AuthService i AuthBloc zarządzają dostępem do całej aplikacji
2. **Integralnośc danych** - BookService i ReadingSessionService muszą zachowywać spójność
3. **User Experience** - BLoCs muszą poprawnie obsługiwać stany loading/success/error
4. **Refactoring confidence** - Testy pozwolą bezpiecznie refaktorować kod
5. **Dokumentacja** - Testy służą jako living documentation
6. **Regression prevention** - Zapobieganie powrotowi już naprawionych bugów

### Szacowany nakład pracy

- **Setup testów + CI/CD:** 1 dzień
- **Implementacja testów (według priorytetów):** 10-12 dni
- **Maintenance (ciągłe):** ~10% czasu development

### Return on Investment (ROI)

- ⬇️ Redukcja bugów w produkcji: **60-80%**
- ⬆️ Szybkość dodawania features: **+30%** (po okresie initial investment)
- ⬆️ Confidence w deployments: **+90%**
- ⬇️ Czas debugowania: **-50%**

---

**Następne kroki:**
1. ✅ Review tego dokumentu z zespołem
2. ⬜ Setup test infrastructure (mocktail, bloc_test)
3. ⬜ Implement Sprint 1 (AuthService + AuthBloc)
4. ⬜ Setup CI/CD z automatycznym uruchamianiem testów
5. ⬜ Kontynuacja według harmonogramu sprintów

**Autor:** GitHub Copilot  
**Review wymagany:** Tech Lead / Senior Developer

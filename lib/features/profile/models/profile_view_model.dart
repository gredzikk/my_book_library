/// Model widoku profilu użytkownika
///
/// Przechowuje dane potrzebne do wyświetlenia na ekranie profilu,
/// w tym informacje o użytkowniku, statystyki i stany ładowania/błędów.
class ProfileViewModel {
  /// Adres e-mail aktualnie zalogowanego użytkownika
  final String userEmail;

  /// Łączna liczba książek w bibliotece użytkownika
  /// Może być null w trakcie ładowania lub w przypadku błędu
  final int? bookCount;

  /// Flaga informująca, czy dane są w trakcie pobierania
  final bool isLoading;

  /// Komunikat o błędzie, jeśli wystąpił problem z pobraniem danych
  final String? errorMessage;

  const ProfileViewModel({
    required this.userEmail,
    this.bookCount,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Tworzy kopię z możliwością nadpisania wybranych pól
  ProfileViewModel copyWith({
    String? userEmail,
    int? bookCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileViewModel(
      userEmail: userEmail ?? this.userEmail,
      bookCount: bookCount ?? this.bookCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

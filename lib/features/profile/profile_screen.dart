import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/book_service.dart';
import '../../widgets/auth_gate.dart';
import 'models/profile_view_model.dart';
import 'widgets/user_info_card.dart';
import 'widgets/book_stats_card.dart';
import 'widgets/theme_toggle_card.dart';
import 'widgets/app_version_card.dart';
import 'widgets/logout_button.dart';

/// Ekran profilu użytkownika
///
/// Wyświetla informacje o koncie użytkownika (email) oraz statystyki
/// dotyczące biblioteki książek. Umożliwia również wylogowanie.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  /// Inicjalizuje profil użytkownika i pobiera dane
  void _initializeProfile() {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      // Brak zalogowanego użytkownika - stan błędu
      setState(() {
        _viewModel = const ProfileViewModel(
          userEmail: '',
          isLoading: false,
          errorMessage: 'Brak aktywnej sesji użytkownika',
        );
      });
      return;
    }

    // Inicjalizacja ze stanem ładowania
    setState(() {
      _viewModel = ProfileViewModel(
        userEmail: currentUser.email!,
        isLoading: true,
      );
    });

    // Asynchroniczne pobranie liczby książek
    _fetchBookCount();
  }

  /// Pobiera liczbę książek z bazy danych
  Future<void> _fetchBookCount() async {
    try {
      final bookService = context.read<BookService>();
      final books = await bookService.listBooks();

      if (mounted) {
        setState(() {
          _viewModel = _viewModel.copyWith(
            bookCount: books.length,
            isLoading: false,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _viewModel = _viewModel.copyWith(
            isLoading: false,
            errorMessage: 'Nie udało się załadować statystyk',
          );
        });
      }
    }
  }

  /// Obsługuje wylogowanie użytkownika
  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();

      // Przekieruj do ekranu uwierzytelnienia
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wylogowanie nie powiodło się. Spróbuj ponownie.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wyświetl błąd braku sesji
    if (_viewModel.userEmail.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _viewModel.errorMessage ?? 'Wystąpił błąd',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Powrót'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 16.0 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User info
                UserInfoCard(viewModel: _viewModel),
                const SizedBox(height: 16),

                // Book stats
                BookStatsCard(viewModel: _viewModel),
                const SizedBox(height: 16),

                // Theme toggle
                const ThemeToggleCard(),
                const SizedBox(height: 16),

                // App version
                const AppVersionCard(),
                const SizedBox(height: 24),

                // Logout button
                LogoutButton(onLogout: _handleLogout),
              ],
            ),
          ),

          // Nakładka podczas wylogowywania
          if (_isLoggingOut)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

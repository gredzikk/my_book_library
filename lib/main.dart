import 'package:flutter/material.dart';
import 'package:my_book_library/config/app_theme.dart';
import 'package:my_book_library/config/theme_cubit.dart';
import 'package:my_book_library/services/reading_session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';

// Import widgets and services
import 'widgets/auth_gate.dart';
import 'services/book_service.dart';
import 'services/genre_service.dart';
import 'services/google_books_api_service.dart';
import 'services/auth_service.dart';
import 'features/auth/bloc/bloc.dart';

Future<void> main() async {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      '${record.level.name}: ${record.message}',
      name: record.loggerName,
      time: record.time,
    );
  });

  // Initialize date formatting for Polish locale
  await initializeDateFormatting('pl_PL', null);

  // Load environment variables
  //.env.dev for test db instance
  //.env.prod for production
  await dotenv.load(fileName: ".env");

  // Try to get variables from dart-define
  String supabaseUrl = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  String supabaseAnonKey = const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // If not available, fall back to .env file
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    supabaseUrl = dotenv.env['SUPABASE_URL']!;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  }

  // Initialize Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  dev.log("Supabase initialized with url: $supabaseUrl");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final Logger _logger = Logger('MyApp');
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /// Initialize deep link handling for email confirmation and password reset
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial deep link if app was opened via email link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _logger.info('App opened with initial deep link: $initialUri');
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      _logger.severe('Error handling initial deep link: $e');
    }

    // Listen for deep links while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        _logger.info('Received deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        _logger.severe('Error in deep link stream: $err');
      },
    );
  }

  /// Handle deep link from email confirmation or password reset
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      _logger.info('Processing deep link: ${uri.toString()}');

      // Check if this is a login callback with authentication fragments
      if (uri.host == 'login-callback') {
        // Supabase handles the auth callback automatically via the SDK
        // The onAuthStateChange stream will trigger and update the AuthBloc
        _logger.info(
          'Login callback detected, Supabase will handle authentication',
        );

        // Wait a moment for Supabase to process the auth callback
        await Future.delayed(const Duration(milliseconds: 500));

        // The AuthBloc will automatically update via the authStateChanges stream
        _logger.info('Auth callback processed, user should be authenticated');
      }
    } catch (e) {
      _logger.severe('Error handling deep link: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Services
        RepositoryProvider(
          create: (context) => BookService(Supabase.instance.client),
        ),
        RepositoryProvider(
          create: (context) => GenreService(Supabase.instance.client),
        ),
        RepositoryProvider(create: (context) => GoogleBooksService()),
        RepositoryProvider<ReadingSessionService>(
          create: (_) => ReadingSessionService(Supabase.instance.client),
        ),
        RepositoryProvider<AuthService>(
          create: (_) => AuthService(Supabase.instance.client),
        ),

        // BLoCs and Cubits
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: context.read<AuthService>()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          _logger.fine(
            'MaterialApp - Rebuilding with theme: ${themeState.runtimeType}',
          );
          return MaterialApp(
            title: 'My Book Library',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: context.read<ThemeCubit>().themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

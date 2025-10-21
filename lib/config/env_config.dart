/// Environment configuration for different stages (dev, test, production)
enum Environment { dev, test, production }

class EnvConfig {
  static Environment _current = Environment.dev;

  /// Get current environment
  static Environment get current => _current;

  /// Set environment (useful for testing)
  static void setEnvironment(Environment env) {
    _current = env;
  }

  /// Get Supabase URL based on environment
  static String get supabaseUrl {
    switch (_current) {
      case Environment.test:
        // Test environment - osobna baza danych Supabase dla testów E2E
        return const String.fromEnvironment(
          'SUPABASE_TEST_URL',
          defaultValue: '', // Fallback - może być pusty w dev
        );
      case Environment.dev:
        return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_PROD_URL',
          defaultValue: '',
        );
    }
  }

  /// Get Supabase Anon Key based on environment
  static String get supabaseAnonKey {
    switch (_current) {
      case Environment.test:
        return const String.fromEnvironment(
          'SUPABASE_TEST_ANON_KEY',
          defaultValue: '',
        );
      case Environment.dev:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: '',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_PROD_ANON_KEY',
          defaultValue: '',
        );
    }
  }

  /// Check if current environment is test
  static bool get isTest => _current == Environment.test;

  /// Check if current environment is production
  static bool get isProduction => _current == Environment.production;

  /// Check if current environment is dev
  static bool get isDev => _current == Environment.dev;
}

import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class for managing test data in E2E tests
class TestDataHelper {
  final SupabaseClient supabase;
  final _random = Random();

  TestDataHelper(this.supabase);

  /// Generate unique test email with timestamp
  String generateTestEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(9999);
    return 'test_user_${timestamp}_$randomSuffix@e2etest.com';
  }

  /// Generate test password
  String generateTestPassword() {
    return 'TestPass123!@#';
  }

  /// Get user ID by email
  Future<String?> getUserIdByEmail(String email) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      return response?['id'] as String?;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  /// Cleanup all data for a test user
  /// IMPORTANT: Must be called in tearDown to avoid polluting test database
  Future<void> cleanupTestUser(String userId) async {
    try {
      print('[TestDataHelper] Cleaning up user: $userId');

      // 1. Delete reading sessions first (foreign key constraint)
      await supabase.from('reading_sessions').delete().eq('user_id', userId);
      print('[TestDataHelper] Deleted reading sessions');

      // 2. Delete books
      await supabase.from('books').delete().eq('user_id', userId);
      print('[TestDataHelper] Deleted books');

      // 3. Delete user profile
      await supabase.from('profiles').delete().eq('id', userId);
      print('[TestDataHelper] Deleted profile');

      // 4. Delete auth user (requires service role key or admin API)
      // Note: This might not work with anon key, but we try
      try {
        await supabase.auth.admin.deleteUser(userId);
        print('[TestDataHelper] Deleted auth user');
      } catch (e) {
        print(
          '[TestDataHelper] Could not delete auth user (may require admin key): $e',
        );
      }

      print('[TestDataHelper] Cleanup completed for user: $userId');
    } catch (e) {
      print('[TestDataHelper] Error during cleanup: $e');
      // Don't rethrow - we want tests to complete even if cleanup fails
    }
  }

  /// Seed test books for a user
  Future<List<String>> seedTestBooks(String userId, {int count = 3}) async {
    final bookIds = <String>[];

    for (int i = 0; i < count; i++) {
      final response = await supabase
          .from('books')
          .insert({
            'user_id': userId,
            'title': 'Test Book ${i + 1}',
            'author': 'Test Author ${i + 1}',
            'page_count': 100 + (i * 50),
            'current_page': 0,
            'progress_percent': 0,
            'status': i == 0
                ? 'not_started'
                : (i == 1 ? 'in_progress' : 'read'),
            'isbn': '978000000000${i}',
          })
          .select('id')
          .single();

      bookIds.add(response['id'] as String);
    }

    print('[TestDataHelper] Seeded $count test books for user: $userId');
    return bookIds;
  }

  /// Seed test reading sessions for a book
  Future<void> seedTestSessions(
    String userId,
    String bookId, {
    int count = 2,
  }) async {
    for (int i = 0; i < count; i++) {
      final startTime = DateTime.now().subtract(Duration(days: count - i));
      final endTime = startTime.add(Duration(hours: 1));

      await supabase.from('reading_sessions').insert({
        'user_id': userId,
        'book_id': bookId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'pages_read': 20 + (i * 10),
      });
    }

    print('[TestDataHelper] Seeded $count test sessions for book: $bookId');
  }

  /// Create a fully set up test user with books and sessions
  Future<TestUserFixture> createFullTestFixture() async {
    final email = generateTestEmail();
    final password = generateTestPassword();

    // Register user
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create test user');
    }

    final userId = authResponse.user!.id;

    // Seed books
    final bookIds = await seedTestBooks(userId);

    // Seed sessions for first book
    if (bookIds.isNotEmpty) {
      await seedTestSessions(userId, bookIds.first);
    }

    return TestUserFixture(
      userId: userId,
      email: email,
      password: password,
      bookIds: bookIds,
    );
  }

  /// Wait for async operations to complete
  Future<void> waitFor(Duration duration) async {
    await Future.delayed(duration);
  }
}

/// Fixture containing test user data
class TestUserFixture {
  final String userId;
  final String email;
  final String password;
  final List<String> bookIds;

  TestUserFixture({
    required this.userId,
    required this.email,
    required this.password,
    required this.bookIds,
  });
}

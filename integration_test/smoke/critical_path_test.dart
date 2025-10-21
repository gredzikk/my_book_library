import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_book_library/config/env_config.dart';
import 'package:my_book_library/main.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_data_helper.dart';
import '../helpers/test_reporter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Smoke Tests - Critical Path', () {
    late TestDataHelper testDataHelper;
    String? testUserId;
    final stopwatch = Stopwatch();

    setUpAll(() async {
      TestReporter.logStep('Setting up test environment');

      // Set environment to test BEFORE initializing Supabase
      EnvConfig.setEnvironment(Environment.test);

      // Note: Supabase will be initialized in app.main()
      // Make sure your test Supabase credentials are in environment variables
    });

    setUp(() async {
      stopwatch.start();
      // Initialize test data helper with Supabase client
      // We'll get the client after app initialization
    });

    tearDown(() async {
      stopwatch.stop();

      // Cleanup test user if created
      if (testUserId != null) {
        try {
          final supabase = Supabase.instance.client;
          testDataHelper = TestDataHelper(supabase);
          await testDataHelper.cleanupTestUser(testUserId!);
          testUserId = null;
        } catch (e) {
          TestReporter.logError('Cleanup failed', StackTrace.current);
        }
      }

      stopwatch.reset();
    });

    testWidgets(
      'TC-SMOKE-01: Complete user journey - Register, Add Book, Read Session',
      (WidgetTester tester) async {
        final testName = 'Complete User Journey';
        TestReporter.logTestStart(testName);

        try {
          // ==========================================
          // GIVEN: App is launched
          // ==========================================
          TestReporter.logStep('Launching application');
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Initialize test data helper
          final supabase = Supabase.instance.client;
          testDataHelper = TestDataHelper(supabase);

          // Clear any existing session (important for test isolation)
          TestReporter.logStep('Clearing any existing user session');
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final testEmail = testDataHelper.generateTestEmail();
          final testPassword = testDataHelper.generateTestPassword();

          TestReporter.logStep('Generated test credentials: $testEmail');

          // ==========================================
          // WHEN: User navigates to registration
          // ==========================================
          TestReporter.logStep('Navigating to registration screen');

          // Look for register button/link on login screen
          final registerButton = find.text('Zarejestruj się');
          expect(registerButton, findsOneWidget);
          await tester.tap(registerButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Registration screen displayed');

          // ==========================================
          // WHEN: User registers with valid credentials
          // ==========================================
          TestReporter.logStep('Filling registration form');

          // Find email field by type or key
          final emailField = find.byType(TextField).first;
          await tester.enterText(emailField, testEmail);
          await tester.pumpAndSettle();

          // Find password field
          final passwordFields = find.byType(TextField);
          await tester.enterText(passwordFields.at(1), testPassword);
          await tester.pumpAndSettle();

          // Confirm password
          await tester.enterText(passwordFields.at(2), testPassword);
          await tester.pumpAndSettle();

          TestReporter.logStep('Submitting registration');
          final submitButton = find.widgetWithText(
            FilledButton,
            'Zarejestruj się',
          );
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // ==========================================
          // THEN: User should be registered and see onboarding or home
          // ==========================================
          TestReporter.logStep('Verifying successful registration');

          // Store user ID for cleanup
          final user = supabase.auth.currentUser;
          expect(
            user,
            isNotNull,
            reason: 'User should be logged in after registration',
          );
          testUserId = user!.id;

          TestReporter.logAssertion('User registered with ID: $testUserId');

          // Wait for home screen to fully load
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // ==========================================
          // WHEN: User adds a book manually
          // ==========================================
          TestReporter.logStep('Adding a new book');

          // Find and tap the add book button (FAB)
          final addButton = find.byType(FloatingActionButton);
          expect(addButton, findsOneWidget);
          await tester.tap(addButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Add book screen displayed');

          // Fill book details manually
          TestReporter.logStep('Filling book details');
          final bookTitleField = find.byType(TextField).first;
          await tester.enterText(bookTitleField, 'Test Book E2E');
          await tester.pumpAndSettle();

          final bookAuthorField = find.byType(TextField).at(1);
          await tester.enterText(bookAuthorField, 'Test Author E2E');
          await tester.pumpAndSettle();

          // Page count
          final pageCountField = find.byType(TextField).at(2);
          await tester.enterText(pageCountField, '300');
          await tester.pumpAndSettle();

          // Save book
          TestReporter.logStep('Saving book');
          final saveBookButton = find.widgetWithText(
            FilledButton,
            'Dodaj książkę',
          );
          await tester.tap(saveBookButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // ==========================================
          // THEN: Book should appear on home screen
          // ==========================================
          TestReporter.logAssertion('Book appears on home screen');
          expect(find.text('Test Book E2E'), findsOneWidget);

          // ==========================================
          // WHEN: User starts a reading session
          // ==========================================
          TestReporter.logStep('Starting reading session');

          // Tap on the book to open details
          await tester.tap(find.text('Test Book E2E'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Book details screen displayed');

          // Find and tap "Start reading" button
          final startReadingButton = find.text('Rozpocznij czytanie');
          expect(startReadingButton, findsOneWidget);
          await tester.tap(startReadingButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Reading session started');

          // ==========================================
          // WHEN: User ends the reading session
          // ==========================================
          TestReporter.logStep('Simulating reading time (5 seconds)');
          await tester.pump(const Duration(seconds: 5));

          TestReporter.logStep('Ending reading session');
          final endSessionButton = find.text('Zakończ sesję');
          expect(endSessionButton, findsOneWidget);
          await tester.tap(endSessionButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Dialog should appear asking for last page
          TestReporter.logAssertion('End session dialog displayed');

          final lastPageField = find.byType(TextField).first;
          await tester.enterText(lastPageField, '50');
          await tester.pumpAndSettle();

          final confirmButton = find.widgetWithText(FilledButton, 'Zapisz');
          await tester.tap(confirmButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // ==========================================
          // THEN: Session should be saved and progress updated
          // ==========================================
          TestReporter.logAssertion('Session saved successfully');

          // Verify progress is shown (should be around 16-17%)
          // 50/300 * 100 = 16.67%
          expect(find.textContaining('16'), findsOneWidget);

          TestReporter.logAssertion('Progress updated to ~16%');

          // ==========================================
          // FINAL VERIFICATION: Check database state
          // ==========================================
          TestReporter.logStep('Verifying database state');

          // Verify book was created
          final books = await supabase
              .from('books')
              .select()
              .eq('user_id', testUserId!)
              .eq('title', 'Test Book E2E');

          expect(books.length, 1, reason: 'Book should be in database');
          TestReporter.logAssertion('Book found in database');

          final bookId = books.first['id'];

          // Verify reading session was created
          final sessions = await supabase
              .from('reading_sessions')
              .select()
              .eq('book_id', bookId);

          expect(
            sessions.length,
            1,
            reason: 'Reading session should be in database',
          );
          expect(sessions.first['pages_read'], 50);
          TestReporter.logAssertion(
            'Reading session found in database with correct pages',
          );

          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}

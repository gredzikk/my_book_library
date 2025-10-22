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
          await supabase.auth.signOut();

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
          final registerButton = find.byKey(
            const Key('login_to_register_button'),
          );
          expect(registerButton, findsOneWidget);
          await tester.tap(registerButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Registration screen displayed');

          // ==========================================
          // WHEN: User registers with valid credentials
          // ==========================================
          TestReporter.logStep('Filling registration form');

          // Find email field by key
          final emailField = find.byKey(const Key('register_email_field'));
          await tester.enterText(emailField, testEmail);
          await tester.pumpAndSettle();

          // Find password field by key
          final passwordField = find.byKey(
            const Key('register_password_field'),
          );
          await tester.enterText(passwordField, testPassword);
          await tester.pumpAndSettle();

          // Confirm password by key
          final confirmPasswordField = find.byKey(
            const Key('register_confirm_password_field'),
          );
          await tester.enterText(confirmPasswordField, testPassword);
          await tester.pumpAndSettle();

          TestReporter.logStep('Submitting registration');
          final submitButton = find.byKey(const Key('register_submit_button'));
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // ==========================================
          // THEN: In test env, user is auto-authenticated and sees home screen
          // ==========================================
          TestReporter.logStep('Verifying successful registration');

          // Store user ID for cleanup
          final user = supabase.auth.currentUser;
          expect(
            user,
            isNotNull,
            reason: 'User should be auto-authenticated in test environment',
          );
          testUserId = user!.id;

          TestReporter.logAssertion(
            'User auto-authenticated with ID: $testUserId',
          );

          // Wait for navigation to home screen
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify we're on the home screen
          expect(
            find.text('Moja Biblioteka'),
            findsOneWidget,
            reason: 'Should be on home screen after auto-authentication',
          );
          TestReporter.logAssertion('Home screen displayed after registration');

          // ==========================================
          // WHEN: User adds a book manually
          // ==========================================
          TestReporter.logStep('Adding a new book');

          // Find and tap the add book button (FAB) by key
          final addButton = find.byKey(const Key('add_book_fab'));
          expect(
            addButton,
            findsOneWidget,
            reason: 'FloatingActionButton should be visible on home screen',
          );
          await tester.tap(addButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Add book screen displayed');

          // Tap on "Add manually" button to navigate to the form
          TestReporter.logStep('Navigating to manual entry form');
          final addManuallyButton = find.byKey(
            const Key('add_book_manually_button'),
          );
          expect(addManuallyButton, findsOneWidget);
          await tester.tap(addManuallyButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Book form screen displayed');

          // Fill book details manually using keys
          TestReporter.logStep('Filling book details');
          final bookTitleField = find.byKey(const Key('book_form_title_field'));
          await tester.enterText(bookTitleField, 'Test Book E2E');
          await tester.pumpAndSettle();

          final bookAuthorField = find.byKey(
            const Key('book_form_author_field'),
          );
          await tester.enterText(bookAuthorField, 'Test Author E2E');
          await tester.pumpAndSettle();

          // Page count
          final pageCountField = find.byKey(
            const Key('book_form_page_count_field'),
          );
          await tester.enterText(pageCountField, '300');
          await tester.pumpAndSettle();

          // Save book
          TestReporter.logStep('Saving book');
          final saveBookButton = find.byKey(const Key('book_form_save_button'));
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

          // Scroll to make the book visible if needed
          final bookFinder = find.text('Test Book E2E');
          await tester.ensureVisible(bookFinder);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // Tap on the book to open details
          await tester.tap(bookFinder);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Wait for book details to fully load by checking for author name
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(
            find.byKey(const Key('book_detail_author_text')),
            findsOneWidget,
            reason: 'Book details should display author name',
          );

          TestReporter.logAssertion('Book details screen displayed');

          // Find and tap "Start reading" button using key
          TestReporter.logStep('Looking for start reading button');
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final startReadingButton = find.byKey(
            const Key('start_reading_button'),
          );
          expect(
            startReadingButton,
            findsOneWidget,
            reason: 'Start reading button should be visible for new books',
          );
          await tester.tap(startReadingButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logAssertion('Reading session started');

          // ==========================================
          // WHEN: User ends the reading session
          // ==========================================
          TestReporter.logStep('Simulating reading time (5 seconds)');
          await tester.pump(const Duration(seconds: 5));

          TestReporter.logStep('Ending reading session');
          final endSessionButton = find.byKey(const Key('end_session_button'));
          expect(endSessionButton, findsOneWidget);
          await tester.tap(endSessionButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Dialog should appear asking for last page
          TestReporter.logAssertion('End session dialog displayed');

          final lastPageField = find.byKey(const Key('end_session_page_field'));
          await tester.enterText(lastPageField, '50');
          await tester.pumpAndSettle();

          final confirmButton = find.byKey(
            const Key('end_session_save_button'),
          );
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_book_library/config/env_config.dart';
import 'package:my_book_library/main.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_data_helper.dart';
import '../helpers/test_reporter.dart';
import '../mocks/mock_google_books_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Book CRUD Tests', () {
    late TestDataHelper testDataHelper;
    String? testUserId;
    final stopwatch = Stopwatch();

    setUpAll(() async {
      TestReporter.logStep('Setting up test environment for Book CRUD tests');
      EnvConfig.setEnvironment(Environment.test);
    });

    setUp(() {
      stopwatch.start();
    });

    tearDown(() async {
      stopwatch.stop();

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

      MockGoogleBooksService.clearCustomMocks();
      stopwatch.reset();
    });

    Future<void> registerAndLoginTestUser(WidgetTester tester) async {
      final supabase = Supabase.instance.client;
      testDataHelper = TestDataHelper(supabase);

      // Clear any existing session (important for test isolation)
      TestReporter.logStep('Clearing any existing user session');
      await supabase.auth.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final testEmail = testDataHelper.generateTestEmail();
      final testPassword = testDataHelper.generateTestPassword();

      TestReporter.logStep('Creating test user: $testEmail');

      // Navigate to registration
      final registerLink = find.text('Zarejestruj się');
      await tester.tap(registerLink);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fill registration form
      await tester.enterText(find.byType(TextField).first, testEmail);
      await tester.enterText(find.byType(TextField).at(1), testPassword);
      await tester.enterText(find.byType(TextField).at(2), testPassword);
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.widgetWithText(FilledButton, 'Zarejestruj się'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After registration, user is redirected to login screen
      // Now we need to log in
      TestReporter.logStep('Logging in with registered user: $testEmail');

      // Fill login form
      await tester.enterText(find.byType(TextField).first, testEmail);
      await tester.enterText(find.byType(TextField).at(1), testPassword);
      await tester.pumpAndSettle();

      // Submit login
      await tester.tap(find.widgetWithText(FilledButton, 'Zaloguj się'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      testUserId = supabase.auth.currentUser?.id;
      expect(testUserId, isNotNull);

      // Skip onboarding if present
      final skipButton = find.text('Pomiń');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      TestReporter.logAssertion('Test user registered and logged in');
    }

    testWidgets(
      'TC-BOOK-01: User can add book via ISBN',
      (WidgetTester tester) async {
        final testName = 'Add Book via ISBN';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: User is logged in
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await registerAndLoginTestUser(tester);

          // Wait for home screen to fully load
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // WHEN: User opens add book screen
          TestReporter.logStep('Opening add book screen');
          final addButton = find.byIcon(Icons.add);
          expect(addButton, findsAtLeastNWidgets(1));
          await tester.tap(addButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // AND: Enters ISBN and fetches book data
          TestReporter.logStep('Entering ISBN: 9780134685991');

          // Find ISBN input field (might be first field)
          final isbnField = find.byType(TextField).first;
          await tester.enterText(isbnField, '9780134685991');
          await tester.pumpAndSettle();

          // Tap fetch/search button
          final fetchButton = find.byIcon(Icons.search);
          if (fetchButton.evaluate().isNotEmpty) {
            await tester.tap(fetchButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }

          // THEN: Book details should be auto-filled
          TestReporter.logAssertion(
            'Book details auto-filled from Google Books',
          );

          // Save the book
          TestReporter.logStep('Saving book');
          final saveButton = find.widgetWithText(FilledButton, 'Dodaj książkę');
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // THEN: Book should appear on home screen
          TestReporter.logAssertion('Verifying book appears on home screen');
          expect(
            find.textContaining('Effective Java', findRichText: true),
            findsOneWidget,
          );

          // Verify in database
          final supabase = Supabase.instance.client;
          final books = await supabase
              .from('books')
              .select()
              .eq('user_id', testUserId!)
              .eq('isbn', '9780134685991');

          expect(books.length, 1, reason: 'Book should be in database');
          TestReporter.logAssertion('Book saved in database');

          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_book_01_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    testWidgets(
      'TC-BOOK-02: User can add book manually',
      (WidgetTester tester) async {
        final testName = 'Add Book Manually';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: User is logged in
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await registerAndLoginTestUser(tester);

          // Wait for home screen to fully load
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // WHEN: User opens add book screen
          TestReporter.logStep('Opening add book screen');
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // AND: Fills form manually
          TestReporter.logStep('Filling book details manually');

          // Title
          final titleField = find.byType(TextField).first;
          await tester.enterText(titleField, 'Manual Test Book');
          await tester.pumpAndSettle();

          // Author
          final authorField = find.byType(TextField).at(1);
          await tester.enterText(authorField, 'Manual Test Author');
          await tester.pumpAndSettle();

          // Page count
          final pageCountField = find.byType(TextField).at(2);
          await tester.enterText(pageCountField, '250');
          await tester.pumpAndSettle();

          // Save
          TestReporter.logStep('Saving manually added book');
          final saveButton = find.widgetWithText(FilledButton, 'Dodaj książkę');
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // THEN: Book should appear on home screen
          TestReporter.logAssertion('Verifying book appears on home screen');
          expect(find.text('Manual Test Book'), findsOneWidget);

          // Verify in database
          final supabase = Supabase.instance.client;
          final books = await supabase
              .from('books')
              .select()
              .eq('user_id', testUserId!)
              .eq('title', 'Manual Test Book');

          expect(books.length, 1, reason: 'Book should be in database');
          expect(books.first['author'], 'Manual Test Author');
          expect(books.first['page_count'], 250);
          TestReporter.logAssertion('Book saved correctly in database');

          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_book_02_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    testWidgets(
      'TC-BOOK-03: User can delete a book',
      (WidgetTester tester) async {
        final testName = 'Delete Book';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: User is logged in with a book
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await registerAndLoginTestUser(tester);

          // Wait for home screen to fully load
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Create a book first
          TestReporter.logStep('Adding a book to delete');
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          await tester.enterText(
            find.byType(TextField).first,
            'Book To Delete',
          );
          await tester.enterText(find.byType(TextField).at(1), 'Test Author');
          await tester.enterText(find.byType(TextField).at(2), '100');
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(FilledButton, 'Dodaj książkę'));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.text('Book To Delete'), findsOneWidget);
          TestReporter.logAssertion('Book created successfully');

          // WHEN: User opens book details and deletes
          TestReporter.logStep('Opening book details');
          await tester.tap(find.text('Book To Delete'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find delete button (usually in menu or as icon button)
          final deleteButton = find.byIcon(Icons.delete);
          expect(
            deleteButton,
            findsOneWidget,
            reason: 'Delete button should be visible',
          );

          TestReporter.logStep('Deleting book');
          await tester.tap(deleteButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Confirm deletion if dialog appears
          final confirmButton = find.text('Usuń');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }

          // THEN: Book should not be visible on home screen
          TestReporter.logAssertion('Verifying book is deleted from UI');
          expect(find.text('Book To Delete'), findsNothing);

          // Verify in database
          final supabase = Supabase.instance.client;
          final books = await supabase
              .from('books')
              .select()
              .eq('user_id', testUserId!)
              .eq('title', 'Book To Delete');

          expect(
            books.isEmpty,
            true,
            reason: 'Book should be deleted from database',
          );
          TestReporter.logAssertion('Book deleted from database');

          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_book_03_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    testWidgets(
      'TC-BOOK-04: User can edit a book',
      (WidgetTester tester) async {
        final testName = 'Edit Book';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: User is logged in with a book
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await registerAndLoginTestUser(tester);

          // Wait for home screen to fully load
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Create a book first
          TestReporter.logStep('Adding a book to edit');
          final addButton = find.byIcon(Icons.add);
          await tester.tap(addButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          await tester.enterText(
            find.byType(TextField).first,
            'Original Title',
          );
          await tester.enterText(
            find.byType(TextField).at(1),
            'Original Author',
          );
          await tester.enterText(find.byType(TextField).at(2), '200');
          await tester.pumpAndSettle();

          await tester.tap(find.widgetWithText(FilledButton, 'Dodaj książkę'));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // WHEN: User opens book for editing
          TestReporter.logStep('Opening book for editing');
          await tester.tap(find.text('Original Title'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Find edit button
          final editButton = find.byIcon(Icons.edit);
          await tester.tap(editButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // AND: Changes the title
          TestReporter.logStep('Updating book title');
          final titleField = find.byType(TextField).first;
          await tester.enterText(titleField, 'Updated Title');
          await tester.pumpAndSettle();

          // Save changes
          final saveButton = find.widgetWithText(FilledButton, 'Zapisz zmiany');
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // THEN: Updated title should be visible
          TestReporter.logAssertion('Verifying book title is updated');
          expect(find.text('Updated Title'), findsOneWidget);
          expect(find.text('Original Title'), findsNothing);

          // Verify in database
          final supabase = Supabase.instance.client;
          final books = await supabase
              .from('books')
              .select()
              .eq('user_id', testUserId!)
              .eq('title', 'Updated Title');

          expect(books.length, 1, reason: 'Updated book should be in database');
          TestReporter.logAssertion('Book updated in database');

          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_book_04_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}

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

  group('E2E Auth Flow Tests', () {
    late TestDataHelper testDataHelper;
    String? testUserId;
    final stopwatch = Stopwatch();

    setUpAll(() async {
      TestReporter.logStep('Setting up test environment for Auth tests');
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

      stopwatch.reset();
    });

    testWidgets(
      'TC-AUTH-01: User can register with valid credentials',
      (WidgetTester tester) async {
        final testName = 'User Registration';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: App is launched
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final supabase = Supabase.instance.client;
          testDataHelper = TestDataHelper(supabase);

          // Clear any existing session (important for test isolation)
          TestReporter.logStep('Clearing any existing user session');
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final testEmail = testDataHelper.generateTestEmail();
          final testPassword = testDataHelper.generateTestPassword();

          TestReporter.logStep('Test credentials: $testEmail');

          // WHEN: User navigates to registration
          final registerLink = find.text('Zarejestruj się');
          expect(registerLink, findsOneWidget);
          await tester.tap(registerLink);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // AND: Fills registration form
          TestReporter.logStep('Filling registration form');
          final emailField = find.byType(TextField).first;
          await tester.enterText(emailField, testEmail);
          await tester.pumpAndSettle();

          final passwordField = find.byType(TextField).at(1);
          await tester.enterText(passwordField, testPassword);
          await tester.pumpAndSettle();

          final confirmPasswordField = find.byType(TextField).at(2);
          await tester.enterText(confirmPasswordField, testPassword);
          await tester.pumpAndSettle();

          // AND: Submits registration
          TestReporter.logStep('Submitting registration');
          final submitButton = find.widgetWithText(
            ElevatedButton,
            'Zarejestruj się',
          );
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // THEN: User should be registered and logged in
          final user = supabase.auth.currentUser;
          expect(user, isNotNull, reason: 'User should be logged in');
          expect(user!.email, testEmail);
          testUserId = user.id;

          TestReporter.logAssertion(
            'User registered successfully: $testUserId',
          );
          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_auth_01_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'TC-AUTH-02: User can login with existing credentials',
      (WidgetTester tester) async {
        final testName = 'User Login';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: App is launched and user exists
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final supabase = Supabase.instance.client;
          testDataHelper = TestDataHelper(supabase);

          // Clear any existing session (important for test isolation)
          TestReporter.logStep('Clearing any existing user session');
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Create test user first
          TestReporter.logStep('Creating test user');
          final testEmail = testDataHelper.generateTestEmail();
          final testPassword = testDataHelper.generateTestPassword();

          final authResponse = await supabase.auth.signUp(
            email: testEmail,
            password: testPassword,
          );
          expect(authResponse.user, isNotNull);
          testUserId = authResponse.user!.id;

          // Sign out
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logStep('Test user created and signed out: $testEmail');

          // WHEN: User fills login form
          TestReporter.logStep('Filling login form');
          final emailField = find.byType(TextField).first;
          await tester.enterText(emailField, testEmail);
          await tester.pumpAndSettle();

          final passwordField = find.byType(TextField).at(1);
          await tester.enterText(passwordField, testPassword);
          await tester.pumpAndSettle();

          // AND: Submits login
          TestReporter.logStep('Submitting login');
          final loginButton = find.widgetWithText(
            ElevatedButton,
            'Zaloguj się',
          );
          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // THEN: User should be logged in and see home screen
          final user = supabase.auth.currentUser;
          expect(user, isNotNull, reason: 'User should be logged in');
          expect(user!.email, testEmail);

          TestReporter.logAssertion('User logged in successfully');
          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_auth_02_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets(
      'TC-AUTH-03: Login fails with incorrect password',
      (WidgetTester tester) async {
        final testName = 'Login with Wrong Password';
        TestReporter.logTestStart(testName);

        try {
          // GIVEN: App is launched and user exists
          await app.main();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final supabase = Supabase.instance.client;
          testDataHelper = TestDataHelper(supabase);

          // Clear any existing session (important for test isolation)
          TestReporter.logStep('Clearing any existing user session');
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Create test user
          TestReporter.logStep('Creating test user');
          final testEmail = testDataHelper.generateTestEmail();
          final correctPassword = testDataHelper.generateTestPassword();
          final wrongPassword = 'WrongPassword123!';

          final authResponse = await supabase.auth.signUp(
            email: testEmail,
            password: correctPassword,
          );
          expect(authResponse.user, isNotNull);
          testUserId = authResponse.user!.id;

          // Sign out
          await supabase.auth.signOut();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          TestReporter.logStep('Test user created: $testEmail');

          // WHEN: User tries to login with wrong password
          TestReporter.logStep('Attempting login with wrong password');
          final emailField = find.byType(TextField).first;
          await tester.enterText(emailField, testEmail);
          await tester.pumpAndSettle();

          final passwordField = find.byType(TextField).at(1);
          await tester.enterText(passwordField, wrongPassword);
          await tester.pumpAndSettle();

          final loginButton = find.widgetWithText(
            ElevatedButton,
            'Zaloguj się',
          );
          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // THEN: Error message should be displayed
          expect(
            find.textContaining('nieprawidłowe', findRichText: true),
            findsOneWidget,
            reason: 'Error message should be shown',
          );

          // AND: User should not be logged in
          final user = supabase.auth.currentUser;
          expect(user, isNull, reason: 'User should not be logged in');

          TestReporter.logAssertion(
            'Login correctly failed with wrong password',
          );
          TestReporter.logTestEnd(testName, stopwatch.elapsed);
        } catch (e, stackTrace) {
          TestReporter.logError('Test failed: $e', stackTrace);
          await TestReporter.takeScreenshot(
            tester,
            'tc_auth_03_error_${DateTime.now().millisecondsSinceEpoch}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWidgets('TC-AUTH-04: User can logout', (WidgetTester tester) async {
      final testName = 'User Logout';
      TestReporter.logTestStart(testName);

      try {
        // GIVEN: User is logged in
        await app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final supabase = Supabase.instance.client;
        testDataHelper = TestDataHelper(supabase);

        // Clear any existing session (important for test isolation)
        TestReporter.logStep('Clearing any existing user session');
        await supabase.auth.signOut();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final testEmail = testDataHelper.generateTestEmail();
        final testPassword = testDataHelper.generateTestPassword();

        // Register and login
        TestReporter.logStep('Creating and logging in test user');
        final registerLink = find.text('Zarejestruj się');
        await tester.tap(registerLink);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.enterText(find.byType(TextField).first, testEmail);
        await tester.enterText(find.byType(TextField).at(1), testPassword);
        await tester.enterText(find.byType(TextField).at(2), testPassword);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Zarejestruj się'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        testUserId = supabase.auth.currentUser?.id;
        expect(testUserId, isNotNull);

        // Skip onboarding if present
        final skipButton = find.text('Pomiń');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        TestReporter.logAssertion('User logged in');

        // WHEN: User logs out
        TestReporter.logStep('Logging out');

        // Open drawer or settings
        final drawerButton = find.byIcon(Icons.menu);
        if (drawerButton.evaluate().isNotEmpty) {
          await tester.tap(drawerButton);
          await tester.pumpAndSettle();
        }

        // Find logout button
        final logoutButton = find.text('Wyloguj się');
        expect(logoutButton, findsOneWidget);
        await tester.tap(logoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // THEN: User should be logged out and see login screen
        final user = supabase.auth.currentUser;
        expect(user, isNull, reason: 'User should be logged out');

        // Should see login screen
        expect(find.text('Zaloguj się'), findsWidgets);

        TestReporter.logAssertion('User logged out successfully');
        TestReporter.logTestEnd(testName, stopwatch.elapsed);
      } catch (e, stackTrace) {
        TestReporter.logError('Test failed: $e', stackTrace);
        await TestReporter.takeScreenshot(
          tester,
          'tc_auth_04_error_${DateTime.now().millisecondsSinceEpoch}',
        );
        rethrow;
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}

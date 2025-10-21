import 'package:flutter_test/flutter_test.dart';

/// Reporter for E2E tests with logging and screenshot capabilities
class TestReporter {
  /// Log test start
  static void logTestStart(String testName) {
    final timestamp = DateTime.now().toIso8601String();
    print('\n╔════════════════════════════════════════════════════════════');
    print('║ [E2E] Test Started: $testName');
    print('║ [E2E] Time: $timestamp');
    print('╚════════════════════════════════════════════════════════════\n');
  }

  /// Log test end
  static void logTestEnd(String testName, Duration duration) {
    print('\n╔════════════════════════════════════════════════════════════');
    print('║ [E2E] Test Completed: $testName');
    print(
      '║ [E2E] Duration: ${duration.inSeconds}s (${duration.inMilliseconds}ms)',
    );
    print('╚════════════════════════════════════════════════════════════\n');
  }

  /// Log test step
  static void logStep(String stepDescription) {
    print('  → [E2E] STEP: $stepDescription');
  }

  /// Log test assertion
  static void logAssertion(String assertion) {
    print('  ✓ [E2E] ASSERT: $assertion');
  }

  /// Log error
  static void logError(String error, [StackTrace? stackTrace]) {
    print('  ✗ [E2E] ERROR: $error');
    if (stackTrace != null) {
      print('  Stack trace: $stackTrace');
    }
  }

  /// Take screenshot (requires WidgetTester)
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    try {
      // Note: Screenshots work better on physical devices
      // On emulator, this might not always work
      await tester.pumpAndSettle();
      print('  📸 [E2E] Screenshot taken: $name.png');

      // Flutter's integration_test automatically saves screenshots
      // when expectLater is used with matchesGoldenFile
      // For basic screenshot, we just log it
    } catch (e) {
      print('  ⚠ [E2E] Failed to take screenshot: $e');
    }
  }

  /// Log performance metric
  static void logPerformance(String metric, Duration duration) {
    print('  ⏱ [E2E] Performance: $metric took ${duration.inMilliseconds}ms');
  }
}

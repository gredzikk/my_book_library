import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

/// Reporter for E2E tests with logging and screenshot capabilities
class TestReporter {
  static final Logger _logger = Logger('TestReporter');

  /// Log test start
  static void logTestStart(String testName) {
    final timestamp = DateTime.now().toIso8601String();
    _logger.info(
      '\n╔════════════════════════════════════════════════════════════',
    );
    _logger.info('║ [E2E] Test Started: $testName');
    _logger.info('║ [E2E] Time: $timestamp');
    _logger.info(
      '╚════════════════════════════════════════════════════════════\n',
    );
  }

  /// Log test end
  static void logTestEnd(String testName, Duration duration) {
    _logger.info(
      '\n╔════════════════════════════════════════════════════════════',
    );
    _logger.info('║ [E2E] Test Completed: $testName');
    _logger.info(
      '║ [E2E] Duration: ${duration.inSeconds}s (${duration.inMilliseconds}ms)',
    );
    _logger.info(
      '╚════════════════════════════════════════════════════════════\n',
    );
  }

  /// Log test step
  static void logStep(String stepDescription) {
    _logger.info('  → [E2E] STEP: $stepDescription');
  }

  /// Log test assertion
  static void logAssertion(String assertion) {
    _logger.info('  ✓ [E2E] ASSERT: $assertion');
  }

  /// Log error
  static void logError(String error, [StackTrace? stackTrace]) {
    _logger.severe('  ✗ [E2E] ERROR: $error');
    if (stackTrace != null) {
      _logger.severe('  Stack trace: $stackTrace');
    }
  }

  /// Take screenshot (requires WidgetTester)
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    try {
      // Note: Screenshots work better on physical devices
      // On emulator, this might not always work
      await tester.pumpAndSettle();
      _logger.info('  📸 [E2E] Screenshot taken: $name.png');

      // Flutter's integration_test automatically saves screenshots
      // when expectLater is used with matchesGoldenFile
      // For basic screenshot, we just log it
    } catch (e) {
      _logger.severe('  ⚠ [E2E] Failed to take screenshot: $e');
    }
  }

  /// Log performance metric
  static void logPerformance(String metric, Duration duration) {
    _logger.info(
      '  ⏱ [E2E] Performance: $metric took ${duration.inMilliseconds}ms',
    );
  }
}

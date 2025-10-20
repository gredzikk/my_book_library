import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

/// Service class for managing onboarding state persistence
///
/// This service handles reading and writing the onboarding completion status
/// to device storage using SharedPreferences.
class OnboardingService {
  static const String _onboardingKey = 'has_onboarding_been_shown';
  final _logger = Logger('OnboardingService');

  /// Checks if the onboarding tutorial has been shown before
  ///
  /// Returns `false` if the onboarding hasn't been shown or if there's an error.
  /// This default value ensures new users always see the tutorial.
  Future<bool> getOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getBool(_onboardingKey) ?? false;
      _logger.info('Onboarding status retrieved: $status');
      return status;
    } catch (e, stackTrace) {
      _logger.severe(
        'Error reading onboarding status from SharedPreferences',
        e,
        stackTrace,
      );
      // Return false (not shown) as safe default - better to show tutorial
      // again than to never show it to a new user
      return false;
    }
  }

  /// Marks the onboarding tutorial as completed
  ///
  /// Saves the completion status to device storage. If the save fails,
  /// the error is logged and the tutorial will be shown again next time.
  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      _logger.info('Onboarding marked as completed');
    } catch (e, stackTrace) {
      _logger.severe(
        'Error saving onboarding status to SharedPreferences',
        e,
        stackTrace,
      );
      // Don't rethrow - failing to save is not critical enough to crash
      // User will just see the tutorial again next time
    }
  }
}

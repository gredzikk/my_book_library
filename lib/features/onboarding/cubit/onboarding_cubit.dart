import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/onboarding_service.dart';
import 'onboarding_state.dart';

/// Cubit for managing onboarding tutorial state
///
/// This cubit coordinates with the OnboardingService to determine if
/// the tutorial should be shown and to persist completion status.
class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingService _onboardingService;
  final _logger = Logger('OnboardingCubit');

  OnboardingCubit({required OnboardingService onboardingService})
    : _onboardingService = onboardingService,
      super(const OnboardingState.initial());

  /// Checks if the onboarding tutorial has been shown before
  ///
  /// Emits [OnboardingState.show] if the tutorial should be displayed,
  /// or [OnboardingState.completed] if it has already been shown.
  Future<void> checkOnboardingStatus() async {
    try {
      _logger.info(
        'Checking onboarding status... (current state: ${state.runtimeType})',
      );
      final hasBeenShown = await _onboardingService.getOnboardingStatus();

      if (hasBeenShown) {
        _logger.info(
          'Onboarding has been completed previously - emitting completed state',
        );
        emit(const OnboardingState.completed());
        _logger.info('State emitted: ${state.runtimeType}');
      } else {
        _logger.info('Onboarding needs to be shown - emitting show state');
        emit(const OnboardingState.show());
        _logger.info('State emitted: ${state.runtimeType}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error checking onboarding status', e, stackTrace);
      // On error, default to showing onboarding (safer for new users)
      _logger.info('Error occurred - emitting show state as fallback');
      emit(const OnboardingState.show());
      _logger.info('State emitted: ${state.runtimeType}');
    }
  }

  /// Marks the onboarding tutorial as completed
  ///
  /// This should be called when the user finishes or skips the tutorial.
  /// Emits [OnboardingState.completed] after saving the status.
  Future<void> markOnboardingAsCompleted() async {
    try {
      _logger.info('Marking onboarding as completed...');
      await _onboardingService.setOnboardingCompleted();
      emit(const OnboardingState.completed());
      _logger.info('Onboarding marked as completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error marking onboarding as completed', e, stackTrace);
      // Still emit completed state even if save fails - don't show tutorial again
      // in current session
      emit(const OnboardingState.completed());
    }
  }
}

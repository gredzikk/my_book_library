import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// State for the onboarding tutorial flow
///
/// This state manages whether the onboarding tutorial should be displayed
/// to the user based on their previous interactions.
@freezed
class OnboardingState with _$OnboardingState {
  /// Initial state before checking onboarding status
  ///
  /// The app starts in this state while determining if the tutorial
  /// needs to be shown.
  const factory OnboardingState.initial() = _Initial;

  /// State indicating the onboarding tutorial should be displayed
  ///
  /// This state is emitted when the user hasn't seen the tutorial before
  /// and triggers the showcase overlay to be shown.
  const factory OnboardingState.show() = _Show;

  /// State indicating the onboarding tutorial has been completed
  ///
  /// This state is emitted when the user has already seen the tutorial
  /// or has just completed/skipped it.
  const factory OnboardingState.completed() = _Completed;
}

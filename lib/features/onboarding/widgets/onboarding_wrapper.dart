import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:logging/logging.dart';

import '../../../services/book_service.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../../home/bloc/bloc.dart';
import '../../home/view/home_screen_content.dart';

/// Wrapper widget that manages the onboarding tutorial overlay
///
/// This widget wraps the HomeScreen and conditionally displays the
/// onboarding tutorial based on the OnboardingCubit state.
/// It uses the showcaseview package to highlight key UI elements.
/// It also provides the HomeScreenBloc to the widget tree.
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final _logger = Logger('OnboardingWrapper');

  /// GlobalKeys for the showcase tutorial steps
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _firstBookKey = GlobalKey();

  /// Flag to prevent multiple showcase triggers
  bool _hasShownShowcase = false;
  bool _isShowcaseActive = false;

  @override
  void initState() {
    super.initState();
    _logger.info('OnboardingWrapper initState - scheduling onboarding check');
    // Check onboarding status when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logger.info(
          'OnboardingWrapper post-frame callback - checking onboarding status',
        );
        context.read<OnboardingCubit>().checkOnboardingStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bookService = context.read<BookService>();
        return HomeScreenBloc(bookService)..add(const LoadBooksEvent());
      },
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          _logger.info(
            'OnboardingWrapper - Onboarding state changed to: ${state.runtimeType}',
          );
          state.maybeWhen(
            show: () {
              // Only show showcase once to avoid multiple triggers
              if (!_hasShownShowcase && mounted) {
                _logger.info(
                  'Onboarding should be shown (hasShownShowcase: $_hasShownShowcase, mounted: $mounted)',
                );
                _hasShownShowcase = true;
                setState(() {
                  _isShowcaseActive = true;
                });
                // Try to start showcase after a delay to ensure UI is ready
                _triggerShowcaseWhenReady();
              } else {
                _logger.warning(
                  'Showcase not started: hasShownShowcase=$_hasShownShowcase, mounted=$mounted',
                );
              }
            },
            orElse: () {
              _logger.info(
                'Onboarding state is not "show" - state is ${state.runtimeType}',
              );
            },
          );
        },
        builder: (context, state) {
          _logger.info(
            'OnboardingWrapper - Building with state: ${state.runtimeType}',
          );
          return ShowCaseWidget(
            onFinish: () {
              // Mark onboarding as completed when user finishes the tutorial
              _logger.info(
                'Onboarding tutorial finished - marking as completed',
              );
              context.read<OnboardingCubit>().markOnboardingAsCompleted();
              setState(() {
                _isShowcaseActive = false;
              });
            },
            onComplete: (index, key) {
              // Optional: Handle completion of individual steps
              // Can be used for analytics or additional logic
            },
            blurValue: 1,
            autoPlayDelay: const Duration(seconds: 3),
            builder: (context) => HomeScreenContent(
              appBarKey: _appBarKey,
              fabKey: _fabKey,
              firstBookKey: _firstBookKey,
              showSkipButton: _isShowcaseActive,
              onSkip: () {
                // Mark completed and stop showcase
                _logger.info(
                  'Onboarding tutorial skipped - marking as completed',
                );
                context.read<OnboardingCubit>().markOnboardingAsCompleted();
                ShowCaseWidget.of(context).dismiss();
                setState(() {
                  _isShowcaseActive = false;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Triggers the showcase when the UI is ready
  ///
  /// This method waits for the next frame to ensure all widgets are built
  /// before starting the showcase tutorial.
  void _triggerShowcaseWhenReady() {
    _logger.info('_triggerShowcaseWhenReady called - waiting for next frame');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _logger.warning('Widget not mounted when trying to start showcase');
        return;
      }

      _logger.info('Post frame callback - checking if UI is ready');

      // Wait a bit longer to ensure the UI is fully rendered
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isShowcaseActive) {
          _logger.info('Starting showcase after delay');
          _startShowcase();
        } else {
          _logger.warning(
            'Cannot start showcase: mounted=$mounted, isShowcaseActive=$_isShowcaseActive',
          );
        }
      });
    });
  }

  /// Starts the showcase tutorial
  ///
  /// This method triggers the showcase overlay with all tutorial steps.
  /// Always shows AppBar and FAB, optionally shows first book if books exist.
  void _startShowcase() {
    try {
      _logger.info('_startShowcase called');

      // Build list of showcase keys
      // Note: We can't check HomeScreenBloc state here because it's not in our context
      // The first book showcase will only appear if there are books in the grid
      final showcaseKeys = [_appBarKey, _fabKey, _firstBookKey];

      _logger.info(
        'Starting showcase with ${showcaseKeys.length} potential steps',
      );

      ShowCaseWidget.of(context).startShowCase(showcaseKeys);
      _logger.info('Showcase started successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error starting showcase', e, stackTrace);
    }
  }
}

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
    // Check onboarding status when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingCubit>().checkOnboardingStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bookService = context.read<BookService>();
        return HomeScreenBloc(bookService)..add(const LoadBooksEvent());
      },
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          state.maybeWhen(
            show: () {
              // Only show showcase once to avoid multiple triggers
              if (!_hasShownShowcase && mounted) {
                _logger.info('Onboarding should be shown - starting showcase');
                _hasShownShowcase = true;
                setState(() {
                  _isShowcaseActive = true;
                });
                // Wait for the next frame to ensure widgets are built
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _startShowcase();
                  }
                });
              }
            },
            orElse: () {},
          );
        },
        child: ShowCaseWidget(
          onFinish: () {
            // Mark onboarding as completed when user finishes the tutorial
            _logger.info('Onboarding tutorial finished - marking as completed');
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
        ),
      ),
    );
  }

  /// Starts the showcase tutorial
  ///
  /// This method triggers the showcase overlay with all tutorial steps.
  void _startShowcase() {
    _logger.info('Starting showcase with 3 steps');
    ShowCaseWidget.of(
      context,
    ).startShowCase([_appBarKey, _fabKey, _firstBookKey]);
  }
}

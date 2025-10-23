import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:showcaseview/showcaseview.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import '../../add_book/add_book.dart';
import '../../profile/profile_screen.dart';

/// Home Screen Content - main UI widget
///
/// This widget builds the UI based on the current state of HomeScreenBloc.
/// It displays different widgets for loading, empty, success, and error states.
class HomeScreenContent extends StatelessWidget {
  /// GlobalKeys for onboarding tutorial showcase
  final GlobalKey? appBarKey;
  final GlobalKey? fabKey;
  final GlobalKey? firstBookKey;
  final VoidCallback? onSkip;

  static final Logger _logger = Logger('HomeScreenContent');

  const HomeScreenContent({
    super.key,
    this.appBarKey,
    this.fabKey,
    this.firstBookKey,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      key: const Key('home_app_bar'),
      title: const Text('Moja Biblioteka'),
      actions: [
        const FilterSortButton(),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          tooltip: 'Profil',
        ),
      ],
    );

    return Scaffold(
      appBar: appBarKey != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Showcase(
                key: appBarKey!,
                title: 'Twoja biblioteka',
                description:
                    'Tutaj znajdują się wszystkie Twoje książki. Możesz je filtrować i sortować używając przycisków w górnym menu.',
                child: appBar,
              ),
            )
          : appBar as PreferredSizeWidget,
      body: BlocConsumer<HomeScreenBloc, HomeScreenState>(
        listener: (context, state) {
          // Show error messages in SnackBar
          if (state is HomeScreenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Ponów',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<HomeScreenBloc>().add(
                      const LoadBooksEvent(forceRefresh: true),
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeScreenLoading) {
            return const LoadingSkeletonWidget();
          }

          if (state is HomeScreenEmpty) {
            return const EmptyStateWidget();
          }

          if (state is HomeScreenSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
                // Wait for the state to change
                await context.read<HomeScreenBloc>().stream.firstWhere(
                  (s) => s is! HomeScreenLoading,
                );
              },
              child: BookGrid(books: state.books, firstBookKey: firstBookKey),
            );
          }

          // Initial or error state - show empty view
          return const Center(child: Text('Wystąpił błąd. Spróbuj ponownie.'));
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Builds the FloatingActionButton with optional Showcase wrapper
  Widget _buildFloatingActionButton(BuildContext context) {
    _logger.fine('Building FloatingActionButton');
    final fab = FloatingActionButton(
      key: const Key('add_book_fab'),
      onPressed: () async {
        // Navigate to add book screen and wait for result
        final result = await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const AddBookScreen()));

        // Refresh the list if a book was added/modified
        if (result == true && context.mounted) {
          context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
        }
      },
      child: const Icon(Icons.add),
    );

    // Wrap in Showcase if fabKey is provided
    if (fabKey != null) {
      return Showcase(
        key: fabKey!,
        title: 'Dodaj książkę',
        description:
            'Kliknij tutaj, aby dodać nową książkę do swojej biblioteki. Możesz ją wprowadzić ręcznie lub zeskanować kod kreskowy.',
        child: fab,
      );
    }

    return fab;
  }
}

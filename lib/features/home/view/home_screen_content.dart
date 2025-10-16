import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import '../../add_book/add_book.dart';

/// Home Screen Content - main UI widget
///
/// This widget builds the UI based on the current state of HomeScreenBloc.
/// It displays different widgets for loading, empty, success, and error states.
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moja Biblioteka'),
        actions: const [FilterSortButton()],
      ),
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
              child: BookGrid(books: state.books),
            );
          }

          // Initial or error state - show empty view
          return const Center(child: Text('Wystąpił błąd. Spróbuj ponownie.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

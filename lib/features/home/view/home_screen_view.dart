import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/book_service.dart';
import '../bloc/bloc.dart';
import 'home_screen_content.dart';

/// Home Screen View - routing widget that provides the BLoC
///
/// This is the entry point for the Home Screen. It creates and provides
/// the HomeScreenBloc to the widget tree.
class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bookService = context.read<BookService>();
        return HomeScreenBloc(bookService)..add(const LoadBooksEvent());
      },
      child: const HomeScreenContent(),
    );
  }
}

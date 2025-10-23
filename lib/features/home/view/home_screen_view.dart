import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../services/book_service.dart';
import '../bloc/bloc.dart';
import 'home_screen_content.dart';

/// Home Screen View - routing widget that provides the BLoC
///
/// This is the entry point for the Home Screen. It creates and provides
/// the HomeScreenBloc to the widget tree.
class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  static final Logger _logger = Logger('HomeScreenView');

  @override
  Widget build(BuildContext context) {
    _logger.fine('Building home screen view');
    return BlocProvider(
      create: (context) {
        _logger.fine('Creating HomeScreenBloc');
        final bookService = context.read<BookService>();
        return HomeScreenBloc(bookService)..add(const LoadBooksEvent());
      },
      child: const HomeScreenContent(),
    );
  }
}

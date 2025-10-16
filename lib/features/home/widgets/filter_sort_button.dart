import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/genre_service.dart';
import '../bloc/bloc.dart';
import 'filter_sort_modal.dart';

/// Filter and sort button in the AppBar
///
/// Opens a bottom sheet modal with filter and sort options.
class FilterSortButton extends StatelessWidget {
  const FilterSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filtruj i sortuj',
      onPressed: () {
        final bloc = context.read<HomeScreenBloc>();
        final genreService = context.read<GenreService>();
        final currentFilters = bloc.currentFilters;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (modalContext) => MultiRepositoryProvider(
            providers: [RepositoryProvider.value(value: genreService)],
            child: BlocProvider.value(
              value: bloc,
              child: FilterSortModal(currentOptions: currentFilters),
            ),
          ),
        );
      },
    );
  }
}

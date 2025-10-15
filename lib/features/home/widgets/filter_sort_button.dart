import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        final currentFilters = context.read<HomeScreenBloc>().currentFilters;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FilterSortModal(currentOptions: currentFilters),
        );
      },
    );
  }
}

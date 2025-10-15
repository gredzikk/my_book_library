import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/database_types.dart';
import '../../../models/types.dart';
import '../../../services/genre_service.dart';
import '../bloc/bloc.dart';
import '../models/filter_sort_options.dart';

/// Modal bottom sheet for filtering and sorting books
class FilterSortModal extends StatefulWidget {
  final FilterSortOptions currentOptions;

  const FilterSortModal({super.key, required this.currentOptions});

  @override
  State<FilterSortModal> createState() => _FilterSortModalState();
}

class _FilterSortModalState extends State<FilterSortModal> {
  late BOOK_STATUS? _selectedStatus;
  late String? _selectedGenreId;
  late String _selectedOrderBy;
  late String _selectedOrderDirection;

  List<GenreDto> _genres = [];
  bool _isLoadingGenres = true;

  @override
  void initState() {
    super.initState();
    // Initialize with current options
    _selectedStatus = widget.currentOptions.status;
    _selectedGenreId = widget.currentOptions.genreId;
    _selectedOrderBy = widget.currentOptions.orderBy;
    _selectedOrderDirection = widget.currentOptions.orderDirection;

    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final genreService = context.read<GenreService>();
      final genres = await genreService.listGenres();
      setState(() {
        _genres = genres;
        _isLoadingGenres = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGenres = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się załadować gatunków')),
        );
      }
    }
  }

  void _applyFilters() {
    final newOptions = FilterSortOptions(
      status: _selectedStatus,
      genreId: _selectedGenreId,
      orderBy: _selectedOrderBy,
      orderDirection: _selectedOrderDirection,
    );

    context.read<HomeScreenBloc>().add(LoadBooksEvent(filters: newOptions));

    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedGenreId = null;
      _selectedOrderBy = 'title';
      _selectedOrderDirection = 'asc';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Filtruj i sortuj',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Wyczyść'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Status filter
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChips(),

                    const SizedBox(height: 24),

                    // Genre filter
                    Text(
                      'Gatunek',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _isLoadingGenres
                        ? const Center(child: CircularProgressIndicator())
                        : _buildGenreDropdown(),

                    const SizedBox(height: 24),

                    // Sort options
                    Text(
                      'Sortowanie',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildSortOptions(),
                  ],
                ),
              ),

              // Apply button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _applyFilters,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Zastosuj'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Wszystkie'),
          selected: _selectedStatus == null,
          onSelected: (selected) {
            setState(() {
              _selectedStatus = null;
            });
          },
        ),
        ...BOOK_STATUS.values.map((status) {
          return FilterChip(
            label: Text(_getStatusLabel(status)),
            selected: _selectedStatus == status,
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? status : null;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildGenreDropdown() {
    return DropdownButtonFormField<String?>(
      value: _selectedGenreId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: const Text('Wszystkie gatunki'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Wszystkie gatunki'),
        ),
        ..._genres.map((genre) {
          return DropdownMenuItem<String?>(
            value: genre.id,
            child: Text(genre.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGenreId = value;
        });
      },
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        // Sort field
        DropdownButtonFormField<String>(
          value: _selectedOrderBy,
          decoration: const InputDecoration(
            labelText: 'Sortuj według',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'title', child: Text('Tytuł')),
            DropdownMenuItem(value: 'author', child: Text('Autor')),
            DropdownMenuItem(value: 'created_at', child: Text('Data dodania')),
            DropdownMenuItem(
              value: 'updated_at',
              child: Text('Ostatnia aktualizacja'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedOrderBy = value;
              });
            }
          },
        ),

        const SizedBox(height: 12),

        // Sort direction
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'asc',
              label: Text('Rosnąco'),
              icon: Icon(Icons.arrow_upward),
            ),
            ButtonSegment(
              value: 'desc',
              label: Text('Malejąco'),
              icon: Icon(Icons.arrow_downward),
            ),
          ],
          selected: {_selectedOrderDirection},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedOrderDirection = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  String _getStatusLabel(BOOK_STATUS status) {
    switch (status) {
      case BOOK_STATUS.unread:
        return 'Nieprzeczytana';
      case BOOK_STATUS.in_progress:
        return 'W trakcie';
      case BOOK_STATUS.finished:
        return 'Ukończona';
      case BOOK_STATUS.abandoned:
        return 'Porzucona';
      case BOOK_STATUS.planned:
        return 'Planowana';
    }
  }
}

/// Reusable dropdown widget for selecting a book genre
///
/// This widget automatically fetches genres from the API and displays them
/// in a dropdown menu. It handles loading, error, and empty states gracefully.
library;

import 'package:flutter/material.dart';
import '../services/genre_service.dart';
import '../models/types.dart';
import '../core/exceptions.dart';

/// Dropdown widget for selecting a book genre
///
/// Automatically fetches genres from the API and displays them in a dropdown.
/// Handles loading, error, and empty states with appropriate UI feedback.
///
/// **Features:**
/// - Auto-fetches genres on initialization
/// - Shows loading indicator while fetching
/// - Displays error messages with retry button
/// - Supports nullable selection (optional genre)
/// - Caches genres for performance
///
/// **Example:**
/// ```dart
/// String? selectedGenreId;
///
/// GenreSelector(
///   selectedGenreId: selectedGenreId,
///   onChanged: (genreId) {
///     setState(() {
///       selectedGenreId = genreId;
///     });
///   },
/// )
/// ```
class GenreSelector extends StatefulWidget {
  /// Currently selected genre ID (null if no selection)
  final String? selectedGenreId;

  /// Callback when genre selection changes
  final ValueChanged<String?> onChanged;

  /// Whether the field is required (shows asterisk)
  final bool isRequired;

  /// Custom label text (default: "Gatunek")
  final String? labelText;

  /// Custom hint text (default: "Wybierz gatunek książki")
  final String? hintText;

  /// GenreService instance (required for fetching genres)
  final GenreService genreService;

  const GenreSelector({
    super.key,
    this.selectedGenreId,
    required this.onChanged,
    required this.genreService,
    this.isRequired = false,
    this.labelText,
    this.hintText,
  });

  @override
  State<GenreSelector> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {
  List<GenreDto>? _genres;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final genres = await widget.genreService.listGenres();
      setState(() {
        _genres = genres;
        _isLoading = false;
      });
    } on UnauthorizedException {
      setState(() {
        _errorMessage = 'Sesja wygasła. Zaloguj się ponownie.';
        _isLoading = false;
      });
    } on NoInternetException {
      setState(() {
        _errorMessage = 'Brak połączenia z internetem';
        _isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        _errorMessage = 'Przekroczono czas oczekiwania';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Wystąpił błąd: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'Gatunek',
          border: const OutlineInputBorder(),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ładowanie gatunków...', style: TextStyle(color: Colors.grey)),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: widget.labelText ?? 'Gatunek',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
              errorMaxLines: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Nie można załadować gatunków',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.red, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadGenres,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Spróbuj ponownie'),
          ),
        ],
      );
    }

    // Empty state
    if (_genres == null || _genres!.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'Gatunek',
          border: const OutlineInputBorder(),
          helperText: 'Brak dostępnych gatunków',
        ),
        child: const Text(
          'Brak gatunków',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Success state - show dropdown
    return DropdownButtonFormField<String>(
      value: widget.selectedGenreId,
      decoration: InputDecoration(
        labelText: widget.isRequired
            ? '${widget.labelText ?? 'Gatunek'} *'
            : widget.labelText ?? 'Gatunek',
        hintText: widget.hintText ?? 'Wybierz gatunek książki',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.category),
      ),
      items: [
        // Optional "No genre" item
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Bez gatunku', style: TextStyle(color: Colors.grey)),
        ),
        // Genre items
        ..._genres!.map((genre) {
          return DropdownMenuItem<String>(
            value: genre.id,
            child: Text(genre.name),
          );
        }),
      ],
      onChanged: widget.onChanged,
      validator: widget.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Proszę wybrać gatunek';
              }
              return null;
            }
          : null,
    );
  }
}

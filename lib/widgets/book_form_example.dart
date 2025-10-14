/// Example form demonstrating how to use GenreSelector widget
///
/// This is a reference implementation showing best practices for using
/// the GenreSelector in a book creation/editing form.

import 'package:flutter/material.dart';
import '../services/genre_service.dart';
import 'genre_selector.dart';

/// Example book form widget
///
/// Demonstrates proper usage of GenreSelector with form validation
/// and state management.
class BookFormExample extends StatefulWidget {
  final GenreService genreService;

  const BookFormExample({Key? key, required this.genreService})
    : super(key: key);

  @override
  State<BookFormExample> createState() => _BookFormExampleState();
}

class _BookFormExampleState extends State<BookFormExample> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedGenreId;
  String _title = '';
  String _author = '';
  int _pageCount = 0;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Here you would typically create a CreateBookDto and call BookService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Książka: $_title\n'
            'Autor: $_author\n'
            'Gatunek ID: ${_selectedGenreId ?? "brak"}\n'
            'Strony: $_pageCount',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj książkę')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tytuł *',
                hintText: 'Wprowadź tytuł książki',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić tytuł';
                }
                return null;
              },
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),

            // Author field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Autor *',
                hintText: 'Wprowadź autora książki',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić autora';
                }
                return null;
              },
              onSaved: (value) => _author = value!,
            ),
            const SizedBox(height: 16),

            // Genre selector (using our custom widget)
            GenreSelector(
              genreService: widget.genreService,
              selectedGenreId: _selectedGenreId,
              onChanged: (genreId) {
                setState(() {
                  _selectedGenreId = genreId;
                });
              },
              isRequired: false, // Genre is optional
              labelText: 'Gatunek',
              hintText: 'Wybierz gatunek książki',
            ),
            const SizedBox(height: 16),

            // Page count field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Liczba stron *',
                hintText: 'Wprowadź liczbę stron',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Proszę wprowadzić liczbę stron';
                }
                final pages = int.tryParse(value);
                if (pages == null || pages <= 0) {
                  return 'Proszę wprowadzić prawidłową liczbę stron';
                }
                return null;
              },
              onSaved: (value) => _pageCount = int.parse(value!),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.save),
              label: const Text('Zapisz książkę'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informacja',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GenreSelector automatycznie pobiera gatunki z API '
                      'i cachuje je przez 24 godziny dla lepszej wydajności.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aktualnie załadowano: ${widget.genreService.cachedGenresCount ?? 0} gatunków',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

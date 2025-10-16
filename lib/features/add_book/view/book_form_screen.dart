import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_book_library/features/add_book/models/add_book_form_view_model.dart';
import '../../../models/types.dart';
import '../../../services/book_service.dart';
import '../../../services/genre_service.dart';
import '../../../services/google_books_api_service.dart';
import '../bloc/bloc.dart';

/// Book Form Screen - formularz dodawania/edycji książki
///
/// Umożliwia:
/// - Dodawanie nowej książki (bookId == null, bookData opcjonalne)
/// - Edycję istniejącej książki (bookId != null, bookData wypełnione)
class BookFormScreen extends StatelessWidget {
  final AddBookFormViewModel? bookData;
  final List<GenreDto>? genres;
  final String? bookId;

  const BookFormScreen({super.key, this.bookData, this.genres, this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = AddBookBloc(
          bookService: context.read<BookService>(),
          genreService: context.read<GenreService>(),
          googleBooksService: context.read<GoogleBooksService>(),
        );

        // Załaduj gatunki jeśli nie zostały przekazane
        if (genres == null) {
          bloc.add(const FetchGenres());
        }

        return bloc;
      },
      child: _BookFormView(bookData: bookData, genres: genres, bookId: bookId),
    );
  }
}

/// Główny widok formularza książki
class _BookFormView extends StatefulWidget {
  final AddBookFormViewModel? bookData;
  final List<GenreDto>? genres;
  final String? bookId;

  const _BookFormView({this.bookData, this.genres, this.bookId});

  @override
  State<_BookFormView> createState() => _BookFormViewState();
}

class _BookFormViewState extends State<_BookFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _isbnController;
  late final TextEditingController _publisherController;
  late final TextEditingController _yearController;

  String? _selectedGenreId;
  List<GenreDto> _availableGenres = [];

  @override
  void initState() {
    super.initState();

    // Inicjalizacja kontrolerów z danymi (jeśli są)
    _titleController = TextEditingController(
      text: widget.bookData?.title ?? '',
    );
    _authorController = TextEditingController(
      text: widget.bookData?.author ?? '',
    );
    _pageCountController = TextEditingController(
      text: widget.bookData?.pageCount.toString() ?? '',
    );
    _coverUrlController = TextEditingController(
      text: widget.bookData?.coverUrl ?? '',
    );
    _isbnController = TextEditingController(text: widget.bookData?.isbn ?? '');
    _publisherController = TextEditingController(
      text: widget.bookData?.publisher ?? '',
    );
    _yearController = TextEditingController(
      text: widget.bookData?.publicationYear?.toString() ?? '',
    );

    _selectedGenreId = widget.bookData?.genreId;
    _availableGenres = widget.genres ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pageCountController.dispose();
    _coverUrlController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName jest wymagane';
    }
    return null;
  }

  String? _validatePageCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Liczba stron jest wymagana';
    }
    final pages = int.tryParse(value);
    if (pages == null || pages <= 0) {
      return 'Liczba stron musi być większa od 0';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Rok jest opcjonalny
    }
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year + 1) {
      return 'Wprowadź poprawny rok (4 cyfry)';
    }
    return null;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = AddBookFormViewModel(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      pageCount: int.parse(_pageCountController.text.trim()),
      genreId: _selectedGenreId,
      coverUrl: _coverUrlController.text.trim().isEmpty
          ? null
          : _coverUrlController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty
          ? null
          : _isbnController.text.trim(),
      publisher: _publisherController.text.trim().isEmpty
          ? null
          : _publisherController.text.trim(),
      publicationYear: _yearController.text.trim().isEmpty
          ? null
          : int.parse(_yearController.text.trim()),
    );

    context.read<AddBookBloc>().add(
      SaveBook(data: viewModel, bookId: widget.bookId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookId == null ? 'Dodaj książkę' : 'Edytuj książkę'),
      ),
      body: BlocConsumer<AddBookBloc, AddBookState>(
        listener: (context, state) {
          // Aktualizuj listę gatunków gdy zostaną załadowane
          if (state is AddBookReady) {
            setState(() {
              _availableGenres = state.genres;
            });
          }

          // Obsługa pomyślnego zapisu
          if (state is BookSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            // Nawigacja powrotna do ekranu głównego
            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          // Obsługa błędów
          if (state is AddBookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddBookLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Tytuł (wymagane)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tytuł *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  enabled: !isLoading,
                  validator: (value) => _validateRequired(value, 'Tytuł'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Autor (wymagane)
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Autor *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: !isLoading,
                  validator: (value) => _validateRequired(value, 'Autor'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Liczba stron (wymagane)
                TextFormField(
                  controller: _pageCountController,
                  decoration: const InputDecoration(
                    labelText: 'Liczba stron *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePageCount,
                ),
                const SizedBox(height: 16),

                // Gatunek (opcjonalne)
                DropdownButtonFormField<String>(
                  value: _selectedGenreId,
                  decoration: const InputDecoration(
                    labelText: 'Gatunek',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Brak'),
                    ),
                    ..._availableGenres.map((genre) {
                      return DropdownMenuItem<String>(
                        value: genre.id,
                        child: Text(genre.name),
                      );
                    }),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedGenreId = value;
                          });
                        },
                ),
                const SizedBox(height: 16),

                // URL okładki (opcjonalne)
                TextFormField(
                  controller: _coverUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL okładki',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                  enabled: !isLoading,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),

                // ISBN (opcjonalne)
                TextFormField(
                  controller: _isbnController,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  enabled: !isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\-\sX]')),
                  ],
                ),
                const SizedBox(height: 16),

                // Wydawca (opcjonalne)
                TextFormField(
                  controller: _publisherController,
                  decoration: const InputDecoration(
                    labelText: 'Wydawca',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Rok wydania (opcjonalne)
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Rok wydania',
                    hintText: 'RRRR',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateYear,
                ),
                const SizedBox(height: 24),

                // Przycisk zapisu
                FilledButton.icon(
                  onPressed: isLoading ? null : _handleSave,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    widget.bookId == null ? 'Dodaj książkę' : 'Zapisz zmiany',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 8),

                // Informacja o wymaganych polach
                Text(
                  '* Pola wymagane',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

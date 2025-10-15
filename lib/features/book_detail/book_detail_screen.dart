import 'package:flutter/material.dart';

/// Screen for displaying book details
///
/// Shows complete information about a book including:
/// - Cover image
/// - Title, author, publisher
/// - Reading status and progress
/// - Actions (edit, delete, start reading session)
class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły książki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edytuj',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edycja - wkrótce dostępna')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuwanie - wkrótce dostępne')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Szczegóły książki',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('ID: $bookId', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text(
                'Wkrótce dostępna pełna funkcjonalność szczegółów książki',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rozpoczęcie sesji czytania - wkrótce dostępne'),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Rozpocznij czytanie'),
      ),
    );
  }
}

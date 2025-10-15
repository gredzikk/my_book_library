import 'package:flutter/material.dart';

/// Screen for adding a new book
///
/// TODO: Implement full book creation form with:
/// - Manual input fields
/// - ISBN scanner
/// - Google Books API search
class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj książkę')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 80, color: Colors.blue),
              SizedBox(height: 24),
              Text(
                'Ekran dodawania książki',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Wkrótce dostępna pełna funkcjonalność dodawania książek',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

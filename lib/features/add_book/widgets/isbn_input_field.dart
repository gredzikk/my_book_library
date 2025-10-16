import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget do wprowadzania numeru ISBN
///
/// Zawiera pole tekstowe z walidacją formatu ISBN oraz przycisk wyszukiwania.
class IsbnInputField extends StatefulWidget {
  final bool enabled;
  final void Function(String isbn) onSearch;

  const IsbnInputField({
    super.key,
    required this.enabled,
    required this.onSearch,
  });

  @override
  State<IsbnInputField> createState() => _IsbnInputFieldState();
}

class _IsbnInputFieldState extends State<IsbnInputField> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Waliduje format numeru ISBN (10 lub 13 cyfr)
  String? _validateIsbn(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wprowadź numer ISBN';
    }

    // Usuń myślniki i spacje
    final cleanIsbn = value.replaceAll(RegExp(r'[-\s]'), '');

    // Sprawdź czy zawiera tylko cyfry (i opcjonalnie X na końcu dla ISBN-10)
    if (!RegExp(r'^\d{9}[\dX]$|^\d{13}$').hasMatch(cleanIsbn)) {
      return 'ISBN musi mieć 10 lub 13 cyfr';
    }

    return null;
  }

  void _handleSearch() {
    setState(() {
      _errorText = _validateIsbn(_controller.text);
    });

    if (_errorText == null) {
      final cleanIsbn = _controller.text.replaceAll(RegExp(r'[-\s]'), '');
      widget.onSearch(cleanIsbn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              decoration: InputDecoration(
                labelText: 'Numer ISBN',
                hintText: '978-83-123-4567-8',
                helperText: 'Format: 10 lub 13 cyfr',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.numbers),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\-\sX]')),
                LengthLimitingTextInputFormatter(17), // 13 cyfr + 4 myślniki
              ],
              onChanged: (value) {
                // Resetuj błąd przy zmianie wartości
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onFieldSubmitted: (_) => _handleSearch(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: widget.enabled ? _handleSearch : null,
            icon: const Icon(Icons.search),
            label: const Text('Szukaj'),
            style: FilledButton.styleFrom(minimumSize: const Size(120, 56)),
          ),
        ],
      ),
    );
  }
}

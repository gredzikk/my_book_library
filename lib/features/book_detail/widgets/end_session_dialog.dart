import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for ending a reading session and inputting progress
///
/// Allows user to input:
/// - Last page read
///
/// Validates that:
/// - Value is a valid integer
/// - Value is greater than current progress
/// - Value does not exceed total page count
class EndSessionDialog extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int newPage) onSave;

  const EndSessionDialog({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSave,
  });

  @override
  State<EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends State<EndSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // Initialize with next page
    _pageController.text = (widget.currentPage + 1).toString();
    _validateInput();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _pageController.text;
    if (text.isEmpty) {
      setState(() => _isValid = false);
      return;
    }

    final value = int.tryParse(text);
    if (value == null) {
      setState(() => _isValid = false);
      return;
    }

    final valid = value > widget.currentPage && value <= widget.totalPages;
    setState(() => _isValid = valid);
  }

  String? _getErrorText() {
    final text = _pageController.text;
    if (text.isEmpty) return null;

    final value = int.tryParse(text);
    if (value == null) {
      return 'Wartość musi być liczbą';
    }

    if (value <= widget.currentPage) {
      return 'Strona musi być większa niż ${widget.currentPage}';
    }

    if (value > widget.totalPages) {
      return 'Strona nie może przekraczać ${widget.totalPages}';
    }

    return null;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final page = int.parse(_pageController.text);
      widget.onSave(page);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Zakończ sesję czytania'),
      insetPadding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: 24.0 + MediaQuery.of(context).padding.bottom,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Na jakiej stronie zakończyłeś czytanie?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Current progress info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Obecny postęp: ${widget.currentPage} / ${widget.totalPages}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Page input field
            TextFormField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Numer strony',
                hintText: 'Np. ${widget.currentPage + 10}',
                prefixIcon: const Icon(Icons.book),
                border: const OutlineInputBorder(),
                errorText: _getErrorText(),
                helperText: 'Wpisz ostatnią przeczytaną stronę',
              ),
              onChanged: (value) => _validateInput(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To pole jest wymagane';
                }

                final page = int.tryParse(value);
                if (page == null) {
                  return 'Wartość musi być liczbą';
                }

                if (page <= widget.currentPage) {
                  return 'Strona musi być większa niż ${widget.currentPage}';
                }

                if (page > widget.totalPages) {
                  return 'Strona nie może przekraczać ${widget.totalPages}';
                }

                return null;
              },
            ),

            // Quick increment buttons
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickButton(context, '+1', 1),
                _buildQuickButton(context, '+5', 5),
                _buildQuickButton(context, '+10', 10),
                _buildQuickButton(context, '+20', 20),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: _isValid ? _handleSave : null,
          child: const Text('Zapisz'),
        ),
      ],
    );
  }

  /// Builds a quick increment button
  Widget _buildQuickButton(BuildContext context, String label, int increment) {
    final newValue = widget.currentPage + increment;
    final enabled = newValue <= widget.totalPages;

    return ActionChip(
      label: Text(label),
      onPressed: enabled
          ? () {
              _pageController.text = newValue.toString();
              _validateInput();
            }
          : null,
    );
  }
}

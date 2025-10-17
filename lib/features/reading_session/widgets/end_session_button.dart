import 'package:flutter/material.dart';

/// Button for ending the reading session
///
/// A prominent call-to-action button that triggers the end session flow
class EndSessionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const EndSessionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.stop),
      label: Text(isLoading ? 'Zapisywanie...' : 'Zakończ sesję'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

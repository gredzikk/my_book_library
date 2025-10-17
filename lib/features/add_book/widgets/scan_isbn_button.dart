import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';

/// Widget przycisku do skanowania ISBN
///
/// Otwiera ekran skanowania kodów kreskowych używając biblioteki mobile_scanner.
/// Po zeskanowaniu ISBN wywołuje callback onScanned.
class ScanIsbnButton extends StatelessWidget {
  final bool enabled;
  final void Function(String isbn) onScanned;

  const ScanIsbnButton({
    super.key,
    required this.enabled,
    required this.onScanned,
  });

  Future<void> _handleScan(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      onScanned(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: enabled ? () => _handleScan(context) : null,
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Skanuj kod kreskowy'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    );
  }
}

import 'package:flutter/material.dart';

/// Widget przycisku do skanowania ISBN
///
/// PLACEHOLDER - wymaga dodania biblioteki mobile_scanner do pubspec.yaml
///
/// Aby włączyć skanowanie:
/// 1. Dodaj do pubspec.yaml: mobile_scanner: ^5.0.0
/// 2. Odkomentuj implementację w _handleScan()
/// 3. Dodaj odpowiednie uprawnienia w AndroidManifest.xml i Info.plist
class ScanIsbnButton extends StatelessWidget {
  final bool enabled;
  final void Function(String isbn) onScanned;

  const ScanIsbnButton({
    super.key,
    required this.enabled,
    required this.onScanned,
  });

  Future<void> _handleScan(BuildContext context) async {
    // TODO: Implement scanner when mobile_scanner is added
    // Example implementation:
    /*
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MobileScannerScreen(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                Navigator.of(context).pop();
                onScanned(barcode.rawValue!);
                break;
              }
            }
          },
        ),
      ),
    );
    */

    // Temporary: Show info dialog
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skaner ISBN'),
        content: const Text(
          'Funkcja skanowania kodów kreskowych będzie dostępna w przyszłej wersji.\n\n'
          'Na razie proszę użyć ręcznego wprowadzania numeru ISBN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

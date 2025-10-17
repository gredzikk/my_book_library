import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Barcode Scanner Screen - ekran skanowania kodów kreskowych
///
/// Używa biblioteki mobile_scanner do skanowania kodów ISBN.
/// Obsługuje formaty: EAN-13 (najczęstszy dla książek), EAN-8, ISBN.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        // Sprawdź czy to potencjalnie ISBN (10 lub 13 cyfr)
        final cleanCode = code.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanCode.length == 10 || cleanCode.length == 13) {
          setState(() => _isProcessing = true);
          Navigator.of(context).pop(cleanCode);
          return;
        }
      }
    }
  }

  void _toggleFlash() {
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skanuj kod ISBN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _toggleFlash,
            tooltip: 'Przełącz latarkę',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner view
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Błąd kamery',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.errorDetails?.message ??
                            'Nie można uruchomić kamery',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Wróć'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Overlay with scanning area indicator
          CustomPaint(painter: _ScannerOverlayPainter(), child: Container()),

          // Instructions at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Skieruj kamerę na kod kreskowy ISBN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kod zostanie automatycznie zeskanowany',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// Custom painter dla overlay z obszarem skanowania
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Wymiary i pozycja obszaru skanowania
    const scanAreaWidth = 280.0;
    const scanAreaHeight = 160.0;
    final scanAreaLeft = (size.width - scanAreaWidth) / 2;
    final scanAreaTop = (size.height - scanAreaHeight) / 2;

    // Rysuj przyciemnione tło wokół obszaru skanowania
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(
        Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaWidth, scanAreaHeight),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Rysuj ramkę obszaru skanowania
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaWidth, scanAreaHeight),
      const Radius.circular(12),
    );

    canvas.drawRRect(borderRect, borderPaint);

    // Rysuj narożniki
    final cornerPaint = Paint()
      ..color = Theme.of(NavigatorState().context).colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Lewy górny róg
    canvas
      ..drawLine(
        Offset(scanAreaLeft, scanAreaTop + cornerLength),
        Offset(scanAreaLeft, scanAreaTop),
        cornerPaint,
      )
      ..drawLine(
        Offset(scanAreaLeft, scanAreaTop),
        Offset(scanAreaLeft + cornerLength, scanAreaTop),
        cornerPaint,
      );

    // Prawy górny róg
    canvas
      ..drawLine(
        Offset(scanAreaLeft + scanAreaWidth - cornerLength, scanAreaTop),
        Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
        cornerPaint,
      )
      ..drawLine(
        Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
        Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + cornerLength),
        cornerPaint,
      );

    // Lewy dolny róg
    canvas
      ..drawLine(
        Offset(scanAreaLeft, scanAreaTop + scanAreaHeight - cornerLength),
        Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
        cornerPaint,
      )
      ..drawLine(
        Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
        Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaHeight),
        cornerPaint,
      );

    // Prawy dolny róg
    canvas
      ..drawLine(
        Offset(
          scanAreaLeft + scanAreaWidth - cornerLength,
          scanAreaTop + scanAreaHeight,
        ),
        Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
        cornerPaint,
      )
      ..drawLine(
        Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
        Offset(
          scanAreaLeft + scanAreaWidth,
          scanAreaTop + scanAreaHeight - cornerLength,
        ),
        cornerPaint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'package:flutter/material.dart';

/// Widget displaying a running stopwatch for the reading session
///
/// This widget manages its own Timer to update the display every second.
/// It calculates the elapsed time based on the provided start time.
class StopwatchDisplay extends StatefulWidget {
  final DateTime startTime;

  const StopwatchDisplay({super.key, required this.startTime});

  @override
  State<StopwatchDisplay> createState() => _StopwatchDisplayState();
}

class _StopwatchDisplayState extends State<StopwatchDisplay> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsedTime();

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateElapsedTime();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Czas czytania',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _formatDuration(_elapsed),
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  /// Formats duration as HH:MM:SS
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

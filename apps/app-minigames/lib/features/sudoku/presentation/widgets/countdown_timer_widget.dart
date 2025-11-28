import 'package:flutter/material.dart';

/// Countdown timer widget for TimeAttack mode
class CountdownTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final bool showPulse;

  const CountdownTimerWidget({
    super.key,
    required this.remainingSeconds,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on remaining time
    Color textColor;
    Color bgColor;
    if (remainingSeconds <= 10) {
      textColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
    } else if (remainingSeconds <= 30) {
      textColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    } else if (remainingSeconds <= 60) {
      textColor = Colors.amber.shade700;
      bgColor = Colors.amber.shade50;
    } else {
      textColor = Colors.grey.shade700;
      bgColor = Colors.transparent;
    }

    Widget timerText = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: textColor, size: 20),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    // Add pulse animation when time is critical
    if (showPulse && remainingSeconds <= 10 && remainingSeconds > 0) {
      return _PulsingWidget(child: timerText);
    }

    return timerText;
  }
}

/// Compact countdown for stats bar
class CountdownStatWidget extends StatelessWidget {
  final int remainingSeconds;

  const CountdownStatWidget({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on remaining time
    Color color;
    if (remainingSeconds <= 10) {
      color = Colors.red;
    } else if (remainingSeconds <= 30) {
      color = Colors.orange;
    } else if (remainingSeconds <= 60) {
      color = Colors.amber.shade700;
    } else {
      color = Colors.grey.shade700;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          timeString,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          'Restante',
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Widget that pulses to draw attention
class _PulsingWidget extends StatefulWidget {
  final Widget child;

  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Full countdown timer with progress bar
class CountdownTimerWithProgressWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const CountdownTimerWithProgressWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on progress
    Color color;
    if (progress <= 0.1) {
      color = Colors.red;
    } else if (progress <= 0.25) {
      color = Colors.orange;
    } else if (progress <= 0.5) {
      color = Colors.amber;
    } else {
      color = Colors.green;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

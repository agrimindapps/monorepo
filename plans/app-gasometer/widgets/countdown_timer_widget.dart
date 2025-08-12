// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetDate;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  const CountdownTimerWidget({
    super.key,
    required this.targetDate,
    this.title = 'LANÇAMENTO PREVISTO PARA',
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);

    if (mounted) {
      setState(() {
        _timeLeft = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysText(int days) {
    if (days == 0) return 'Hoje é o dia!';
    if (days == 1) return 'Falta apenas 1 dia';
    return 'Faltam apenas $days dias';
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final isLaunched = _timeLeft == Duration.zero;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[400]!.withValues(alpha: 0.9),
            Colors.orange[500]!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLaunched ? 'JÁ DISPONÍVEL!' : widget.title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _formatDate(widget.targetDate),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLaunched ? Icons.celebration : Icons.schedule,
                color: Colors.black87,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getDaysText(days),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

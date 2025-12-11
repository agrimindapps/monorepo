import 'dart:async';

import 'package:flutter/material.dart';

/// Compact countdown widget for the navigation bar
/// Shows remaining time in a discrete, minimal format
class PromoCompactCountdown extends StatefulWidget {
  final DateTime launchDate;
  final TextStyle? textStyle;

  const PromoCompactCountdown({
    required this.launchDate,
    this.textStyle,
    super.key,
  });

  @override
  State<PromoCompactCountdown> createState() => _PromoCompactCountdownState();
}

class _PromoCompactCountdownState extends State<PromoCompactCountdown> {
  late Timer _timer;
  late String _displayText;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_updateCountdown);
      }
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final remaining = widget.launchDate.difference(now);

    if (remaining.isNegative) {
      _displayText = 'Lançado!';
      _timer.cancel();
      return;
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    if (days > 0) {
      _displayText = '$days dias, ${hours}h';
    } else if (hours > 0) {
      _displayText = '${hours}h ${minutes}m';
    } else {
      final seconds = remaining.inSeconds % 60;
      _displayText = '${minutes}m ${seconds}s';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFF9800), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 16, color: Color(0xFFFF6F00)),
          const SizedBox(width: 6),
          Text(
            _displayText,
            style:
                widget.textStyle ??
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
          ),
        ],
      ),
    );
  }
}

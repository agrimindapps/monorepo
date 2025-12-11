import 'dart:async';

import 'package:flutter/material.dart';

/// Highlighted countdown badge for hero section with flip clock style
/// Shows prominently above action buttons with real-time updates
/// Digital flip clock design with individual digit boxes
class PromoHeroCountdownBadge extends StatefulWidget {
  final DateTime launchDate;

  const PromoHeroCountdownBadge({required this.launchDate, super.key});

  @override
  State<PromoHeroCountdownBadge> createState() =>
      _PromoHeroCountdownBadgeState();
}

class _PromoHeroCountdownBadgeState extends State<PromoHeroCountdownBadge> {
  late Timer _timer;
  late int _days;
  late int _hours;
  late int _minutes;
  late int _seconds;

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
      _days = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _timer.cancel();
      return;
    }

    _days = remaining.inDays;
    _hours = remaining.inHours % 24;
    _minutes = remaining.inMinutes % 60;
    _seconds = remaining.inSeconds % 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flip Clock Display
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlipClockUnit('${_days ~/ 10}', '${_days % 10}'),
            const SizedBox(width: 8),
            _buildTimeSeparator(isMobile),
            const SizedBox(width: 8),
            _buildFlipClockUnit('${_hours ~/ 10}', '${_hours % 10}'),
            const SizedBox(width: 8),
            _buildTimeSeparator(isMobile),
            const SizedBox(width: 8),
            _buildFlipClockUnit('${_minutes ~/ 10}', '${_minutes % 10}'),
            const SizedBox(width: 8),
            _buildTimeSeparator(isMobile),
            const SizedBox(width: 8),
            _buildFlipClockUnit('${_seconds ~/ 10}', '${_seconds % 10}'),
          ],
        ),
        const SizedBox(height: 16),
        // Labels
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLabel('Dias', isMobile),
            const SizedBox(width: 8),
            const SizedBox(width: 24), // Spacing for separator
            const SizedBox(width: 8),
            _buildLabel('Horas', isMobile),
            const SizedBox(width: 8),
            const SizedBox(width: 24), // Spacing for separator
            const SizedBox(width: 8),
            _buildLabel('Minutos', isMobile),
            const SizedBox(width: 8),
            const SizedBox(width: 24), // Spacing for separator
            const SizedBox(width: 8),
            _buildLabel('Segundos', isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildFlipClockUnit(String tens, String ones) {
    return Row(
      children: [
        _buildDigitBox(tens),
        const SizedBox(width: 4),
        _buildDigitBox(ones),
      ],
    );
  }

  Widget _buildDigitBox(String digit) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'monospace',
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSeparator(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2C),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2C),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, bool isMobile) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isMobile ? 11 : 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }
}

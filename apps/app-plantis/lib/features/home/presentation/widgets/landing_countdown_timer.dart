import 'dart:async';

import 'package:flutter/material.dart';

/// Widget that displays a countdown timer to the launch date
/// Updates every second to show days, hours, minutes, and seconds remaining
class LandingCountdownTimer extends StatefulWidget {
  /// The target launch date
  final DateTime launchDate;

  /// Style configuration for the countdown display
  final CountdownTimerStyle style;

  const LandingCountdownTimer({
    required this.launchDate,
    this.style = const CountdownTimerStyle(),
    super.key,
  });

  @override
  State<LandingCountdownTimer> createState() => _LandingCountdownTimerState();
}

class _LandingCountdownTimerState extends State<LandingCountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_updateRemaining);
      }
    });
  }

  void _updateRemaining() {
    _remaining = widget.launchDate.difference(DateTime.now());
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      padding: widget.style.padding,
      decoration: widget.style.decoration,
      child: Column(
        children: [
          if (widget.style.showLabel)
            Text(
              widget.style.label,
              style: widget.style.labelStyle,
            ),
          if (widget.style.showLabel)
            SizedBox(height: widget.style.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimerUnit(
                value: days,
                label: 'Dias',
                style: widget.style.unitStyle,
              ),
              SizedBox(width: widget.style.spacing),
              _TimerUnit(
                value: hours,
                label: 'Horas',
                style: widget.style.unitStyle,
              ),
              SizedBox(width: widget.style.spacing),
              _TimerUnit(
                value: minutes,
                label: 'Minutos',
                style: widget.style.unitStyle,
              ),
              SizedBox(width: widget.style.spacing),
              _TimerUnit(
                value: seconds,
                label: 'Segundos',
                style: widget.style.unitStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual timer unit display (e.g., days, hours, minutes, seconds)
class _TimerUnit extends StatelessWidget {
  final int value;
  final String label;
  final TimerUnitStyle style;

  const _TimerUnit({
    required this.value,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: style.width,
          height: style.height,
          decoration: style.boxDecoration,
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: style.numberStyle,
            ),
          ),
        ),
        SizedBox(height: style.labelSpacing),
        Text(
          label,
          style: style.labelStyle,
        ),
      ],
    );
  }
}

/// Style configuration for the countdown timer widget
class CountdownTimerStyle {
  /// Padding around the countdown widget
  final EdgeInsets padding;

  /// Decoration for the countdown container
  final BoxDecoration decoration;

  /// Whether to show the "Lançamento em:" label
  final bool showLabel;

  /// Text for the countdown label
  final String label;

  /// Style for the countdown label
  final TextStyle labelStyle;

  /// Spacing between elements
  final double spacing;

  /// Style for individual timer units
  final TimerUnitStyle unitStyle;

  const CountdownTimerStyle({
    this.padding = const EdgeInsets.all(24),
    this.decoration = const BoxDecoration(
      color: Color(0xFFF0F9F0),
      borderRadius: BorderRadius.all(Radius.circular(16)),
      border: Border(
        bottom: BorderSide(
          color: Color(0xFF4CAF50),
          width: 4,
        ),
      ),
    ),
    this.showLabel = true,
    this.label = 'Lançamento em:',
    this.labelStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2E7D32),
    ),
    this.spacing = 12,
    this.unitStyle = const TimerUnitStyle(),
  });
}

/// Style configuration for individual timer units
class TimerUnitStyle {
  /// Width of the timer box
  final double width;

  /// Height of the timer box
  final double height;

  /// Decoration for the timer box
  final BoxDecoration boxDecoration;

  /// Style for the number text
  final TextStyle numberStyle;

  /// Spacing between number and label
  final double labelSpacing;

  /// Style for the unit label
  final TextStyle labelStyle;

  const TimerUnitStyle({
    this.width = 60,
    this.height = 60,
    this.boxDecoration = const BoxDecoration(
      color: Color(0xFF4CAF50),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.numberStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.labelSpacing = 8,
    this.labelStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF2E7D32),
      fontWeight: FontWeight.w500,
    ),
  });
}

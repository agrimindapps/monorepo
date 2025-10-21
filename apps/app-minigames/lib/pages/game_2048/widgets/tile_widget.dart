// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'merge_effect.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final bool isMerging;
  final bool isNew;
  final TileColorScheme colorScheme;
  final double? size;
  final double? fontSize;

  const TileWidget({
    super.key,
    required this.value,
    this.isMerging = false,
    this.isNew = false,
    required this.colorScheme,
    this.size,
    this.fontSize,
  });

  Color _getTileColor(int value) {
    if (value == 0) return Colors.grey[200]!;
    if (value == 2048) return Colors.amber;

    // Calculate color intensity based on the value
    int colorLevel = min(900, (log(value) / log(2) - 1).floor() * 100);

    switch (colorScheme) {
      case TileColorScheme.blue:
        return value <= 4
            ? Colors.blue[50 + colorLevel ~/ 2]!
            : Colors.blue[colorLevel]!;
      case TileColorScheme.green:
        return value <= 4
            ? Colors.green[50 + colorLevel ~/ 2]!
            : Colors.green[colorLevel]!;
      case TileColorScheme.purple:
        return value <= 4
            ? Colors.purple[50 + colorLevel ~/ 2]!
            : Colors.purple[colorLevel]!;
      case TileColorScheme.orange:
        return value <= 4
            ? Colors.orange[50 + colorLevel ~/ 2]!
            : Colors.orange[colorLevel]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: isNew ? 300 : 200),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MergeEffect(
        isMerging: isMerging,
        child: AnimatedScale(
          duration: Duration(milliseconds: isNew ? 300 : 200),
          scale: value == 0 ? 0 : 1.0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                value == 0 ? '' : value.toString(),
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: fontSize ?? 24,
                  fontWeight: FontWeight.bold,
                  color: value > 4 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

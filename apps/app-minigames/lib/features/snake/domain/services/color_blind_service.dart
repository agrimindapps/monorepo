// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/enums.dart';

/// Service for color blind accessible colors
class ColorBlindService {
  final bool colorBlindMode;

  const ColorBlindService({this.colorBlindMode = false});

  /// Snake head color
  Color get snakeHeadColor =>
      colorBlindMode ? Colors.blue : Colors.green;

  /// Snake body color
  Color get snakeBodyColor =>
      colorBlindMode ? Colors.blue.shade300 : Colors.green.shade300;

  /// Food color
  Color get foodColor =>
      colorBlindMode ? Colors.orange : Colors.red;

  /// Get power-up color
  Color getPowerUpColor(PowerUpType type) {
    if (colorBlindMode) {
      return switch (type) {
        PowerUpType.speedBoost => Colors.blue.shade300,
        PowerUpType.shield => Colors.blue.shade700,
        PowerUpType.doublePoints => Colors.yellow,
        PowerUpType.slowMotion => Colors.purple,
        PowerUpType.magnet => Colors.orange,
        PowerUpType.ghostMode => Colors.white,
      };
    }
    return type.color;
  }

  /// Get difficulty color
  Color getDifficultyColor(SnakeDifficulty difficulty) {
    if (colorBlindMode) {
      return switch (difficulty) {
        SnakeDifficulty.easy => Colors.blue.shade300,
        SnakeDifficulty.medium => Colors.orange,
        SnakeDifficulty.hard => Colors.purple,
      };
    }
    return difficulty.color;
  }
}

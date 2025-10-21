// Define as constantes e enums do jogo Tower Stack

// Flutter imports:
import 'package:flutter/material.dart';

enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Fácil';
      case GameDifficulty.medium:
        return 'Médio';
      case GameDifficulty.hard:
        return 'Difícil';
    }
  }

  double get speedMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 0.8;
      case GameDifficulty.medium:
        return 1.0;
      case GameDifficulty.hard:
        return 1.5;
    }
  }
}

class GameColors {
  static List<Color> blockColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
  ];
}

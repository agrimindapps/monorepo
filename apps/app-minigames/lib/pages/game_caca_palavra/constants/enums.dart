// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'strings.dart';

enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return GameStrings.difficultyEasy;
      case GameDifficulty.medium:
        return GameStrings.difficultyMedium;
      case GameDifficulty.hard:
        return GameStrings.difficultyHard;
    }
  }

  // Tamanho do grid por nível de dificuldade
  int get gridSize {
    switch (this) {
      case GameDifficulty.easy:
        return 8;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 12;
    }
  }

  // Quantidade de palavras por nível
  int get wordCount {
    switch (this) {
      case GameDifficulty.easy:
        return 5;
      case GameDifficulty.medium:
        return 8;
      case GameDifficulty.hard:
        return 12;
    }
  }
}

enum Direction {
  horizontal,
  vertical,
  diagonalDown,
  diagonalUp;

  static Direction random() {
    final random = Random();
    const values = Direction.values;
    return values[random.nextInt(values.length)];
  }

  String get label {
    switch (this) {
      case Direction.horizontal:
        return GameStrings.directionHorizontal;
      case Direction.vertical:
        return GameStrings.directionVertical;
      case Direction.diagonalDown:
        return GameStrings.directionDiagonalDown;
      case Direction.diagonalUp:
        return GameStrings.directionDiagonalUp;
    }
  }
}

class GameColors {
  static const Color selectedLetter = Colors.amber;
  static const Color foundWord = Colors.green;
  static const Color highlightedWord = Colors.blue;
  static const Color gridBackground = Color(0xFFF5F5F5);
  static const Color wordListText = Colors.black87;
  static const Color foundWordText = Colors.green;
}

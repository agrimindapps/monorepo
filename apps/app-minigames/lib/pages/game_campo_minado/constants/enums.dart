// Flutter imports:
import 'package:flutter/material.dart';

/// Game state enumeration
enum GameState {
  ready,
  playing,
  won,
  lost,
}

extension GameStateExtension on GameState {
  String get message {
    switch (this) {
      case GameState.ready:
        return 'Toque para iniciar!';
      case GameState.playing:
        return '';
      case GameState.won:
        return '🎉 Você Venceu! 🎉';
      case GameState.lost:
        return '💥 Game Over! 💥';
    }
  }

  Color get color {
    switch (this) {
      case GameState.ready:
        return Colors.blue;
      case GameState.playing:
        return Colors.green;
      case GameState.won:
        return Colors.amber;
      case GameState.lost:
        return Colors.red;
    }
  }
}

/// Difficulty levels
enum GameDifficulty {
  beginner,
  intermediate,
  expert,
  custom,
}

extension GameDifficultyExtension on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.beginner:
        return 'Iniciante';
      case GameDifficulty.intermediate:
        return 'Intermediário';
      case GameDifficulty.expert:
        return 'Expert';
      case GameDifficulty.custom:
        return 'Personalizado';
    }
  }

  /// Grid dimensions and mine count for each difficulty
  GameConfig get config {
    switch (this) {
      case GameDifficulty.beginner:
        return const GameConfig(rows: 9, cols: 9, mines: 10);
      case GameDifficulty.intermediate:
        return const GameConfig(rows: 16, cols: 16, mines: 40);
      case GameDifficulty.expert:
        return const GameConfig(rows: 16, cols: 30, mines: 99);
      case GameDifficulty.custom:
        return const GameConfig(rows: 10, cols: 10, mines: 15); // Default custom
    }
  }
}

/// Game configuration data class
class GameConfig {
  final int rows;
  final int cols;
  final int mines;

  const GameConfig({
    required this.rows,
    required this.cols,
    required this.mines,
  });

  int get totalCells => rows * cols;
  int get safeCells => totalCells - mines;

  GameConfig copyWith({
    int? rows,
    int? cols,
    int? mines,
  }) {
    return GameConfig(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      mines: mines ?? this.mines,
    );
  }
}

/// Cell state enumeration
enum CellState {
  hidden,
  revealed,
  flagged,
  questioned,
}

/// Game colors
class GameColors {
  static const Color background = Color(0xFFC6C6C6);
  static const Color cellHidden = Color(0xFFBDBDBD);
  static const Color cellRevealed = Color(0xFFE0E0E0);
  static const Color cellMine = Color(0xFFFF1744);
  static const Color cellFlag = Color(0xFFFF5722);
  static const Color cellQuestion = Color(0xFFFF9800);
  
  // Number colors for revealed cells
  static const List<Color> numberColors = [
    Colors.transparent, // 0 - no color
    Color(0xFF1976D2), // 1 - blue
    Color(0xFF388E3C), // 2 - green
    Color(0xFFD32F2F), // 3 - red
    Color(0xFF7B1FA2), // 4 - purple
    Color(0xFF795548), // 5 - brown
    Color(0xFF00796B), // 6 - teal
    Color(0xFF424242), // 7 - grey
    Color(0xFF000000), // 8 - black
  ];

  static Color getNumberColor(int count) {
    if (count >= 0 && count < numberColors.length) {
      return numberColors[count];
    }
    return Colors.black;
  }
}

/// Game sizes and dimensions
class GameSizes {
  static const double cellSize = 32.0;
  static const double cellPadding = 1.0;
  static const double headerHeight = 80.0;
  static const double timerFontSize = 24.0;
  static const double counterFontSize = 24.0;
  static const double cellFontSize = 16.0;
}

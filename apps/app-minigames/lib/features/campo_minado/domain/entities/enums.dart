import 'package:flutter/material.dart';

/// Represents the current state of the Campo Minado game
enum GameStatus {
  ready,
  playing,
  won,
  lost;

  String get message {
    switch (this) {
      case GameStatus.ready:
        return 'Toque para iniciar!';
      case GameStatus.playing:
        return '';
      case GameStatus.won:
        return 'Você Venceu!';
      case GameStatus.lost:
        return 'Game Over!';
    }
  }

  Color get color {
    switch (this) {
      case GameStatus.ready:
        return Colors.blue;
      case GameStatus.playing:
        return Colors.green;
      case GameStatus.won:
        return Colors.amber;
      case GameStatus.lost:
        return Colors.red;
    }
  }

  bool get isGameOver => this == GameStatus.won || this == GameStatus.lost;
  bool get isPlaying => this == GameStatus.playing;
}

/// Difficulty levels for Campo Minado
enum Difficulty {
  beginner,
  intermediate,
  expert,
  custom;

  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Iniciante';
      case Difficulty.intermediate:
        return 'Intermediário';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.custom:
        return 'Personalizado';
    }
  }

  /// Grid dimensions and mine count for each difficulty
  GameConfig get config {
    switch (this) {
      case Difficulty.beginner:
        return const GameConfig(rows: 9, cols: 9, mines: 10);
      case Difficulty.intermediate:
        return const GameConfig(rows: 16, cols: 16, mines: 40);
      case Difficulty.expert:
        return const GameConfig(rows: 16, cols: 30, mines: 99);
      case Difficulty.custom:
        return const GameConfig(rows: 10, cols: 10, mines: 15);
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameConfig &&
        other.rows == rows &&
        other.cols == cols &&
        other.mines == mines;
  }

  @override
  int get hashCode => Object.hash(rows, cols, mines);
}

/// Cell state in the minefield
enum CellStatus {
  hidden,
  revealed,
  flagged,
  questioned;

  bool get isHidden => this == CellStatus.hidden;
  bool get isRevealed => this == CellStatus.revealed;
  bool get isFlagged => this == CellStatus.flagged;
  bool get isQuestioned => this == CellStatus.questioned;
}

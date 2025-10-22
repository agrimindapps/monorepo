// Flutter imports:
import 'package:flutter/material.dart';

/// Direction of snake movement
enum Direction {
  up,
  down,
  left,
  right;

  /// Check if this direction is opposite to another
  bool isOpposite(Direction other) {
    return (this == Direction.up && other == Direction.down) ||
        (this == Direction.down && other == Direction.up) ||
        (this == Direction.left && other == Direction.right) ||
        (this == Direction.right && other == Direction.left);
  }
}

/// Status of the snake game
enum SnakeGameStatus {
  notStarted,
  running,
  paused,
  gameOver;

  bool get isNotStarted => this == SnakeGameStatus.notStarted;
  bool get isRunning => this == SnakeGameStatus.running;
  bool get isPaused => this == SnakeGameStatus.paused;
  bool get isGameOver => this == SnakeGameStatus.gameOver;

  bool get isPlayable => isRunning;
}

/// Difficulty levels for snake game
enum SnakeDifficulty {
  easy(
    label: 'Fácil',
    gameSpeed: Duration(milliseconds: 50),
    color: Colors.green,
  ),
  medium(
    label: 'Médio',
    gameSpeed: Duration(milliseconds: 32),
    color: Colors.orange,
  ),
  hard(
    label: 'Difícil',
    gameSpeed: Duration(milliseconds: 16),
    color: Colors.red,
  );

  const SnakeDifficulty({
    required this.label,
    required this.gameSpeed,
    required this.color,
  });

  final String label;
  final Duration gameSpeed;
  final Color color;
}

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

/// Game modes for snake game
enum SnakeGameMode {
  classic(
    label: 'Clássico',
    description: 'Modo tradicional',
    emoji: '🐍',
  ),
  survival(
    label: 'Survival',
    description: 'Velocidade aumenta constantemente',
    emoji: '⚡',
  ),
  timeAttack(
    label: 'Time Attack',
    description: 'Máximo de pontos no tempo limite',
    emoji: '⏱️',
  ),
  endless(
    label: 'Endless',
    description: 'Sem game over por colisão',
    emoji: '♾️',
  );

  const SnakeGameMode({
    required this.label,
    required this.description,
    required this.emoji,
  });

  final String label;
  final String description;
  final String emoji;
}

/// Death types for statistics tracking
enum SnakeDeathType {
  self('Próprio corpo'),
  wall('Parede'),
  timeout('Tempo esgotado'),
  scorePenalty('Penalidade de score');

  const SnakeDeathType(this.label);
  final String label;
}

/// Types of power-ups available in the game
enum PowerUpType {
  speedBoost(
    label: 'Speed Boost',
    emoji: '🚀',
    duration: Duration(seconds: 5),
    color: Colors.cyan,
  ),
  shield(
    label: 'Shield',
    emoji: '🛡️',
    duration: Duration(seconds: 8),
    color: Colors.blue,
  ),
  doublePoints(
    label: 'Double Points',
    emoji: '⭐',
    duration: Duration(seconds: 10),
    color: Colors.amber,
  ),
  slowMotion(
    label: 'Slow Motion',
    emoji: '🐌',
    duration: Duration(seconds: 6),
    color: Colors.purple,
  ),
  magnet(
    label: 'Magnet',
    emoji: '🧲',
    duration: Duration(seconds: 7),
    color: Colors.red,
  ),
  ghostMode(
    label: 'Ghost Mode',
    emoji: '👻',
    duration: Duration(seconds: 5),
    color: Colors.grey,
  );

  const PowerUpType({
    required this.label,
    required this.emoji,
    required this.duration,
    required this.color,
  });

  final String label;
  final String emoji;
  final Duration duration;
  final Color color;
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

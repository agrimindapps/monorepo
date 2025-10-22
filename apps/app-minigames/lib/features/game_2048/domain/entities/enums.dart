import 'package:flutter/material.dart';

/// Direction for tile movement
enum Direction {
  left,
  right,
  up,
  down;

  /// Returns the opposite direction
  Direction get opposite {
    switch (this) {
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
    }
  }

  /// Checks if direction is horizontal
  bool get isHorizontal => this == Direction.left || this == Direction.right;

  /// Checks if direction is vertical
  bool get isVertical => this == Direction.up || this == Direction.down;
}

/// Game status states
enum GameStatus {
  initial,
  playing,
  paused,
  won,
  gameOver;

  bool get isActive => this == GameStatus.playing;
  bool get isEnded => this == GameStatus.won || this == GameStatus.gameOver;
}

/// Board size variants
enum BoardSize {
  size4x4(4, '4x4'),
  size5x5(5, '5x5'),
  size6x6(6, '6x6');

  final int size;
  final String label;

  const BoardSize(this.size, this.label);
}

/// Tile color schemes
enum TileColorScheme {
  blue('Azul', Colors.blue),
  green('Verde', Colors.green),
  purple('Roxo', Colors.purple),
  orange('Laranja', Colors.orange);

  final String label;
  final MaterialColor baseColor;

  const TileColorScheme(this.label, this.baseColor);
}

/// Animation type for tiles
enum AnimationType {
  none,
  spawn,
  merge,
  move;
}

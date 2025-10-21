// Flutter imports:
import 'package:flutter/material.dart';

enum BoardSize {
  size4x4(4, '4x4'),
  size5x5(5, '5x5'),
  size6x6(6, '6x6');

  final int size;
  final String label;
  const BoardSize(this.size, this.label);
}

enum TileColorScheme {
  blue('Azul', Colors.blue),
  green('Verde', Colors.green),
  purple('Roxo', Colors.purple),
  orange('Laranja', Colors.orange);

  final String label;
  final MaterialColor baseColor;
  const TileColorScheme(this.label, this.baseColor);
}

enum Direction {
  left,
  right,
  up,
  down;

  /// Retorna a direção oposta
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

  /// Verifica se é uma direção horizontal
  bool get isHorizontal => this == Direction.left || this == Direction.right;

  /// Verifica se é uma direção vertical
  bool get isVertical => this == Direction.up || this == Direction.down;
}

/// Configurações para detecção de gestos
class GestureConfig {
  /// Velocidade mínima para considerar um gesto válido (pixels por segundo)
  static const double minVelocity = 50.0;

  /// Distância mínima para considerar um gesto válido (pixels)
  static const double minDistance = 20.0;

  /// Multiplicador de sensibilidade para diferentes dispositivos
  static const double sensitivityMultiplier = 1.0;

  /// Detecta direção baseada em delta de posição e velocidade
  static Direction? detectDirection({
    required double deltaX,
    required double deltaY,
    required double velocityX,
    required double velocityY,
  }) {
    // Usar delta de posição como prioridade, velocidade como fallback
    double dx = deltaX.abs() > minDistance ? deltaX : velocityX;
    double dy = deltaY.abs() > minDistance ? deltaY : velocityY;

    // Aplicar multiplicador de sensibilidade
    dx *= sensitivityMultiplier;
    dy *= sensitivityMultiplier;

    // Verificar se o movimento é suficiente
    if (dx.abs() < minVelocity && dy.abs() < minVelocity) {
      return null; // Movimento muito pequeno
    }

    // Determinar direção baseada no maior movimento
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? Direction.right : Direction.left;
    } else {
      return dy > 0 ? Direction.down : Direction.up;
    }
  }
}

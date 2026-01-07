import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../space_invaders_game.dart';
import 'bullet.dart';

class Invader extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceInvadersGame> {
  final int row;
  final int points;
  final Color color;

  Invader({
    required Vector2 position,
    required this.row,
    required this.points,
    required this.color,
  }) : super(
          position: position,
          size: Vector2(36, 28),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Simple alien shape
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color,
    ));

    // Eyes
    add(CircleComponent(
      radius: 4,
      position: Vector2(8, 10),
      paint: Paint()..color = Colors.black,
    ));
    add(CircleComponent(
      radius: 4,
      position: Vector2(28, 10),
      paint: Paint()..color = Colors.black,
    ));

    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      other.removeFromParent();
      removeFromParent();
      game.addScore(points);
      game.checkWinCondition();
    }
  }
}

class InvaderManager extends Component with HasGameReference<SpaceInvadersGame> {
  static const int rows = 5;
  static const int cols = 8;
  static const double invaderSpacing = 50;
  static const double horizontalSpeed = 30;
  static const double verticalDrop = 20;

  final List<Invader> _invaders = [];
  double _direction = 1;
  double _shootTimer = 0;
  final Random _random = Random();

  int get invaderCount => _invaders.where((i) => i.isMounted).length;

  @override
  Future<void> onLoad() async {
    _createInvaders();
  }

  void _createInvaders() {
    final startX = (game.size.x - (cols * invaderSpacing)) / 2 + invaderSpacing / 2;
    const startY = 80.0;

    final rowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.cyan,
      Colors.purple,
    ];

    final rowPoints = [50, 40, 30, 20, 10];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final invader = Invader(
          position: Vector2(
            startX + col * invaderSpacing,
            startY + row * 40,
          ),
          row: row,
          points: rowPoints[row],
          color: rowColors[row],
        );
        _invaders.add(invader);
        game.add(invader);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver || game.isGameWon) return;

    _moveInvaders(dt);
    _handleShooting(dt);
  }

  void _moveInvaders(double dt) {
    bool shouldDrop = false;
    final mountedInvaders = _invaders.where((i) => i.isMounted).toList();

    for (final invader in mountedInvaders) {
      invader.x += horizontalSpeed * _direction * dt;

      if (invader.x >= game.size.x - 30 || invader.x <= 30) {
        shouldDrop = true;
      }

      // Check if invaders reached the bottom
      if (invader.y >= game.size.y - 100) {
        game.gameOver();
        return;
      }
    }

    if (shouldDrop) {
      _direction *= -1;
      for (final invader in mountedInvaders) {
        invader.y += verticalDrop;
      }
    }
  }

  void _handleShooting(double dt) {
    _shootTimer += dt;

    if (_shootTimer >= 1.5) {
      _shootTimer = 0;

      final mountedInvaders = _invaders.where((i) => i.isMounted).toList();
      if (mountedInvaders.isNotEmpty) {
        final shooter = mountedInvaders[_random.nextInt(mountedInvaders.length)];
        game.add(Bullet(
          position: Vector2(shooter.x, shooter.y + shooter.height / 2),
          isPlayerBullet: false,
        ));
      }
    }
  }
}

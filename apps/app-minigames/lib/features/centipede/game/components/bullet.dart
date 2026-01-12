import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../centipede_game.dart';

/// Bullet fired by the player
class CentipedeBullet extends PositionComponent with CollisionCallbacks {
  final double cellSize;
  final CentipedeGame gameRef;

  static const double speed = 500.0;

  CentipedeBullet({
    required Vector2 position,
    required this.cellSize,
    required this.gameRef,
  }) : super(
         position: position,
         size: Vector2(cellSize * 0.2, cellSize * 0.5),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move upward
    position.y -= speed * dt;

    // Remove if off screen
    if (position.y < -size.y) {
      removeFromParent();
      return;
    }

    // Check collisions manually for better control
    _checkCollisions();
  }

  void _checkCollisions() {
    // Check mushroom collision
    for (final mushroom in gameRef.mushrooms.toList()) {
      if (_isColliding(mushroom)) {
        mushroom.takeDamage();
        if (mushroom.isDead) {
          gameRef.removeMushroom(mushroom);
        }
        removeFromParent();
        return;
      }
    }

    // Check centipede collision
    for (final centipede in gameRef.centipedes) {
      for (int i = 0; i < centipede.segments.length; i++) {
        final segment = centipede.segments[i];
        if (_isColliding(segment)) {
          centipede.hitSegment(i);
          removeFromParent();
          return;
        }
      }
    }

    // Check spider collision
    if (gameRef.spider != null && _isColliding(gameRef.spider!)) {
      gameRef.addScore(600); // Spider bonus
      gameRef.removeSpider();
      removeFromParent();
      return;
    }
  }

  bool _isColliding(PositionComponent other) {
    return (position - other.position).length < cellSize * 0.6;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFFFFFF00); // Yellow bullet

    // Bullet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(size.x / 2),
      ),
      paint,
    );

    // Glow effect
    paint.color = const Color(0xFFFFFF88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.1, size.x * 0.6, size.y * 0.8),
        Radius.circular(size.x / 3),
      ),
      paint,
    );
  }
}

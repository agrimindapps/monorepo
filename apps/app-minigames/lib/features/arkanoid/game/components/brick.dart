import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../arkanoid_game.dart';
import 'ball.dart';

class Brick extends PositionComponent with CollisionCallbacks, HasGameReference<ArkanoidGame> {
  final Color color;

  Brick({
    required Vector2 position,
    required Vector2 size,
    required this.color,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Add visual (with small margin for grid effect)
    add(RectangleComponent(
      size: size - Vector2(2, 2), 
      position: Vector2(1, 1),
      paint: Paint()..color = color,
    ));

    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      removeFromParent();
      game.onBrickDestroyed();
    }
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../asteroids_game.dart';

class Laser extends PositionComponent
    with CollisionCallbacks, HasGameReference<AsteroidsGame> {
  final Vector2 direction;
  static const double speed = 500;
  double _lifetime = 2.0;

  Laser({
    required Vector2 position,
    required this.direction,
  }) : super(
          position: position,
          size: Vector2(3, 10),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    angle = direction.angleTo(Vector2(0, -1));

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white,
    ));

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * speed * dt;

    // Wrap around screen
    if (x < 0) x = game.size.x;
    if (x > game.size.x) x = 0;
    if (y < 0) y = game.size.y;
    if (y > game.size.y) y = 0;

    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }
}

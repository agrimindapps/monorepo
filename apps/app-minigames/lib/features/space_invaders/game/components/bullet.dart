import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../space_invaders_game.dart';

class Bullet extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceInvadersGame> {
  final bool isPlayerBullet;
  static const double speed = 400;

  Bullet({
    required Vector2 position,
    required this.isPlayerBullet,
  }) : super(
          position: position,
          size: Vector2(4, 12),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = isPlayerBullet ? Colors.yellow : Colors.red,
    ));

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isPlayerBullet) {
      y -= speed * dt;
      if (y < 0) removeFromParent();
    } else {
      y += speed * 0.5 * dt;
      if (y > game.size.y) removeFromParent();
    }
  }
}

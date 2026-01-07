import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../space_invaders_game.dart';
import 'bullet.dart';

class PlayerShip extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceInvadersGame> {
  static const double shipWidth = 50;
  static const double shipHeight = 30;
  
  double _shootCooldown = 0;
  static const double shootDelay = 0.3;

  PlayerShip()
      : super(
          size: Vector2(shipWidth, shipHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 2, game.size.y - 50);

    // Draw ship shape (triangle-ish)
    add(PolygonComponent(
      [
        Vector2(shipWidth / 2, 0), // Top center
        Vector2(0, shipHeight), // Bottom left
        Vector2(shipWidth, shipHeight), // Bottom right
      ],
      paint: Paint()..color = Colors.green,
    ));

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }
  }

  void moveBy(double dx) {
    x += dx;
    x = x.clamp(width / 2, game.size.x - width / 2);
  }

  void shoot() {
    if (_shootCooldown > 0) return;
    
    _shootCooldown = shootDelay;
    game.add(Bullet(
      position: Vector2(x, y - height / 2),
      isPlayerBullet: true,
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !other.isPlayerBullet) {
      other.removeFromParent();
      game.playerHit();
    }
  }
}

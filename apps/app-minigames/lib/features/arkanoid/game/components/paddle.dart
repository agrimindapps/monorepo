import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../arkanoid_game.dart';

class Paddle extends PositionComponent with CollisionCallbacks, HasGameReference<ArkanoidGame> {
  Paddle() : super(
    size: Vector2(100, 20),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Start at bottom center
    position = Vector2(game.size.x / 2, game.size.y - 50);
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.cyan,
    ));

    add(RectangleHitbox());
  }
  
  void moveBy(double dx) {
    x += dx;
    // Clamp to screen
    x = x.clamp(width / 2, game.size.x - width / 2);
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Keep at bottom
    y = size.y - 50;
    x = x.clamp(width / 2, size.x - width / 2);
  }
}

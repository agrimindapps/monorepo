import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../ping_pong_game.dart';

class Paddle extends PositionComponent
    with CollisionCallbacks, HasGameRef<PingPongGame> {
  final bool isPlayer;

  Paddle({
    required Vector2 position,
    required Vector2 size,
    required this.isPlayer,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = isPlayer ? Colors.blue : Colors.red;
    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rrect, paint);

    // Add some detail
    final innerPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final innerRect = Rect.fromLTWH(5, 5, size.x - 10, size.y - 10);
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      const Radius.circular(5),
    );
    canvas.drawRRect(innerRRect, innerPaint);
  }

  void moveUp(double dt, double speed) {
    position.y -= speed * dt;
    clampPosition(gameRef.size.y);
  }

  void moveDown(double dt, double speed) {
    position.y += speed * dt;
    clampPosition(gameRef.size.y);
  }

  void clampPosition(double screenHeight) {
    if (position.y < 0) {
      position.y = 0;
    }
    if (position.y + size.y > screenHeight) {
      position.y = screenHeight - size.y;
    }
  }

  void reset() {
    position.y = gameRef.size.y / 2 - size.y / 2;
  }
}

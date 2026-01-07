import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../flappy_bird_game.dart';

class Ground extends PositionComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
  Ground({required Vector2 size}) : super(size: size, position: Vector2(0, 0));

  @override
  Future<void> onLoad() async {
    position.y = gameRef.size.y - size.y;
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF8B4513); // Brown
    canvas.drawRect(size.toRect(), paint);

    // Top border
    final borderPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawLine(const Offset(0, 0), Offset(size.x, 0), borderPaint);
  }
}

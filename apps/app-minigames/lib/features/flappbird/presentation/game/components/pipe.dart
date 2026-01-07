import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../flappy_bird_game.dart';

class Pipe extends PositionComponent with HasGameRef<FlappyBirdGame> {
  final bool isTopPipe;

  Pipe({
    required Vector2 position,
    required Vector2 size,
    required this.isTopPipe,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isPlaying) return;

    position.x -= gameRef.gameSpeed * dt;

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.green;
    final borderPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = size.toRect();
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw pipe cap
    final capHeight = 20.0;
    final capRect = isTopPipe
        ? Rect.fromLTWH(-2, size.y - capHeight, size.x + 4, capHeight)
        : Rect.fromLTWH(-2, 0, size.x + 4, capHeight);

    canvas.drawRect(capRect, paint);
    canvas.drawRect(capRect, borderPaint);
  }
}

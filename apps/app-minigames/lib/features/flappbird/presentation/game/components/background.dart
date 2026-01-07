import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Background extends PositionComponent {
  Background({required Vector2 size}) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF87CEEB); // Sky blue
    canvas.drawRect(size.toRect(), paint);

    // Draw some clouds (simple circles)
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);

    // Cloud 1
    canvas.drawCircle(Offset(size.x * 0.2, size.y * 0.2), 30, cloudPaint);
    canvas.drawCircle(
      Offset(size.x * 0.2 + 20, size.y * 0.2 + 10),
      30,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.2 - 20, size.y * 0.2 + 10),
      30,
      cloudPaint,
    );

    // Cloud 2
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.3), 40, cloudPaint);
    canvas.drawCircle(
      Offset(size.x * 0.8 + 25, size.y * 0.3 + 10),
      40,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.8 - 25, size.y * 0.3 + 10),
      40,
      cloudPaint,
    );
  }
}

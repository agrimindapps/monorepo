import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Court extends PositionComponent {
  Court({required Vector2 size}) : super(size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final bgPaint = Paint()..color = const Color(0xFF1A1A1A); // Dark grey
    canvas.drawRect(size.toRect(), bgPaint);

    // Center line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final dashHeight = 20.0;
    final dashSpace = 15.0;
    double startY = 0;

    while (startY < size.y) {
      canvas.drawLine(
        Offset(size.x / 2, startY),
        Offset(size.x / 2, startY + dashHeight),
        linePaint,
      );
      startY += dashHeight + dashSpace;
    }

    // Center circle
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 50, linePaint);

    // Center dot
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
  }
}

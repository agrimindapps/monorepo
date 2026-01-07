import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/enums.dart';

class PowerUpComponent extends PositionComponent {
  final Point<int> gridPosition;
  final double cellSize;
  final Vector2 boardOffset;
  final PowerUpType type;
  double _pulseTime = 0;

  PowerUpComponent({
    required this.gridPosition,
    required this.cellSize,
    required this.boardOffset,
    required this.type,
  }) : super(
         position: Vector2(
           boardOffset.x + gridPosition.x * cellSize,
           boardOffset.y + gridPosition.y * cellSize,
         ),
         size: Vector2(cellSize, cellSize),
       );

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final scale = 0.8 + sin(_pulseTime) * 0.1;
    final center = Offset(size.x / 2, size.y / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // Draw background glow
    final glowPaint = Paint()
      ..color = type.color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, size.x / 2, glowPaint);

    // Draw circle border
    final borderPaint = Paint()
      ..color = type.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.x / 2 - 2, borderPaint);

    // Draw emoji text
    final textSpan = TextSpan(
      text: type.emoji,
      style: TextStyle(fontSize: size.x * 0.6),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    canvas.restore();
  }
}

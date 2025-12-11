import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Food extends PositionComponent {
  final Point<int> gridPosition;
  final double cellSize;
  final Vector2 boardOffset;
  double _pulseTime = 0;

  Food({
    required this.gridPosition,
    required this.cellSize,
    required this.boardOffset,
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
    _pulseTime += dt * 5;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final scale = 1.0 + sin(_pulseTime) * 0.1;
    final center = Offset(size.x / 2, size.y / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    
    final paint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(center, size.x / 2 - 2, paint);
    
    // Shine
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), size.x * 0.1, shinePaint);
    
    canvas.restore();
  }
}

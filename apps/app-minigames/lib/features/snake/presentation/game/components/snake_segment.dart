import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SnakeSegment extends PositionComponent {
  final Point<int> gridPosition;
  final double cellSize;
  final Vector2 boardOffset;
  bool isHead;

  SnakeSegment({
    required this.gridPosition,
    required this.cellSize,
    required this.boardOffset,
    this.isHead = false,
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
    // Update position in case grid changes (not typical but good for resizing)
    position = Vector2(
      boardOffset.x + gridPosition.x * cellSize,
      boardOffset.y + gridPosition.y * cellSize,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final color = isHead ? Colors.greenAccent : Colors.green.withOpacity(0.7);
    final paint = Paint()..color = color;
    
    // Draw rounded rect with padding
    final padding = 1.0;
    final rect = Rect.fromLTWH(padding, padding, size.x - padding * 2, size.y - padding * 2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(isHead ? 4 : 2));
    
    canvas.drawRRect(rrect, paint);
    
    // Draw eyes if head
    if (isHead) {
      final eyePaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), size.x * 0.1, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), size.x * 0.1, eyePaint);
    }
  }
}

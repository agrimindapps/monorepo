import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TowerBlock extends PositionComponent {
  final Color color;
  bool isBase;
  bool isDebris;
  double velocityY = 0;
  double gravity = 800;

  TowerBlock({
    required Vector2 position,
    required Vector2 size,
    required this.color,
    this.isBase = false,
    this.isDebris = false,
  }) : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDebris) {
      velocityY += gravity * dt;
      position.y += velocityY * dt;
      
      // Rotate slightly
      angle += dt;
      
      // Remove if off screen
      if (position.y > 2000) { // Arbitrary large number
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..color = color;
    final rect = size.toRect();
    
    // Draw main block
    canvas.drawRect(rect, paint);
    
    // Draw highlight (3D effect)
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 5), highlightPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, 5, size.y), highlightPaint);
    
    // Draw shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.2);
    canvas.drawRect(Rect.fromLTWH(size.x - 5, 0, 5, size.y), shadowPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.y - 5, size.x, 5), shadowPaint);
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Mushroom obstacle that blocks centipede movement
/// Takes 4 hits to destroy
class Mushroom extends PositionComponent with CollisionCallbacks {
  final double cellSize;
  int health = 4;
  
  // Colors based on health
  static const List<Color> healthColors = [
    Color(0xFF880000), // 1 health - dark red
    Color(0xFFFF4444), // 2 health - red
    Color(0xFFFFAA00), // 3 health - orange
    Color(0xFFFF6600), // 4 health - full - orange-red
  ];
  
  Mushroom({
    required Vector2 position,
    required this.cellSize,
  }) : super(
    position: position,
    size: Vector2.all(cellSize * 0.8),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint();
    
    // Get color based on health
    final colorIndex = (health - 1).clamp(0, healthColors.length - 1);
    paint.color = healthColors[colorIndex];
    
    // Mushroom cap (dome)
    final capRect = Rect.fromLTWH(0, 0, size.x, size.y * 0.6);
    canvas.drawArc(capRect, 3.14159, 3.14159, true, paint);
    
    // Mushroom cap top
    canvas.drawOval(
      Rect.fromLTWH(0, size.y * 0.1, size.x, size.y * 0.5),
      paint,
    );
    
    // Stem
    paint.color = const Color(0xFFCCCCCC);
    canvas.drawRect(
      Rect.fromLTWH(
        size.x * 0.3,
        size.y * 0.5,
        size.x * 0.4,
        size.y * 0.5,
      ),
      paint,
    );
    
    // Spots on cap
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(
      Offset(size.x * 0.3, size.y * 0.25),
      size.x * 0.1,
      paint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.65, size.y * 0.3),
      size.x * 0.08,
      paint,
    );
  }

  void takeDamage() {
    health--;
  }

  bool get isDead => health <= 0;

  /// Repair mushroom to full health (used when centipede passes)
  void repair() {
    health = 4;
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Water extends PositionComponent {
  Water({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Water background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1565C0),
    ));
    
    // Wave lines
    for (int i = 0; i < (size.y / 20).floor(); i++) {
      add(RectangleComponent(
        position: Vector2(0, i * 20.0 + 10),
        size: Vector2(size.x, 2),
        paint: Paint()..color = const Color(0xFF1976D2).withValues(alpha: 0.5),
      ));
    }
    
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}

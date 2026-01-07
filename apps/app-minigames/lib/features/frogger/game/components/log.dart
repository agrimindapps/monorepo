import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LogPlatform extends PositionComponent {
  final double speed;
  final double screenWidth;
  
  LogPlatform({
    required Vector2 position,
    required Vector2 size,
    required this.speed,
    required this.screenWidth,
  }) : super(
    position: position,
    size: size,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Log body
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF8B4513),
    ));
    
    // Log texture lines
    for (int i = 1; i < (size.x / 20).floor(); i++) {
      add(RectangleComponent(
        position: Vector2(i * 20.0, 2),
        size: Vector2(2, size.y - 4),
        paint: Paint()..color = const Color(0xFF5D3A1A),
      ));
    }
    
    // Log ends
    add(CircleComponent(
      radius: size.y / 2,
      position: Vector2(0, size.y / 2),
      paint: Paint()..color = const Color(0xFF6D4C41),
    ));
    add(CircleComponent(
      radius: size.y / 2,
      position: Vector2(size.x, size.y / 2),
      paint: Paint()..color = const Color(0xFF6D4C41),
    ));
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position.x += speed * dt;
    
    // Wrap around screen
    if (speed > 0 && position.x > screenWidth) {
      position.x = -size.x;
    } else if (speed < 0 && position.x < -size.x) {
      position.x = screenWidth;
    }
  }
}

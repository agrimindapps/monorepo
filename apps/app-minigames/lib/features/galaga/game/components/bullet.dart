import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerBullet extends PositionComponent with CollisionCallbacks {
  final double speed = 400;
  
  PlayerBullet({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(4, 16),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Bullet body
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.cyan,
    ));
    
    // Glow effect
    add(RectangleComponent(
      position: Vector2(-2, 0),
      size: Vector2(8, 16),
      paint: Paint()..color = Colors.cyan.withValues(alpha: 0.3),
    ));
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position.y -= speed * dt;
    
    if (position.y < -20) {
      removeFromParent();
    }
  }
}

class EnemyBullet extends PositionComponent with CollisionCallbacks {
  final double speed = 250;
  
  EnemyBullet({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(6, 12),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Bullet body
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red,
    ));
    
    // Glow effect
    add(RectangleComponent(
      position: Vector2(-2, 0),
      size: Vector2(10, 12),
      paint: Paint()..color = Colors.red.withValues(alpha: 0.3),
    ));
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    position.y += speed * dt;
    
    if (position.y > 800) {
      removeFromParent();
    }
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../galaga_game.dart';
import 'bullet.dart';

class GalagaPlayerShip extends PositionComponent with HasGameReference<GalagaGame>, CollisionCallbacks {
  double speed = 200;
  double moveDirection = 0;
  double invincibleTimer = 0;
  bool isInvincible = false;
  
  GalagaPlayerShip({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(40, 40),
    anchor: Anchor.center,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Ship body - triangle shape using polygon
    final paint = Paint()..color = Colors.cyan;
    
    // Main body
    add(PolygonComponent(
      [
        Vector2(20, 0),
        Vector2(40, 40),
        Vector2(20, 32),
        Vector2(0, 40),
      ],
      paint: paint,
    ));
    
    // Cockpit
    add(CircleComponent(
      radius: 6,
      position: Vector2(20, 18),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
    ));
    
    // Wings accent
    add(RectangleComponent(
      position: Vector2(2, 30),
      size: Vector2(8, 6),
      paint: Paint()..color = Colors.blue,
    ));
    add(RectangleComponent(
      position: Vector2(30, 30),
      size: Vector2(8, 6),
      paint: Paint()..color = Colors.blue,
    ));
    
    // Engine flames
    add(PolygonComponent(
      [
        Vector2(15, 40),
        Vector2(20, 50),
        Vector2(25, 40),
      ],
      paint: Paint()..color = Colors.orange,
    ));
    
    add(RectangleHitbox(
      size: Vector2(30, 30),
      position: Vector2(5, 5),
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Movement
    position.x += moveDirection * speed * dt;
    position.x = position.x.clamp(20, game.size.x - 20);
    
    // Invincibility
    if (isInvincible) {
      invincibleTimer -= dt;
      if (invincibleTimer <= 0) {
        isInvincible = false;
        _setChildrenVisible(true);
      } else {
        // Blink effect
        final visible = (invincibleTimer * 10).floor() % 2 == 0;
        _setChildrenVisible(visible);
      }
    }
  }
  
  void _setChildrenVisible(bool visible) {
    for (final child in children) {
      if (child is ShapeComponent) {
        child.paint.color = child.paint.color.withValues(alpha: visible ? 1.0 : 0.2);
      }
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (isInvincible) return;
    
    if (other is EnemyBullet) {
      other.removeFromParent();
      game.playerHit();
    }
  }
  
  void moveLeft() {
    moveDirection = -1;
  }
  
  void moveRight(double maxX) {
    moveDirection = 1;
  }
  
  void stopMoving() {
    moveDirection = 0;
  }
  
  void setInvincible(double duration) {
    isInvincible = true;
    invincibleTimer = duration;
  }
}

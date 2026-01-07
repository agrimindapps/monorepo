import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../frogger_game.dart';
import 'vehicle.dart';
import 'water.dart';
import 'log.dart';
import 'goal.dart';

class Frog extends PositionComponent with HasGameReference<FroggerGame>, CollisionCallbacks {
  final double gridSize;
  LogPlatform? ridingLog;
  bool isOnWater = false;
  bool isDead = false;
  
  Frog({
    required Vector2 position,
    required this.gridSize,
  }) : super(
    position: position,
    size: Vector2.all(gridSize - 4),
    anchor: Anchor.topLeft,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Frog body
    add(RectangleComponent(
      size: Vector2(size.x * 0.8, size.y * 0.7),
      position: Vector2(size.x * 0.1, size.y * 0.15),
      paint: Paint()..color = const Color(0xFF4CAF50),
    ));
    
    // Eyes
    add(CircleComponent(
      radius: 4,
      position: Vector2(size.x * 0.25, size.y * 0.1),
      paint: Paint()..color = Colors.white,
    ));
    add(CircleComponent(
      radius: 4,
      position: Vector2(size.x * 0.65, size.y * 0.1),
      paint: Paint()..color = Colors.white,
    ));
    
    // Pupils
    add(CircleComponent(
      radius: 2,
      position: Vector2(size.x * 0.27, size.y * 0.12),
      paint: Paint()..color = Colors.black,
    ));
    add(CircleComponent(
      radius: 2,
      position: Vector2(size.x * 0.67, size.y * 0.12),
      paint: Paint()..color = Colors.black,
    ));
    
    // Legs
    add(RectangleComponent(
      size: Vector2(8, 12),
      position: Vector2(2, size.y * 0.7),
      paint: Paint()..color = const Color(0xFF388E3C),
    ));
    add(RectangleComponent(
      size: Vector2(8, 12),
      position: Vector2(size.x - 10, size.y * 0.7),
      paint: Paint()..color = const Color(0xFF388E3C),
    ));
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDead) return;
    
    // Move with log if riding one
    if (ridingLog != null) {
      position.x += ridingLog!.speed * dt;
      
      // Check if fell off screen
      if (position.x < -gridSize || position.x > game.size.x) {
        die();
      }
    }
    
    // Check if on water without log
    if (isOnWater && ridingLog == null) {
      die();
    }
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (isDead) return;
    
    if (other is Vehicle) {
      die();
    } else if (other is Water) {
      isOnWater = true;
    } else if (other is LogPlatform) {
      ridingLog = other;
    } else if (other is Goal) {
      game.frogHitGoal(other.index);
    }
  }
  
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other is Water) {
      isOnWater = false;
    } else if (other is LogPlatform) {
      if (ridingLog == other) {
        ridingLog = null;
      }
    }
  }
  
  void moveUp() {
    if (position.y > 0) {
      position.y -= gridSize;
      ridingLog = null;
    }
  }
  
  void moveDown(double maxY) {
    if (position.y < maxY - gridSize) {
      position.y += gridSize;
      ridingLog = null;
    }
  }
  
  void moveLeft() {
    if (position.x > 0) {
      position.x -= gridSize;
    }
  }
  
  void moveRight(double maxX) {
    if (position.x < maxX - gridSize) {
      position.x += gridSize;
    }
  }
  
  void die() {
    if (isDead) return;
    isDead = true;
    
    // Death animation - turn red
    removeAll(children.whereType<RectangleComponent>());
    removeAll(children.whereType<CircleComponent>());
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.withValues(alpha: 0.8),
    ));
    
    Future.delayed(const Duration(milliseconds: 500), () {
      isDead = false;
      isOnWater = false;
      ridingLog = null;
      
      removeAll(children.whereType<RectangleComponent>());
      onLoad();
      
      game.frogDied();
    });
  }
}

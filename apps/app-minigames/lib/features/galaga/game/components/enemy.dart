import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../galaga_game.dart';
import 'bullet.dart';

enum EnemyType { basic, shooter, diver }

class GalagaEnemy extends PositionComponent with HasGameReference<GalagaGame>, CollisionCallbacks {
  final EnemyType type;
  final int row;
  final int col;
  final double formationX;
  final double formationY;
  
  Vector2 velocity = Vector2.zero();
  bool isInFormation = false;
  bool isDiving = false;
  double diveTimer = 0;
  double shootTimer = 0;
  double entryProgress = 0;
  
  final Random _random = Random();
  
  GalagaEnemy({
    required this.type,
    required this.row,
    required this.col,
    required this.formationX,
    required this.formationY,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(32, 32),
    anchor: Anchor.center,
  );
  
  Color get _color {
    switch (type) {
      case EnemyType.basic:
        return Colors.green;
      case EnemyType.shooter:
        return Colors.yellow;
      case EnemyType.diver:
        return Colors.red;
    }
  }
  
  int get points {
    switch (type) {
      case EnemyType.basic:
        return 50;
      case EnemyType.shooter:
        return 100;
      case EnemyType.diver:
        return 150;
    }
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Enemy body
    add(PolygonComponent(
      [
        Vector2(16, 0),
        Vector2(32, 12),
        Vector2(28, 28),
        Vector2(16, 32),
        Vector2(4, 28),
        Vector2(0, 12),
      ],
      paint: Paint()..color = _color,
    ));
    
    // Eyes
    add(CircleComponent(
      radius: 4,
      position: Vector2(10, 12),
      paint: Paint()..color = Colors.white,
    ));
    add(CircleComponent(
      radius: 4,
      position: Vector2(22, 12),
      paint: Paint()..color = Colors.white,
    ));
    
    // Pupils
    add(CircleComponent(
      radius: 2,
      position: Vector2(11, 13),
      paint: Paint()..color = Colors.black,
    ));
    add(CircleComponent(
      radius: 2,
      position: Vector2(23, 13),
      paint: Paint()..color = Colors.black,
    ));
    
    // Antenna for special types
    if (type != EnemyType.basic) {
      add(RectangleComponent(
        position: Vector2(14, -6),
        size: Vector2(4, 8),
        paint: Paint()..color = type == EnemyType.shooter ? Colors.orange : Colors.purple,
      ));
    }
    
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Entry animation
    if (!isInFormation) {
      entryProgress += dt * 2;
      
      // Curve entry path
      final targetX = formationX;
      final targetY = formationY;
      
      position.x += (targetX - position.x) * dt * 3;
      position.y += (targetY - position.y) * dt * 3;
      
      if ((position - Vector2(targetX, targetY)).length < 5) {
        isInFormation = true;
        position = Vector2(targetX, targetY);
      }
      return;
    }
    
    // Diving behavior
    if (isDiving) {
      position += velocity * dt;
      
      // Return to formation after diving
      if (position.y > game.size.y + 50) {
        position.y = -50;
        isDiving = false;
        velocity = Vector2.zero();
      }
      return;
    }
    
    // Random diving
    diveTimer += dt;
    if (diveTimer > 3 + _random.nextDouble() * 5) {
      if (_random.nextDouble() < 0.3 && type == EnemyType.diver) {
        startDive();
      }
      diveTimer = 0;
    }
    
    // Shooting for shooter type
    if (type == EnemyType.shooter) {
      shootTimer += dt;
      if (shootTimer > 2 + _random.nextDouble() * 3) {
        shoot();
        shootTimer = 0;
      }
    }
  }
  
  void startDive() {
    isDiving = true;
    
    // Dive toward player
    final playerX = game.player.position.x;
    final dx = playerX - position.x;
    
    velocity = Vector2(dx * 0.5, 250);
  }
  
  void shoot() {
    game.add(EnemyBullet(
      position: position + Vector2(0, 20),
    ));
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is PlayerBullet) {
      other.removeFromParent();
      game.addScore(points);
      removeFromParent();
    }
  }
}

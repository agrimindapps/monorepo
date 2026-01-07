import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../arkanoid_game.dart';
import 'brick.dart';
import 'paddle.dart';

class Ball extends CircleComponent with CollisionCallbacks, HasGameReference<ArkanoidGame> {
  Vector2 velocity = Vector2.zero();
  static const double speed = 400.0;
  
  // Prevent multiple collisions in short time
  bool _hasCollidedRecently = false;
  double _collisionCooldown = 0.0;

  Ball() : super(
    radius: 8,
    anchor: Anchor.center,
    paint: Paint()..color = Colors.white,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    resetPosition();
    add(CircleHitbox());
  }

  void resetPosition() {
    position = Vector2(game.size.x / 2, game.size.y / 2 + 50);
    velocity = Vector2.zero();
  }

  void launch() {
    // Launch upwards at random angle
    velocity = Vector2(1, -1)..normalize();
    velocity *= speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (velocity.isZero()) {
      // Follow paddle before launch if we wanted that logic, 
      // but for now we just wait in center
      return;
    }

    position += velocity * dt;

    // Screen collisions
    // Left
    if (position.x - radius <= 0) {
      position.x = radius;
      velocity.x = -velocity.x;
    }
    // Right
    if (position.x + radius >= game.size.x) {
      position.x = game.size.x - radius;
      velocity.x = -velocity.x;
    }
    // Top
    if (position.y - radius <= 0) {
      position.y = radius;
      velocity.y = -velocity.y;
    }
    // Bottom (Game Over)
    if (position.y - radius >= game.size.y) {
      game.onBallLost();
    }
    
    if (_collisionCooldown > 0) {
      _collisionCooldown -= dt;
      if (_collisionCooldown <= 0) _hasCollidedRecently = false;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (_hasCollidedRecently) return;

    if (other is Brick) {
      _handleBrickCollision(other, intersectionPoints);
    } else if (other is Paddle) {
      _handlePaddleCollision(other);
    }
  }

  void _handlePaddleCollision(Paddle paddle) {
    // Only bounce if hitting from top
    if (position.y < paddle.position.y - paddle.size.y / 2 + radius) {
       // Calculate relative hit position (-1 to 1)
       double relativeX = (position.x - paddle.x) / (paddle.width / 2);
       
       // Reflect angle based on hit position
       // Center = vertical bounce, Edges = angled bounce
       velocity.y = -velocity.y.abs(); // Always go up
       velocity.x = velocity.x + (relativeX * 200); // Add spin
       
       // Normalize to keep constant speed
       velocity = velocity.normalized() * speed;
       
       _setCooldown();
    }
  }

  void _handleBrickCollision(Brick brick, Set<Vector2> points) {
     if (points.isEmpty) return;
     
     // Simple bounce: reverse Y if hitting top/bottom, X if hitting sides
     // This is a naive implementation, a proper one checks normal vectors.
     
     final point = points.first;
     final brickCenter = brick.position + (brick.size / 2);
     
     // Determine if horizontal or vertical collision based on relative position
     double dx = point.x - brickCenter.x;
     double dy = point.y - brickCenter.y;
     
     // Check overlap ratio
     double overlapX = (brick.width / 2) - dx.abs();
     double overlapY = (brick.height / 2) - dy.abs();
     
     if (overlapX < overlapY) {
       // Hit side
       velocity.x = -velocity.x;
     } else {
       // Hit top/bottom
       velocity.y = -velocity.y;
     }
     
     _setCooldown();
  }
  
  void _setCooldown() {
    _hasCollidedRecently = true;
    _collisionCooldown = 0.05; // 50ms cooldown
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dino_run_game.dart';

class DinoPlayer extends PositionComponent with CollisionCallbacks, HasGameReference<DinoRunGame> {
  // Constants
  static const double gravity = 1000.0;
  static const double initialJumpVelocity = -600.0;
  static const double groundY = 100.0; // Distance from bottom
  
  double _verticalVelocity = 0.0;
  bool _isOnGround = true;

  DinoPlayer() : super(size: Vector2(40, 60), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    // Start position (relative to screen height in resize)
    position = Vector2(50, game.size.y - groundY);
    
    // Add visual representation (placeholder rectangle)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.green,
    ));

    // Add collision hitbox
    add(RectangleHitbox());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Keep dino on ground when screen resizes
    y = size.y - groundY;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply gravity
    _verticalVelocity += gravity * dt;
    
    // Update position
    y += _verticalVelocity * dt;

    // Ground collision check
    double groundLevel = game.size.y - groundY;
    
    if (y >= groundLevel) {
      y = groundLevel;
      _verticalVelocity = 0.0;
      _isOnGround = true;
    }
  }

  void jump() {
    if (_isOnGround) {
      _verticalVelocity = initialJumpVelocity;
      _isOnGround = false;
    }
  }

  void stop() {
    // Animation stop logic would go here
  }
  
  void reset() {
    _verticalVelocity = 0.0;
    _isOnGround = true;
    y = game.size.y - groundY;
  }
}

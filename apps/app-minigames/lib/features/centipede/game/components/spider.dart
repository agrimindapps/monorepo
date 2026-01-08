import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../centipede_game.dart';

/// Spider enemy that moves erratically in the player area
/// Worth bonus points when destroyed
class Spider extends PositionComponent with CollisionCallbacks {
  final double cellSize;
  final bool movingRight;
  final CentipedeGame gameRef;
  
  // Movement
  double _moveSpeed = 150.0;
  double _verticalSpeed = 0;
  double _directionChangeTimer = 0;
  final Random _random = Random();
  
  // Animation
  double _animTime = 0;
  double _legOffset = 0;
  
  Spider({
    required Vector2 position,
    required this.cellSize,
    required this.movingRight,
    required this.gameRef,
  }) : super(
    position: position,
    size: Vector2.all(cellSize * 1.5),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    _changeDirection();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Animation
    _animTime += dt * 10;
    _legOffset = sin(_animTime) * 5;
    
    // Movement
    position.x += (movingRight ? _moveSpeed : -_moveSpeed) * dt;
    position.y += _verticalSpeed * dt;
    
    // Random direction changes
    _directionChangeTimer -= dt;
    if (_directionChangeTimer <= 0) {
      _changeDirection();
    }
    
    // Keep in player area (bottom of screen)
    final minY = gameRef.size.y - gameRef.playerAreaHeight - cellSize * 3;
    final maxY = gameRef.size.y - cellSize;
    position.y = position.y.clamp(minY, maxY);
    
    // Remove if off screen
    if (position.x < -size.x * 2 || position.x > gameRef.size.x + size.x * 2) {
      gameRef.removeSpider();
    }
    
    // Check player collision
    if ((position - gameRef.player.position).length < cellSize) {
      gameRef.playerHit();
    }
  }

  void _changeDirection() {
    _verticalSpeed = (_random.nextDouble() - 0.5) * 200;
    _directionChangeTimer = _random.nextDouble() * 0.5 + 0.2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint();
    
    // Body color - purple/red
    paint.color = const Color(0xFFAA00AA);
    
    // Draw spider body (two circles)
    // Abdomen
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.6),
        width: size.x * 0.7,
        height: size.y * 0.5,
      ),
      paint,
    );
    
    // Head
    paint.color = const Color(0xFFCC00CC);
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.25),
      size.x * 0.25,
      paint,
    );
    
    // Eyes
    paint.color = Colors.red;
    canvas.drawCircle(
      Offset(size.x * 0.4, size.y * 0.2),
      size.x * 0.08,
      paint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.6, size.y * 0.2),
      size.x * 0.08,
      paint,
    );
    
    // Legs (8 legs, animated)
    paint.color = const Color(0xFF880088);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    
    // Left legs
    for (int i = 0; i < 4; i++) {
      final yOffset = size.y * (0.35 + i * 0.12);
      final legPath = Path();
      legPath.moveTo(size.x * 0.3, yOffset);
      legPath.quadraticBezierTo(
        -size.x * 0.1 + _legOffset * (i.isEven ? 1 : -1),
        yOffset + size.y * 0.1,
        -size.x * 0.05,
        yOffset + size.y * 0.2,
      );
      canvas.drawPath(legPath, paint);
    }
    
    // Right legs
    for (int i = 0; i < 4; i++) {
      final yOffset = size.y * (0.35 + i * 0.12);
      final legPath = Path();
      legPath.moveTo(size.x * 0.7, yOffset);
      legPath.quadraticBezierTo(
        size.x * 1.1 + _legOffset * (i.isEven ? -1 : 1),
        yOffset + size.y * 0.1,
        size.x * 1.05,
        yOffset + size.y * 0.2,
      );
      canvas.drawPath(legPath, paint);
    }
    
    // Pattern on body
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF660066);
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.55),
      size.x * 0.1,
      paint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.7),
      size.x * 0.08,
      paint,
    );
  }
}

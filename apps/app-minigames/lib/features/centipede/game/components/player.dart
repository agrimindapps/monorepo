import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../centipede_game.dart';
import 'bullet.dart';
import 'centipede.dart';
import 'spider.dart';

/// Player ship that can move and shoot
class CentipedePlayer extends PositionComponent with CollisionCallbacks {
  final double cellSize;
  final CentipedeGame gameRef;
  
  // Shooting cooldown
  double _shootCooldown = 0;
  static const double shootCooldownTime = 0.15;
  
  CentipedePlayer({
    required Vector2 position,
    required this.cellSize,
    required this.gameRef,
  }) : super(
    position: position,
    size: Vector2(cellSize * 1.2, cellSize * 1.2),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Add collision hitbox
    add(RectangleHitbox(
      size: size * 0.8,
      position: size * 0.1,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }
  }

  void move(Vector2 delta) {
    position += delta;
    
    // Clamp to player area (bottom portion of screen)
    final minY = gameRef.size.y - gameRef.playerAreaHeight;
    final maxY = gameRef.size.y - cellSize;
    
    position.x = position.x.clamp(cellSize, gameRef.size.x - cellSize);
    position.y = position.y.clamp(minY, maxY);
  }

  void shoot() {
    if (_shootCooldown > 0) return;
    
    _shootCooldown = shootCooldownTime;
    
    final bullet = CentipedeBullet(
      position: position - Vector2(0, size.y / 2),
      cellSize: cellSize,
      gameRef: gameRef,
    );
    gameRef.add(bullet);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint();
    
    // Ship body (green like classic arcade)
    paint.color = const Color(0xFF00FF00);
    
    // Draw triangular ship
    final path = Path();
    path.moveTo(size.x / 2, 0); // Top point
    path.lineTo(size.x, size.y); // Bottom right
    path.lineTo(size.x / 2, size.y * 0.7); // Bottom center indent
    path.lineTo(0, size.y); // Bottom left
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Cockpit
    paint.color = const Color(0xFF88FF88);
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.4),
      size.x * 0.15,
      paint,
    );
    
    // Engine glow
    paint.color = const Color(0xFFFFAA00);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.9),
        width: size.x * 0.3,
        height: size.y * 0.15,
      ),
      paint,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Handle collision with enemies
    if (other is CentipedeSegment || other is Spider) {
      gameRef.playerHit();
    }
  }
}

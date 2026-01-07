import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../flappy_bird_game.dart';

class Bird extends PositionComponent
    with CollisionCallbacks, HasGameRef<FlappyBirdGame> {
  Bird({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, anchor: Anchor.center);

  double velocity = 0;
  final double gravity = 1000; // Pixels per second squared
  final double jumpForce = -350; // Pixels per second

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isPlaying) return;

    // Apply gravity
    velocity += gravity * dt;
    position.y += velocity * dt;

    // Rotate bird based on velocity
    angle = (velocity / 500).clamp(-0.5, 0.5);

    // Check if bird hits the ground or ceiling
    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }

    // Ground collision is handled by collision detection or game loop checking
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.yellow;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    // Draw eye
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.x * 0.7, size.y * 0.3),
      size.x * 0.1,
      eyePaint,
    );

    // Draw beak
    final beakPaint = Paint()..color = Colors.orange;
    final path = Path()
      ..moveTo(size.x * 0.8, size.y * 0.5)
      ..lineTo(size.x, size.y * 0.6)
      ..lineTo(size.x * 0.8, size.y * 0.7)
      ..close();
    canvas.drawPath(path, beakPaint);
  }

  void fly() {
    velocity = jumpForce;
  }

  void reset() {
    position = Vector2(gameRef.size.x * 0.25, gameRef.size.y / 2);
    velocity = 0;
    angle = 0;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    gameRef.gameOver();
  }
}

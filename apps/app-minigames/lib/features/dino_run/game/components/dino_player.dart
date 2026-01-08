import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dino_run_game.dart';

enum DinoState { idle, running, jumping, ducking, dead }

class DinoPlayer extends PositionComponent
    with CollisionCallbacks, HasGameReference<DinoRunGame> {
  // Physics
  static const double gravity = 2800.0;
  static const double jumpVelocity = -900.0;
  static const double groundY = 80.0;

  double _verticalVelocity = 0.0;
  bool _isOnGround = true;

  // Animation
  DinoState _state = DinoState.idle;
  double _animationTimer = 0;
  int _animationFrame = 0;

  // Dino visual dimensions
  static const double normalWidth = 44.0;
  static const double normalHeight = 48.0;
  static const double duckWidth = 58.0;
  static const double duckHeight = 30.0;

  // Colors
  static const Color dinoColor = Color(0xFF535353);
  static const Color dinoEyeColor = Color(0xFFFFFFFF);

  DinoPlayer()
      : super(
          size: Vector2(normalWidth, normalHeight),
          anchor: Anchor.bottomLeft,
        );

  @override
  Future<void> onLoad() async {
    position = Vector2(50, game.size.y - groundY);
    _updateHitbox();
  }

  void _updateHitbox() {
    // Remove old hitboxes
    children.whereType<RectangleHitbox>().forEach((h) => h.removeFromParent());

    // Add hitbox slightly smaller than visual for better feel
    add(RectangleHitbox(
      size: Vector2(size.x * 0.8, size.y * 0.9),
      position: Vector2(size.x * 0.1, size.y * 0.05),
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isOnGround) {
      y = size.y - groundY;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animation timer
    _animationTimer += dt;
    if (_animationTimer >= 0.1) {
      _animationTimer = 0;
      _animationFrame = (_animationFrame + 1) % 2;
    }

    // Physics
    if (!_isOnGround) {
      _verticalVelocity += gravity * dt;
      y += _verticalVelocity * dt;

      // Ground collision
      final groundLevel = game.size.y - groundY;
      if (y >= groundLevel) {
        y = groundLevel;
        _verticalVelocity = 0;
        _isOnGround = true;

        if (_state == DinoState.jumping) {
          _state = game.isPlaying ? DinoState.running : DinoState.idle;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (_state) {
      case DinoState.idle:
        _renderIdleDino(canvas);
        break;
      case DinoState.running:
        _renderRunningDino(canvas);
        break;
      case DinoState.jumping:
        _renderJumpingDino(canvas);
        break;
      case DinoState.ducking:
        _renderDuckingDino(canvas);
        break;
      case DinoState.dead:
        _renderDeadDino(canvas);
        break;
    }
  }

  void _renderIdleDino(Canvas canvas) {
    _renderStandingDino(canvas, eyeOpen: true, mouthOpen: false);
  }

  void _renderRunningDino(Canvas canvas) {
    _renderStandingDino(
      canvas,
      eyeOpen: true,
      mouthOpen: false,
      legFrame: _animationFrame,
    );
  }

  void _renderJumpingDino(Canvas canvas) {
    _renderStandingDino(canvas, eyeOpen: true, mouthOpen: false, legsUp: true);
  }

  void _renderDeadDino(Canvas canvas) {
    _renderStandingDino(canvas, eyeOpen: false, mouthOpen: true);
  }

  void _renderStandingDino(
    Canvas canvas, {
    required bool eyeOpen,
    required bool mouthOpen,
    int legFrame = 0,
    bool legsUp = false,
  }) {
    final paint = Paint()..color = dinoColor;

    // Body (main rectangle with rounded top)
    final bodyRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(8, 0, 28, 32),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(12),
    );
    canvas.drawRRect(bodyRect, paint);

    // Head
    final headRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, -12, 24, 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(headRect, paint);

    // Eye
    final eyePaint = Paint()..color = dinoEyeColor;
    if (eyeOpen) {
      canvas.drawCircle(const Offset(36, -4), 4, eyePaint);
      canvas.drawCircle(const Offset(37, -5), 2, Paint()..color = dinoColor);
    } else {
      // X eyes for dead
      final xPaint = Paint()
        ..color = dinoEyeColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(33, -7), const Offset(39, -1), xPaint);
      canvas.drawLine(const Offset(33, -1), const Offset(39, -7), xPaint);
    }

    // Mouth
    if (mouthOpen) {
      final mouthPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(const Offset(38, 2), const Offset(44, 2), mouthPaint);
    }

    // Tail
    final tailPath = Path()
      ..moveTo(8, 10)
      ..lineTo(0, 8)
      ..lineTo(0, 16)
      ..lineTo(8, 14)
      ..close();
    canvas.drawPath(tailPath, paint);

    // Arms (small)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 18, 8, 4),
        const Radius.circular(2),
      ),
      paint,
    );

    // Legs
    if (legsUp) {
      // Both legs tucked up for jumping
      canvas.drawRect(const Rect.fromLTWH(14, 30, 6, 10), paint);
      canvas.drawRect(const Rect.fromLTWH(24, 30, 6, 10), paint);
    } else if (legFrame == 0) {
      // Left leg forward, right leg back
      canvas.drawRect(const Rect.fromLTWH(12, 30, 6, 18), paint);
      canvas.drawRect(const Rect.fromLTWH(26, 30, 6, 14), paint);
    } else {
      // Right leg forward, left leg back
      canvas.drawRect(const Rect.fromLTWH(12, 30, 6, 14), paint);
      canvas.drawRect(const Rect.fromLTWH(26, 30, 6, 18), paint);
    }
  }

  void _renderDuckingDino(Canvas canvas) {
    final paint = Paint()..color = dinoColor;

    // Ducking body (long and flat)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.y - 24, 50, 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, paint);

    // Head (smaller, at front)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(42, size.y - 28, 16, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(headRect, paint);

    // Eye
    final eyePaint = Paint()..color = dinoEyeColor;
    canvas.drawCircle(Offset(52, size.y - 22), 3, eyePaint);
    canvas.drawCircle(Offset(53, size.y - 23), 1.5, Paint()..color = dinoColor);

    // Tail
    final tailPath = Path()
      ..moveTo(4, size.y - 20)
      ..lineTo(-4, size.y - 22)
      ..lineTo(-4, size.y - 14)
      ..lineTo(4, size.y - 16)
      ..close();
    canvas.drawPath(tailPath, paint);

    // Legs (short, running animation)
    if (_animationFrame == 0) {
      canvas.drawRect(Rect.fromLTWH(10, size.y - 6, 5, 6), paint);
      canvas.drawRect(Rect.fromLTWH(30, size.y - 4, 5, 4), paint);
    } else {
      canvas.drawRect(Rect.fromLTWH(10, size.y - 4, 5, 4), paint);
      canvas.drawRect(Rect.fromLTWH(30, size.y - 6, 5, 6), paint);
    }
  }

  void jump() {
    if (_isOnGround && _state != DinoState.dead) {
      _verticalVelocity = jumpVelocity;
      _isOnGround = false;
      _state = DinoState.jumping;

      // Restore size if was ducking
      size = Vector2(normalWidth, normalHeight);
      _updateHitbox();

      HapticFeedback.lightImpact();
    }
  }

  void duck() {
    if (_isOnGround && _state != DinoState.dead && _state != DinoState.jumping) {
      _state = DinoState.ducking;
      size = Vector2(duckWidth, duckHeight);
      // Adjust Y to keep on ground
      y = game.size.y - groundY;
      _updateHitbox();
    }
  }

  void standUp() {
    if (_state == DinoState.ducking) {
      _state = DinoState.running;
      size = Vector2(normalWidth, normalHeight);
      y = game.size.y - groundY;
      _updateHitbox();
    }
  }

  void startRunning() {
    _state = DinoState.running;
  }

  void die() {
    _state = DinoState.dead;
  }

  void reset() {
    _state = DinoState.idle;
    _verticalVelocity = 0;
    _isOnGround = true;
    size = Vector2(normalWidth, normalHeight);
    y = game.size.y - groundY;
    _updateHitbox();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Check collision with obstacles by type name to avoid circular imports
    final typeName = other.runtimeType.toString();
    if (typeName.contains('Cactus') || typeName.contains('Pterodactyl')) {
      game.gameOver();
    }
  }
}

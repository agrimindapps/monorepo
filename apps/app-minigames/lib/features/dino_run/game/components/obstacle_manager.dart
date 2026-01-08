import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_run_game.dart';

class ObstacleManager extends Component with HasGameReference<DinoRunGame> {
  late Timer _timer;
  final Random _random = Random();
  bool _isRunning = false;

  static const double groundY = 80.0;

  // Obstacle spawn timing
  static const double minSpawnTime = 1.2;
  static const double maxSpawnTime = 2.8;

  @override
  Future<void> onLoad() async {
    _timer = Timer(
      minSpawnTime + _random.nextDouble() * (maxSpawnTime - minSpawnTime),
      repeat: false,
      onTick: _spawnObstacle,
    );
  }

  @override
  void update(double dt) {
    if (_isRunning) {
      _timer.update(dt);

      // Restart timer if it finished
      if (_timer.finished) {
        // Spawn time decreases as game speed increases
        final adjustedMin = minSpawnTime / game.gameSpeed;
        final adjustedMax = maxSpawnTime / game.gameSpeed;
        _timer.limit =
            adjustedMin + _random.nextDouble() * (adjustedMax - adjustedMin);
        _timer.reset();
        _timer.start();
      }
    }
  }

  void _spawnObstacle() {
    if (game.isGameOver || !_isRunning) return;

    // Decide what to spawn
    final roll = _random.nextDouble();

    if (roll < 0.15 && game.score > 300) {
      // 15% chance for pterodactyl after 300 points
      _spawnPterodactyl();
    } else if (roll < 0.35) {
      // 20% chance for large cactus
      _spawnLargeCactus();
    } else if (roll < 0.60) {
      // 25% chance for cactus group
      _spawnCactusGroup();
    } else {
      // 40% chance for small cactus
      _spawnSmallCactus();
    }
  }

  void _spawnSmallCactus() {
    game.add(SmallCactus(
      position: Vector2(game.size.x + 50, game.size.y - groundY),
      gameSpeedGetter: () => game.gameSpeed,
    ));
  }

  void _spawnLargeCactus() {
    game.add(LargeCactus(
      position: Vector2(game.size.x + 50, game.size.y - groundY),
      gameSpeedGetter: () => game.gameSpeed,
    ));
  }

  void _spawnCactusGroup() {
    final count = _random.nextInt(2) + 2; // 2-3 cacti
    double xOffset = 0;

    for (int i = 0; i < count; i++) {
      game.add(SmallCactus(
        position:
            Vector2(game.size.x + 50 + xOffset, game.size.y - groundY),
        gameSpeedGetter: () => game.gameSpeed,
      ));
      xOffset += 25 + _random.nextDouble() * 10;
    }
  }

  void _spawnPterodactyl() {
    // Random height: low, medium, or high
    final heights = [groundY + 10, groundY + 45, groundY + 80];
    final height = heights[_random.nextInt(heights.length)];

    game.add(PterodactylObstacle(
      position: Vector2(game.size.x + 50, game.size.y - height),
      gameSpeedGetter: () => game.gameSpeed,
    ));
  }

  void start() {
    _isRunning = true;
    _timer.start();
  }

  void stop() {
    _isRunning = false;
    _timer.stop();
  }

  void reset() {
    _isRunning = false;
    _timer.stop();

    // Remove all obstacles
    game.children.whereType<SmallCactus>().forEach((e) => e.removeFromParent());
    game.children.whereType<LargeCactus>().forEach((e) => e.removeFromParent());
    game.children
        .whereType<PterodactylObstacle>()
        .forEach((e) => e.removeFromParent());
  }
}

// Base obstacle class
abstract class BaseObstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<DinoRunGame> {
  final double Function() gameSpeedGetter;
  static const double baseSpeed = 350.0;

  BaseObstacle({
    required Vector2 position,
    required Vector2 size,
    required this.gameSpeedGetter,
  }) : super(position: position, size: size, anchor: Anchor.bottomLeft);

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver) return;

    x -= baseSpeed * gameSpeedGetter() * dt;

    if (x < -width - 50) {
      removeFromParent();
    }
  }
}

// Small Cactus
class SmallCactus extends BaseObstacle {
  static const Color cactusColor = Color(0xFF535353);

  SmallCactus({
    required super.position,
    required super.gameSpeedGetter,
  }) : super(size: Vector2(18, 36));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: Vector2(size.x * 0.7, size.y * 0.9),
      position: Vector2(size.x * 0.15, size.y * 0.05),
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = cactusColor;

    // Main stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 8, 8, size.y - 8),
        const Radius.circular(3),
      ),
      paint,
    );

    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 14, 6, 4),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 6, 4, 12),
        const Radius.circular(2),
      ),
      paint,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 18, 6, 4),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 10, 4, 12),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}

// Large Cactus
class LargeCactus extends BaseObstacle {
  static const Color cactusColor = Color(0xFF535353);

  LargeCactus({
    required super.position,
    required super.gameSpeedGetter,
  }) : super(size: Vector2(26, 52));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: Vector2(size.x * 0.7, size.y * 0.9),
      position: Vector2(size.x * 0.15, size.y * 0.05),
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = cactusColor;

    // Main stem (wider and taller)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 8, 12, size.y - 8),
        const Radius.circular(4),
      ),
      paint,
    );

    // Left arm (lower)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 24, 8, 5),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 12, 5, 16),
        const Radius.circular(2),
      ),
      paint,
    );

    // Right arm (higher)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 16, 8, 5),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(21, 6, 5, 14),
        const Radius.circular(2),
      ),
      paint,
    );

    // Additional detail - small branch
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 32, 6, 4),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}

// Pterodactyl (flying obstacle)
class PterodactylObstacle extends BaseObstacle {
  static const Color pterodactylColor = Color(0xFF535353);

  double _animTimer = 0;
  int _wingFrame = 0;

  PterodactylObstacle({
    required super.position,
    required super.gameSpeedGetter,
  }) : super(size: Vector2(46, 40));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: Vector2(size.x * 0.7, size.y * 0.5),
      position: Vector2(size.x * 0.15, size.y * 0.25),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Wing animation
    _animTimer += dt;
    if (_animTimer >= 0.15) {
      _animTimer = 0;
      _wingFrame = (_wingFrame + 1) % 2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = pterodactylColor;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 16, 26, 12),
        const Radius.circular(4),
      ),
      paint,
    );

    // Head/beak
    final beakPath = Path()
      ..moveTo(36, 18)
      ..lineTo(46, 20)
      ..lineTo(36, 24)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Eye
    canvas.drawCircle(
      const Offset(32, 20),
      2,
      Paint()..color = Colors.white,
    );

    // Crest
    final crestPath = Path()
      ..moveTo(16, 16)
      ..lineTo(10, 8)
      ..lineTo(20, 16)
      ..close();
    canvas.drawPath(crestPath, paint);

    // Wings (animated)
    if (_wingFrame == 0) {
      // Wings up
      final wingPath = Path()
        ..moveTo(12, 16)
        ..lineTo(6, 0)
        ..lineTo(30, 0)
        ..lineTo(32, 16)
        ..close();
      canvas.drawPath(wingPath, paint);
    } else {
      // Wings down
      final wingPath = Path()
        ..moveTo(12, 28)
        ..lineTo(6, 40)
        ..lineTo(30, 40)
        ..lineTo(32, 28)
        ..close();
      canvas.drawPath(wingPath, paint);
    }

    // Tail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 18, 12, 6),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}

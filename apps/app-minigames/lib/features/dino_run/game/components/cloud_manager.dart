import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_run_game.dart';

class CloudManager extends Component with HasGameReference<DinoRunGame> {
  final List<Cloud> _clouds = [];
  final Random _random = Random();
  double _spawnTimer = 0;
  bool _isNight = false;

  static const double minSpawnTime = 3.0;
  static const double maxSpawnTime = 8.0;

  @override
  Future<void> onLoad() async {
    // Spawn initial clouds
    for (int i = 0; i < 3; i++) {
      _spawnCloud(
        x: _random.nextDouble() * game.size.x,
        immediate: true,
      );
    }
  }

  @override
  void update(double dt) {
    // Update clouds
    for (final cloud in _clouds) {
      cloud.move(dt, game.gameSpeed, _isNight);
    }

    // Remove off-screen clouds
    _clouds.removeWhere((cloud) {
      if (cloud.x < -cloud.width) {
        cloud.removeFromParent();
        return true;
      }
      return false;
    });

    // Spawn new clouds
    _spawnTimer += dt;
    final spawnTime =
        minSpawnTime + _random.nextDouble() * (maxSpawnTime - minSpawnTime);

    if (_spawnTimer >= spawnTime) {
      _spawnTimer = 0;
      _spawnCloud();
    }
  }

  void _spawnCloud({double? x, bool immediate = false}) {
    final cloud = Cloud(
      x: x ?? game.size.x + 50,
      y: 30 + _random.nextDouble() * 60,
      cloudScale: 0.5 + _random.nextDouble() * 0.5,
      speed: 30 + _random.nextDouble() * 20,
    );

    _clouds.add(cloud);
    game.add(cloud);
  }

  void setNightMode(bool isNight) {
    _isNight = isNight;
  }
}

class Cloud extends PositionComponent {
  double speed;
  double cloudScale;

  Color _color = const Color(0xFFD0D0D0);

  static const Color dayColor = Color(0xFFD0D0D0);
  static const Color nightColor = Color(0xFF3A3A5A);

  Cloud({
    required double x,
    required double y,
    required this.cloudScale,
    required this.speed,
  }) : super(
          position: Vector2(x, y),
          size: Vector2(80 * cloudScale, 30 * cloudScale),
          priority: 1,
        );

  void move(double dt, double gameSpeed, bool isNight) {
    x -= speed * gameSpeed * dt;
    _color = Color.lerp(_color, isNight ? nightColor : dayColor, dt * 2)!;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = _color;

    // Draw cloud as overlapping circles
    final baseRadius = 12 * cloudScale;

    // Main body (3 circles)
    canvas.drawCircle(
      Offset(20 * cloudScale, 18 * cloudScale),
      baseRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(40 * cloudScale, 15 * cloudScale),
      baseRadius * 1.3,
      paint,
    );
    canvas.drawCircle(
      Offset(60 * cloudScale, 18 * cloudScale),
      baseRadius,
      paint,
    );

    // Top puff
    canvas.drawCircle(
      Offset(35 * cloudScale, 8 * cloudScale),
      baseRadius * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(50 * cloudScale, 10 * cloudScale),
      baseRadius * 0.7,
      paint,
    );
  }
}

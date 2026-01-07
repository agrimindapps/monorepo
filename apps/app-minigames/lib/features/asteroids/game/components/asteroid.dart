import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../asteroids_game.dart';
import 'laser.dart';

enum AsteroidSize { large, medium, small }

class Asteroid extends PositionComponent
    with CollisionCallbacks, HasGameReference<AsteroidsGame> {
  final AsteroidSize asteroidSize;
  late Vector2 velocity;
  late double rotationSpeed;
  final Random _random = Random();

  Asteroid({
    required Vector2 position,
    required this.asteroidSize,
    Vector2? initialVelocity,
  }) : super(
          position: position,
          anchor: Anchor.center,
        ) {
    size = _getSize();
    velocity = initialVelocity ?? _randomVelocity();
    rotationSpeed = (_random.nextDouble() - 0.5) * 2;
  }

  Vector2 _getSize() {
    switch (asteroidSize) {
      case AsteroidSize.large:
        return Vector2(60, 60);
      case AsteroidSize.medium:
        return Vector2(40, 40);
      case AsteroidSize.small:
        return Vector2(20, 20);
    }
  }

  int get points {
    switch (asteroidSize) {
      case AsteroidSize.large:
        return 20;
      case AsteroidSize.medium:
        return 50;
      case AsteroidSize.small:
        return 100;
    }
  }

  Vector2 _randomVelocity() {
    final speed = 50 + _random.nextDouble() * 100;
    final angle = _random.nextDouble() * 2 * pi;
    return Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  Future<void> onLoad() async {
    // Irregular polygon shape
    final vertices = _generateAsteroidShape();

    add(PolygonComponent(
      vertices,
      paint: Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));

    add(PolygonHitbox(vertices));
  }

  List<Vector2> _generateAsteroidShape() {
    final points = <Vector2>[];
    final numPoints = 8;
    final radius = size.x / 2;

    for (int i = 0; i < numPoints; i++) {
      final angle = (i / numPoints) * 2 * pi;
      final r = radius * (0.7 + _random.nextDouble() * 0.3);
      points.add(Vector2(
        size.x / 2 + cos(angle) * r,
        size.y / 2 + sin(angle) * r,
      ));
    }

    return points;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    angle += rotationSpeed * dt;

    // Wrap around screen
    if (x < -width) x = game.size.x + width;
    if (x > game.size.x + width) x = -width;
    if (y < -height) y = game.size.y + height;
    if (y > game.size.y + height) y = -height;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Laser) {
      other.removeFromParent();
      _split();
      removeFromParent();
      game.addScore(points);
    }
  }

  void _split() {
    if (asteroidSize == AsteroidSize.small) return;

    final newSize = asteroidSize == AsteroidSize.large
        ? AsteroidSize.medium
        : AsteroidSize.small;

    // Create two smaller asteroids
    for (int i = 0; i < 2; i++) {
      final offset = Vector2(
        (_random.nextDouble() - 0.5) * 20,
        (_random.nextDouble() - 0.5) * 20,
      );

      game.add(Asteroid(
        position: position + offset,
        asteroidSize: newSize,
        initialVelocity: _randomVelocity() * 1.5,
      ));
    }
  }
}

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../asteroids_game.dart';
import 'asteroid.dart';
import 'laser.dart';

class Ship extends PositionComponent
    with CollisionCallbacks, HasGameReference<AsteroidsGame> {
  Vector2 velocity = Vector2.zero();
  static const double rotationSpeed = 3.5;
  static const double thrustPower = 200;
  static const double friction = 0.98;
  static const double maxSpeed = 300;

  double _shootCooldown = 0;
  static const double shootDelay = 0.2;

  bool _invincible = false;
  double _invincibleTimer = 0;

  Ship({required Vector2 position})
      : super(
          position: position,
          size: Vector2(30, 40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Triangle ship
    add(PolygonComponent(
      [
        Vector2(15, 0), // Nose
        Vector2(0, 40), // Bottom left
        Vector2(15, 32), // Indent
        Vector2(30, 40), // Bottom right
      ],
      paint: Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));

    add(PolygonHitbox([
      Vector2(15, 0),
      Vector2(0, 40),
      Vector2(30, 40),
    ]));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }

    if (_invincible) {
      _invincibleTimer -= dt;
      if (_invincibleTimer <= 0) {
        _invincible = false;
      }
    }

    // Apply friction
    velocity *= friction;

    // Clamp speed
    if (velocity.length > maxSpeed) {
      velocity = velocity.normalized() * maxSpeed;
    }

    // Move
    position += velocity * dt;

    // Wrap around screen
    if (x < 0) x = game.size.x;
    if (x > game.size.x) x = 0;
    if (y < 0) y = game.size.y;
    if (y > game.size.y) y = 0;
  }

  void rotateLeft(double dt) {
    angle -= rotationSpeed * dt;
  }

  void rotateRight(double dt) {
    angle += rotationSpeed * dt;
  }

  void thrust(double dt) {
    // Thrust in direction ship is facing
    final direction = Vector2(sin(angle), -cos(angle));
    velocity += direction * thrustPower * dt;
  }

  void shoot() {
    if (_shootCooldown > 0) return;

    _shootCooldown = shootDelay;

    final direction = Vector2(sin(angle), -cos(angle));
    final bulletPos = position + direction * 20;

    game.add(Laser(
      position: bulletPos,
      direction: direction,
    ));
  }

  void respawn(Vector2 newPosition) {
    position = newPosition;
    velocity = Vector2.zero();
    angle = 0;
    _invincible = true;
    _invincibleTimer = 3.0;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_invincible) return;

    if (other is Asteroid) {
      game.shipDestroyed();
    }
  }
}

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dino_player.dart';
import 'dino_run_game.dart';

class ObstacleManager extends Component with HasGameReference<DinoRunGame> {
  late Timer _timer;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _timer = Timer(2, repeat: true, onTick: _spawnObstacle);
    _timer.start();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  void _spawnObstacle() {
    if (game.isGameOver) return;
    
    final obstacle = Obstacle();
    game.add(obstacle);
    
    // Randomize next spawn time between 1 and 3 seconds
    _timer.limit = 1.0 + _random.nextDouble() * 2.0;
  }

  void stop() {
    _timer.stop();
  }
  
  void reset() {
    _timer.start();
    // Remove all existing obstacles
    game.children.whereType<Obstacle>().forEach((element) {
      element.removeFromParent();
    });
  }
}

class Obstacle extends PositionComponent with CollisionCallbacks, HasGameReference<DinoRunGame> {
  static const double speed = 300.0;
  static const double groundY = 100.0;

  Obstacle() : super(size: Vector2(30, 50), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    // Start off-screen right
    position = Vector2(game.size.x, game.size.y - groundY);
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red,
    ));

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver) return;

    // Move left
    x -= speed * dt;

    // Remove if off-screen
    if (x < -width) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is DinoPlayer) {
      game.gameOver();
    }
  }
}

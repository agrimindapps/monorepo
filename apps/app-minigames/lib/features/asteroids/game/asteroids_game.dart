import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_minigames/core/mixins/esc_pause_handler.dart';
import 'components/asteroid.dart';
import 'components/ship.dart';
import 'components/laser.dart';

class AsteroidsGame extends FlameGame
    with TapCallbacks, KeyboardEvents, HasCollisionDetection, EscPauseHandler {
  late Ship ship;
  final Random _random = Random();

  int score = 0;
  int lives = 3;
  bool isGameOver = false;

  // Tracking for Clean Architecture persistence
  DateTime? gameStartTime;
  int wave = 1;
  int asteroidsDestroyed = 0;

  // Keyboard state
  final Set<LogicalKeyboardKey> _keysPressed = {};

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await _setupGame();
  }

  Future<void> _setupGame() async {
    // Initialize tracking on first game start
    gameStartTime ??= DateTime.now();
    
    // Clear existing
    children.whereType<Ship>().forEach((e) => e.removeFromParent());
    children.whereType<Asteroid>().forEach((e) => e.removeFromParent());
    children.whereType<Laser>().forEach((e) => e.removeFromParent());

    // Create ship
    ship = Ship(position: size / 2);
    add(ship);

    // Spawn initial asteroids
    _spawnAsteroids(5);

    // Score display
    add(
      TextComponent(
        text: 'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..priority = 10,
    );

    // Lives display
    add(
      TextComponent(
        text: 'Lives: $lives',
        position: Vector2(size.x - 100, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..priority = 10,
    );
  }

  void _spawnAsteroids(int count) {
    for (int i = 0; i < count; i++) {
      // Spawn away from ship
      Vector2 pos;
      do {
        pos = Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        );
      } while (pos.distanceTo(ship.position) < 150);

      add(Asteroid(
        position: pos,
        asteroidSize: AsteroidSize.large,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Handle continuous key presses
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      ship.rotateLeft(dt);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      ship.rotateRight(dt);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      ship.thrust(dt);
    }

    // Update score display
    final scoreText = children.whereType<TextComponent>().firstOrNull;
    if (scoreText != null) {
      scoreText.text = 'Score: $score';
    }

    // Update lives display
    final livesText = children.whereType<TextComponent>().skip(1).firstOrNull;
    if (livesText != null) {
      livesText.text = 'Lives: $lives';
    }

    // Check if all asteroids destroyed
    if (!children.whereType<Asteroid>().any((a) => a.isMounted)) {
      wave++;
      _spawnAsteroids(5 + score ~/ 500); // More asteroids as score increases
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    ship.shoot();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed.clear();
    _keysPressed.addAll(keysPressed);

    if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.space)) {
      if (!isGameOver) {
        ship.shoot();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  void addScore(int points) {
    score += points;
    asteroidsDestroyed++;
  }

  void shipDestroyed() {
    lives--;
    if (lives <= 0) {
      isGameOver = true;
      super.isGameOver = true; // Update EscPauseHandler
      overlays.add('GameOver');
    } else {
      // Respawn ship at center
      ship.respawn(size / 2);
    }
  }

  void reset() {
    score = 0;
    lives = 3;
    isGameOver = false;
    super.isGameOver = false; // Update EscPauseHandler
    overlays.remove('GameOver');
    
    // Reset tracking
    gameStartTime = DateTime.now();
    wave = 1;
    asteroidsDestroyed = 0;
    
    _setupGame();
  }

  @override
  void restartFromPause() {
    overlays.remove('PauseMenu');
    reset();
  }
}

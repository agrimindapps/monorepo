import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/dino_player.dart';
import 'components/ground.dart';
import 'components/obstacle_manager.dart';
import 'components/cloud_manager.dart';
import 'components/parallax_background.dart';
import 'components/score_text.dart';

class DinoRunGame extends FlameGame
    with TapCallbacks, KeyboardEvents, HasCollisionDetection {
  // Callbacks for Flutter UI
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onScoreChanged;
  final ValueChanged<int>? onHighScoreChanged;

  DinoRunGame({
    this.onGameOver,
    this.onScoreChanged,
    this.onHighScoreChanged,
  });

  late DinoPlayer dino;
  late Ground ground;
  late ObstacleManager obstacleManager;
  late CloudManager cloudManager;
  late ParallaxBackground background;
  late ScoreText scoreText;

  double score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isPlaying = false;

  // Game speed increases over time
  double gameSpeed = 1.0;
  static const double maxGameSpeed = 2.5;
  static const double speedIncreaseRate = 0.001;

  // Day/Night cycle
  double _dayNightTimer = 0;
  bool isNight = false;
  static const double dayNightCycleDuration = 30.0; // seconds

  // Colors for day/night
  Color _skyColor = const Color(0xFFF7F7F7);
  Color _targetSkyColor = const Color(0xFFF7F7F7);

  static const Color daySkyColor = Color(0xFFF7F7F7);
  static const Color nightSkyColor = Color(0xFF1A1A2E);

  @override
  Color backgroundColor() => _skyColor;

  @override
  Future<void> onLoad() async {
    // Add parallax background first (lowest priority)
    background = ParallaxBackground();
    add(background);

    // Add clouds
    cloudManager = CloudManager();
    add(cloudManager);

    // Add ground
    ground = Ground();
    add(ground);

    // Add dino
    dino = DinoPlayer();
    add(dino);

    // Add obstacle manager
    obstacleManager = ObstacleManager();
    add(obstacleManager);

    // Add score display
    scoreText = ScoreText();
    add(scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPlaying || isGameOver) return;

    // Update score
    score += dt * 10 * gameSpeed;
    final intScore = score.toInt();
    onScoreChanged?.call(intScore);

    // Increase game speed over time
    if (gameSpeed < maxGameSpeed) {
      gameSpeed += speedIncreaseRate * dt * 60;
    }

    // Milestone haptic feedback every 100 points
    if (intScore > 0 && intScore % 100 == 0) {
      final lastScore = ((score - dt * 10 * gameSpeed)).toInt();
      if (lastScore % 100 != 0) {
        HapticFeedback.mediumImpact();
      }
    }

    // Day/Night cycle
    _updateDayNightCycle(dt);

    // Lerp sky color
    _skyColor = Color.lerp(_skyColor, _targetSkyColor, dt * 2)!;
  }

  void _updateDayNightCycle(double dt) {
    _dayNightTimer += dt;

    if (_dayNightTimer >= dayNightCycleDuration) {
      _dayNightTimer = 0;
      isNight = !isNight;
      _targetSkyColor = isNight ? nightSkyColor : daySkyColor;

      // Update components for night mode
      ground.setNightMode(isNight);
      cloudManager.setNightMode(isNight);
      background.setNightMode(isNight);
      scoreText.setNightMode(isNight);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;

    if (!isPlaying) {
      startGame();
    } else {
      dino.jump();
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space) ||
          keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (isGameOver) return KeyEventResult.ignored;

        if (!isPlaying) {
          startGame();
        } else {
          dino.jump();
        }
        return KeyEventResult.handled;
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        if (isPlaying && !isGameOver) {
          dino.duck();
        }
        return KeyEventResult.handled;
      }
    }

    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        dino.standUp();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void startGame() {
    if (isPlaying) return;

    isPlaying = true;
    isGameOver = false;
    dino.startRunning();
    obstacleManager.start();
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    isPlaying = false;

    HapticFeedback.heavyImpact();

    dino.die();
    obstacleManager.stop();

    // Update high score
    if (score.toInt() > highScore) {
      highScore = score.toInt();
      onHighScoreChanged?.call(highScore);
    }

    onGameOver?.call();
    overlays.add('GameOver');
  }

  void reset() {
    isGameOver = false;
    isPlaying = false;
    score = 0;
    gameSpeed = 1.0;
    _dayNightTimer = 0;
    isNight = false;
    _skyColor = daySkyColor;
    _targetSkyColor = daySkyColor;

    onScoreChanged?.call(0);

    // Reset components
    dino.reset();
    obstacleManager.reset();
    ground.setNightMode(false);
    cloudManager.setNightMode(false);
    background.setNightMode(false);
    scoreText.setNightMode(false);

    overlays.remove('GameOver');
  }
}

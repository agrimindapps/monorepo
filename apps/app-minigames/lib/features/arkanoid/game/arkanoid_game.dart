import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_minigames/core/mixins/esc_pause_handler.dart';
import 'components/ball.dart';
import 'components/brick.dart';
import 'components/paddle.dart';

class ArkanoidGame extends FlameGame with DragCallbacks, TapCallbacks, HasCollisionDetection, KeyboardEvents, EscPauseHandler {
  late Paddle paddle;
  late Ball ball;
  
  int score = 0;
  bool isGameOver = false;
  bool isGameWon = false;
  bool isPlaying = false;
  
  // Tracking for persistence
  DateTime? gameStartTime;
  int level = 1;
  int bricksDestroyed = 0;

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await setupGame();
  }

  Future<void> setupGame() async {
    // Clean up if restarting
    children.whereType<Paddle>().forEach((e) => e.removeFromParent());
    children.whereType<Ball>().forEach((e) => e.removeFromParent());
    children.whereType<Brick>().forEach((e) => e.removeFromParent());
    
    // Initialize game start time
    gameStartTime ??= DateTime.now();
    
    // Create Paddle
    paddle = Paddle();
    add(paddle);

    // Create Ball
    ball = Ball();
    add(ball);

    // Create Bricks
    _createBricks();
    
    score = 0;
    isGameOver = false;
    isGameWon = false;
    isPlaying = false;
  }
  
  void _createBricks() {
    const int rows = 5;
    const int columns = 7;
    final double brickWidth = size.x / columns;
    final double brickHeight = 30.0;
    final double startY = 100.0; // Margin from top

    final List<Color> rowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
    ];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        add(Brick(
          position: Vector2(j * brickWidth, startY + (i * brickHeight)),
          size: Vector2(brickWidth, brickHeight),
          color: rowColors[i % rowColors.length],
        ));
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || isGameWon) return;
    paddle.moveBy(event.localDelta.x);
    
    if (!isPlaying && isAttached) {
       // Optional: Move ball with paddle before launch? 
       // For now, let's keep it simple: tap to start.
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying && !isGameOver && !isGameWon) {
      startGame();
    } else if (isGameOver || isGameWon) {
       // Handled by overlay usually, but good fallback
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        if (!isPlaying && !isGameOver) {
          startGame();
        }
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        paddle.moveBy(-20);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        paddle.moveBy(20);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void startGame() {
    isPlaying = true;
    ball.launch();
  }

  void onBallLost() {
    isGameOver = true;
    isPlaying = false;
    overlays.add('GameOver');
  }
  
  void onBrickDestroyed() {
    score += 10;
    bricksDestroyed++;
    if (children.whereType<Brick>().isEmpty) {
      isGameWon = true;
      isPlaying = false;
      ball.velocity = Vector2.zero();
      overlays.add('GameWon');
    }
  }

  void reset() {
    isGameOver = false;
    isGameWon = false;
    super.isGameOver = false;
    gameStartTime = DateTime.now();
    level = 1;
    bricksDestroyed = 0;
    overlays.remove('GameOver');
    overlays.remove('GameWon');
    setupGame();
  }

  @override
  void restartFromPause() {
    overlays.remove('PauseMenu');
    reset();
  }
}

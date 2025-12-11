import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/enums.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/court.dart';

class PingPongGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onPlayerScoreChanged;
  final ValueChanged<int>? onAiScoreChanged;
  final GameDifficulty difficulty;

  PingPongGame({
    this.onGameOver,
    this.onPlayerScoreChanged,
    this.onAiScoreChanged,
    this.difficulty = GameDifficulty.medium,
  });

  late Paddle playerPaddle;
  late Paddle aiPaddle;
  late Ball ball;
  late Court court;

  int playerScore = 0;
  int aiScore = 0;
  bool isGameOver = false;
  bool isPlaying = false;
  
  // Difficulty settings
  late double aiSpeed;
  late double ballSpeed;

  @override
  Future<void> onLoad() async {
    // Set difficulty parameters
    switch (difficulty) {
      case GameDifficulty.easy:
        aiSpeed = 150;
        ballSpeed = 300;
        break;
      case GameDifficulty.medium:
        aiSpeed = 250;
        ballSpeed = 450;
        break;
      case GameDifficulty.hard:
        aiSpeed = 400;
        ballSpeed = 600;
        break;
    }

    // Add court (background and lines)
    court = Court(size: size);
    add(court);

    // Add paddles
    final paddleSize = Vector2(20, 100);
    final paddleMargin = 30.0;
    
    playerPaddle = Paddle(
      position: Vector2(paddleMargin, size.y / 2),
      size: paddleSize,
      isPlayer: true,
    );
    add(playerPaddle);
    
    aiPaddle = Paddle(
      position: Vector2(size.x - paddleMargin - paddleSize.x, size.y / 2),
      size: paddleSize,
      isPlayer: false,
    );
    add(aiPaddle);

    // Add ball
    ball = Ball(
      position: size / 2,
      radius: 10,
      speed: ballSpeed,
    );
    add(ball);
    
    // Start paused
    pauseGame();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPlaying || isGameOver) return;
    
    // AI Logic
    _updateAI(dt);
    
    // Check scoring
    if (ball.position.x < 0) {
      // AI scored
      aiScore++;
      if (onAiScoreChanged != null) onAiScoreChanged!(aiScore);
      _resetBall(servingPlayer: true);
      _checkWinCondition();
    } else if (ball.position.x > size.x) {
      // Player scored
      playerScore++;
      if (onPlayerScoreChanged != null) onPlayerScoreChanged!(playerScore);
      _resetBall(servingPlayer: false);
      _checkWinCondition();
    }
  }
  
  void _updateAI(double dt) {
    // Simple AI: follow the ball Y position
    final ballY = ball.position.y;
    final paddleY = aiPaddle.position.y + aiPaddle.size.y / 2;
    
    // Add some reaction delay/error based on difficulty
    // For now, just simple tracking with speed limit
    
    if (ballY < paddleY - 10) {
      aiPaddle.moveUp(dt, aiSpeed);
    } else if (ballY > paddleY + 10) {
      aiPaddle.moveDown(dt, aiSpeed);
    }
  }
  
  void _resetBall({required bool servingPlayer}) {
    ball.reset(servingPlayer: servingPlayer);
  }
  
  void _checkWinCondition() {
    if (playerScore >= 11 || aiScore >= 11) {
      gameOver();
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
        playerPaddle.moveUp(0.1, 400); // Manual move for keyboard
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
        playerPaddle.moveDown(0.1, 400);
      }
    }
    
    // Continuous movement handling would be better in update() checking keysPressed
    return KeyEventResult.handled;
  }
  
  // Touch controls
  void movePlayerPaddle(double dy) {
    if (!isPlaying) return;
    
    // Map screen touch Y to paddle position
    // Or use delta movement
    playerPaddle.position.y += dy;
    playerPaddle.clampPosition(size.y);
  }

  void startGame() {
    isPlaying = true;
    resumeEngine();
  }

  void pauseGame() {
    isPlaying = false;
    pauseEngine();
  }

  void gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    isPlaying = false;
    pauseEngine();
    
    if (onGameOver != null) {
      onGameOver!();
    }
  }

  void restartGame() {
    playerScore = 0;
    aiScore = 0;
    isGameOver = false;
    isPlaying = false;
    
    if (onPlayerScoreChanged != null) onPlayerScoreChanged!(0);
    if (onAiScoreChanged != null) onAiScoreChanged!(0);

    ball.reset(servingPlayer: true);
    playerPaddle.reset();
    aiPaddle.reset();
    
    resumeEngine();
    // Wait for user to start
    pauseGame(); 
  }
}

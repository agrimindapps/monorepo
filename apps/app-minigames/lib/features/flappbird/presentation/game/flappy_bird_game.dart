import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/background.dart';
import 'components/bird.dart';
import 'components/ground.dart';
import 'components/pipe_manager.dart';

class FlappyBirdGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onScoreChanged;

  FlappyBirdGame({
    this.onGameOver,
    this.onScoreChanged,
  });

  late Bird bird;
  late PipeManager pipeManager;
  late Ground ground;
  late Background background;

  double gameSpeed = 200.0;
  double groundHeight = 100.0;
  int score = 0;
  bool isGameOver = false;
  bool isPlaying = false;

  @override
  Future<void> onLoad() async {
    // Calculate ground height (15% of screen height)
    groundHeight = size.y * 0.15;

    // Add background
    background = Background(size: size);
    add(background);

    // Add pipe manager
    pipeManager = PipeManager();
    add(pipeManager);

    // Add ground
    ground = Ground(size: Vector2(size.x, groundHeight));
    add(ground);

    // Add bird
    bird = Bird(
      position: Vector2(size.x * 0.25, size.y / 2),
      size: Vector2(40, 30),
    );
    add(bird);
    
    // Start paused
    isPlaying = false;
    overlays.add('Start');
  }

  @override
  void update(double dt) {
    if (isPlaying) {
      super.update(dt);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isGameOver) {
      return;
    }

    if (!isPlaying) {
      startGame();
    }

    bird.fly();
  }

  void startGame() {
    isPlaying = true;
    overlays.remove('Start');
  }

  void pauseGame() {
    isPlaying = false;
  }

  void gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    isPlaying = false;
    overlays.add('GameOver');
    
    if (onGameOver != null) {
      onGameOver!();
    }
  }

  void restartGame() {
    score = 0;
    isGameOver = false;
    isPlaying = false;
    
    if (onScoreChanged != null) {
      onScoreChanged!(score);
    }

    bird.reset();
    pipeManager.reset();
    
    overlays.remove('GameOver');
    overlays.add('Start');
    
    // Wait for next tap to start
    pauseGame(); 
  }

  void increaseScore() {
    score++;
    if (onScoreChanged != null) {
      onScoreChanged!(score);
    }
  }
}

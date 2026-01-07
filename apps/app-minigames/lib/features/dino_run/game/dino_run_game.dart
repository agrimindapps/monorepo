import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dino_player.dart';
import 'ground.dart';
import 'obstacle_manager.dart';

class DinoRunGame extends FlameGame with TapCallbacks, KeyboardEvents, HasCollisionDetection {
  late DinoPlayer _dino;
  late Ground _ground;
  late ObstacleManager _obstacleManager;
  
  double score = 0;
  bool isGameOver = false;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    // Add ground
    _ground = Ground();
    add(_ground);

    // Add dino
    _dino = DinoPlayer();
    add(_dino);

    // Add obstacle manager
    _obstacleManager = ObstacleManager();
    add(_obstacleManager);
    
    // Simple Score Text
    add(
      TextComponent(
        text: 'Score: 0',
        position: Vector2(20, 20),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
      )..priority = 10, // Ensure it's on top
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;
    
    score += dt * 10;
    
    // Update score text if we had a reference to it, 
    // for now just logic
    children.query<TextComponent>().first.text = 'Score: ${score.toInt()}';
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      reset();
    } else {
      _dino.jump();
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.space) || 
          keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (isGameOver) {
          reset();
        } else {
          _dino.jump();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void gameOver() {
    isGameOver = true;
    _dino.stop();
    _obstacleManager.stop();
    pauseEngine();
    
    overlays.add('GameOver');
  }

  void reset() {
    isGameOver = false;
    score = 0;
    
    // Reset components
    _dino.reset();
    _obstacleManager.reset();
    
    resumeEngine();
    overlays.remove('GameOver');
  }
}

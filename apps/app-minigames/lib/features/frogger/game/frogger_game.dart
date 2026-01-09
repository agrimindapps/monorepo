import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_minigames/core/mixins/esc_pause_handler.dart';
import 'components/frog.dart';
import 'components/vehicle.dart';
import 'components/log.dart';
import 'components/water.dart';
import 'components/safe_zone.dart';
import 'components/goal.dart';

class FroggerGame extends FlameGame with KeyboardEvents, TapCallbacks, HasCollisionDetection, EscPauseHandler {
  late Frog frog;
  late TextComponent scoreText;
  late TextComponent livesText;
  
  int score = 0;
  int lives = 3;
  int level = 1;
  bool isGameOver = false;
  List<bool> goalsReached = [false, false, false, false, false];
  
  final double gridSize = 40;
  final Random _random = Random();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));
    
    _setupLevel();
    _spawnFrog();
    _setupUI();
  }
  
  void _setupLevel() {
    final rows = (size.y / gridSize).floor();
    final waterStartRow = 1;
    final waterEndRow = (rows / 2).floor() - 1;
    final roadStartRow = (rows / 2).floor() + 1;
    final roadEndRow = rows - 2;
    
    // Goals at top
    for (int i = 0; i < 5; i++) {
      final goalX = (size.x / 5) * i + (size.x / 10) - gridSize / 2;
      add(Goal(
        position: Vector2(goalX, 0),
        size: Vector2(gridSize, gridSize),
        index: i,
      ));
    }
    
    // Safe zone at top (between goals)
    add(SafeZone(
      position: Vector2(0, 0),
      size: Vector2(size.x, gridSize),
    ));
    
    // Water section
    add(Water(
      position: Vector2(0, gridSize * waterStartRow),
      size: Vector2(size.x, gridSize * (waterEndRow - waterStartRow + 1)),
    ));
    
    // Logs on water
    for (int row = waterStartRow; row <= waterEndRow; row++) {
      final speed = (50 + _random.nextInt(50)) * (row.isEven ? 1 : -1) * (1 + level * 0.1);
      final logCount = 2 + _random.nextInt(2);
      final logWidth = gridSize * (2 + _random.nextInt(2));
      
      for (int i = 0; i < logCount; i++) {
        add(LogPlatform(
          position: Vector2(
            (size.x / logCount) * i,
            gridSize * row,
          ),
          size: Vector2(logWidth, gridSize - 4),
          speed: speed.toDouble(),
          screenWidth: size.x,
        ));
      }
    }
    
    // Middle safe zone
    add(SafeZone(
      position: Vector2(0, gridSize * ((rows / 2).floor())),
      size: Vector2(size.x, gridSize),
      color: const Color(0xFF4A4A6A),
    ));
    
    // Road section
    add(RectangleComponent(
      position: Vector2(0, gridSize * roadStartRow),
      size: Vector2(size.x, gridSize * (roadEndRow - roadStartRow + 1)),
      paint: Paint()..color = const Color(0xFF333344),
    ));
    
    // Vehicles on road
    for (int row = roadStartRow; row <= roadEndRow; row++) {
      final speed = (80 + _random.nextInt(60)) * (row.isEven ? 1 : -1) * (1 + level * 0.15);
      final vehicleCount = 2 + _random.nextInt(2);
      
      for (int i = 0; i < vehicleCount; i++) {
        final vehicleType = VehicleType.values[_random.nextInt(VehicleType.values.length)];
        add(Vehicle(
          position: Vector2(
            (size.x / vehicleCount) * i + _random.nextDouble() * 50,
            gridSize * row + 5,
          ),
          type: vehicleType,
          speed: speed.toDouble(),
          screenWidth: size.x,
        ));
      }
    }
    
    // Start safe zone
    add(SafeZone(
      position: Vector2(0, gridSize * (rows - 1)),
      size: Vector2(size.x, gridSize),
      color: const Color(0xFF4A4A6A),
    ));
  }
  
  void _spawnFrog() {
    final rows = (size.y / gridSize).floor();
    frog = Frog(
      position: Vector2(size.x / 2 - gridSize / 2, gridSize * (rows - 1)),
      gridSize: gridSize,
    );
    add(frog);
  }
  
  void _setupUI() {
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, size.y - 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
    
    livesText = TextComponent(
      text: 'Lives: $lives',
      position: Vector2(size.x - 80, size.y - 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(livesText);
  }
  
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && !isGameOver) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        frog.moveUp();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        frog.moveDown(size.y);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        frog.moveLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        frog.moveRight(size.x);
      }
    }
    
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space && isGameOver) {
      restartGame();
    }
    
    return KeyEventResult.handled;
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      restartGame();
      return;
    }
    
    final tapPos = event.localPosition;
    final frogCenter = frog.position + Vector2(gridSize / 2, gridSize / 2);
    
    final dx = tapPos.x - frogCenter.x;
    final dy = tapPos.y - frogCenter.y;
    
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        frog.moveRight(size.x);
      } else {
        frog.moveLeft();
      }
    } else {
      if (dy > 0) {
        frog.moveDown(size.y);
      } else {
        frog.moveUp();
      }
    }
  }
  
  void frogHitGoal(int index) {
    if (!goalsReached[index]) {
      goalsReached[index] = true;
      score += 100;
      scoreText.text = 'Score: $score';
      
      if (goalsReached.every((reached) => reached)) {
        levelUp();
      } else {
        resetFrogPosition();
      }
    }
  }
  
  void frogDied() {
    lives--;
    livesText.text = 'Lives: $lives';
    
    if (lives <= 0) {
      gameOver();
    } else {
      resetFrogPosition();
    }
  }
  
  void resetFrogPosition() {
    final rows = (size.y / gridSize).floor();
    frog.position = Vector2(size.x / 2 - gridSize / 2, gridSize * (rows - 1));
    frog.ridingLog = null;
  }
  
  void levelUp() {
    level++;
    score += 500;
    scoreText.text = 'Score: $score';
    goalsReached = [false, false, false, false, false];
    
    // Clear and rebuild level
    removeAll(children.whereType<Vehicle>());
    removeAll(children.whereType<LogPlatform>());
    removeAll(children.whereType<Goal>());
    
    _setupLevel();
    resetFrogPosition();
  }
  
  void gameOver() {
    isGameOver = true;
    super.isGameOver = true; // Update EscPauseHandler
    
    add(RectangleComponent(
      position: Vector2(size.x / 2 - 120, size.y / 2 - 60),
      size: Vector2(240, 120),
      paint: Paint()..color = Colors.black87,
    ));
    
    add(TextComponent(
      text: 'GAME OVER',
      position: Vector2(size.x / 2, size.y / 2 - 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    
    add(TextComponent(
      text: 'Score: $score',
      position: Vector2(size.x / 2, size.y / 2 + 5),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ));
    
    add(TextComponent(
      text: 'Tap to restart',
      position: Vector2(size.x / 2, size.y / 2 + 35),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    ));
  }
  
  void restartGame() {
    removeAll(children);
    score = 0;
    lives = 3;
    level = 1;
    isGameOver = false;
    super.isGameOver = false; // Update EscPauseHandler
    goalsReached = [false, false, false, false, false];
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));
    
    _setupLevel();
    _spawnFrog();
    _setupUI();
  }

  @override
  void restartFromPause() {
    restartGame();
  }
}

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/player.dart';
import 'components/centipede.dart';
import 'components/mushroom.dart';
import 'components/bullet.dart';
import 'components/spider.dart';

/// Classic Centipede arcade game
/// 
/// Gameplay:
/// - Player shoots at descending centipede
/// - Centipede navigates around mushrooms
/// - When hit, centipede splits into segments
/// - Mushrooms block centipede path
/// - Spider provides bonus points
/// - Clear all centipede segments to win wave
class CentipedeGame extends FlameGame
    with TapCallbacks, PanDetector, KeyboardEvents, HasCollisionDetection {
  
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onScoreChanged;
  final ValueChanged<int>? onLivesChanged;
  final ValueChanged<int>? onWaveChanged;

  CentipedeGame({
    this.onGameOver,
    this.onScoreChanged,
    this.onLivesChanged,
    this.onWaveChanged,
  });

  // Game state
  late CentipedePlayer player;
  List<Centipede> centipedes = [];
  List<Mushroom> mushrooms = [];
  Spider? spider;
  
  int score = 0;
  int lives = 3;
  int wave = 1;
  bool isGameOver = false;
  bool isPaused = false;
  
  // Grid configuration
  static const int gridColumns = 30;
  static const int gridRows = 30;
  late double cellSize;
  late double playerAreaHeight; // Bottom area for player movement
  
  // Timers
  double _spiderSpawnTimer = 0;
  final double _spiderSpawnInterval = 8.0;
  
  final Random _random = Random();

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    // Calculate cell size based on screen
    cellSize = min(size.x / gridColumns, size.y / gridRows);
    playerAreaHeight = cellSize * 4; // Player can move in bottom 4 rows
    
    await _setupGame();
  }

  Future<void> _setupGame() async {
    // Clear existing components
    removeAll(children.where((c) => 
      c is CentipedePlayer || 
      c is Centipede || 
      c is Mushroom || 
      c is CentipedeBullet ||
      c is Spider
    ).toList());
    
    centipedes.clear();
    mushrooms.clear();
    spider = null;
    
    // Create player
    player = CentipedePlayer(
      position: Vector2(size.x / 2, size.y - cellSize * 2),
      cellSize: cellSize,
      gameRef: this,
    );
    add(player);
    
    // Create mushroom field
    _generateMushrooms();
    
    // Create initial centipede
    _spawnCentipede();
    
    // Notify initial state
    Future.microtask(() {
      onScoreChanged?.call(score);
      onLivesChanged?.call(lives);
      onWaveChanged?.call(wave);
    });
  }

  void _generateMushrooms() {
    // Place mushrooms randomly in the playing field (not in player area)
    final mushroomCount = 20 + (wave * 5);
    
    for (int i = 0; i < mushroomCount; i++) {
      final col = _random.nextInt(gridColumns);
      final row = _random.nextInt(gridRows - 5) + 1; // Leave top row for centipede entry, bottom 4 for player
      
      // Check if position is already occupied
      final pos = Vector2(col * cellSize, row * cellSize);
      if (!_isMushroomAt(pos)) {
        final mushroom = Mushroom(
          position: pos,
          cellSize: cellSize,
        );
        mushrooms.add(mushroom);
        add(mushroom);
      }
    }
  }

  bool _isMushroomAt(Vector2 pos) {
    for (final m in mushrooms) {
      if ((m.position - pos).length < cellSize * 0.5) {
        return true;
      }
    }
    return false;
  }

  void _spawnCentipede() {
    final segmentCount = 10 + (wave * 2);
    final startX = size.x / 2;
    const startY = 0.0;
    
    final centipede = Centipede(
      startPosition: Vector2(startX, startY),
      segmentCount: segmentCount,
      cellSize: cellSize,
      gameRef: this,
    );
    centipedes.add(centipede);
    add(centipede);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver || isPaused) return;
    
    // Spider spawning
    _spiderSpawnTimer += dt;
    if (_spiderSpawnTimer >= _spiderSpawnInterval && spider == null) {
      _spiderSpawnTimer = 0;
      _spawnSpider();
    }
    
    // Check for wave completion
    _checkWaveComplete();
    
    // Clean up dead centipedes
    centipedes.removeWhere((c) => c.isFullyDestroyed);
  }

  void _spawnSpider() {
    final startFromLeft = _random.nextBool();
    spider = Spider(
      position: Vector2(
        startFromLeft ? -cellSize : size.x + cellSize,
        size.y - playerAreaHeight - cellSize * 2,
      ),
      cellSize: cellSize,
      movingRight: !startFromLeft,
      gameRef: this,
    );
    add(spider!);
  }

  void _checkWaveComplete() {
    if (centipedes.isEmpty || centipedes.every((c) => c.isFullyDestroyed)) {
      _nextWave();
    }
  }

  void _nextWave() {
    wave++;
    onWaveChanged?.call(wave);
    
    // Clear bullets
    removeAll(children.whereType<CentipedeBullet>().toList());
    
    // Spawn new centipede
    _spawnCentipede();
    
    // Add bonus mushrooms
    for (int i = 0; i < 5; i++) {
      final col = _random.nextInt(gridColumns);
      final row = _random.nextInt(gridRows - 5) + 1;
      final pos = Vector2(col * cellSize, row * cellSize);
      
      if (!_isMushroomAt(pos)) {
        final mushroom = Mushroom(position: pos, cellSize: cellSize);
        mushrooms.add(mushroom);
        add(mushroom);
      }
    }
  }

  // Input handling
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused) return;
    player.move(info.delta.global);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || isPaused) return;
    player.shoot();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isGameOver || isPaused) return KeyEventResult.ignored;

    const moveSpeed = 8.0;
    
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      player.move(Vector2(-moveSpeed, 0));
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      player.move(Vector2(moveSpeed, 0));
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      player.move(Vector2(0, -moveSpeed));
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      player.move(Vector2(0, moveSpeed));
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.space)) {
      player.shoot();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Game events
  void addScore(int points) {
    score += points;
    onScoreChanged?.call(score);
  }

  void playerHit() {
    lives--;
    onLivesChanged?.call(lives);
    HapticFeedback.heavyImpact();
    
    if (lives <= 0) {
      gameOver();
    } else {
      // Reset player position
      player.position = Vector2(size.x / 2, size.y - cellSize * 2);
    }
  }

  void gameOver() {
    isGameOver = true;
    HapticFeedback.heavyImpact();
    onGameOver?.call();
  }

  void removeMushroom(Mushroom mushroom) {
    mushrooms.remove(mushroom);
    mushroom.removeFromParent();
    addScore(1);
  }

  void removeSpider() {
    spider?.removeFromParent();
    spider = null;
  }

  void splitCentipede(Centipede centipede, int atSegment) {
    // Create new centipede from remaining segments
    final newCentipede = centipede.splitAt(atSegment);
    if (newCentipede != null) {
      centipedes.add(newCentipede);
      add(newCentipede);
    }
  }

  void restart() {
    score = 0;
    lives = 3;
    wave = 1;
    isGameOver = false;
    isPaused = false;
    _spiderSpawnTimer = 0;
    _setupGame();
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  // Getters for mushroom collision detection
  Mushroom? getMushroomAt(Vector2 pos) {
    for (final m in mushrooms) {
      if ((m.position - pos).length < cellSize * 0.8) {
        return m;
      }
    }
    return null;
  }
}

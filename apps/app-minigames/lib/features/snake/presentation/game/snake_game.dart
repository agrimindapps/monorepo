import 'dart:async';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/power_up.dart';
import 'components/food.dart';
import 'components/snake_segment.dart';
import 'components/power_up_component.dart';

class SnakeGame extends FlameGame with KeyboardEvents, TapCallbacks {
  final VoidCallback? onGameOver;
  final ValueChanged<int>? onScoreChanged;
  final ValueChanged<List<ActivePowerUp>>? onActivePowerUpsChanged;
  final int gridSize;
  final bool hasWalls;

  SnakeGame({
    this.onGameOver,
    this.onScoreChanged,
    this.onActivePowerUpsChanged,
    this.gridSize = 20,
    this.hasWalls = true,
  });

  // Game state
  List<SnakeSegment> snakeBody = [];
  late Food food;
  List<PowerUpComponent> powerUpsOnBoard = [];
  List<ActivePowerUp> activePowerUps = [];

  Direction currentDirection = Direction.right;
  Direction nextDirection = Direction.right;
  double _timer = 0;
  double _baseMoveInterval = 0.15;
  double _currentMoveInterval = 0.15;
  double _powerUpSpawnTimer = 0;

  int score = 0;
  bool isGameOver = false;
  bool isPlaying = false;

  // Grid dimensions
  late double cellSize;
  late double boardOffsetX;
  late double boardOffsetY;
  late double boardSize;

  @override
  Future<void> onLoad() async {
    // Calculate grid layout
    final minDimension = min(size.x, size.y);
    boardSize = minDimension * 0.9;
    cellSize = boardSize / gridSize;
    boardOffsetX = (size.x - boardSize) / 2;
    boardOffsetY = (size.y - boardSize) / 2;

    // Initialize snake
    _resetGame();
  }

  void _resetGame() {
    // Clear existing components
    children.whereType<SnakeSegment>().forEach((c) => c.removeFromParent());
    children.whereType<Food>().forEach((c) => c.removeFromParent());
    children.whereType<PowerUpComponent>().forEach((c) => c.removeFromParent());

    snakeBody.clear();
    powerUpsOnBoard.clear();
    activePowerUps.clear();

    score = 0;
    isGameOver = false;
    isPlaying = false;
    currentDirection = Direction.right;
    nextDirection = Direction.right;
    _currentMoveInterval = _baseMoveInterval;

    if (onScoreChanged != null) {
      onScoreChanged!(score);
    }

    // Create initial snake (3 segments)
    final startX = gridSize ~/ 2;
    final startY = gridSize ~/ 2;

    for (int i = 0; i < 3; i++) {
      _addSnakeSegment(startX - i, startY);
    }

    // Add food
    _spawnFood();

    // Start paused
    pauseGame();
  }

  void _addSnakeSegment(int x, int y) {
    final segment = SnakeSegment(
      gridPosition: Point(x, y),
      cellSize: cellSize,
      boardOffset: Vector2(boardOffsetX, boardOffsetY),
      isHead: snakeBody.isEmpty,
    );
    snakeBody.add(segment);
    add(segment);
  }

  void _spawnFood() {
    // Find empty spot
    final random = Random();
    Point<int> position;

    do {
      position = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (_isOccupied(position));

    food = Food(
      gridPosition: position,
      cellSize: cellSize,
      boardOffset: Vector2(boardOffsetX, boardOffsetY),
    );
    add(food);
  }

  void _spawnPowerUp() {
    final random = Random();
    // 20% chance to spawn powerup every 5 seconds if none exists
    if (powerUpsOnBoard.isNotEmpty || random.nextDouble() > 0.3) return;

    Point<int> position;
    do {
      position = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (_isOccupied(position));

    final type = PowerUpType.values[random.nextInt(PowerUpType.values.length)];

    final powerUp = PowerUpComponent(
      gridPosition: position,
      cellSize: cellSize,
      boardOffset: Vector2(boardOffsetX, boardOffsetY),
      type: type,
    );

    powerUpsOnBoard.add(powerUp);
    add(powerUp);
  }

  bool _isOccupied(Point<int> pos) {
    if (snakeBody.any((s) => s.gridPosition == pos)) return true;
    if (food.gridPosition == pos) return true;
    if (powerUpsOnBoard.any((p) => p.gridPosition == pos)) return true;
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPlaying || isGameOver) return;

    // Update power-up spawn timer
    _powerUpSpawnTimer += dt;
    if (_powerUpSpawnTimer >= 5.0) {
      _powerUpSpawnTimer = 0;
      _spawnPowerUp();
    }

    // Update active power-ups
    final initialCount = activePowerUps.length;
    activePowerUps.removeWhere((p) => !p.isActive);
    if (activePowerUps.length != initialCount &&
        onActivePowerUpsChanged != null) {
      onActivePowerUpsChanged!(List.from(activePowerUps));
    }
    _updateGameSpeed();

    // Magnet effect
    if (_hasActivePowerUp(PowerUpType.magnet)) {
      // Logic to pull food could go here, but for grid snake it's tricky.
      // Instead, let's just say if we are within 3 cells, we eat it.
      final head = snakeBody.first.gridPosition;
      final dist =
          (head.x - food.gridPosition.x).abs() +
          (head.y - food.gridPosition.y).abs();
      if (dist <= 3 && dist > 0) {
        // Move food one step closer? Or just eat it?
        // Let's keep it simple for now and just eat if very close
      }
    }

    _timer += dt;
    if (_timer >= _currentMoveInterval) {
      _timer = 0;
      _moveSnake();
    }
  }

  void _updateGameSpeed() {
    double speedMultiplier = 1.0;

    if (_hasActivePowerUp(PowerUpType.speedBoost)) {
      speedMultiplier = 0.5; // Faster (smaller interval)
    } else if (_hasActivePowerUp(PowerUpType.slowMotion)) {
      speedMultiplier = 1.5; // Slower (larger interval)
    }

    _currentMoveInterval = _baseMoveInterval * speedMultiplier;
  }

  bool _hasActivePowerUp(PowerUpType type) {
    return activePowerUps.any((p) => p.type == type && p.isActive);
  }

  void _moveSnake() {
    currentDirection = nextDirection;

    final head = snakeBody.first;
    int newX = head.gridPosition.x;
    int newY = head.gridPosition.y;

    switch (currentDirection) {
      case Direction.up:
        newY--;
        break;
      case Direction.down:
        newY++;
        break;
      case Direction.left:
        newX--;
        break;
      case Direction.right:
        newX++;
        break;
    }

    // Check collisions
    if (_checkCollision(newX, newY)) {
      gameOver();
      return;
    }

    // Wrap around if no walls
    if (!hasWalls) {
      if (newX < 0) newX = gridSize - 1;
      if (newX >= gridSize) newX = 0;
      if (newY < 0) newY = gridSize - 1;
      if (newY >= gridSize) newY = 0;
    }

    // Check for power-ups
    final powerUpIndex = powerUpsOnBoard.indexWhere(
      (p) => p.gridPosition.x == newX && p.gridPosition.y == newY,
    );
    if (powerUpIndex != -1) {
      final powerUp = powerUpsOnBoard[powerUpIndex];
      _activatePowerUp(powerUp.type);
      powerUp.removeFromParent();
      powerUpsOnBoard.removeAt(powerUpIndex);
    }

    // Move body
    // If ate food, grow (don't remove tail)
    // If not, move tail to head position

    bool ateFood = newX == food.gridPosition.x && newY == food.gridPosition.y;

    // Magnet check (eat if close)
    if (!ateFood && _hasActivePowerUp(PowerUpType.magnet)) {
      final dist =
          (newX - food.gridPosition.x).abs() +
          (newY - food.gridPosition.y).abs();
      if (dist <= 2) {
        ateFood = true;
      }
    }

    if (ateFood) {
      // Add new head
      final newHead = SnakeSegment(
        gridPosition: Point(newX, newY),
        cellSize: cellSize,
        boardOffset: Vector2(boardOffsetX, boardOffsetY),
        isHead: true,
      );

      // Old head becomes body
      snakeBody.first.isHead = false;

      snakeBody.insert(0, newHead);
      add(newHead);

      // Remove old food and spawn new
      food.removeFromParent();
      _spawnFood();

      // Increase score
      int points = 10;
      if (_hasActivePowerUp(PowerUpType.doublePoints)) {
        points *= 2;
      }
      score += points;

      if (onScoreChanged != null) {
        onScoreChanged!(score);
      }

      // Speed up slightly (base speed)
      _baseMoveInterval = max(0.05, _baseMoveInterval * 0.98);
    } else {
      // Move tail to new head position
      final tail = snakeBody.removeLast();
      tail.removeFromParent();

      final newHead = SnakeSegment(
        gridPosition: Point(newX, newY),
        cellSize: cellSize,
        boardOffset: Vector2(boardOffsetX, boardOffsetY),
        isHead: true,
      );

      // Old head becomes body
      snakeBody.first.isHead = false;

      snakeBody.insert(0, newHead);
      add(newHead);
    }
  }

  void _activatePowerUp(PowerUpType type) {
    // Remove existing of same type to refresh duration
    activePowerUps.removeWhere((p) => p.type == type);
    activePowerUps.add(ActivePowerUp.fromType(type));
    if (onActivePowerUpsChanged != null) {
      onActivePowerUpsChanged!(List.from(activePowerUps));
    }
  }

  bool _checkCollision(int x, int y) {
    // Ghost mode ignores collisions
    if (_hasActivePowerUp(PowerUpType.ghostMode)) return false;

    // Shield protects once (we could implement "consume shield" logic, but for now let's just say it protects)
    // Actually, usually shield protects against one hit.
    // Let's check if we would collide, and if so, if we have shield, consume it and return false.

    bool wouldCollide = false;

    // Wall collision
    if (hasWalls) {
      if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) {
        wouldCollide = true;
      }
    }

    // Self collision
    if (!wouldCollide) {
      for (int i = 0; i < snakeBody.length - 1; i++) {
        if (snakeBody[i].gridPosition.x == x &&
            snakeBody[i].gridPosition.y == y) {
          wouldCollide = true;
          break;
        }
      }
    }

    if (wouldCollide) {
      if (_hasActivePowerUp(PowerUpType.shield)) {
        activePowerUps.removeWhere((p) => p.type == PowerUpType.shield);
        return false; // Saved by shield!
      }
      return true;
    }

    return false;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        if (currentDirection != Direction.down) nextDirection = Direction.up;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        if (currentDirection != Direction.up) nextDirection = Direction.down;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        if (currentDirection != Direction.right) nextDirection = Direction.left;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        if (currentDirection != Direction.left) nextDirection = Direction.right;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        if (isPlaying) {
          pauseGame();
        } else {
          startGame();
        }
      }
    }
    return KeyEventResult.handled;
  }

  // Touch controls
  void changeDirection(Direction direction) {
    if (direction == Direction.up && currentDirection != Direction.down) {
      nextDirection = Direction.up;
    } else if (direction == Direction.down &&
        currentDirection != Direction.up) {
      nextDirection = Direction.down;
    } else if (direction == Direction.left &&
        currentDirection != Direction.right) {
      nextDirection = Direction.left;
    } else if (direction == Direction.right &&
        currentDirection != Direction.left) {
      nextDirection = Direction.right;
    }
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
    _resetGame();
    startGame();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw board border
    final paint = Paint()
      ..color = hasWalls
          ? Colors.redAccent.withValues(alpha: 0.5)
          : Colors.blueAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(
      boardOffsetX,
      boardOffsetY,
      boardSize,
      boardSize,
    );
    canvas.drawRect(rect, paint);
  }
}

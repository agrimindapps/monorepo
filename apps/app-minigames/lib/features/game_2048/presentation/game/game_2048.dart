import 'dart:async';
import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/enums.dart';
import 'components/tile.dart';

class Game2048 extends FlameGame with KeyboardEvents, DragCallbacks {
  final int gridSize;
  final Function(int) onScoreChanged;
  final VoidCallback onGameOver;
  final VoidCallback onWin;

  Game2048({
    required this.gridSize,
    required this.onScoreChanged,
    required this.onGameOver,
    required this.onWin,
  });

  late double cellSize;
  late double spacing;
  late double boardSize;
  late Vector2 boardOffset;

  List<Tile> tiles = [];
  bool isAnimating = false;
  bool hasWon = false;

  @override
  Future<void> onLoad() async {
    _calculateLayout();
    _spawnInitialTiles();
  }

  void _calculateLayout() {
    final minDimension = min(size.x, size.y);
    boardSize = minDimension * 0.9;
    spacing = 10.0;
    cellSize = (boardSize - (spacing * (gridSize + 1))) / gridSize;
    boardOffset = Vector2(
      (size.x - boardSize) / 2,
      (size.y - boardSize) / 2,
    );
  }

  void _spawnInitialTiles() {
    _spawnTile();
    _spawnTile();
  }

  void _spawnTile() {
    final emptyPositions = _getEmptyPositions();
    if (emptyPositions.isEmpty) return;

    final random = Random();
    final pos = emptyPositions[random.nextInt(emptyPositions.length)];
    final value = random.nextDouble() < 0.9 ? 2 : 4;

    final tile = Tile(
      id: DateTime.now().microsecondsSinceEpoch.toString() + random.nextInt(1000).toString(),
      value: value,
      position: _getVectorPosition(pos.x, pos.y),
      size: Vector2.all(cellSize),
    );
    
    // Set grid coordinates
    tile.userData = pos; 

    tiles.add(tile);
    add(tile);
    tile.spawn();
  }

  List<Point<int>> _getEmptyPositions() {
    final occupied = <Point<int>>{};
    for (final tile in tiles) {
      occupied.add(tile.userData as Point<int>);
    }

    final empty = <Point<int>>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final point = Point(x, y);
        if (!occupied.contains(point)) {
          empty.add(point);
        }
      }
    }
    return empty;
  }

  Vector2 _getVectorPosition(int col, int row) {
    return Vector2(
      boardOffset.x + spacing + (col * (cellSize + spacing)) + cellSize / 2,
      boardOffset.y + spacing + (row * (cellSize + spacing)) + cellSize / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFFBBADA0);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boardOffset.x, boardOffset.y, boardSize, boardSize),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Draw empty cells
    final cellPaint = Paint()..color = const Color(0xFFCDC1B4);
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final pos = _getVectorPosition(x, y);
        final cellRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos.toOffset(), width: cellSize, height: cellSize),
          const Radius.circular(4),
        );
        canvas.drawRRect(cellRect, cellPaint);
      }
    }

    super.render(canvas);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isAnimating) return;

    final velocity = event.velocity;
    if (velocity.x.abs() > velocity.y.abs()) {
      if (velocity.x > 0) {
        move(Direction.right);
      } else {
        move(Direction.left);
      }
    } else {
      if (velocity.y > 0) {
        move(Direction.down);
      } else {
        move(Direction.up);
      }
    }
  }
  
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isAnimating) return KeyEventResult.ignored;
    
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        move(Direction.up);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        move(Direction.down);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        move(Direction.left);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        move(Direction.right);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> move(Direction direction) async {
    if (isAnimating) return;
    isAnimating = true;

    bool moved = false;
    int scoreToAdd = 0;
    final List<Tile> tilesToRemove = [];
    
    // Sort tiles based on direction to process correctly
    // Right: sort by col desc
    // Left: sort by col asc
    // Down: sort by row desc
    // Up: sort by row asc
    
    tiles.sort((a, b) {
      final posA = a.userData as Point<int>;
      final posB = b.userData as Point<int>;
      
      switch (direction) {
        case Direction.left:
          return posA.x.compareTo(posB.x);
        case Direction.right:
          return posB.x.compareTo(posA.x);
        case Direction.up:
          return posA.y.compareTo(posB.y);
        case Direction.down:
          return posB.y.compareTo(posA.y);
      }
    });

    // Map to track occupied positions for this move step
    final Map<Point<int>, Tile> occupied = {};
    final Set<Tile> mergedTargets = {};
    
    for (final tile in tiles) {
      final currentPos = tile.userData as Point<int>;
      var targetPos = currentPos;
      Tile? mergeTarget;
      
      // Calculate furthest position
      var nextPos = _getNextPosition(targetPos, direction);
      while (_isValidPosition(nextPos)) {
        final otherTile = occupied[nextPos];
        if (otherTile == null) {
          // Empty, can move
          targetPos = nextPos;
          nextPos = _getNextPosition(targetPos, direction);
        } else {
          // Occupied
          if (otherTile.value == tile.value && 
              !tilesToRemove.contains(otherTile) &&
              !mergedTargets.contains(otherTile)) {
             mergeTarget = otherTile;
             targetPos = nextPos;
          }
          break;
        }
      }
      
      if (targetPos != currentPos) {
        moved = true;
        
        // Animate
        final targetVector = _getVectorPosition(targetPos.x, targetPos.y);
        tile.add(
          MoveEffect.to(
            targetVector,
            EffectController(duration: 0.15, curve: Curves.easeInOut),
          ),
        );
        
        tile.userData = targetPos;
        
        if (mergeTarget != null) {
          // Merge logic
          tilesToRemove.add(tile); // The moving tile disappears into the target
          mergedTargets.add(mergeTarget);
          
          final newValue = tile.value * 2;
          scoreToAdd += newValue;
          
          // Queue the update
          Future.delayed(const Duration(milliseconds: 150), () {
             mergeTarget!.updateValue(newValue);
             mergeTarget.merge(); // Play merge animation
             tile.removeFromParent();
          });
        } else {
          // Just move
          occupied[targetPos] = tile;
        }
      } else {
        occupied[currentPos] = tile;
      }
    }
    
    if (moved) {
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Cleanup removed tiles
      tiles.removeWhere((t) => tilesToRemove.contains(t));
      
      // Update score
      if (scoreToAdd > 0) {
        onScoreChanged(scoreToAdd);
      }
      
      // Spawn new
      _spawnTile();
      
      // Check game over
      if (_isGameOver()) {
        onGameOver();
      }
    }
    
    isAnimating = false;
  }
  
  Point<int> _getNextPosition(Point<int> pos, Direction dir) {
    switch (dir) {
      case Direction.left:
        return Point(pos.x - 1, pos.y);
      case Direction.right:
        return Point(pos.x + 1, pos.y);
      case Direction.up:
        return Point(pos.x, pos.y - 1);
      case Direction.down:
        return Point(pos.x, pos.y + 1);
    }
  }
  
  bool _isValidPosition(Point<int> pos) {
    return pos.x >= 0 && pos.x < gridSize && pos.y >= 0 && pos.y < gridSize;
  }
  
  bool _isGameOver() {
    if (_getEmptyPositions().isNotEmpty) return false;
    
    // Check possible merges
    for (final tile in tiles) {
      final pos = tile.userData as Point<int>;
      for (final dir in Direction.values) {
        final next = _getNextPosition(pos, dir);
        if (_isValidPosition(next)) {
          final neighbor = tiles.firstWhere(
            (t) => (t.userData as Point<int>) == next,
            orElse: () => tile, // Should not happen if grid full
          );
          if (neighbor != tile && neighbor.value == tile.value) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  void restart() {
    children.whereType<Tile>().forEach((t) => t.removeFromParent());
    tiles.clear();
    _spawnInitialTiles();
    isAnimating = false;
  }
}

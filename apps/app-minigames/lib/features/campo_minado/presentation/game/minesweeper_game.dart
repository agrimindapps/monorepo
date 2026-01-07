import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/game_state.dart';
import 'components/cell.dart';

class MinesweeperGame extends FlameGame with PanDetector, ScrollDetector {
  final Function(int, int) onCellTap;
  final Function(int, int) onCellLongPress;

  MinesweeperGame({
    required this.onCellTap,
    required this.onCellLongPress,
  });

  late List<List<Cell>> gridCells = [];
  late double cellSize;
  late Vector2 boardOffset;
  
  // Cache dimensions to detect changes
  int _rows = 0;
  int _cols = 0;
  GameState? _lastState;

  @override
  Future<void> onLoad() async {
    // Initial setup
    camera.viewfinder.anchor = Anchor.center;
  }
  
  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Move camera opposite to drag direction to simulate moving the world
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // Zoom in/out
    final zoomDelta = info.scrollDelta.global.y.sign * -0.1;
    final newZoom = (camera.viewfinder.zoom + zoomDelta).clamp(0.5, 3.0);
    camera.viewfinder.zoom = newZoom;
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_lastState != null) {
      // Recenter camera on resize
      camera.viewfinder.position = size / 2;
      _createGrid(_lastState!.rows, _lastState!.cols);
      _updateCells(_lastState!);
    }
  }

  void updateState(GameState state) {
    _lastState = state;
    final rows = state.rows;
    final cols = state.cols;
    
    // Recreate grid if dimensions changed
    if (rows != _rows || cols != _cols) {
      _rows = rows;
      _cols = cols;
      if (size.x > 0 && size.y > 0) {
        _createGrid(rows, cols);
        // Center camera on the new grid
        camera.viewfinder.position = size / 2;
        camera.viewfinder.zoom = 1.0;
      }
    }
    
    if (gridCells.isNotEmpty) {
      _updateCells(state);
    }
  }
  
  void _updateCells(GameState state) {
    bool mineExploded = false;

    // Update cells
    for (int r = 0; r < state.rows; r++) {
      for (int c = 0; c < state.cols; c++) {
        if (r < gridCells.length && c < gridCells[r].length) {
          final cellData = state.grid[r][c];
          final cell = gridCells[r][c];
          
          // Detect reveal for effects
          if (!cell.isRevealed && cellData.isRevealed) {
            if (cellData.isMine) {
              mineExploded = true;
            } else {
              _spawnDust(cell.position + cell.size / 2);
            }
          }
          
          cell.isMine = cellData.isMine;
          cell.isRevealed = cellData.isRevealed;
          cell.isFlagged = cellData.isFlagged;
          cell.neighborMineCount = cellData.neighborMines;
        }
      }
    }
    
    if (mineExploded) {
      _shakeCamera();
    }
  }
  
  void _shakeCamera() {
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(10, 10),
        EffectController(
          duration: 0.05,
          alternate: true,
          repeatCount: 5,
        ),
      ),
    );
  }
  
  void _spawnDust(Vector2 position) {
    final random = Random();
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) {
            final speed = Vector2.random(random) - Vector2(0.5, 0.5);
            speed.multiply(Vector2(100, 100));
            
            return AcceleratedParticle(
              position: position,
              speed: speed,
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = Colors.grey.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ),
    );
  }

  void _calculateLayout(int rows, int cols) {
    final availableWidth = size.x * 0.95;
    final availableHeight = size.y * 0.9;
    
    final cellWidth = availableWidth / cols;
    final cellHeight = availableHeight / rows;
    
    cellSize = min(cellWidth, cellHeight);
    
    final boardWidth = cellSize * cols;
    final boardHeight = cellSize * rows;
    
    boardOffset = Vector2(
      (size.x - boardWidth) / 2,
      (size.y - boardHeight) / 2,
    );
  }

  void _createGrid(int rows, int cols) {
    // Clear existing
    children.whereType<Cell>().forEach((c) => c.removeFromParent());
    gridCells.clear();
    
    _calculateLayout(rows, cols);
    
    gridCells = List.generate(rows, (row) {
      return List.generate(cols, (col) {
        final cell = Cell(
          row: row,
          col: col,
          cellSize: cellSize,
          position: Vector2(
            boardOffset.x + col * cellSize,
            boardOffset.y + row * cellSize,
          ),
          onReveal: (c) => onCellTap(c.row, c.col),
          onFlag: (c) => onCellLongPress(c.row, c.col),
        );
        add(cell);
        return cell;
      });
    });
  }
}

import 'package:flutter/material.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  final TetrominoType type;
  List<List<int>> shape;
  int x;
  int y;
  
  Tetromino({
    required this.type,
    required this.shape,
    this.x = 3,
    this.y = 0,
  });
  
  Color get color {
    switch (type) {
      case TetrominoType.I:
        return Colors.cyan;
      case TetrominoType.O:
        return Colors.yellow;
      case TetrominoType.T:
        return Colors.purple;
      case TetrominoType.S:
        return Colors.green;
      case TetrominoType.Z:
        return Colors.red;
      case TetrominoType.J:
        return Colors.blue;
      case TetrominoType.L:
        return Colors.orange;
    }
  }
  
  Tetromino copy() {
    return Tetromino(
      type: type,
      shape: shape.map((row) => List<int>.from(row)).toList(),
      x: x,
      y: y,
    );
  }
  
  void rotateClockwise() {
    final rows = shape.length;
    final cols = shape[0].length;
    final rotated = List.generate(cols, (i) => List.generate(rows, (j) => 0));
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[j][rows - 1 - i] = shape[i][j];
      }
    }
    
    shape = rotated;
  }
  
  void rotateCounterClockwise() {
    final rows = shape.length;
    final cols = shape[0].length;
    final rotated = List.generate(cols, (i) => List.generate(rows, (j) => 0));
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[cols - 1 - j][i] = shape[i][j];
      }
    }
    
    shape = rotated;
  }
  
  static Tetromino create(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return Tetromino(
          type: type,
          shape: [
            [1, 1, 1, 1],
          ],
        );
      case TetrominoType.O:
        return Tetromino(
          type: type,
          shape: [
            [1, 1],
            [1, 1],
          ],
        );
      case TetrominoType.T:
        return Tetromino(
          type: type,
          shape: [
            [0, 1, 0],
            [1, 1, 1],
          ],
        );
      case TetrominoType.S:
        return Tetromino(
          type: type,
          shape: [
            [0, 1, 1],
            [1, 1, 0],
          ],
        );
      case TetrominoType.Z:
        return Tetromino(
          type: type,
          shape: [
            [1, 1, 0],
            [0, 1, 1],
          ],
        );
      case TetrominoType.J:
        return Tetromino(
          type: type,
          shape: [
            [1, 0, 0],
            [1, 1, 1],
          ],
        );
      case TetrominoType.L:
        return Tetromino(
          type: type,
          shape: [
            [0, 0, 1],
            [1, 1, 1],
          ],
        );
    }
  }
}

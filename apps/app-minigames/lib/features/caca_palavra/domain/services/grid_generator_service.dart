import 'dart:math';
import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import '../entities/position.dart';
import '../entities/word_entity.dart';

/// Service responsible for grid generation logic
/// Follows SRP by handling only grid placement operations
@lazySingleton
class GridGeneratorService {
  final Random _random = Random();

  /// Creates an empty grid
  List<List<String>> createEmptyGrid(int size) {
    return List.generate(
      size,
      (_) => List.filled(size, ''),
    );
  }

  /// Places a word on the grid
  WordEntity? placeWordOnGrid(
    List<List<String>> grid,
    String word,
    int gridSize,
  ) {
    const maxAttempts = 100;
    final directions = WordDirection.values.toList()..shuffle(_random);

    for (final direction in directions) {
      for (int attempt = 0; attempt < maxAttempts ~/ 4; attempt++) {
        final placement = _tryPlacement(grid, word, direction, gridSize);

        if (placement != null) {
          final (positions, _, _) = placement;

          // Place word on grid
          for (int i = 0; i < word.length; i++) {
            final pos = positions[i];
            grid[pos.row][pos.col] = word[i];
          }

          return WordEntity(
            text: word,
            direction: direction,
            positions: positions,
          );
        }
      }
    }

    return null;
  }

  /// Tries to place word in a specific direction
  (List<Position>, int, int)? _tryPlacement(
    List<List<String>> grid,
    String word,
    WordDirection direction,
    int gridSize,
  ) {
    late int startRow, startCol;
    final positions = <Position>[];

    // Calculate start position based on direction
    switch (direction) {
      case WordDirection.horizontal:
        if (gridSize < word.length) return null;
        startRow = _random.nextInt(gridSize);
        startCol = _random.nextInt(gridSize - word.length + 1);

        if (!_canPlaceWord(grid, word, startRow, startCol, 0, 1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow, startCol + i));
        }

      case WordDirection.vertical:
        if (gridSize < word.length) return null;
        startRow = _random.nextInt(gridSize - word.length + 1);
        startCol = _random.nextInt(gridSize);

        if (!_canPlaceWord(grid, word, startRow, startCol, 1, 0)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol));
        }

      case WordDirection.diagonalDown:
        if (gridSize < word.length) return null;
        startRow = _random.nextInt(gridSize - word.length + 1);
        startCol = _random.nextInt(gridSize - word.length + 1);

        if (!_canPlaceWord(grid, word, startRow, startCol, 1, 1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol + i));
        }

      case WordDirection.diagonalUp:
        if (gridSize < word.length) return null;
        startRow = _random.nextInt(gridSize - word.length + 1);
        final minCol = word.length - 1;
        startCol = _random.nextInt(gridSize - minCol) + minCol;

        if (!_canPlaceWord(grid, word, startRow, startCol, 1, -1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol - i));
        }
    }

    return (positions, startRow, startCol);
  }

  /// Checks if a word can be placed at the given position
  bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    int rowStep,
    int colStep,
  ) {
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * rowStep;
      final col = startCol + i * colStep;

      final cell = grid[row][col];

      // Cell must be empty or contain the same letter
      if (cell.isNotEmpty && cell != word[i]) {
        return false;
      }
    }

    return true;
  }

  /// Fills empty spaces with random letters
  void fillEmptySpaces(List<List<String>> grid, int gridSize) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isEmpty) {
          grid[row][col] = letters[_random.nextInt(letters.length)];
        }
      }
    }
  }

  /// Validates grid integrity
  bool validateGrid(List<List<String>> grid, int expectedSize) {
    if (grid.length != expectedSize) return false;

    for (final row in grid) {
      if (row.length != expectedSize) return false;
      if (row.any((cell) => cell.isEmpty)) return false;
    }

    return true;
  }

  /// Gets grid statistics
  GridStatistics getGridStatistics(
      List<List<String>> grid, List<WordEntity> words) {
    int totalCells = grid.length * grid.length;
    int filledByWords = words.fold<int>(
      0,
      (sum, word) => sum + word.text.length,
    );
    int randomLetters = totalCells - filledByWords;

    return GridStatistics(
      totalCells: totalCells,
      filledByWords: filledByWords,
      randomLetters: randomLetters,
      wordCount: words.length,
      fillPercentage: (filledByWords / totalCells * 100).round(),
    );
  }

  /// Creates a copy of the grid
  List<List<String>> copyGrid(List<List<String>> grid) {
    return grid.map((row) => List<String>.from(row)).toList();
  }
}

// Models

class GridStatistics {
  final int totalCells;
  final int filledByWords;
  final int randomLetters;
  final int wordCount;
  final int fillPercentage;

  GridStatistics({
    required this.totalCells,
    required this.filledByWords,
    required this.randomLetters,
    required this.wordCount,
    required this.fillPercentage,
  });
}

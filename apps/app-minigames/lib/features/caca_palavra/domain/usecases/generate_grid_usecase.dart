import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../entities/word_entity.dart';
import '../repositories/caca_palavra_repository.dart';

/// Generates a new word search grid with words placed randomly
class GenerateGridUseCase {
  final CacaPalavraRepository repository;

  GenerateGridUseCase(this.repository);

  Future<Either<Failure, GameState>> call({
    required GameDifficulty difficulty,
  }) async {
    try {
      // Get available words
      final wordsResult = await repository.getAvailableWords();

      return wordsResult.fold(
        (failure) => Left(failure),
        (availableWords) {
          final gridSize = difficulty.gridSize;
          final wordCount = difficulty.wordCount;

          // Initialize empty grid
          final grid = List.generate(
            gridSize,
            (_) => List.filled(gridSize, ''),
          );

          // Select random words that fit in grid
          final selectedWords = _selectRandomWords(
            availableWords,
            wordCount,
            gridSize,
          );

          // Place words on grid
          final words = <WordEntity>[];
          for (final word in selectedWords) {
            final placedWord = _placeWordOnGrid(grid, word, gridSize);
            if (placedWord != null) {
              words.add(placedWord);
            }
          }

          // Fill empty spaces with random letters
          _fillEmptySpaces(grid, gridSize);

          return Right(
            GameState(
              grid: grid,
              words: words,
              selectedPositions: const [],
              difficulty: difficulty,
              status: GameStatus.playing,
              foundWordsCount: 0,
            ),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to generate grid: ${e.toString()}'));
    }
  }

  /// Selects random words that fit in the grid
  List<String> _selectRandomWords(
    List<String> availableWords,
    int count,
    int gridSize,
  ) {
    final random = Random();
    final shuffled = List<String>.from(availableWords)..shuffle(random);

    return shuffled
        .where((word) => word.length <= gridSize)
        .take(count)
        .map((word) => word.toUpperCase())
        .toList();
  }

  /// Attempts to place a word on the grid
  WordEntity? _placeWordOnGrid(
    List<List<String>> grid,
    String word,
    int gridSize,
  ) {
    final random = Random();
    const maxAttempts = 100;
    final directions = WordDirection.values.toList()..shuffle(random);

    for (final direction in directions) {
      for (int attempt = 0; attempt < maxAttempts ~/ 4; attempt++) {
        final placement = _tryPlacement(grid, word, direction, gridSize);

        if (placement != null) {
          final (positions, startRow, startCol) = placement;

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
    final random = Random();
    late int startRow, startCol;
    final positions = <Position>[];

    // Calculate start position based on direction
    switch (direction) {
      case WordDirection.horizontal:
        if (gridSize < word.length) return null;
        startRow = random.nextInt(gridSize);
        startCol = random.nextInt(gridSize - word.length + 1);

        if (!_canPlaceWord(grid, word, startRow, startCol, 0, 1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow, startCol + i));
        }

      case WordDirection.vertical:
        if (gridSize < word.length) return null;
        startRow = random.nextInt(gridSize - word.length + 1);
        startCol = random.nextInt(gridSize);

        if (!_canPlaceWord(grid, word, startRow, startCol, 1, 0)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol));
        }

      case WordDirection.diagonalDown:
        if (gridSize < word.length) return null;
        startRow = random.nextInt(gridSize - word.length + 1);
        startCol = random.nextInt(gridSize - word.length + 1);

        if (!_canPlaceWord(grid, word, startRow, startCol, 1, 1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow + i, startCol + i));
        }

      case WordDirection.diagonalUp:
        if (gridSize < word.length) return null;
        startRow = random.nextInt(gridSize - word.length + 1) + word.length - 1;
        startCol = random.nextInt(gridSize - word.length + 1);

        if (!_canPlaceWord(grid, word, startRow, startCol, -1, 1)) {
          return null;
        }

        for (int i = 0; i < word.length; i++) {
          positions.add(Position(startRow - i, startCol + i));
        }
    }

    return (positions, startRow, startCol);
  }

  /// Checks if word can be placed at position
  bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    int rowDelta,
    int colDelta,
  ) {
    for (int i = 0; i < word.length; i++) {
      final row = startRow + i * rowDelta;
      final col = startCol + i * colDelta;

      if (grid[row][col] != '' && grid[row][col] != word[i]) {
        return false;
      }
    }
    return true;
  }

  /// Fills empty grid spaces with random letters
  void _fillEmptySpaces(List<List<String>> grid, int gridSize) {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == '') {
          grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }
}

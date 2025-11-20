// Package imports:
import 'package:equatable/equatable.dart';

// Domain imports:
import 'position.dart';
import 'enums.dart';

/// Entity representing the current state of the snake game
class SnakeGameState extends Equatable {
  final List<Position> snake; // Snake body (head is first element)
  final Position foodPosition;
  final Direction direction;
  final int score;
  final int gridSize;
  final SnakeGameStatus gameStatus;
  final SnakeDifficulty difficulty;
  final bool hasWalls; // Whether walls kill the snake (true) or wrap around (false)
  final Set<Position> freePositions; // Cached free positions for performance

  const SnakeGameState({
    required this.snake,
    required this.foodPosition,
    required this.direction,
    required this.score,
    required this.gridSize,
    required this.gameStatus,
    required this.difficulty,
    required this.hasWalls,
    required this.freePositions,
  });

  /// Initial state (not started)
  factory SnakeGameState.initial({
    int gridSize = 20,
    SnakeDifficulty difficulty = SnakeDifficulty.medium,
    bool hasWalls = false,
  }) {
    final center = gridSize ~/ 2;
    final initialSnake = [Position(center, center)];
    final freePositions = _calculateFreePositions(gridSize, initialSnake);

    return SnakeGameState(
      snake: initialSnake,
      foodPosition: Position(center + 5, center),
      direction: Direction.right,
      score: 0,
      gridSize: gridSize,
      gameStatus: SnakeGameStatus.notStarted,
      difficulty: difficulty,
      hasWalls: hasWalls,
      freePositions: freePositions,
    );
  }

  /// Calculates all free positions in the grid (not occupied by snake)
  static Set<Position> _calculateFreePositions(
    int gridSize,
    List<Position> snake,
  ) {
    final freePositions = <Position>{};
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final pos = Position(x, y);
        if (!snake.contains(pos)) {
          freePositions.add(pos);
        }
      }
    }
    return freePositions;
  }

  /// Get snake head position
  Position get head => snake.first;

  /// Get snake length
  int get length => snake.length;

  /// Check if position contains food
  bool isFood(int x, int y) => foodPosition == Position(x, y);

  /// Check if position contains snake
  bool isSnake(int x, int y) => snake.contains(Position(x, y));

  /// Check if position is snake head
  bool isSnakeHead(int x, int y) => head == Position(x, y);

  /// Create a copy with modified fields
  SnakeGameState copyWith({
    List<Position>? snake,
    Position? foodPosition,
    Direction? direction,
    int? score,
    int? gridSize,
    SnakeGameStatus? gameStatus,
    SnakeDifficulty? difficulty,
    bool? hasWalls,
    Set<Position>? freePositions,
  }) {
    // Auto-calculate freePositions if snake changed but freePositions not provided
    final newSnake = snake ?? this.snake;
    final newFreePositions = freePositions ??
        (snake != null ? _calculateFreePositions(gridSize ?? this.gridSize, newSnake) : this.freePositions);

    return SnakeGameState(
      snake: newSnake,
      foodPosition: foodPosition ?? this.foodPosition,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      gridSize: gridSize ?? this.gridSize,
      gameStatus: gameStatus ?? this.gameStatus,
      difficulty: difficulty ?? this.difficulty,
      hasWalls: hasWalls ?? this.hasWalls,
      freePositions: newFreePositions,
    );
  }

  @override
  List<Object?> get props => [
        snake,
        foodPosition,
        direction,
        score,
        gridSize,
        gameStatus,
        difficulty,
        hasWalls,
        freePositions,
      ];
}

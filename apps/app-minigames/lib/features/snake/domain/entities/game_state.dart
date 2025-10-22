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

  const SnakeGameState({
    required this.snake,
    required this.foodPosition,
    required this.direction,
    required this.score,
    required this.gridSize,
    required this.gameStatus,
    required this.difficulty,
  });

  /// Initial state (not started)
  factory SnakeGameState.initial({
    int gridSize = 20,
    SnakeDifficulty difficulty = SnakeDifficulty.medium,
  }) {
    final center = gridSize ~/ 2;
    return SnakeGameState(
      snake: [Position(center, center)],
      foodPosition: Position(center + 5, center),
      direction: Direction.right,
      score: 0,
      gridSize: gridSize,
      gameStatus: SnakeGameStatus.notStarted,
      difficulty: difficulty,
    );
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
  }) {
    return SnakeGameState(
      snake: snake ?? this.snake,
      foodPosition: foodPosition ?? this.foodPosition,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      gridSize: gridSize ?? this.gridSize,
      gameStatus: gameStatus ?? this.gameStatus,
      difficulty: difficulty ?? this.difficulty,
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
      ];
}

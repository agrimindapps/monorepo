import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'grid_entity.dart';

/// Represents the complete state of the game
class GameStateEntity extends Equatable {
  final GridEntity grid;
  final int score;
  final int bestScore;
  final int moves;
  final GameStatus status;
  final BoardSize boardSize;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration pausedDuration;

  const GameStateEntity({
    required this.grid,
    required this.score,
    required this.bestScore,
    required this.moves,
    required this.status,
    required this.boardSize,
    this.startTime,
    this.endTime,
    this.pausedDuration = Duration.zero,
  });

  /// Creates initial game state
  factory GameStateEntity.initial({
    required BoardSize boardSize,
    int bestScore = 0,
  }) {
    return GameStateEntity(
      grid: GridEntity.empty(boardSize.size),
      score: 0,
      bestScore: bestScore,
      moves: 0,
      status: GameStatus.initial,
      boardSize: boardSize,
      startTime: DateTime.now(),
    );
  }

  /// Creates a copy with optional new values
  GameStateEntity copyWith({
    GridEntity? grid,
    int? score,
    int? bestScore,
    int? moves,
    GameStatus? status,
    BoardSize? boardSize,
    DateTime? startTime,
    DateTime? endTime,
    Duration? pausedDuration,
  }) {
    return GameStateEntity(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      moves: moves ?? this.moves,
      status: status ?? this.status,
      boardSize: boardSize ?? this.boardSize,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pausedDuration: pausedDuration ?? this.pausedDuration,
    );
  }

  /// Checks if player has won
  bool get hasWon => grid.has2048Tile;

  /// Checks if game is over
  bool get isGameOver => status == GameStatus.gameOver;

  /// Checks if game is active
  bool get isPlaying => status == GameStatus.playing;

  /// Checks if game is paused
  bool get isPaused => status == GameStatus.paused;

  /// Calculates game duration
  Duration get gameDuration {
    if (startTime == null) return Duration.zero;

    final end = endTime ?? DateTime.now();
    final totalDuration = end.difference(startTime!);

    return totalDuration - pausedDuration;
  }

  /// Updates best score if current score is higher
  GameStateEntity updateBestScore() {
    if (score > bestScore) {
      return copyWith(bestScore: score);
    }
    return this;
  }

  /// Increments move count
  GameStateEntity incrementMoves() {
    return copyWith(moves: moves + 1);
  }

  /// Adds points to score
  GameStateEntity addScore(int points) {
    return copyWith(score: score + points);
  }

  /// Marks game as won
  GameStateEntity markAsWon() {
    return copyWith(
      status: GameStatus.won,
      endTime: DateTime.now(),
    );
  }

  /// Marks game as over
  GameStateEntity markAsGameOver() {
    return copyWith(
      status: GameStatus.gameOver,
      endTime: DateTime.now(),
    );
  }

  /// Pauses the game
  GameStateEntity pause() {
    return copyWith(status: GameStatus.paused);
  }

  /// Resumes the game
  GameStateEntity resume(Duration additionalPausedTime) {
    return copyWith(
      status: GameStatus.playing,
      pausedDuration: pausedDuration + additionalPausedTime,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        score,
        bestScore,
        moves,
        status,
        boardSize,
        startTime,
        endTime,
        pausedDuration,
      ];

  @override
  String toString() =>
      'GameState(score: $score, moves: $moves, status: $status)';
}

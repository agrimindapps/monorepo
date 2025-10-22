import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Immutable entity representing the current state of a TicTacToe game
/// Contains board state, current player, game mode, difficulty and result
class GameState extends Equatable {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameMode gameMode;
  final Difficulty difficulty;
  final GameResult result;
  final List<int>? winningLine;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.gameMode,
    required this.difficulty,
    required this.result,
    this.winningLine,
  });

  /// Factory constructor for initial/empty game state
  factory GameState.initial({
    GameMode gameMode = GameMode.vsPlayer,
    Difficulty difficulty = Difficulty.medium,
  }) {
    return GameState(
      board: List.generate(3, (_) => List.filled(3, Player.none)),
      currentPlayer: Player.x,
      gameMode: gameMode,
      difficulty: difficulty,
      result: GameResult.inProgress,
      winningLine: null,
    );
  }

  // Helper methods (NOT business logic - just computed properties)

  /// Checks if a specific cell is empty
  bool isCellEmpty(int row, int col) => board[row][col] == Player.none;

  /// Checks if the game is still in progress
  bool get isInProgress => result == GameResult.inProgress;

  /// Checks if the game has ended
  bool get isGameOver => result != GameResult.inProgress;

  /// Checks if the board is full
  bool get isBoardFull {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  /// Returns list of available moves (row, col pairs)
  List<List<int>> get availableMoves {
    final moves = <List<int>>[];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          moves.add([i, j]);
        }
      }
    }
    return moves;
  }

  /// Creates a copy of this game state with updated fields
  GameState copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    GameMode? gameMode,
    Difficulty? difficulty,
    GameResult? result,
    List<int>? winningLine,
  }) {
    return GameState(
      board: board ?? this.board.map((row) => List<Player>.from(row)).toList(),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      result: result ?? this.result,
      winningLine: winningLine ?? this.winningLine,
    );
  }

  @override
  List<Object?> get props => [
        board,
        currentPlayer,
        gameMode,
        difficulty,
        result,
        winningLine,
      ];
}

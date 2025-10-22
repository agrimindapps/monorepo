import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for making AI moves based on difficulty level
/// Implements minimax-like strategy with memoization cache
@injectable
class MakeAIMoveUseCase {
  // Cache for memoization of board states
  static final Map<String, List<int>?> _moveCache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;

  /// Makes an AI move based on current difficulty setting
  ///
  /// Difficulty levels:
  /// - Easy: Random moves
  /// - Medium: 50% smart, 50% random
  /// - Hard: Always optimal move
  ///
  /// Returns updated [GameState] with AI move applied
  Future<Either<Failure, GameState>> call(GameState currentState) async {
    // Validation: Game must be in progress
    if (!currentState.isInProgress) {
      return const Left(
        GameLogicFailure('Game is not in progress'),
      );
    }

    // Validation: Must be in vsComputer mode
    if (currentState.gameMode != GameMode.vsComputer) {
      return const Left(
        GameLogicFailure('AI moves only available in vsComputer mode'),
      );
    }

    // Get best move based on difficulty
    final move = _getBestMove(currentState);

    if (move == null) {
      return const Left(
        GameLogicFailure('No available moves'),
      );
    }

    // Execute move
    final newBoard = List.generate(
      3,
      (i) => List<Player>.from(currentState.board[i]),
    );
    newBoard[move[0]][move[1]] = currentState.currentPlayer;

    // Return new state with move applied
    return Right(
      currentState.copyWith(
        board: newBoard,
        currentPlayer: currentState.currentPlayer.opponent,
      ),
    );
  }

  /// Gets best move based on difficulty level
  List<int>? _getBestMove(GameState state) {
    switch (state.difficulty) {
      case Difficulty.easy:
        return _getRandomMove(state);
      case Difficulty.medium:
        // 50% chance of smart move, 50% random
        return Random().nextBool()
            ? _getSmartMove(state)
            : _getRandomMove(state);
      case Difficulty.hard:
        return _getSmartMove(state);
    }
  }

  /// Returns a random available move
  List<int>? _getRandomMove(GameState state) {
    final availableMoves = state.availableMoves;

    if (availableMoves.isEmpty) {
      return null;
    }

    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  /// Returns optimal move using strategy with memoization
  List<int>? _getSmartMove(GameState state) {
    final stateKey = _getBoardStateKey(state);

    // Check cache first
    if (_moveCache.containsKey(stateKey)) {
      _cacheHits++;
      return _moveCache[stateKey];
    }

    _cacheMisses++;
    List<int>? bestMove;

    // Priority 1: Find winning move
    bestMove = _findWinningMove(state);
    if (bestMove != null) {
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }

    // Priority 2: Block opponent's winning move
    bestMove = _findBlockingMove(state);
    if (bestMove != null) {
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }

    // Priority 3: Take center if available
    if (state.board[1][1] == Player.none) {
      bestMove = [1, 1];
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }

    // Priority 4: Take a corner
    final corners = [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2]
    ];
    for (final corner in corners) {
      if (state.board[corner[0]][corner[1]] == Player.none) {
        bestMove = corner;
        _moveCache[stateKey] = bestMove;
        return bestMove;
      }
    }

    // Priority 5: Random move
    bestMove = _getRandomMove(state);
    _moveCache[stateKey] = bestMove;
    return bestMove;
  }

  /// Finds a move that would win the game
  List<int>? _findWinningMove(GameState state) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state.board[i][j] == Player.none) {
          // Test move
          final testBoard = List.generate(
            3,
            (idx) => List<Player>.from(state.board[idx]),
          );
          testBoard[i][j] = state.currentPlayer;

          final testState = state.copyWith(board: testBoard);

          // Check if this move wins
          if (_wouldWin(testState, state.currentPlayer)) {
            return [i, j];
          }
        }
      }
    }
    return null;
  }

  /// Finds a move that blocks opponent from winning
  List<int>? _findBlockingMove(GameState state) {
    final opponent = state.currentPlayer.opponent;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state.board[i][j] == Player.none) {
          // Test opponent's move
          final testBoard = List.generate(
            3,
            (idx) => List<Player>.from(state.board[idx]),
          );
          testBoard[i][j] = opponent;

          final testState = state.copyWith(board: testBoard);

          // Check if opponent would win
          if (_wouldWin(testState, opponent)) {
            return [i, j];
          }
        }
      }
    }
    return null;
  }

  /// Checks if a player would win with given board state
  bool _wouldWin(GameState state, Player player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (state.board[i][0] == player &&
          state.board[i][1] == player &&
          state.board[i][2] == player) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (state.board[0][i] == player &&
          state.board[1][i] == player &&
          state.board[2][i] == player) {
        return true;
      }
    }

    // Check diagonals
    if (state.board[0][0] == player &&
        state.board[1][1] == player &&
        state.board[2][2] == player) {
      return true;
    }

    if (state.board[0][2] == player &&
        state.board[1][1] == player &&
        state.board[2][0] == player) {
      return true;
    }

    return false;
  }

  /// Generates unique key for board state (for memoization)
  String _getBoardStateKey(GameState state) {
    final buffer = StringBuffer();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        buffer.write(state.board[i][j].index);
      }
    }
    buffer.write(state.currentPlayer.index);
    return buffer.toString();
  }

  /// Clears the memoization cache (call when restarting game)
  static void clearCache() {
    _moveCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Gets cache hit rate for performance monitoring
  static double get cacheHitRate {
    final total = _cacheHits + _cacheMisses;
    return total > 0 ? _cacheHits / total : 0.0;
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for checking if the game has ended (win/draw)
/// Checks all winning conditions and updates game result
@injectable
class CheckGameResultUseCase {
  /// Checks current board state for game end conditions
  ///
  /// Returns updated [GameState] with:
  /// - Updated result (xWins, oWins, draw, or inProgress)
  /// - Winning line indices (if there's a winner)
  Future<Either<Failure, GameState>> call(GameState currentState) async {
    // Check rows for winner
    for (int i = 0; i < 3; i++) {
      if (currentState.board[i][0] != Player.none &&
          currentState.board[i][0] == currentState.board[i][1] &&
          currentState.board[i][0] == currentState.board[i][2]) {
        final winner = currentState.board[i][0];
        return Right(
          currentState.copyWith(
            result: winner == Player.x ? GameResult.xWins : GameResult.oWins,
            winningLine: [i * 3, i * 3 + 1, i * 3 + 2],
          ),
        );
      }
    }

    // Check columns for winner
    for (int i = 0; i < 3; i++) {
      if (currentState.board[0][i] != Player.none &&
          currentState.board[0][i] == currentState.board[1][i] &&
          currentState.board[0][i] == currentState.board[2][i]) {
        final winner = currentState.board[0][i];
        return Right(
          currentState.copyWith(
            result: winner == Player.x ? GameResult.xWins : GameResult.oWins,
            winningLine: [i, i + 3, i + 6],
          ),
        );
      }
    }

    // Check main diagonal
    if (currentState.board[0][0] != Player.none &&
        currentState.board[0][0] == currentState.board[1][1] &&
        currentState.board[0][0] == currentState.board[2][2]) {
      final winner = currentState.board[0][0];
      return Right(
        currentState.copyWith(
          result: winner == Player.x ? GameResult.xWins : GameResult.oWins,
          winningLine: [0, 4, 8],
        ),
      );
    }

    // Check secondary diagonal
    if (currentState.board[0][2] != Player.none &&
        currentState.board[0][2] == currentState.board[1][1] &&
        currentState.board[0][2] == currentState.board[2][0]) {
      final winner = currentState.board[0][2];
      return Right(
        currentState.copyWith(
          result: winner == Player.x ? GameResult.xWins : GameResult.oWins,
          winningLine: [2, 4, 6],
        ),
      );
    }

    // Check for draw (board full with no winner)
    if (currentState.isBoardFull) {
      return Right(
        currentState.copyWith(result: GameResult.draw),
      );
    }

    // Game still in progress
    return Right(currentState);
  }
}

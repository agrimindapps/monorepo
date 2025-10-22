import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for making a move in the TicTacToe game
/// Validates move and returns updated game state
@injectable
class MakeMoveUseCase {
  /// Makes a move at the specified position
  ///
  /// Validates:
  /// - Game is in progress
  /// - Cell is empty
  ///
  /// Returns updated [GameState] with:
  /// - Move placed on board
  /// - Current player switched (if game continues)
  Future<Either<Failure, GameState>> call({
    required GameState currentState,
    required int row,
    required int col,
  }) async {
    // Validation: Game must be in progress
    if (!currentState.isInProgress) {
      return const Left(
        GameLogicFailure('Game is not in progress'),
      );
    }

    // Validation: Row and col must be valid
    if (row < 0 || row > 2 || col < 0 || col > 2) {
      return const Left(
        ValidationFailure('Invalid board position'),
      );
    }

    // Validation: Cell must be empty
    if (!currentState.isCellEmpty(row, col)) {
      return const Left(
        GameLogicFailure('Cell is not empty'),
      );
    }

    // Execute move
    final newBoard = List.generate(
      3,
      (i) => List<Player>.from(currentState.board[i]),
    );
    newBoard[row][col] = currentState.currentPlayer;

    // Return new state (switching player)
    // Note: Game result checking is done in CheckGameResultUseCase
    return Right(
      currentState.copyWith(
        board: newBoard,
        currentPlayer: currentState.currentPlayer.opponent,
      ),
    );
  }
}

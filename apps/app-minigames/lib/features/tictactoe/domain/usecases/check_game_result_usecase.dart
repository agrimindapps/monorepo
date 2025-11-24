import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../services/game_result_validation_service.dart';

/// Use case for checking if the game has ended (win/draw)
/// Checks all winning conditions and updates game result
class CheckGameResultUseCase {
  final GameResultValidationService _validationService;

  CheckGameResultUseCase(this._validationService);

  /// Checks current board state for game end conditions
  ///
  /// Returns updated [GameState] with:
  /// - Updated result (xWins, oWins, draw, or inProgress)
  /// - Winning line indices (if there's a winner)
  Future<Either<Failure, GameState>> call(GameState currentState) async {
    // Check for winner using service
    final winResult = _validationService.checkForWinner(currentState.board);

    if (winResult.hasWinner) {
      return Right(
        currentState.copyWith(
          result: winResult.result,
          winningLine: winResult.winningLine,
        ),
      );
    }

    // Check for draw (board full with no winner)
    if (currentState.isBoardFull) {
      return Right(currentState.copyWith(result: GameResult.draw));
    }

    // Game still in progress
    return Right(currentState);
  }
}

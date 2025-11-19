import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../services/ai_move_strategy_service.dart';

/// Use case for making AI moves based on difficulty level
/// Implements minimax-like strategy with memoization cache
@injectable
class MakeAIMoveUseCase {
  final AIMoveStrategyService _aiStrategyService;

  MakeAIMoveUseCase(this._aiStrategyService);

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

    // Get best move using service
    final moveResult = _aiStrategyService.getBestMove(
      board: currentState.board,
      currentPlayer: currentState.currentPlayer,
      difficulty: currentState.difficulty,
    );

    if (moveResult == null) {
      return const Left(
        GameLogicFailure('No available moves'),
      );
    }

    // Execute move
    final newBoard = List.generate(
      3,
      (i) => List<Player>.from(currentState.board[i]),
    );
    newBoard[moveResult.row][moveResult.col] = currentState.currentPlayer;

    // Return new state with move applied
    return Right(
      currentState.copyWith(
        board: newBoard,
        currentPlayer: currentState.currentPlayer.opponent,
      ),
    );
  }
}





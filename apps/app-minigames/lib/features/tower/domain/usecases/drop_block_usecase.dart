import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/block_data.dart';

/// Use case for dropping the current block
/// Contains core game logic: overlap calculation, precision, combo, and scoring
@injectable
class DropBlockUseCase {
  DropBlockUseCase();

  Future<Either<Failure, GameState>> call(GameState currentState) async {
    // Validate state
    if (currentState.isPaused) {
      return const Left(GameLogicFailure('Cannot drop block when paused'));
    }

    if (currentState.isGameOver) {
      return const Left(GameLogicFailure('Cannot drop block when game is over'));
    }

    // Calculate overlap (how much the current block overlaps with the last one)
    final overlap = currentState.currentBlockWidth -
        (currentState.currentBlockPosX - currentState.lastBlockX).abs();

    // Game Over if no overlap
    if (overlap <= 0) {
      return Right(currentState.copyWith(
        isGameOver: true,
        isPerfectPlacement: false,
      ));
    }

    // Calculate precision (0.0 to 1.0)
    final precision = overlap / currentState.currentBlockWidth;

    // Base score from precision
    var dropScore = (precision * 10).round();

    // Check for perfect placement (>= 90% precision)
    final isPerfect = precision >= 0.9;

    // Update combo
    final newCombo = isPerfect ? currentState.combo + 1 : 0;

    // Apply combo multiplier to score
    if (isPerfect && newCombo > 0) {
      dropScore = dropScore * newCombo;
    }

    // Create new block with calculated width
    final newBlock = BlockData(
      width: overlap,
      height: GameState.blockHeight,
      posX: currentState.currentBlockPosX,
      color: GameState.blockColors[
          currentState.blocks.length % GameState.blockColors.length],
    );

    // Calculate speed increment based on difficulty
    final speedIncrement = 0.2 * currentState.difficulty.speedMultiplier;

    // Return new state
    return Right(currentState.copyWith(
      blocks: [...currentState.blocks, newBlock],
      currentBlockWidth: overlap,
      lastBlockX: currentState.currentBlockPosX,
      score: currentState.score + dropScore,
      combo: newCombo,
      lastDropScore: dropScore,
      isPerfectPlacement: isPerfect,
      blockSpeed: currentState.blockSpeed + speedIncrement,
    ));
  }
}

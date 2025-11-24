import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../services/overlap_calculation_service.dart';
import '../services/scoring_service.dart';
import '../services/physics_service.dart';
import '../services/block_generation_service.dart';

/// Use case for dropping the current block
/// Orchestrates services for overlap, scoring, and block generation
class DropBlockUseCase {
  final OverlapCalculationService _overlapService;
  final ScoringService _scoringService;
  final PhysicsService _physicsService;
  final BlockGenerationService _blockGenerationService;

  DropBlockUseCase(
    this._overlapService,
    this._scoringService,
    this._physicsService,
    this._blockGenerationService,
  );

  Future<Either<Failure, GameState>> call(GameState currentState) async {
    // Validate state
    if (currentState.isPaused) {
      return const Left(GameLogicFailure('Cannot drop block when paused'));
    }

    if (currentState.isGameOver) {
      return const Left(
          GameLogicFailure('Cannot drop block when game is over'));
    }

    // Calculate overlap and precision using service
    final overlapResult = _overlapService.calculateOverlap(
      currentBlockWidth: currentState.currentBlockWidth,
      currentBlockPosX: currentState.currentBlockPosX,
      lastBlockX: currentState.lastBlockX,
    );

    // Game over if no overlap
    if (overlapResult.isGameOver) {
      return Right(currentState.copyWith(
        isGameOver: true,
        isPerfectPlacement: false,
      ));
    }

    // Calculate score and combo using service
    final scoreResult = _scoringService.calculateScore(
      precision: overlapResult.precision,
      isPerfect: overlapResult.isPerfect,
      currentCombo: currentState.combo,
      currentTotalScore: currentState.score,
    );

    // Calculate aligned position for placed block
    final alignedPosX = _overlapService.calculateAlignedPosition(
      currentBlockPosX: currentState.currentBlockPosX,
      lastBlockX: currentState.lastBlockX,
      currentBlockWidth: currentState.currentBlockWidth,
      overlap: overlapResult.overlap,
    );

    // Get next color index
    final colorIndex =
        _blockGenerationService.getNextColorIndex(currentState.blocks);

    // Create placed block
    final placedBlockResult = _blockGenerationService.createBlock(
      width: overlapResult.overlap,
      posX: alignedPosX,
      colorIndex: colorIndex,
    );

    // Increase speed progressively using physics service
    final speedResult = _physicsService.calculateSpeedIncrease(
      currentSpeed: currentState.blockSpeed,
      difficulty: currentState.difficulty,
    );

    // Return new state
    return Right(currentState.copyWith(
      blocks: [...currentState.blocks, placedBlockResult.block],
      currentBlockWidth: overlapResult.overlap,
      lastBlockX: alignedPosX,
      score: scoreResult.totalScore,
      combo: scoreResult.combo,
      lastDropScore: scoreResult.dropScore,
      isPerfectPlacement: overlapResult.isPerfect,
      blockSpeed: speedResult.newSpeed,
    ));
  }
}

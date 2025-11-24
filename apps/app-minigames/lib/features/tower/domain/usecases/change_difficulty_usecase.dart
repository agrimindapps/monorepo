import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../services/physics_service.dart';

/// Use case for changing game difficulty
/// Updates difficulty and recalculates speed using PhysicsService
class ChangeDifficultyUseCase {
  final PhysicsService _physicsService;

  ChangeDifficultyUseCase(this._physicsService);

  Either<Failure, GameState> call({
    required GameState currentState,
    required GameDifficulty difficulty,
  }) {
    // Recalculate block speed based on new difficulty using physics service
    final newSpeed = _physicsService.calculateDifficultySpeedAdjustment(
      currentSpeed: currentState.blockSpeed,
      currentDifficulty: currentState.difficulty,
      newDifficulty: difficulty,
      baseSpeed: 5.0,
    );

    return Right(currentState.copyWith(
      difficulty: difficulty,
      blockSpeed: newSpeed,
    ));
  }
}

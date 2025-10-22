import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case for starting a new game
/// Resets all game state to initial values
@injectable
class StartNewGameUseCase {
  StartNewGameUseCase();

  Either<Failure, GameState> call({
    required double screenWidth,
    GameDifficulty? difficulty,
  }) {
    return Right(GameState.initial(
      screenWidth: screenWidth,
      difficulty: difficulty ?? GameDifficulty.medium,
    ));
  }
}

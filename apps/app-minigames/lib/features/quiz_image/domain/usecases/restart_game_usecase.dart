import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Use case that restarts the game with new questions
/// Returns a fresh game state in ready state
@injectable
class RestartGameUseCase {
  RestartGameUseCase();

  Either<Failure, QuizGameState> call({
    required GameDifficulty difficulty,
  }) {
    // Simply return a new initial state
    return Right(QuizGameState.initial(difficulty));
  }
}

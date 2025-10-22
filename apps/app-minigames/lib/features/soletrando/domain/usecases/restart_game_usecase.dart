import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../repositories/soletrando_repository.dart';

import 'generate_word_usecase.dart';

/// Parameters for restarting game
class RestartGameParams {
  final GameDifficulty difficulty;
  final WordCategory category;
  final bool keepScore;

  const RestartGameParams({
    required this.difficulty,
    required this.category,
    this.keepScore = false,
  });
}

/// Use case to restart the game with new settings
class RestartGameUseCase {
  final SoletrandoRepository repository;

  RestartGameUseCase(this.repository);

  Future<Either<Failure, GameStateEntity>> call(RestartGameParams params) async {
    // Generate first word
    final generateUseCase = GenerateWordUseCase(repository);
    final wordResult = await generateUseCase(GenerateWordParams(
      difficulty: params.difficulty,
      category: params.category,
    ));

    return wordResult.fold(
      (failure) => Left(failure),
      (word) {
        // Create fresh game state
        return Right(
          GameStateEntity.forWord(
            word: word,
            difficulty: params.difficulty,
            score: params.keepScore ? 0 : 0, // Always reset for now
            wordsCompleted: 0,
          ),
        );
      },
    );
  }
}

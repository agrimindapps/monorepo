import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../entities/word_entity.dart';
import '../repositories/soletrando_repository.dart';

import 'generate_word_usecase.dart';

/// Use case to skip current word and get next word
class SkipWordUseCase {
  final SoletrandoRepository repository;

  SkipWordUseCase(this.repository);

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    // Validation: game must be active
    if (!state.isActive) {
      return const Left(
        ValidationFailure('Jogo não está ativo'),
      );
    }

    // Generate new word
    final generateUseCase = GenerateWordUseCase(repository);
    final wordResult = await generateUseCase(GenerateWordParams(
      difficulty: state.difficulty,
      category: state.currentWord.category,
    ));

    return wordResult.fold(
      (failure) => Left(failure),
      (newWord) {
        // Create new game state for the new word, keeping score and words completed
        final newState = GameStateEntity.forWord(
          word: newWord,
          difficulty: state.difficulty,
          score: state.score,
          wordsCompleted: state.wordsCompleted,
        );

        // Penalize for skipping (reduce score)
        final skipPenalty = 50 * state.difficulty.scoreMultiplier;
        final newScore = (state.score - skipPenalty).clamp(0, double.infinity).toInt();

        return Right(newState.copyWith(score: newScore));
      },
    );
  }
}

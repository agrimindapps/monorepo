import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/game_state.dart';

/// Toggles word highlight in the word list
class ToggleWordHighlightUseCase {
  Either<Failure, GameState> call({
    required GameState currentState,
    required int wordIndex,
  }) {
    try {
      // Validate index
      if (wordIndex < 0 || wordIndex >= currentState.words.length) {
        return const Left(ValidationFailure('Invalid word index'));
      }

      final targetWord = currentState.words[wordIndex];

      // Cannot highlight found words
      if (targetWord.isFound) {
        return Right(currentState);
      }

      // Remove all other highlights and toggle target
      final updatedWords = currentState.words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;

        if (index == wordIndex) {
          return word.copyWith(isHighlighted: !word.isHighlighted);
        } else {
          return word.copyWith(isHighlighted: false);
        }
      }).toList();

      return Right(currentState.copyWith(words: updatedWords));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to toggle highlight: ${e.toString()}'));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';
import '../entities/word_entity.dart';

/// Checks if selected positions match any word and updates game state
class CheckWordMatchUseCase {
  Either<Failure, GameState> call({
    required GameState currentState,
  }) {
    try {
      // Need at least 2 positions to form a word
      if (currentState.selectedPositions.length < 2) {
        return Right(currentState.copyWith(selectedPositions: []));
      }

      // Check each word for match
      final updatedWords = List<WordEntity>.from(currentState.words);
      int foundCount = currentState.foundWordsCount;

      for (int i = 0; i < updatedWords.length; i++) {
        final word = updatedWords[i];

        if (!word.isFound && word.matchesPositions(currentState.selectedPositions)) {
          // Mark word as found
          updatedWords[i] = word.copyWith(isFound: true);
          foundCount++;
          break; // Only match one word per selection
        }
      }

      // Check if game is completed
      final status = foundCount == updatedWords.length
          ? GameStatus.completed
          : GameStatus.playing;

      // Clear selection after checking
      return Right(
        currentState.copyWith(
          words: updatedWords,
          foundWordsCount: foundCount,
          status: status,
          selectedPositions: [],
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check word match: ${e.toString()}'));
    }
  }
}

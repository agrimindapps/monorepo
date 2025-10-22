import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../entities/letter_entity.dart';
import '../repositories/soletrando_repository.dart';

/// Parameters for checking a letter
class CheckLetterParams {
  final GameStateEntity currentState;
  final String letter;

  const CheckLetterParams({
    required this.currentState,
    required this.letter,
  });
}

/// Use case to check if a guessed letter is in the word
class CheckLetterUseCase {
  CheckLetterUseCase();

  Future<Either<Failure, GameStateEntity>> call(CheckLetterParams params) async {
    final state = params.currentState;
    final letter = params.letter.toUpperCase().trim();

    // Validation: game must be active
    if (!state.isActive) {
      return const Left(
        ValidationFailure('Jogo não está ativo'),
      );
    }

    // Validation: letter must be single character
    if (letter.length != 1) {
      return const Left(
        ValidationFailure('Deve fornecer apenas uma letra'),
      );
    }

    // Validation: letter must be alphabetic
    if (!RegExp(r'^[A-ZÁÀÂÃÉÊÍÓÔÕÚÇ]$').hasMatch(letter)) {
      return const Left(
        ValidationFailure('Letra inválida'),
      );
    }

    // Validation: letter not already guessed
    if (state.wasLetterGuessed(letter)) {
      return const Left(
        ValidationFailure('Letra já foi tentada'),
      );
    }

    // Check if letter exists in word
    final wordContainsLetter = state.currentWord.containsLetter(letter);

    // Update guessed letters
    final newGuessedLetters = Set<String>.from(state.guessedLetters)
      ..add(letter);

    if (wordContainsLetter) {
      // Letter is correct - reveal all occurrences
      final positions = state.currentWord.getLetterPositions(letter);
      final updatedLetters = List<LetterEntity>.from(state.letters);

      for (final pos in positions) {
        updatedLetters[pos] = updatedLetters[pos].copyWith(
          state: LetterState.correct,
        );
      }

      // Check if word is complete
      final isComplete = updatedLetters.every((l) => l.isRevealed);
      final newStatus = isComplete ? GameStatus.wordCompleted : state.status;

      // Calculate score bonus if word completed
      int scoreBonus = 0;
      if (isComplete) {
        final timeBonus = state.timeRemaining * 2;
        final mistakePenalty = state.mistakes * 5;
        final baseScore = 100;
        scoreBonus = (baseScore + timeBonus - mistakePenalty) *
            state.difficulty.scoreMultiplier;
      }

      return Right(
        state.copyWith(
          letters: updatedLetters,
          guessedLetters: newGuessedLetters,
          status: newStatus,
          score: state.score + scoreBonus,
          wordsCompleted: isComplete ? state.wordsCompleted + 1 : state.wordsCompleted,
        ),
      );
    } else {
      // Letter is incorrect - increment mistakes
      final newMistakes = state.mistakes + 1;
      final maxMistakes = state.difficulty.mistakesAllowed;
      final newStatus =
          newMistakes >= maxMistakes ? GameStatus.gameOver : state.status;

      return Right(
        state.copyWith(
          mistakes: newMistakes,
          guessedLetters: newGuessedLetters,
          status: newStatus,
        ),
      );
    }
  }
}

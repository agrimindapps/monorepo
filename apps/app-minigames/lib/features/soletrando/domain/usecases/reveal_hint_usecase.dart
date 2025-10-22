import 'dart:math';

import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../entities/letter_entity.dart';
import '../repositories/soletrando_repository.dart';

/// Use case to reveal a random hidden letter as a hint
class RevealHintUseCase {
  RevealHintUseCase();

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    // Validation: game must be active
    if (!state.isActive) {
      return const Left(
        ValidationFailure('Jogo não está ativo'),
      );
    }

    // Validation: hints available
    if (!state.canUseHint) {
      return const Left(
        ValidationFailure('Sem dicas disponíveis'),
      );
    }

    // Find all pending (unrevealed) letters
    final pendingIndices = <int>[];
    for (int i = 0; i < state.letters.length; i++) {
      if (!state.letters[i].isRevealed) {
        pendingIndices.add(i);
      }
    }

    // Should always have pending letters if canUseHint is true
    if (pendingIndices.isEmpty) {
      return const Left(
        ValidationFailure('Não há letras para revelar'),
      );
    }

    // Select random pending letter
    final randomIndex = pendingIndices[Random().nextInt(pendingIndices.length)];
    final updatedLetters = List<LetterEntity>.from(state.letters);

    // Reveal the letter
    updatedLetters[randomIndex] = updatedLetters[randomIndex].copyWith(
      state: LetterState.revealed,
    );

    // Add revealed letter to guessed letters
    final revealedLetter = state.letters[randomIndex].letter;
    final newGuessedLetters = Set<String>.from(state.guessedLetters)
      ..add(revealedLetter);

    return Right(
      state.copyWith(
        letters: updatedLetters,
        hintsUsed: state.hintsUsed + 1,
        guessedLetters: newGuessedLetters,
      ),
    );
  }
}

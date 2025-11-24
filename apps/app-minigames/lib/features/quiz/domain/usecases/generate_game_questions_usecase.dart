// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/quiz_question.dart';
import '../repositories/quiz_repository.dart';

/// Use case to generate quiz questions for a new game
class GenerateGameQuestionsUseCase {
  final QuizRepository repository;

  GenerateGameQuestionsUseCase(this.repository);

  /// Execute the use case
  /// Returns all available questions (3 questions hardcoded)
  Future<Either<Failure, List<QuizQuestion>>> call() async {
    // Get all questions from repository
    final result = await repository.getQuestions();

    return result.fold(
      (failure) => Left(failure),
      (questions) {
        // Validation: must have at least 1 question
        if (questions.isEmpty) {
          return Left(ValidationFailure('No questions available'));
        }

        // Return all questions (no random selection for quiz)
        return Right(questions);
      },
    );
  }
}

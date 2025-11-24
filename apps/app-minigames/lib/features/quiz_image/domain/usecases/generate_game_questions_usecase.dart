import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/quiz_question.dart';
import '../repositories/quiz_image_repository.dart';

/// Use case that generates a randomized set of quiz questions
/// Selects 10 random questions from available pool and adjusts options based on difficulty
class GenerateGameQuestionsUseCase {
  final QuizImageRepository repository;

  GenerateGameQuestionsUseCase(this.repository);

  Either<Failure, List<QuizQuestion>> call(GameDifficulty difficulty) {
    // Load all available questions
    final questionsResult = repository.getAvailableQuestions();

    return questionsResult.fold(
      (failure) => Left(failure),
      (allQuestions) {
        // Validate we have enough questions
        if (allQuestions.length < 10) {
          return const Left(
            DataFailure('Insufficient questions'),
          );
        }

        // Shuffle and select 10 questions
        final shuffled = List<QuizQuestion>.from(allQuestions)..shuffle();
        final selected = shuffled.take(10).toList();

        // Adjust number of options based on difficulty
        final adjusted = selected.map((question) {
          final optionsCount = difficulty.optionsCount;

          // If question already has fewer options than required, keep all
          if (question.options.length <= optionsCount) {
            return question;
          }

          // Create new options list with correct answer
          final adjustedOptions = <String>[question.correctAnswer];

          // Get other options (excluding correct answer)
          final otherOptions = question.options
              .where((option) => option != question.correctAnswer)
              .toList();

          // Shuffle and take required number of wrong options
          otherOptions.shuffle();
          adjustedOptions.addAll(otherOptions.take(optionsCount - 1));

          // Shuffle final options so correct answer is not always first
          adjustedOptions.shuffle();

          return QuizQuestion(
            id: question.id,
            question: question.question,
            imageUrl: question.imageUrl,
            options: adjustedOptions,
            correctAnswer: question.correctAnswer,
            explanation: question.explanation,
          );
        }).toList();

        return Right(adjusted);
      },
    );
  }
}

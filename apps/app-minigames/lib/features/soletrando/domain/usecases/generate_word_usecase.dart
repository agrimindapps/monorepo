import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/word_entity.dart';
import '../repositories/soletrando_repository.dart';

/// Parameters for generating a word
class GenerateWordParams {
  final GameDifficulty difficulty;
  final WordCategory category;

  const GenerateWordParams({
    required this.difficulty,
    required this.category,
  });
}

/// Use case to generate/fetch a random word for gameplay
class GenerateWordUseCase {
  final SoletrandoRepository repository;

  GenerateWordUseCase(this.repository);

  Future<Either<Failure, WordEntity>> call(GenerateWordParams params) async {
    final result = await repository.getRandomWord(
      difficulty: params.difficulty,
      category: params.category,
    );

    return result.fold(
      (failure) => Left(failure),
      (word) {
        // Validate word is not empty
        if (word.word.isEmpty) {
          return const Left(ValidationFailure('Palavra gerada está vazia'));
        }

        // Validate word has minimum length
        if (word.word.length < 2) {
          return const Left(
            ValidationFailure('Palavra deve ter pelo menos 2 letras'),
          );
        }

        return Right(word);
      },
    );
  }
}

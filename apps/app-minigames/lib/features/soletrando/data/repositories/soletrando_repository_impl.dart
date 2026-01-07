import 'package:dartz/dartz.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/soletrando_repository.dart';
import '../datasources/soletrando_local_datasource.dart';
import '../datasources/soletrando_words_datasource.dart';
import '../models/high_score_model.dart';

/// Implementation of SoletrandoRepository
class SoletrandoRepositoryImpl implements SoletrandoRepository {
  final SoletrandoLocalDataSource localDataSource;
  final SoletrandoWordsDataSource wordsDataSource;

  SoletrandoRepositoryImpl({
    required this.localDataSource,
    required this.wordsDataSource,
  });

  @override
  Future<Either<Failure, WordEntity>> getRandomWord({
    required GameDifficulty difficulty,
    required WordCategory category,
  }) async {
    try {
      final word = await wordsDataSource.getRandomWord(
        category: category,
        difficulty: difficulty,
      );

      if (word.word.isEmpty) {
        return const Left(
          NotFoundFailure('Nenhuma palavra encontrada para categoria/dificuldade'),
        );
      }

      return Right(word);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar palavra: $e'));
    }
  }

  @override
  Future<Either<Failure, HighScoresCollection>> loadHighScores() async {
    try {
      final highScores = await localDataSource.loadHighScores();
      return Right(highScores);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar pontuações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(HighScoreEntity highScore) async {
    try {
      // Load existing scores
      final existingScores = await localDataSource.loadHighScores();

      // Update score for specific difficulty
      final updatedScores = existingScores.updateForDifficulty(
        highScore.difficulty,
        HighScoreModel.fromEntity(highScore),
      );

      // Save updated collection
      await localDataSource.saveHighScores(
        HighScoresCollectionModel.fromEntity(updatedScores),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar pontuação: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loadSettings() async {
    try {
      final settings = await localDataSource.loadSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      await localDataSource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar configurações: $e'));
    }
  }
}

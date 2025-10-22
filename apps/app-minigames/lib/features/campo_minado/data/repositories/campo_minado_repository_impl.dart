import 'package:core/core.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/campo_minado_repository.dart';
import '../datasources/campo_minado_local_data_source.dart';
import '../models/game_stats_model.dart';

/// Implementation of Campo Minado repository
class CampoMinadoRepositoryImpl implements CampoMinadoRepository {
  final CampoMinadoLocalDataSource _localDataSource;

  const CampoMinadoRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, GameStats>> loadStats(Difficulty difficulty) async {
    try {
      final stats = await _localDataSource.loadStats(difficulty);
      return Right(stats);
    } catch (e) {
      return Left(
        CacheFailure('Falha ao carregar estatísticas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveStats(GameStats stats) async {
    try {
      // Convert entity to model before saving
      final model = stats is GameStatsModel
          ? stats
          : GameStatsModel.fromEntity(stats);

      await _localDataSource.saveStats(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Falha ao salvar estatísticas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetStats(Difficulty difficulty) async {
    try {
      await _localDataSource.resetStats(difficulty);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Falha ao resetar estatísticas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, GameStats>> loadGlobalStats() async {
    try {
      final stats = await _localDataSource.loadGlobalStats();
      return Right(stats);
    } catch (e) {
      return Left(
        CacheFailure('Falha ao carregar estatísticas globais: ${e.toString()}'),
      );
    }
  }
}

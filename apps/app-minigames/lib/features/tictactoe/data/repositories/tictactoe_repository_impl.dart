import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game_settings.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/repositories/tictactoe_repository.dart';
import '../datasources/tictactoe_local_data_source.dart';
import '../models/game_settings_model.dart';
import '../models/game_stats_model.dart';

/// Implementation of TicTacToeRepository using local data source
@LazySingleton(as: TicTacToeRepository)
class TicTacToeRepositoryImpl implements TicTacToeRepository {
  final TicTacToeLocalDataSource localDataSource;

  TicTacToeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, GameStats>> getStats() async {
    try {
      final stats = await localDataSource.getStats();
      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to load stats'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error loading stats: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStats(GameStats stats) async {
    try {
      final model = GameStatsModel.fromEntity(stats);
      await localDataSource.saveStats(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to save stats'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error saving stats: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetStats() async {
    try {
      await localDataSource.resetStats();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to reset stats'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error resetting stats: $e'));
    }
  }

  @override
  Future<Either<Failure, GameSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to load settings'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error loading settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(GameSettings settings) async {
    try {
      final model = GameSettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to save settings'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error saving settings: $e'));
    }
  }
}

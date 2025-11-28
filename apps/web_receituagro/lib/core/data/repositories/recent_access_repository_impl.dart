import 'package:dartz/dartz.dart';

import '../../domain/entities/recent_access.dart';
import '../../domain/repositories/recent_access_repository.dart';
import '../../error/failures.dart';
import '../datasources/recent_access_local_datasource.dart';

/// Implementation of RecentAccessRepository
class RecentAccessRepositoryImpl implements RecentAccessRepository {
  final RecentAccessLocalDataSource _localDataSource;

  RecentAccessRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<RecentAccess>>> getRecentDefensivos() async {
    try {
      final result =
          await _localDataSource.getRecentByType(RecentAccessType.defensivo);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar defensivos recentes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecentAccess>>> getRecentPragas() async {
    try {
      final result =
          await _localDataSource.getRecentByType(RecentAccessType.praga);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar pragas recentes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addRecentAccess(RecentAccess access) async {
    try {
      await _localDataSource.addRecentAccess(access);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao registrar acesso: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory(RecentAccessType type) async {
    try {
      await _localDataSource.clearHistory(type);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllHistory() async {
    try {
      await _localDataSource.clearAllHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar todo o histórico: $e'));
    }
  }
}

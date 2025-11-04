import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/pragas_repository.dart';
import '../datasources/pragas_local_datasource.dart';
import '../datasources/pragas_remote_datasource.dart';

/// Pragas repository implementation
///
/// Implements IPragasRepository with offline-first caching strategy
class PragasRepositoryImpl implements IPragasRepository {
  final PragasRemoteDataSource _remoteDataSource;
  final PragasLocalDataSource _localDataSource;

  PragasRepositoryImpl({
    required PragasRemoteDataSource remoteDataSource,
    required PragasLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<PragaEntity>>> getPragas() async {
    try {
      // Try to fetch from remote
      final remoteList = await _remoteDataSource.getPragas();

      // Cache the results
      await _localDataSource.cachePragas(remoteList);

      // Return as entities
      return Right(remoteList.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      // On server error, try to fetch from cache
      try {
        final cachedList = await _localDataSource.getCachedPragas();
        return Right(cachedList.map((e) => e.toEntity()).toList());
      } on CacheException {
        // No cache available, return server failure
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PragaEntity>> getPragaById(String id) async {
    try {
      final remoteItem = await _remoteDataSource.getPragaById(id);
      return Right(remoteItem.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}

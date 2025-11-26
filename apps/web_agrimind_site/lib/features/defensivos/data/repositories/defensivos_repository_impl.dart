import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/defensivos_repository.dart';
import '../datasources/defensivos_local_datasource.dart';
import '../datasources/defensivos_remote_datasource.dart';

/// Defensivos repository implementation
///
/// Implements offline-first pattern with local cache fallback
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final DefensivosRemoteDataSource _remoteDataSource;
  final DefensivosLocalDataSource _localDataSource;

  const DefensivosRepositoryImpl({
    required DefensivosRemoteDataSource remoteDataSource,
    required DefensivosLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivos() async {
    try {
      // Try to fetch from remote
      final remoteList = await _remoteDataSource.getDefensivos();

      // Cache the results locally
      await _localDataSource.cacheDefensivos(remoteList);

      // Return mapped entities
      return Right(remoteList.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      // On server error, try to use cached data
      try {
        final cachedList = await _localDataSource.getCachedDefensivos();
        if (cachedList.isEmpty) {
          return Left(ServerFailure(e.message));
        }
        return Right(cachedList.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity>> getDefensivoById(String id) async {
    // Validate input
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo não pode ser vazio'));
    }

    try {
      // Try to fetch from remote
      final remoteModel = await _remoteDataSource.getDefensivoById(id);
      return Right(remoteModel.toEntity());
    } on NotFoundException catch (e) {
      // Try cache as fallback
      try {
        final cachedModel = await _localDataSource.getCachedDefensivoById(id);
        if (cachedModel == null) {
          return Left(NotFoundFailure(e.message));
        }
        return Right(cachedModel.toEntity());
      } on CacheException {
        return Left(NotFoundFailure(e.message));
      }
    } on ServerException catch (e) {
      // Try cache as fallback
      try {
        final cachedModel = await _localDataSource.getCachedDefensivoById(id);
        if (cachedModel == null) {
          return Left(ServerFailure(e.message));
        }
        return Right(cachedModel.toEntity());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}

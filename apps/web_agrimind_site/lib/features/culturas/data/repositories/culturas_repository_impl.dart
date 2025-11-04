import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cultura_entity.dart';
import '../../domain/repositories/culturas_repository.dart';
import '../datasources/culturas_local_datasource.dart';
import '../datasources/culturas_remote_datasource.dart';

/// Culturas repository implementation
///
/// Implements offline-first pattern with local cache fallback
@LazySingleton(as: ICulturasRepository)
class CulturasRepositoryImpl implements ICulturasRepository {
  final CulturasRemoteDataSource _remoteDataSource;
  final CulturasLocalDataSource _localDataSource;

  const CulturasRepositoryImpl({
    required CulturasRemoteDataSource remoteDataSource,
    required CulturasLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<CulturaEntity>>> getCulturas() async {
    try {
      // Try to fetch from remote
      final remoteList = await _remoteDataSource.getCulturas();

      // Cache the results locally
      await _localDataSource.cacheCulturas(remoteList);

      // Return mapped entities
      return Right(remoteList.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      // On server error, try to use cached data
      try {
        final cachedList = await _localDataSource.getCachedCulturas();
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
  Future<Either<Failure, CulturaEntity>> getCulturaById(String id) async {
    // Validate input
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID da cultura não pode ser vazio'));
    }

    try {
      // Try to fetch from remote
      final remoteModel = await _remoteDataSource.getCulturaById(id);
      return Right(remoteModel.toEntity());
    } on NotFoundException catch (e) {
      // Try cache as fallback
      try {
        final cachedModel = await _localDataSource.getCachedCulturaById(id);
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
        final cachedModel = await _localDataSource.getCachedCulturaById(id);
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

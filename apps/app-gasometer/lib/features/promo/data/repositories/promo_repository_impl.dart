import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/i_promo_repository.dart';
import '../datasources/promo_local_datasource.dart';
import '../datasources/promo_remote_datasource.dart';

class PromoRepositoryImpl implements IPromoRepository {

  PromoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final IPromoRemoteDataSource remoteDataSource;
  final IPromoLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<PromoEntity>>> getActivePromos() async {
    try {
      // Try cache first
      try {
        final cachedPromos = await localDataSource.getCachedPromos();
        return Right(cachedPromos);
      } catch (_) {
        // If cache fails, fetch from remote
      }

      final promos = await remoteDataSource.getActivePromos();
      await localDataSource.cachePromos(promos);
      return Right(promos);
    } on ServerException {
      return const Left(ServerFailure('Failed to fetch promos'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromoEntity>> getPromoById(String id) async {
    try {
      final promo = await remoteDataSource.getPromoById(id);
      return Right(promo);
    } on ServerException {
      return const Left(ServerFailure('Failed to fetch promo'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markPromoAsViewed(String promoId) async {
    try {
      await localDataSource.markPromoAsViewed(promoId);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure('Failed to mark promo as viewed'));
    }
  }
}

import 'package:core/core.dart' hide SubscriptionStatus, Column;

import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/local/premium_local_datasource.dart';

/// Implementation of PremiumRepository
@LazySingleton(as: PremiumRepository)
class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumLocalDataSource _localDataSource;

  PremiumRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, SubscriptionStatus>> checkSubscriptionStatus() async {
    try {
      final status = await _localDataSource.checkSubscriptionStatus();
      return Right(status.toEntity());
    } catch (e) {
      return Left(
        ServerFailure('Failed to check subscription status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async {
    try {
      final status = await _localDataSource.restorePurchases();
      return Right(status.toEntity());
    } catch (e) {
      return Left(
        ServerFailure('Failed to restore purchases: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAvailablePackages() async {
    try {
      final packages = await _localDataSource.getAvailablePackages();
      return Right(packages);
    } catch (e) {
      return Left(
        ServerFailure('Failed to get available packages: ${e.toString()}'),
      );
    }
  }
}

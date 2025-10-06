import 'package:core/core.dart' show Right, Left, Either;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans() async {
    try {
      // First try to get from remote (RevenueCat)
      final remotePlans = await remoteDataSource.getAvailablePlans();
      await localDataSource.cachePlans(remotePlans);
      return Right(remotePlans);
    } on ServerException catch (e) {
      // Fallback to cached plans if remote fails
      try {
        final cachedPlans = await localDataSource.getAvailablePlans();
        return Right(cachedPlans);
      } on CacheException catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar planos: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(
    String userId,
  ) async {
    try {
      // Try remote first for most up-to-date subscription status
      final remoteSubscription = await remoteDataSource.getCurrentSubscription(
        userId,
      );
      if (remoteSubscription != null) {
        await localDataSource.cacheSubscription(remoteSubscription);
        return Right(remoteSubscription);
      }

      // Fallback to cache
      final cachedSubscription = await localDataSource.getCurrentSubscription(
        userId,
      );
      return Right(cachedSubscription);
    } on ServerException catch (_) {
      // If remote fails, try cache
      try {
        final cachedSubscription = await localDataSource.getCurrentSubscription(
          userId,
        );
        return Right(cachedSubscription);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar assinatura: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> subscribeToPlan(
    String userId,
    String planId,
  ) async {
    try {
      // Use RevenueCat to make the purchase
      final subscription = await remoteDataSource.subscribeToPlan(
        userId,
        planId,
      );
      await localDataSource.cacheSubscription(subscription);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao processar assinatura: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String userId) async {
    try {
      await remoteDataSource.cancelSubscription(userId);
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription != null) {
        final cancelledSubscription = subscription.copyWith(
          status: PlanStatus.cancelled,
          cancelledAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheSubscription(cancelledSubscription);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao cancelar assinatura: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String userId) async {
    try {
      await remoteDataSource.pauseSubscription(userId);
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription != null) {
        final pausedSubscription = subscription.copyWith(
          status: PlanStatus.paused,
          pausedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheSubscription(pausedSubscription);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao pausar assinatura: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(String userId) async {
    try {
      await remoteDataSource.resumeSubscription(userId);
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription != null) {
        final resumedSubscription = subscription.copyWith(
          status: PlanStatus.active,
          pausedAt: null,
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheSubscription(resumedSubscription);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao retomar assinatura: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> upgradePlan(
    String userId,
    String newPlanId,
  ) async {
    try {
      // Use RevenueCat to upgrade the plan
      final upgradedSubscription = await remoteDataSource.upgradePlan(
        userId,
        newPlanId,
      );
      await localDataSource.cacheSubscription(upgradedSubscription);
      return Right(upgradedSubscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao fazer upgrade: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases(String userId) async {
    try {
      await remoteDataSource.restorePurchases(userId);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao restaurar compras: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> validateReceipt(String receiptData) async {
    try {
      final isValid = await remoteDataSource.validateReceipt(receiptData);
      return Right(isValid);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro ao validar recibo: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, UserSubscription?>> watchSubscription(String userId) {
    try {
      return remoteDataSource
          .watchSubscription(userId)
          .map((subscription) {
            if (subscription != null) {
              localDataSource.cacheSubscription(subscription);
            }
            return Right<Failure, UserSubscription?>(subscription);
          })
          .handleError((Object error) {
            return Left<Failure, UserSubscription?>(
              ServerFailure(
                message: 'Erro ao observar assinatura: ${error.toString()}',
              ),
            );
          });
    } catch (e) {
      return Stream.value(
        Left(
          ServerFailure(
            message: 'Erro ao observar assinatura: ${e.toString()}',
          ),
        ),
      );
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

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
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao buscar planos: $e'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(String userId) async {
    try {
      // Try remote first for most up-to-date subscription status
      final remoteSubscription = await remoteDataSource.getCurrentSubscription(userId);
      if (remoteSubscription != null) {
        await localDataSource.cacheSubscription(remoteSubscription);
        return Right(remoteSubscription);
      }
      
      // Fallback to cache
      final cachedSubscription = await localDataSource.getCurrentSubscription(userId);
      return Right(cachedSubscription);
    } on ServerException catch (_) {
      // If remote fails, try cache
      try {
        final cachedSubscription = await localDataSource.getCurrentSubscription(userId);
        return Right(cachedSubscription);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao buscar assinatura: $e'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> subscribeToPlan(String userId, String planId) async {
    try {
      // Use RevenueCat to make the purchase
      final subscription = await remoteDataSource.subscribeToPlan(userId, planId);
      await localDataSource.cacheSubscription(subscription);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao processar assinatura: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String userId) async {
    try {
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription == null) {
        return Left(NotFoundFailure('Assinatura não encontrada'));
      }

      final cancelledSubscription = subscription.copyWith(
        status: PlanStatus.cancelled,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.cacheSubscription(cancelledSubscription);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao cancelar assinatura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String userId) async {
    try {
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription == null) {
        return Left(NotFoundFailure('Assinatura não encontrada'));
      }

      final pausedSubscription = subscription.copyWith(
        status: PlanStatus.paused,
        pausedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.cacheSubscription(pausedSubscription);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao pausar assinatura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(String userId) async {
    try {
      final subscription = await localDataSource.getCurrentSubscription(userId);
      if (subscription == null) {
        return Left(NotFoundFailure('Assinatura não encontrada'));
      }

      final resumedSubscription = subscription.copyWith(
        status: PlanStatus.active,
        pausedAt: null,
        updatedAt: DateTime.now(),
      );

      await localDataSource.cacheSubscription(resumedSubscription);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao retomar assinatura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> upgradePlan(String userId, String newPlanId) async {
    try {
      final currentSubscription = await localDataSource.getCurrentSubscription(userId);
      if (currentSubscription == null) {
        return Left(NotFoundFailure('Assinatura atual não encontrada'));
      }

      final plans = await localDataSource.getAvailablePlans();
      final newPlan = plans.firstWhere((p) => p.id == newPlanId);

      final upgradedSubscription = currentSubscription.copyWith(
        planId: newPlanId,
        plan: newPlan,
        updatedAt: DateTime.now(),
      );

      await localDataSource.cacheSubscription(upgradedSubscription);
      return Right(upgradedSubscription);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer upgrade: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases(String userId) async {
    try {
      // Mock restore - Replace with RevenueCat restore
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao restaurar compras: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateReceipt(String receiptData) async {
    try {
      // Mock validation - Replace with actual receipt validation
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Erro ao validar recibo: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, UserSubscription?>> watchSubscription(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getCurrentSubscription(userId);
    }).asyncMap((future) => future);
  }
}
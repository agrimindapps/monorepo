import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../services/subscription_error_handling_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;
  final SubscriptionRemoteDataSource remoteDataSource;
  final SubscriptionErrorHandlingService errorHandlingService;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.errorHandlingService,
  });

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans() async {
    return errorHandlingService.executeOperation<List<SubscriptionPlan>>(
      operation: () async {
        final remotePlans = await remoteDataSource.getAvailablePlans();
        await localDataSource.cachePlans(remotePlans);
        return remotePlans;
      },
      fallback: () => localDataSource.getAvailablePlans(),
      errorMessage: 'Erro inesperado ao buscar planos',
    );
  }

  @override
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(
      String userId) async {
    return errorHandlingService.executeOperation<UserSubscription?>(
      operation: () async {
        final remoteSubscription =
            await remoteDataSource.getCurrentSubscription(userId);
        if (remoteSubscription != null) {
          await localDataSource.cacheSubscription(remoteSubscription);
          return remoteSubscription;
        }
        final cachedSubscription =
            await localDataSource.getCurrentSubscription(userId);
        return cachedSubscription;
      },
      fallback: () => localDataSource.getCurrentSubscription(userId),
      errorMessage: 'Erro inesperado ao buscar assinatura',
    );
  }

  @override
  Future<Either<Failure, UserSubscription>> subscribeToPlan(
      String userId, String planId) async {
    return errorHandlingService.executeOperation<UserSubscription>(
      operation: () async {
        final subscription =
            await remoteDataSource.subscribeToPlan(userId, planId);
        await localDataSource.cacheSubscription(subscription);
        return subscription;
      },
      errorMessage: 'Erro inesperado ao processar assinatura',
    );
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String userId) async {
    return errorHandlingService.executeVoidOperation(
      operation: () async {
        final subscription =
            await localDataSource.getCurrentSubscription(userId);
        if (subscription == null) {
          throw Exception('Assinatura não encontrada');
        }

        final cancelledSubscription = subscription.copyWith(
          status: PlanStatus.cancelled,
          cancelledAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await localDataSource.cacheSubscription(cancelledSubscription);
      },
      errorMessage: 'Erro ao cancelar assinatura',
    );
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String userId) async {
    return errorHandlingService.executeVoidOperation(
      operation: () async {
        final subscription =
            await localDataSource.getCurrentSubscription(userId);
        if (subscription == null) {
          throw Exception('Assinatura não encontrada');
        }

        final pausedSubscription = subscription.copyWith(
          status: PlanStatus.paused,
          pausedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await localDataSource.cacheSubscription(pausedSubscription);
      },
      errorMessage: 'Erro ao pausar assinatura',
    );
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(String userId) async {
    return errorHandlingService.executeVoidOperation(
      operation: () async {
        final subscription =
            await localDataSource.getCurrentSubscription(userId);
        if (subscription == null) {
          throw Exception('Assinatura não encontrada');
        }

        final resumedSubscription = subscription.copyWith(
          status: PlanStatus.active,
          pausedAt: null,
          updatedAt: DateTime.now(),
        );

        await localDataSource.cacheSubscription(resumedSubscription);
      },
      errorMessage: 'Erro ao retomar assinatura',
    );
  }

  @override
  Future<Either<Failure, UserSubscription>> upgradePlan(
      String userId, String newPlanId) async {
    return errorHandlingService.executeOperation<UserSubscription>(
      operation: () async {
        final currentSubscription =
            await localDataSource.getCurrentSubscription(userId);
        if (currentSubscription == null) {
          throw Exception('Assinatura atual não encontrada');
        }

        final plans = await localDataSource.getAvailablePlans();
        final newPlan = plans.firstWhere((p) => p.id == newPlanId);

        final upgradedSubscription = currentSubscription.copyWith(
          planId: newPlanId,
          plan: newPlan,
          updatedAt: DateTime.now(),
        );

        await localDataSource.cacheSubscription(upgradedSubscription);
        return upgradedSubscription;
      },
      errorMessage: 'Erro ao fazer upgrade',
    );
  }

  @override
  Future<Either<Failure, void>> restorePurchases(String userId) async {
    return errorHandlingService.executeVoidOperation(
      operation: () => Future<void>.delayed(const Duration(seconds: 1)),
      errorMessage: 'Erro ao restaurar compras',
    );
  }

  @override
  Future<Either<Failure, bool>> validateReceipt(String receiptData) async {
    return errorHandlingService.executeOperation<bool>(
      operation: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return true;
      },
      errorMessage: 'Erro ao validar recibo',
    );
  }

  @override
  Stream<Either<Failure, UserSubscription?>> watchSubscription(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getCurrentSubscription(userId);
    }).asyncMap((future) => future);
  }
}

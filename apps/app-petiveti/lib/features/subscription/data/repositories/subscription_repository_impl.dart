import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans() async {
    try {
      // Mock plans - Replace with RevenueCat integration
      final mockPlans = [
        SubscriptionPlanModel(
          id: 'free_plan',
          productId: 'petiveti_free',
          title: 'Plano Gratuito',
          description: 'Funcionalidades básicas para começar',
          price: 0.0,
          currency: 'R\$',
          type: PlanType.free,
          features: [
            'Até 2 animais',
            'Controle básico de vacinas',
            'Lembretes simples',
            'Acesso limitado às calculadoras',
          ],
        ),
        SubscriptionPlanModel(
          id: 'monthly_plan',
          productId: 'petiveti_monthly',
          title: 'Plano Mensal',
          description: 'Acesso completo com renovação mensal',
          price: 19.90,
          currency: 'R\$',
          type: PlanType.monthly,
          durationInDays: 30,
          trialDays: 7,
          features: [
            'Animais ilimitados',
            'Todas as calculadoras veterinárias',
            'Controle completo de medicamentos',
            'Lembretes avançados',
            'Controle de despesas',
            'Backup na nuvem',
            'Relatórios detalhados',
          ],
        ),
        SubscriptionPlanModel(
          id: 'yearly_plan',
          productId: 'petiveti_yearly',
          title: 'Plano Anual',
          description: 'Melhor valor com pagamento anual',
          price: 199.90,
          originalPrice: 238.80,
          currency: 'R\$',
          type: PlanType.yearly,
          durationInDays: 365,
          trialDays: 14,
          isPopular: true,
          features: [
            'Tudo do plano mensal',
            'Desconto de 17%',
            'Teste grátis de 14 dias',
            'Suporte prioritário',
            'Acesso antecipado a novidades',
          ],
        ),
        SubscriptionPlanModel(
          id: 'lifetime_plan',
          productId: 'petiveti_lifetime',
          title: 'Plano Vitalício',
          description: 'Pagamento único, acesso para sempre',
          price: 299.90,
          originalPrice: 599.90,
          currency: 'R\$',
          type: PlanType.lifetime,
          features: [
            'Acesso vitalício',
            'Todas as funcionalidades premium',
            'Todas as atualizações futuras',
            'Suporte VIP',
            'Desconto de 50%',
          ],
        ),
      ];

      await localDataSource.cachePlans(mockPlans);
      return Right(mockPlans);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar planos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(String userId) async {
    try {
      final subscription = await localDataSource.getCurrentSubscription(userId);
      return Right(subscription);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar assinatura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription>> subscribeToPlan(String userId, String planId) async {
    try {
      // Mock subscription - Replace with RevenueCat purchase flow
      await Future.delayed(const Duration(seconds: 2));

      final plans = await localDataSource.getAvailablePlans();
      final plan = plans.firstWhere((p) => p.id == planId);

      final subscription = UserSubscriptionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        planId: planId,
        plan: plan,
        status: PlanStatus.active,
        startDate: DateTime.now(),
        expirationDate: plan.type == PlanType.lifetime 
            ? null
            : DateTime.now().add(Duration(days: plan.durationInDays ?? 30)),
        isTrialPeriod: plan.trialDays != null && plan.trialDays! > 0,
        trialEndDate: plan.trialDays != null 
            ? DateTime.now().add(Duration(days: plan.trialDays!))
            : null,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.cacheSubscription(subscription);
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure('Erro ao processar assinatura: ${e.toString()}'));
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
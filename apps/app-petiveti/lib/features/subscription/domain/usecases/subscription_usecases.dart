import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/subscription_plan.dart';
import '../entities/user_subscription.dart';
import '../repositories/subscription_repository.dart';

class GetAvailablePlans implements UseCase<List<SubscriptionPlan>, NoParams> {
  final SubscriptionRepository repository;

  GetAvailablePlans(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> call(NoParams params) async {
    return await repository.getAvailablePlans();
  }
}

class GetCurrentSubscription implements UseCase<UserSubscription?, String> {
  final SubscriptionRepository repository;

  GetCurrentSubscription(this.repository);

  @override
  Future<Either<Failure, UserSubscription?>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }
    return await repository.getCurrentSubscription(userId);
  }
}

class SubscribeToPlanParams {
  final String userId;
  final String planId;

  SubscribeToPlanParams({
    required this.userId,
    required this.planId,
  });
}

class SubscribeToPlan implements UseCase<UserSubscription, SubscribeToPlanParams> {
  final SubscriptionRepository repository;

  SubscribeToPlan(this.repository);

  @override
  Future<Either<Failure, UserSubscription>> call(SubscribeToPlanParams params) async {
    if (params.userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }

    if (params.planId.trim().isEmpty) {
      return Left(ValidationFailure('ID do plano é obrigatório'));
    }

    return await repository.subscribeToPlan(params.userId, params.planId);
  }
}

class CancelSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;

  CancelSubscription(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }
    return await repository.cancelSubscription(userId);
  }
}

class PauseSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;

  PauseSubscription(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }
    return await repository.pauseSubscription(userId);
  }
}

class ResumeSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;

  ResumeSubscription(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }
    return await repository.resumeSubscription(userId);
  }
}

class UpgradePlanParams {
  final String userId;
  final String newPlanId;

  UpgradePlanParams({
    required this.userId,
    required this.newPlanId,
  });
}

class UpgradePlan implements UseCase<UserSubscription, UpgradePlanParams> {
  final SubscriptionRepository repository;

  UpgradePlan(this.repository);

  @override
  Future<Either<Failure, UserSubscription>> call(UpgradePlanParams params) async {
    if (params.userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }

    if (params.newPlanId.trim().isEmpty) {
      return Left(ValidationFailure('ID do novo plano é obrigatório'));
    }

    return await repository.upgradePlan(params.userId, params.newPlanId);
  }
}

class RestorePurchases implements UseCase<void, String> {
  final SubscriptionRepository repository;

  RestorePurchases(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure('ID do usuário é obrigatório'));
    }
    return await repository.restorePurchases(userId);
  }
}

class ValidateReceipt implements UseCase<bool, String> {
  final SubscriptionRepository repository;

  ValidateReceipt(this.repository);

  @override
  Future<Either<Failure, bool>> call(String receiptData) async {
    if (receiptData.trim().isEmpty) {
      return Left(ValidationFailure('Dados do recibo são obrigatórios'));
    }
    return await repository.validateReceipt(receiptData);
  }
}
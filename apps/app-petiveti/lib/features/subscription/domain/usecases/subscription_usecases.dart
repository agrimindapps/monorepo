import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/subscription_plan.dart';
import '../entities/user_subscription.dart';
import '../repositories/subscription_repository.dart';
import '../services/subscription_validation_service.dart';

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
  final SubscriptionValidationService validationService;

  GetCurrentSubscription(this.repository, this.validationService);

  @override
  Future<Either<Failure, UserSubscription?>> call(String userId) async {
    final validation = validationService.validateUserId(userId);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
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

class SubscribeToPlan
    implements UseCase<UserSubscription, SubscribeToPlanParams> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  SubscribeToPlan(this.repository, this.validationService);

  @override
  Future<Either<Failure, UserSubscription>> call(
      SubscribeToPlanParams params) async {
    final validation = validationService.validateSubscribeToPlanParams(
      userId: params.userId,
      planId: params.planId,
    );
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.subscribeToPlan(params.userId, params.planId);
  }
}

class CancelSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  CancelSubscription(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    final validation = validationService.validateUserId(userId);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.cancelSubscription(userId);
  }
}

class PauseSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  PauseSubscription(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    final validation = validationService.validateUserId(userId);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.pauseSubscription(userId);
  }
}

class ResumeSubscription implements UseCase<void, String> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  ResumeSubscription(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    final validation = validationService.validateUserId(userId);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
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
  final SubscriptionValidationService validationService;

  UpgradePlan(this.repository, this.validationService);

  @override
  Future<Either<Failure, UserSubscription>> call(
      UpgradePlanParams params) async {
    final validation = validationService.validateUpgradePlanParams(
      userId: params.userId,
      newPlanId: params.newPlanId,
    );
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.upgradePlan(params.userId, params.newPlanId);
  }
}

class RestorePurchases implements UseCase<void, String> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  RestorePurchases(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    final validation = validationService.validateUserId(userId);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.restorePurchases(userId);
  }
}

class ValidateReceipt implements UseCase<bool, String> {
  final SubscriptionRepository repository;
  final SubscriptionValidationService validationService;

  ValidateReceipt(this.repository, this.validationService);

  @override
  Future<Either<Failure, bool>> call(String receiptData) async {
    final validation = validationService.validateReceiptData(receiptData);
    if (validation.isLeft()) {
      return Left(validation.fold((l) => l, (r) => throw Exception()));
    }

    return await repository.validateReceipt(receiptData);
  }
}

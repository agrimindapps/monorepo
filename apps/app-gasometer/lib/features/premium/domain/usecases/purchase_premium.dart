import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para comprar premium
@injectable
class PurchasePremium implements UseCase<core.SubscriptionEntity, PurchasePremiumParams> {
  final PremiumRepository repository;

  PurchasePremium(this.repository);

  @override
  Future<Either<Failure, core.SubscriptionEntity>> call(PurchasePremiumParams params) async {
    return await repository.purchasePremium(productId: params.productId);
  }
}

/// Use case para iniciar trial gratuito
@injectable
class StartFreeTrial implements UseCase<bool, NoParams> {
  final PremiumRepository repository;

  StartFreeTrial(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.startFreeTrial();
  }
}

/// Use case para verificar elegibilidade para trial
@injectable
class IsEligibleForTrial implements UseCase<bool, NoParams> {
  final PremiumRepository repository;

  IsEligibleForTrial(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isEligibleForTrial();
  }
}

/// Use case para obter URL de gerenciamento
@injectable
class GetManagementUrl implements UseCase<String?, NoParams> {
  final PremiumRepository repository;

  GetManagementUrl(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await repository.getManagementUrl();
  }
}
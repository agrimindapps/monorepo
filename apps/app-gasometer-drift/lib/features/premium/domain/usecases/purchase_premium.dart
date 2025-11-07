import 'package:core/core.dart' as core;
import 'package:core/core.dart' show injectable;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para comprar premium
@injectable
class PurchasePremium
    implements UseCase<core.SubscriptionEntity, PurchasePremiumParams> {
  PurchasePremium(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> call(
    PurchasePremiumParams params,
  ) async {
    return await repository.purchasePremium(productId: params.productId);
  }
}

/// Use case para iniciar trial gratuito
@injectable
class StartFreeTrial implements UseCase<bool, NoParams> {
  StartFreeTrial(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(NoParams params) async {
    return await repository.startFreeTrial();
  }
}

/// Use case para verificar elegibilidade para trial
@injectable
class IsEligibleForTrial implements UseCase<bool, NoParams> {
  IsEligibleForTrial(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(NoParams params) async {
    return await repository.isEligibleForTrial();
  }
}

/// Use case para obter URL de gerenciamento
@injectable
class GetManagementUrl implements UseCase<String?, NoParams> {
  GetManagementUrl(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, String?>> call(NoParams params) async {
    return await repository.getManagementUrl();
  }
}

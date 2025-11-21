import 'package:core/core.dart' hide Column;

import '../repositories/i_subscription_repository.dart';

/// Use case para restaurar compras (usa core repository)
@injectable
class RestorePurchasesUseCase
    implements UseCase<List<SubscriptionEntity>, NoParams> {
  RestorePurchasesUseCase(this.coreRepository, this.appRepository);

  final ISubscriptionRepository coreRepository;
  final IAppSubscriptionRepository appRepository;

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> call(
    NoParams params,
  ) async {
    final result = await coreRepository.restorePurchases();
    await result.fold(
      (failure) => Future<void>.value(),
      (subscriptions) async {
        final hasReceitaAgro = subscriptions.any(
          (s) => s.isReceitaAgroSubscription && s.isActive,
        );
        await appRepository.cachePremiumStatus(hasReceitaAgro);
      },
    );

    return result;
  }
}

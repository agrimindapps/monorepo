import 'package:core/core.dart';

import '../repositories/i_subscription_repository.dart';

/// Use case para atualizar status da assinatura
@injectable
class RefreshSubscriptionStatusUseCase implements UseCase<bool, NoParams> {
  RefreshSubscriptionStatusUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    await repository.clearCache();
    final result = await repository.hasReceitaAgroSubscription();
    await result.fold(
      (failure) => Future<void>.value(),
      (isPremium) => repository.cachePremiumStatus(isPremium),
    );

    return result;
  }
}

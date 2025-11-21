import 'package:core/core.dart' hide Column;

import '../repositories/i_subscription_repository.dart';

/// Use case para verificar status premium do usuário ReceitaAgro
@injectable
class GetUserPremiumStatusUseCase implements UseCase<bool, NoParams> {
  GetUserPremiumStatusUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    final cachedResult = await repository.getCachedPremiumStatus();

    return cachedResult.fold(
      (failure) => repository.hasReceitaAgroSubscription(),
      (cachedStatus) async {
        if (cachedStatus != null) {
          return Right(cachedStatus);
        }
        final freshResult = await repository.hasReceitaAgroSubscription();
        await freshResult.fold(
          (failure) => Future<void>.value(),
          (isPremium) => repository.cachePremiumStatus(isPremium),
        );

        return freshResult;
      },
    );
  }
}

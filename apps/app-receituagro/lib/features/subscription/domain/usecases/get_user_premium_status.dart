import 'package:core/core.dart';

import '../repositories/i_subscription_repository.dart';

/// Use case para verificar status premium do usuário ReceitaAgro
@injectable
class GetUserPremiumStatusUseCase implements UseCase<bool, NoParams> {
  GetUserPremiumStatusUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // Primeiro tenta cache local para resposta rápida
    final cachedResult = await repository.getCachedPremiumStatus();

    return cachedResult.fold(
      (failure) => repository.hasReceitaAgroSubscription(),
      (cachedStatus) async {
        // Se tem cache, usa cache
        if (cachedStatus != null) {
          return Right(cachedStatus);
        }

        // Senão, busca status atualizado
        final freshResult = await repository.hasReceitaAgroSubscription();

        // Salva no cache se bem-sucedido
        await freshResult.fold(
          (failure) => Future<void>.value(),
          (isPremium) => repository.cachePremiumStatus(isPremium),
        );

        return freshResult;
      },
    );
  }
}

import 'package:core/core.dart';

/// Use case para buscar a assinatura atual com todos os detalhes do RevenueCat
/// Retorna SubscriptionEntity com expirationDate, purchaseDate, daysRemaining, etc.
///
/// Este use case busca diretamente do ISubscriptionRepository do core
/// que por sua vez consulta o RevenueCat SDK
@injectable
class GetCurrentSubscriptionUseCase implements UseCase<SubscriptionEntity?, NoParams> {
  GetCurrentSubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionEntity?>> call(NoParams params) async {
    return _repository.getCurrentSubscription();
  }
}

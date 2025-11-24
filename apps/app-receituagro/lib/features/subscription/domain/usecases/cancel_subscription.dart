import 'package:core/core.dart' hide Column;

/// Use case para cancelar assinatura (usa core repository)

class CancelSubscriptionUseCase implements UseCase<void, String?> {
  CancelSubscriptionUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, void>> call(String? reason) async {
    return coreRepository.cancelSubscription(reason: reason);
  }
}

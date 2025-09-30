import 'package:core/core.dart';

/// Use case para cancelar assinatura (usa core repository)
@injectable
class CancelSubscriptionUseCase implements UseCase<void, String?> {
  CancelSubscriptionUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, void>> call(String? reason) async {
    return coreRepository.cancelSubscription(reason: reason);
  }
}

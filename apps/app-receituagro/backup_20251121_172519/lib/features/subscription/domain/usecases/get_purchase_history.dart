import 'package:core/core.dart' hide Column;

/// Use case para buscar histórico de compras (usa core repository)
@injectable
class GetPurchaseHistoryUseCase
    implements UseCase<List<SubscriptionEntity>, NoParams> {
  GetPurchaseHistoryUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> call(
    NoParams params,
  ) async {
    return coreRepository.getUserSubscriptions();
  }
}

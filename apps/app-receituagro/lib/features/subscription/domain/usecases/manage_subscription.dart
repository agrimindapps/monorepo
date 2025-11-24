import 'package:core/core.dart' hide Column;

/// Use case para gerenciar assinatura (usa core repository)

class ManageSubscriptionUseCase implements UseCase<String?, NoParams> {
  ManageSubscriptionUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return coreRepository.getManagementUrl();
  }
}

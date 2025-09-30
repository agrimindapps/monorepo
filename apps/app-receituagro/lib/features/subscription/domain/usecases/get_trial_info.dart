import 'package:core/core.dart';

/// Use case para buscar informações de trial (usa core repository)
@injectable
class GetTrialInfoUseCase implements UseCase<SubscriptionEntity?, NoParams> {
  GetTrialInfoUseCase(this.coreRepository);

  final ISubscriptionRepository coreRepository;

  @override
  Future<Either<Failure, SubscriptionEntity?>> call(NoParams params) async {
    final result = await coreRepository.getCurrentSubscription();
    return result.map(
      (subscription) => subscription?.isInTrial == true ? subscription : null,
    );
  }
}

import 'package:core/core.dart';

import '../repositories/i_subscription_repository.dart';

/// Use case para verificar trial ativo
@injectable
class CheckActiveTrialUseCase implements UseCase<bool, NoParams> {
  CheckActiveTrialUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return repository.hasActiveTrial();
  }
}

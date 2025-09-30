import 'package:core/core.dart';

import '../repositories/i_subscription_repository.dart';

/// Use case para verificar acesso a feature
@injectable
class CheckFeatureAccessUseCase implements UseCase<bool, String> {
  CheckFeatureAccessUseCase(this.repository);

  final IAppSubscriptionRepository repository;

  @override
  Future<Either<Failure, bool>> call(String featureKey) async {
    if (featureKey.trim().isEmpty) {
      return const Left(
        ValidationFailure('Chave da feature não pode ser vazia'),
      );
    }

    return repository.hasFeatureAccess(featureKey);
  }
}

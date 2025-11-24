import 'package:core/core.dart' hide Column;

import '../../presentation/services/subscription_error_message_service.dart';
import '../repositories/i_subscription_repository.dart';

/// Use case para verificar acesso a feature

class CheckFeatureAccessUseCase implements UseCase<bool, String> {
  CheckFeatureAccessUseCase(this.repository, this.errorService);

  final IAppSubscriptionRepository repository;
  final SubscriptionErrorMessageService errorService;

  @override
  Future<Either<Failure, bool>> call(String featureKey) async {
    if (featureKey.trim().isEmpty) {
      return Left(ValidationFailure(errorService.getEmptyFeatureKeyError()));
    }

    return repository.hasFeatureAccess(featureKey);
  }
}

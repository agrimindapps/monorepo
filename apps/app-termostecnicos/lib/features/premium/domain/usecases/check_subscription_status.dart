import 'package:core/core.dart' hide SubscriptionStatus, Column;

import '../entities/subscription_status.dart';
import '../repositories/premium_repository.dart';

/// Use case for checking current subscription status
@injectable
class CheckSubscriptionStatus {
  final PremiumRepository _repository;

  CheckSubscriptionStatus(this._repository);

  Future<Either<Failure, SubscriptionStatus>> call() async {
    try {
      return await _repository.checkSubscriptionStatus();
    } catch (e) {
      return Left(
        ServerFailure('Failed to check subscription status: ${e.toString()}'),
      );
    }
  }
}

import 'package:core/core.dart' hide SubscriptionStatus, Column;

import '../entities/subscription_status.dart';
import '../repositories/premium_repository.dart';

/// Use case for restoring purchases from app store
class RestorePurchases {
  final PremiumRepository _repository;

  RestorePurchases(this._repository);

  Future<Either<Failure, SubscriptionStatus>> call() async {
    try {
      return await _repository.restorePurchases();
    } catch (e) {
      return Left(
        ServerFailure('Failed to restore purchases: ${e.toString()}'),
      );
    }
  }
}

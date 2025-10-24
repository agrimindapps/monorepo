import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide SubscriptionStatus;
import 'package:injectable/injectable.dart';

import '../entities/subscription_status.dart';
import '../repositories/premium_repository.dart';

/// Use case for restoring purchases from app store
@injectable
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

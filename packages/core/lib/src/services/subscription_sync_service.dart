import 'package:dartz/dartz.dart';

import '../domain/entities/subscription_entity.dart';
import '../domain/repositories/i_subscription_repository.dart';
import '../shared/utils/failure.dart';

enum SubscriptionStatus { active, cancelled, expired, gracePeriod, unknown }

enum SubscriptionTier { free, premium, pro }

enum Store { appStore, playStore, stripe, promotional, unknown }

class SyncOperations {
  const SyncOperations();
}

class SyncQueue {
  const SyncQueue();
}

/// Stub implementation of the subscription sync service
/// This prevents compilation errors while the full service is being developed

class SubscriptionSyncService {
  final ISubscriptionRepository _subscriptionRepository;

  const SubscriptionSyncService({
    required ISubscriptionRepository subscriptionRepository,
    required SyncOperations syncOperations,
  }) : _subscriptionRepository = subscriptionRepository;

  /// Stub method to prevent compilation errors
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    try {
      return await _subscriptionRepository.getCurrentSubscription();
    } catch (e) {
      return Left(ServerFailure('Failed to get subscription: $e'));
    }
  }
}

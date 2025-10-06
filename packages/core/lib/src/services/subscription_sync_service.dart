// TEMPORARY STUB FILE TO RESOLVE BUILD ERRORS
// This is a stub version of the advanced subscription sync service
// Will be replaced with proper implementation later

import 'package:dartz/dartz.dart';

import '../domain/entities/subscription_entity.dart';
import '../domain/repositories/i_local_storage_repository.dart';
import '../domain/repositories/i_subscription_repository.dart';
import '../shared/utils/failure.dart';

// Missing enums - stub implementations
enum SubscriptionStatus { active, cancelled, expired, gracePeriod, unknown }

enum SubscriptionTier { free, premium, pro }

enum Store { appStore, playStore, stripe, promotional, unknown }

// Stub class for sync operations
class SyncOperations {
  const SyncOperations();
}

// Stub class for sync queue
class SyncQueue {
  const SyncQueue();
}

/// Stub implementation of the subscription sync service
/// This prevents compilation errors while the full service is being developed
class SubscriptionSyncService {
  final ISubscriptionRepository _subscriptionRepository;
  final ILocalStorageRepository _localStorage;
  final SyncQueue _syncQueue;
  final SyncOperations _syncOperations;

  const SubscriptionSyncService({
    required ISubscriptionRepository subscriptionRepository,
    required ILocalStorageRepository localStorage,
    required SyncQueue syncQueue,
    required SyncOperations syncOperations,
  }) : _subscriptionRepository = subscriptionRepository,
       _localStorage = localStorage,
       _syncQueue = syncQueue,
       _syncOperations = syncOperations;

  /// Stub method to prevent compilation errors
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    try {
      return await _subscriptionRepository.getCurrentSubscription();
    } catch (e) {
      return Left(ServerFailure('Failed to get subscription: $e'));
    }
  }

  /// Parse store from string - stub implementation
  Store _parseStore(String? storeString) {
    if (storeString == null) return Store.unknown;

    switch (storeString.toLowerCase()) {
      case 'app_store':
        return Store.appStore;
      case 'play_store':
        return Store.playStore;
      case 'stripe':
        return Store.stripe;
      case 'promotional':
        return Store.promotional;
      default:
        return Store.unknown;
    }
  }
}

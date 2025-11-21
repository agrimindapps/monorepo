import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/services/i_subscription_data_provider.dart';
import '../../../domain/services/i_subscription_sync_service.dart';
import '../../../shared/utils/failure.dart';
import '../subscription_sync_models.dart';
import 'subscription_cache_service.dart';
import 'subscription_conflict_resolver.dart';
import 'subscription_debounce_manager.dart';
import 'subscription_retry_manager.dart';

/// Advanced subscription sync service with multi-source support.
///
/// Orchestrates multiple [ISubscriptionDataProvider]s to provide:
/// - Real-time multi-source synchronization
/// - Conflict resolution between sources
/// - Automatic retry with exponential backoff
/// - Debouncing to prevent excessive syncs
/// - In-memory caching for performance
/// - Cross-device sync capabilities
///
/// Architecture:
/// ```
/// RevenueCat Provider (priority: 100) ──┐
/// Firebase Provider (priority: 80) ─────┤
/// Webhook Provider (priority: 60) ──────┼──> Conflict Resolver ──> Master Stream
/// Local Provider (priority: 40) ────────┘
/// ```
///
/// Usage:
/// ```dart
/// final syncService = AdvancedSubscriptionSyncService(
///   providers: [revenueCatProvider, firebaseProvider, webhookProvider],
///   configuration: AdvancedSyncConfiguration.aggressive(),
///   conflictResolver: resolver,
///   debounceManager: debouncer,
///   retryManager: retrier,
///   cacheService: cacher,
/// );
///
/// // Listen to subscription changes
/// syncService.subscriptionStream.listen((subscription) {
///   print('Subscription updated: ${subscription?.isActive}');
/// });
///
/// // Force sync
/// await syncService.forceSync();
/// ```
class AdvancedSubscriptionSyncService implements ISubscriptionSyncService {
  /// Creates an advanced subscription sync service.
  AdvancedSubscriptionSyncService({
    required List<ISubscriptionDataProvider> providers,
    required AdvancedSyncConfiguration configuration,
    required SubscriptionConflictResolver conflictResolver,
    required SubscriptionDebounceManager debounceManager,
    required SubscriptionRetryManager retryManager,
    required SubscriptionCacheService cacheService,
  }) : _providers = providers,
       _configuration = configuration,
       _conflictResolver = conflictResolver,
       _debounceManager = debounceManager,
       _retryManager = retryManager,
       _cacheService = cacheService;

  final List<ISubscriptionDataProvider> _providers;
  final AdvancedSyncConfiguration _configuration;
  final SubscriptionConflictResolver _conflictResolver;
  final SubscriptionDebounceManager _debounceManager;
  final SubscriptionRetryManager _retryManager;
  final SubscriptionCacheService _cacheService;

  // Master subscription stream
  final BehaviorSubject<SubscriptionEntity?> _masterSubscriptionController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  // Sync events stream for monitoring
  final PublishSubject<SubscriptionSyncEvent> _syncEventController =
      PublishSubject<SubscriptionSyncEvent>();

  // Provider subscriptions
  final Map<String, StreamSubscription<SubscriptionEntity?>>
  _providerSubscriptions = {};

  bool _isInitialized = false;

  // ==================== ISubscriptionSyncService Implementation ====================

  @override
  Stream<SubscriptionEntity?> get subscriptionStream =>
      _masterSubscriptionController.stream.distinct(
        (prev, next) => _conflictResolver.areEqual(prev, next),
      );

  @override
  SubscriptionEntity? get currentSubscription =>
      _masterSubscriptionController.value;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _log('Initializing with ${_providers.length} providers');

    // Initialize all enabled providers
    for (final provider in _providers.where((p) => p.isEnabled)) {
      await _initializeProvider(provider);
    }

    // Load from cache if enabled
    if (_configuration.enableOfflineSupport) {
      final cached = _cacheService.get('master_subscription');
      if (cached != null) {
        _masterSubscriptionController.add(cached);
        _log('Loaded subscription from cache');
      }
    }

    // Perform initial sync
    await forceSync();

    _isInitialized = true;
    _emitEvent(SubscriptionSyncEvent.initialized());
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> forceSync() async {
    try {
      _emitEvent(SubscriptionSyncEvent.syncStarted());

      // Fetch from all enabled providers
      final results = await _retryManager.executeWithRetry(
        key: 'force-sync-all',
        operation: () => _fetchFromAllProviders(),
        maxRetries: _configuration.maxRetryAttempts,
      );

      // Resolve conflicts if multiple sources returned data
      final validResults = results.where((r) => r != null).toList();

      if (validResults.isEmpty) {
        _emitEvent(
          SubscriptionSyncEvent.syncCompleted(SubscriptionSyncSource.manual),
        );
        return const Right(null);
      }

      final resolved = validResults.length == 1
          ? validResults.first!
          : _conflictResolver.resolveMultiple(
              validResults.cast<SubscriptionEntity>(),
              priorities: _providers.map((p) => p.priority).toList(),
            );

      await _updateMasterSubscription(
        newSubscription: resolved,
        source: SubscriptionSyncSource.manual,
      );

      _emitEvent(
        SubscriptionSyncEvent.syncCompleted(SubscriptionSyncSource.manual),
      );
      return Right(resolved);
    } catch (e) {
      _log('Force sync failed: $e', isError: true);
      _emitEvent(SubscriptionSyncEvent.syncFailed(e.toString()));
      return Left(ServerFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveSubscriptionForApp(
    String appName,
  ) async {
    final subscription = currentSubscription;
    if (subscription == null || !subscription.isActive) {
      return const Right(false);
    }

    return Right(subscription.productId.contains(appName));
  }

  @override
  bool get hasActiveSubscription => currentSubscription?.isActive ?? false;

  @override
  bool get isSyncing =>
      _retryManager.scheduledRetryCount > 0 ||
      _debounceManager.pendingCount > 0;

  @override
  bool get isDisposed => _masterSubscriptionController.isClosed;

  @override
  Future<void> dispose() async {
    _log('Disposing service');

    // Cancel all provider subscriptions
    for (final subscription in _providerSubscriptions.values) {
      await subscription.cancel();
    }
    _providerSubscriptions.clear();

    // Cancel pending operations
    _debounceManager.cancelAll();
    _retryManager.cancelAllRetries();

    // Close streams
    await _masterSubscriptionController.close();
    await _syncEventController.close();

    _isInitialized = false;
  }

  // ==================== Public Observables ====================

  /// Stream of sync events for monitoring
  Stream<SubscriptionSyncEvent> get syncEvents => _syncEventController.stream;

  /// Get current configuration
  AdvancedSyncConfiguration get configuration => _configuration;

  /// Get enabled providers
  List<ISubscriptionDataProvider> get enabledProviders =>
      _providers.where((p) => p.isEnabled).toList();

  // ==================== Provider Management ====================

  /// Initialize a single provider and listen to its updates
  Future<void> _initializeProvider(ISubscriptionDataProvider provider) async {
    _log('Initializing provider: ${provider.name}');

    // Subscription is stored in _providerSubscriptions and cancelled in dispose()
    // ignore: cancel_subscriptions
    final subscription = provider.updates.listen(
      (subscription) => _onProviderUpdate(provider, subscription),
      onError: (Object error) => _onProviderError(provider, error),
    );

    _providerSubscriptions[provider.name] = subscription;
  }

  /// Handle update from a provider
  void _onProviderUpdate(
    ISubscriptionDataProvider provider,
    SubscriptionEntity? subscription,
  ) {
    _log('Provider ${provider.name} updated: ${subscription?.isActive}');

    _debounceManager.debounceVoid(
      key: 'provider-${provider.name}',
      duration: _configuration.debounceDuration,
      operation: () async {
        await _updateMasterSubscription(
          newSubscription: subscription,
          source: _mapProviderToSource(provider.name),
        );
      },
    );
  }

  /// Handle error from a provider
  void _onProviderError(ISubscriptionDataProvider provider, dynamic error) {
    _log('Provider ${provider.name} error: $error', isError: true);

    _retryManager.scheduleRetry(
      key: 'provider-${provider.name}-retry',
      operation: () async {
        final result = await provider.fetch();
        result.fold(
          (failure) => _log('Retry failed: ${failure.message}', isError: true),
          (subscription) => _onProviderUpdate(provider, subscription),
        );
      },
      delay: _retryManager.getNextRetryDelay('provider-${provider.name}'),
    );
  }

  /// Fetch subscription from all enabled providers
  Future<List<SubscriptionEntity?>> _fetchFromAllProviders() async {
    final results = <SubscriptionEntity?>[];

    for (final provider in _providers.where((p) => p.isEnabled)) {
      final result = await provider.fetch();
      result.fold(
        (failure) =>
            _log('Provider ${provider.name} fetch failed: ${failure.message}'),
        (subscription) => results.add(subscription),
      );
    }

    return results;
  }

  // ==================== Master Subscription Management ====================

  /// Update master subscription with conflict resolution
  Future<void> _updateMasterSubscription({
    required SubscriptionEntity? newSubscription,
    required SubscriptionSyncSource source,
  }) async {
    try {
      final current = _masterSubscriptionController.value;

      // Check if update is needed
      if (!_conflictResolver.needsUpdate(current, newSubscription)) {
        _log('No update needed - subscriptions are equal');
        return;
      }

      // Resolve conflict
      final resolved = await _resolveSubscriptionConflict(
        current: current,
        newSubscription: newSubscription,
        source: source,
      );

      // Update master stream
      _masterSubscriptionController.add(resolved);

      // Update cache if enabled
      if (_configuration.enableOfflineSupport) {
        _cacheService.set(
          key: 'master_subscription',
          value: resolved,
          ttl: const Duration(minutes: 30),
        );
      }

      // Emit event
      _emitEvent(
        SubscriptionSyncEvent.updated(
          oldSubscription: current,
          newSubscription: resolved,
          source: source,
        ),
      );

      _log('Master subscription updated from $source');
    } catch (e) {
      _log('Failed to update master subscription: $e', isError: true);
      rethrow;
    }
  }

  /// Resolve conflict between current and new subscription
  Future<SubscriptionEntity?> _resolveSubscriptionConflict({
    required SubscriptionEntity? current,
    required SubscriptionEntity? newSubscription,
    required SubscriptionSyncSource source,
  }) async {
    // If no conflict, return new subscription
    if (current == null) return newSubscription;
    if (newSubscription == null) return current;

    // Use conflict resolver
    return _conflictResolver.resolve(current, newSubscription);
  }

  // ==================== Utilities ====================

  /// Map provider name to sync source
  SubscriptionSyncSource _mapProviderToSource(String providerName) {
    final lowerName = providerName.toLowerCase();
    if (lowerName.contains('revenuecat')) {
      return SubscriptionSyncSource.revenueCat;
    } else if (lowerName.contains('firebase')) {
      return SubscriptionSyncSource.firebase;
    } else if (lowerName.contains('webhook')) {
      return SubscriptionSyncSource.webhook;
    } else if (lowerName.contains('local')) {
      return SubscriptionSyncSource.local;
    }
    return SubscriptionSyncSource.unknown;
  }

  /// Emit sync event
  void _emitEvent(SubscriptionSyncEvent event) {
    if (!_syncEventController.isClosed) {
      _syncEventController.add(event);
    }
  }

  /// Log message based on configuration
  void _log(String message, {bool isError = false}) {
    final shouldLog = isError
        ? _configuration.logLevel.index >= SubscriptionSyncLogLevel.error.index
        : _configuration.logLevel.index >= SubscriptionSyncLogLevel.info.index;

    if (shouldLog) {
      const prefix = '[AdvancedSubscriptionSyncService]';
      if (isError) {
        debugPrint('$prefix ERROR: $message');
      } else {
        debugPrint('$prefix $message');
      }
    }
  }
}

/// Subscription sync events for monitoring
sealed class SubscriptionSyncEvent {
  const SubscriptionSyncEvent();

  factory SubscriptionSyncEvent.initialized() = _Initialized;
  factory SubscriptionSyncEvent.syncStarted() = _SyncStarted;
  factory SubscriptionSyncEvent.syncCompleted(SubscriptionSyncSource source) =
      _SyncCompleted;
  factory SubscriptionSyncEvent.syncFailed(String error) = _SyncFailed;
  factory SubscriptionSyncEvent.updated({
    required SubscriptionEntity? oldSubscription,
    required SubscriptionEntity? newSubscription,
    required SubscriptionSyncSource source,
  }) = _Updated;
}

class _Initialized extends SubscriptionSyncEvent {
  const _Initialized();
}

class _SyncStarted extends SubscriptionSyncEvent {
  const _SyncStarted();
}

class _SyncCompleted extends SubscriptionSyncEvent {
  const _SyncCompleted(this.source);
  final SubscriptionSyncSource source;
}

class _SyncFailed extends SubscriptionSyncEvent {
  const _SyncFailed(this.error);
  final String error;
}

class _Updated extends SubscriptionSyncEvent {
  const _Updated({
    required this.oldSubscription,
    required this.newSubscription,
    required this.source,
  });
  final SubscriptionEntity? oldSubscription;
  final SubscriptionEntity? newSubscription;
  final SubscriptionSyncSource source;
}

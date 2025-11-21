import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/repositories/i_subscription_repository.dart';
import '../../../domain/services/i_subscription_data_provider.dart';
import '../../../shared/utils/failure.dart';

/// RevenueCat subscription data provider
///
/// Primary source for subscription data from in-app purchases.
///
/// Priority: 100 (highest)
/// - Most authoritative source
/// - Direct from app stores (Apple/Google/Amazon)
/// - Real-time purchase events
///
/// Usage:
/// ```dart
/// final provider = RevenueCatSubscriptionProvider(
///   subscriptionRepository: repository,
/// );
///
/// // Listen to updates
/// provider.updates.listen((subscription) {
///   print('RevenueCat: ${subscription?.isActive}');
/// });
///
/// // Manual fetch
/// final result = await provider.fetch();
/// ```
@lazySingleton
class RevenueCatSubscriptionProvider implements ISubscriptionDataProvider {
  /// Creates a RevenueCat subscription provider.
  RevenueCatSubscriptionProvider({
    required ISubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository {
    if (!kIsWeb) {
      _initializeStream();
    } else {
      _log('Web platform detected: RevenueCat provider disabled');
    }
  }

  final ISubscriptionRepository _subscriptionRepository;

  final BehaviorSubject<SubscriptionEntity?> _updatesController =
      BehaviorSubject<SubscriptionEntity?>.seeded(null);

  StreamSubscription<SubscriptionEntity?>? _subscription;
  bool _isEnabled = true;

  // ==================== ISubscriptionDataProvider Implementation ====================

  @override
  String get name => 'RevenueCat';

  @override
  Stream<SubscriptionEntity?> get updates => _updatesController.stream;

  @override
  int get priority => 100; // Highest priority

  @override
  bool get isEnabled => _isEnabled && !kIsWeb;

  @override
  Future<Either<Failure, SubscriptionEntity?>> fetch() async {
    if (kIsWeb) {
      _log('Web platform: fetch skipped');
      return const Right(null);
    }

    try {
      _log('Fetching subscription from RevenueCat');

      final result = await _subscriptionRepository.getCurrentSubscription();

      return result.fold(
        (failure) {
          _log('Fetch failed: ${failure.message}', isError: true);
          return Left(
            ServerFailure('RevenueCat fetch failed: ${failure.message}'),
          );
        },
        (subscription) {
          _log('Fetched: ${subscription?.isActive}');

          // Update stream
          if (!_updatesController.isClosed) {
            _updatesController.add(subscription);
          }

          return Right(subscription);
        },
      );
    } catch (e) {
      _log('Unexpected error: $e', isError: true);
      return Left(ServerFailure('RevenueCat error: ${e.toString()}'));
    }
  }

  // ==================== Lifecycle ====================

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      _log('Web platform: initialization skipped');
      return;
    }

    _log('Initializing provider');
    _initializeStream();

    // Perform initial fetch
    await fetch();
  }

  /// Initialize stream listener
  void _initializeStream() {
    _log('Initializing RevenueCat stream');

    _subscription = _subscriptionRepository.subscriptionStatus.listen(
      (subscription) {
        _log('Stream update: ${subscription?.isActive}');

        if (!_updatesController.isClosed) {
          _updatesController.add(subscription);
        }
      },
      onError: (Object error) {
        _log('Stream error: $error', isError: true);
      },
    );
  }

  @override
  Future<void> dispose() async {
    _log('Disposing provider');

    await _subscription?.cancel();
    await _updatesController.close();
  }

  /// Enable this provider
  void enable() {
    if (!_isEnabled) {
      _isEnabled = true;
      _log('Provider enabled');
    }
  }

  /// Disable this provider
  void disable() {
    if (_isEnabled) {
      _isEnabled = false;
      _log('Provider disabled');
    }
  }

  // ==================== Utilities ====================

  void _log(String message, {bool isError = false}) {
    const prefix = '[RevenueCatProvider]';
    if (isError) {
      debugPrint('$prefix ERROR: $message');
    } else {
      debugPrint('$prefix $message');
    }
  }
}

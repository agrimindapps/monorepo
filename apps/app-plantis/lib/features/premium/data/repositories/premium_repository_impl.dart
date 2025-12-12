import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Either, Failure, ProductInfo;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../database/repositories/subscription_local_repository.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';

/// Implementação do repositório premium para o Plantis
///
/// Delega operações para o ISubscriptionRepository do core (RevenueCat)
/// e adiciona lógica específica do Plantis (features, limits)
class PremiumRepositoryImpl implements PremiumRepository {
  PremiumRepositoryImpl({
    required core.ISubscriptionRepository coreSubscriptionRepository,
    required SubscriptionLocalRepository localRepository,
  }) : _coreRepository = coreSubscriptionRepository,
       _localRepository = localRepository {
    // Initialize premium status stream
    _initializePremiumStream();
  }

  final core.ISubscriptionRepository _coreRepository;
  final SubscriptionLocalRepository _localRepository;

  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  @override
  Stream<PremiumStatus> get premiumStatus => _statusController.stream;

  /// Initialize premium status stream by listening to subscription changes
  void _initializePremiumStream() {
    // Note: ISubscriptionRepository doesn't expose a subscription stream
    // We'll rely on manual sync and polling

    // Initial load
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    final result = await getPremiumStatus();
    result.fold(
      (failure) => debugPrint(
        '[PremiumRepository] Failed to load initial status: $failure',
      ),
      (status) => _updateStatus(status),
    );
  }

  void _updateStatus(PremiumStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  Future<Either<Failure, bool>> hasActivePremium() async {
    try {
      final result = await _coreRepository.getCurrentSubscription();

      return result.fold((failure) => Left(failure), (subscription) {
        if (subscription == null) return const Right(false);
        return Right(
          subscription.isActive &&
              subscription.isPlantisSubscription &&
              !_isExpired(subscription),
        );
      });
    } catch (e) {
      return Left(
        core.SubscriptionUnknownFailure('Error checking premium: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      final result = await _coreRepository.getCurrentSubscription();

      return result.fold((failure) => Left(failure), (subscription) {
        final status = _convertToPremiumStatus(subscription);
        return Right(status);
      });
    } catch (e) {
      return Left(
        core.SubscriptionUnknownFailure('Error getting premium status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductInfo>>> getAvailableProducts() async {
    try {
      // Get Plantis-specific products from core repository
      final result = await _coreRepository.getPlantisProducts();

      return result;
    } catch (e) {
      return Left(
        core.SubscriptionUnknownFailure('Error loading products: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, core.SubscriptionEntity>> purchasePremium({
    required String productId,
  }) async {
    try {
      final result = await _coreRepository.purchaseProduct(
        productId: productId,
      );

      // Save to local cache on success
      result.fold(
        (failure) => null,
        (subscription) => _localRepository.saveSubscription(subscription),
      );

      return result;
    } catch (e) {
      return Left(core.SubscriptionPaymentFailure('Purchase failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final result = await _coreRepository.restorePurchases();

      return result.fold((failure) => Left(failure), (subscriptions) async {
        // Check if user has Plantis subscription
        final plantisSubscriptions = subscriptions
            .where((s) => s.isPlantisSubscription && s.isActive)
            .toList();

        // Save to local cache
        for (final subscription in plantisSubscriptions) {
          await _localRepository.saveSubscription(subscription);
        }

        return Right(plantisSubscriptions.isNotEmpty);
      });
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async {
    try {
      final result = await _coreRepository.setUser(
        userId: userId,
        attributes: attributes,
      );

      return result;
    } catch (e) {
      return Left(core.SubscriptionValidationFailure('Set user failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> syncPremiumStatus() async {
    try {
      // Note: syncSubscriptionStatus() is not in ISubscriptionRepository interface
      // We just get the latest status directly
      final result = await getPremiumStatus();

      // Update local cache
      result.fold((failure) => null, (status) async {
        if (status.subscription != null) {
          await _localRepository.saveSubscription(status.subscription!);
        }
        _updateStatus(status);
      });

      return result;
    } catch (e) {
      return Left(core.SubscriptionUnknownFailure('Sync failed: $e'));
    }
  }

  /// Convert core SubscriptionEntity to PremiumStatus
  PremiumStatus _convertToPremiumStatus(core.SubscriptionEntity? subscription) {
    if (subscription == null) {
      return PremiumStatus.free;
    }

    // Check if subscription is active and for Plantis
    final isPremium =
        subscription.isActive &&
        subscription.isPlantisSubscription &&
        !_isExpired(subscription);

    if (!isPremium) {
      return PremiumStatus.free;
    }

    // Check if in trial
    final isInTrial = subscription.isInTrial;
    final trialDaysRemaining = isInTrial
        ? _calculateDaysRemaining(subscription)
        : null;

    return PremiumStatus.premium(
      subscription: subscription,
      expirationDate: subscription.expirationDate,
      isInTrial: isInTrial,
      trialDaysRemaining: trialDaysRemaining,
    );
  }

  /// Check if subscription is expired
  bool _isExpired(core.SubscriptionEntity subscription) {
    if (subscription.expirationDate == null) return false;
    return DateTime.now().isAfter(subscription.expirationDate!);
  }

  /// Calculate days remaining until expiration
  int? _calculateDaysRemaining(core.SubscriptionEntity subscription) {
    if (subscription.expirationDate == null) return null;
    final difference = subscription.expirationDate!.difference(DateTime.now());
    return difference.inDays;
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}

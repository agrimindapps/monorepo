import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/widgets/loading_overlay.dart';

part 'premium_provider.freezed.dart';
part 'premium_provider.g.dart';

// Add top‑level error handling types
enum PremiumErrorType { network, auth, purchase, unknown }

class PremiumError {
  final PremiumErrorType type;
  final String message;
  const PremiumError({required this.type, required this.message});
}

/// State for Premium/Subscription
@freezed
class PremiumState with _$PremiumState {
  const factory PremiumState({
    SubscriptionEntity? currentSubscription,
    @Default([]) List<ProductInfo> availableProducts,
    @Default(false) bool isLoading,
    PremiumError? error,
    PurchaseOperation? currentOperation,
  }) = _PremiumState;

  const PremiumState._();

  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => true; // Simplificado

  String get subscriptionStatus {
    if (currentSubscription == null) return 'Gratuito';
    if (currentSubscription!.isActive) {
      if (currentSubscription!.isInTrial) return 'Trial';
      return 'Premium';
    }
    return 'Expirado';
  }

  DateTime? get expirationDate => currentSubscription?.expirationDate;
}

/// Provider for managing Premium subscription functionality
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  ISubscriptionRepository get _subscriptionRepository =>
      ref.read(subscriptionRepositoryProvider);
  IAuthRepository get _authRepository => ref.read(authRepositoryProvider);
  SimpleSubscriptionSyncService? get _simpleSubscriptionSyncService =>
      ref.read(simpleSubscriptionSyncServiceProvider);

  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<SubscriptionEntity?>? _syncSubscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;

  @override
  PremiumState build() {
    ref.onDispose(() {
      _subscriptionStream?.cancel();
      _syncSubscriptionStream?.cancel();
      _authStream?.cancel();
    });

    _initialize();

    return const PremiumState();
  }

  void _initialize() {
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream =
          _simpleSubscriptionSyncService!.subscriptionStatus.listen(
        (subscription) {
          state = state.copyWith(currentSubscription: subscription);
        },
        onError: (Object error) {
          state = state.copyWith(
            error: PremiumError(
              type: PremiumErrorType.unknown,
              message: error.toString(),
            ),
          );
        },
      );
    } else {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
        (subscription) async {
          state = state.copyWith(currentSubscription: subscription);
        },
        onError: (Object error) {
          state = state.copyWith(
            error: PremiumError(
              type: PremiumErrorType.unknown,
              message: error.toString(),
            ),
          );
        },
      );
    }

    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        state = state.copyWith(currentSubscription: null);
      }
    });

    _loadAvailableProducts();
    _checkCurrentSubscription();
  }

  Future<void> _syncUserSubscription(String userId) async {
    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'platform': defaultTargetPlatform.name},
    );
    await _checkCurrentSubscription();
  }

  // Helper method to run operations with consistent state handling
  Future<Either<Failure, T>> _runOperation<T>(
    PurchaseOperation operation,
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentOperation: operation,
    );

    final result = await action();

    result.fold((failure) {
      state = state.copyWith(
        error: PremiumError(
          type: PremiumErrorType.unknown,
          message: failure.message,
        ),
      );
    }, (_) {});

    state = state.copyWith(isLoading: false, currentOperation: null);

    return result;
  }

  // Refactor _loadAvailableProducts to use the helper
  Future<void> _loadAvailableProducts() async {
    final result = await _runOperation<List<ProductInfo>>(
      PurchaseOperation.loadProducts,
      () => _subscriptionRepository.getPlantisProducts(),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Erro ao carregar produtos: ${failure.message}');
        }
      },
      (products) {
        state = state.copyWith(availableProducts: products);
      },
    );
  }

  // Refactor _checkCurrentSubscription
  Future<void> _checkCurrentSubscription() async {
    if (_simpleSubscriptionSyncService != null) {
      await _runOperation<bool>(
        PurchaseOperation.loadProducts,
        () => _simpleSubscriptionSyncService!.hasActiveSubscriptionForApp(
          'plantis',
        ),
      );
    } else {
      final result = await _runOperation<SubscriptionEntity?>(
        PurchaseOperation.loadProducts,
        () => _subscriptionRepository.getCurrentSubscription(),
      );
      result.fold((failure) {}, (subscription) {
        state = state.copyWith(currentSubscription: subscription);
      });
    }
  }

  // Refactor purchaseProduct
  Future<bool> purchaseProduct(String productId) async {
    final result = await _runOperation<SubscriptionEntity>(
      PurchaseOperation.purchase,
      () => _subscriptionRepository.purchaseProduct(productId: productId),
    );

    return result.fold((failure) => false, (subscription) async {
      state = state.copyWith(currentSubscription: subscription);
      return true;
    });
  }

  // Refactor restorePurchases
  Future<bool> restorePurchases() async {
    final result = await _runOperation<List<SubscriptionEntity>>(
      PurchaseOperation.restore,
      () => _subscriptionRepository.restorePurchases(),
    );

    return result.fold((failure) => false, (subscriptions) {
      if (subscriptions.isNotEmpty) {
        final active = subscriptions.where((s) => s.isActive).toList();
        if (active.isNotEmpty) {
          state = state.copyWith(currentSubscription: active.first);
        }
      }
      return true;
    });
  }

  Future<String?> getManagementUrl() async {
    final result = await _subscriptionRepository.getManagementUrl();

    return result.fold((failure) => null, (url) => url);
  }

  Future<bool> checkEligibilityForTrial(String productId) async {
    final result = await _subscriptionRepository.isEligibleForTrial(
      productId: productId,
    );

    return result.fold((failure) => false, (isEligible) => isEligible);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentOperation() {
    state = state.copyWith(currentOperation: null);
  }

  bool canCreateUnlimitedPlants() => state.isPremium;
  bool canAccessAdvancedFeatures() => state.isPremium;
  bool canExportData() => state.isPremium;
  bool canUseCustomReminders() => state.isPremium;
  bool canAccessPremiumThemes() => state.isPremium;
  bool canBackupToCloud() => state.isPremium;

  bool hasFeature(String featureId) {
    if (!state.isPremium) return false;
    const premiumFeatures = [
      'unlimited_plants',
      'advanced_reminders',
      'export_data',
      'custom_themes',
      'cloud_backup',
      'detailed_analytics',
      'plant_identification',
      'disease_diagnosis',
    ];

    return premiumFeatures.contains(featureId);
  }
}

// Dependency providers (to be defined in DI setup)
@riverpod
ISubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  throw UnimplementedError('Define in DI setup');
}

@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  throw UnimplementedError('Define in DI setup');
}

@riverpod
SimpleSubscriptionSyncService? simpleSubscriptionSyncService(
  SimpleSubscriptionSyncServiceRef ref,
) {
  throw UnimplementedError('Define in DI setup');
}

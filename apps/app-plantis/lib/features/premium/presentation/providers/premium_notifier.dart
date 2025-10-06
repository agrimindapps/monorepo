import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/widgets/loading_overlay.dart';

part 'premium_notifier.g.dart';

/// State for premium subscription management
class PremiumState {
  final SubscriptionEntity? currentSubscription;
  final List<ProductInfo> availableProducts;
  final bool isLoading;
  final String? errorMessage;
  final PurchaseOperation? currentOperation;

  const PremiumState({
    this.currentSubscription,
    this.availableProducts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentOperation,
  });

  PremiumState copyWith({
    SubscriptionEntity? currentSubscription,
    List<ProductInfo>? availableProducts,
    bool? isLoading,
    String? errorMessage,
    PurchaseOperation? currentOperation,
    bool clearError = false,
    bool clearSubscription = false,
    bool clearOperation = false,
  }) {
    return PremiumState(
      currentSubscription: clearSubscription
          ? null
          : (currentSubscription ?? this.currentSubscription),
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentOperation:
          clearOperation ? null : (currentOperation ?? this.currentOperation),
    );
  }
  bool get isPremium => currentSubscription?.isActive ?? false;
  bool get isInTrial => currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => true; // Simplified

  String get subscriptionStatus {
    if (currentSubscription == null) return 'Gratuito';
    if (currentSubscription!.isActive) {
      if (currentSubscription!.isInTrial) return 'Trial';
      return 'Premium';
    }
    return 'Expirado';
  }

  DateTime? get expirationDate => currentSubscription?.expirationDate;
  bool canCreateUnlimitedPlants() => isPremium;
  bool canAccessAdvancedFeatures() => isPremium;
  bool canExportData() => isPremium;
  bool canUseCustomReminders() => isPremium;
  bool canAccessPremiumThemes() => isPremium;
  bool canBackupToCloud() => isPremium;

  bool hasFeature(String featureId) {
    if (!isPremium) return false;

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

/// Notifier for premium subscription management
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  late final ISubscriptionRepository _subscriptionRepository;
  late final IAuthRepository _authRepository;
  late final SimpleSubscriptionSyncService? _simpleSubscriptionSyncService;

  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<SubscriptionEntity?>? _syncSubscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;

  @override
  Future<PremiumState> build() async {
    _subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    _authRepository = ref.read(authRepositoryProvider);
    _simpleSubscriptionSyncService =
        ref.read(simpleSubscriptionSyncServiceProvider);
    ref.onDispose(() {
      _subscriptionStream?.cancel();
      _syncSubscriptionStream?.cancel();
      _authStream?.cancel();

      if (kDebugMode) {
        debugPrint('[PremiumNotifier] Disposed successfully');
      }
    });
    await _loadAvailableProducts();
    await _checkCurrentSubscription();
    _setupSubscriptionStreams();
    _setupAuthStream();

    return const PremiumState();
  }

  void _setupSubscriptionStreams() {
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream = _simpleSubscriptionSyncService
          .subscriptionStatus
          .listen(
            (subscription) {
              state = AsyncValue.data(
                (state.valueOrNull ?? const PremiumState()).copyWith(
                  currentSubscription: subscription,
                ),
              );
            },
            onError: (Object error) {
              state = AsyncValue.data(
                (state.valueOrNull ?? const PremiumState()).copyWith(
                  errorMessage: error.toString(),
                ),
              );
            },
          );
    } else {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
        (subscription) async {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              currentSubscription: subscription,
            ),
          );
        },
        onError: (Object error) {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              errorMessage: error.toString(),
            ),
          );
        },
      );
    }
  }

  void _setupAuthStream() {
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            clearSubscription: true,
          ),
        );
      }
    });
  }

  Future<void> _syncUserSubscription(String userId) async {
    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'platform': defaultTargetPlatform.name},
    );
    await _checkCurrentSubscription();
  }

  Future<void> _checkCurrentSubscription() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const PremiumState()).copyWith(
        isLoading: true,
        currentOperation: PurchaseOperation.loadProducts,
        clearError: true,
      ),
    );
    if (_simpleSubscriptionSyncService != null) {
      final result = await _simpleSubscriptionSyncService
          .hasActiveSubscriptionForApp('plantis');

      result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              errorMessage: failure.message,
              isLoading: false,
              clearOperation: true,
            ),
          );
        },
        (hasSubscription) {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              isLoading: false,
              clearOperation: true,
            ),
          );
        },
      );
    } else {
      final result = await _subscriptionRepository.getCurrentSubscription();

      result.fold(
        (failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              errorMessage: failure.message,
              isLoading: false,
              clearOperation: true,
            ),
          );
        },
        (subscription) {
          state = AsyncValue.data(
            (state.valueOrNull ?? const PremiumState()).copyWith(
              currentSubscription: subscription,
              isLoading: false,
              clearOperation: true,
            ),
          );
        },
      );
    }
  }

  Future<void> _loadAvailableProducts() async {
    final result = await _subscriptionRepository.getPlantisProducts();

    result.fold(
      (failure) {
        debugPrint('Erro ao carregar produtos: ${failure.message}');
      },
      (products) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            availableProducts: products,
          ),
        );
      },
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const PremiumState()).copyWith(
        isLoading: true,
        currentOperation: PurchaseOperation.purchase,
        clearError: true,
      ),
    );

    final result = await _subscriptionRepository.purchaseProduct(
      productId: productId,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
        return false;
      },
      (subscription) async {
        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            currentSubscription: subscription,
            isLoading: false,
            clearOperation: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> restorePurchases() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const PremiumState()).copyWith(
        isLoading: true,
        currentOperation: PurchaseOperation.restore,
        clearError: true,
      ),
    );

    final result = await _subscriptionRepository.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
        return false;
      },
      (subscriptions) {
        if (subscriptions.isNotEmpty) {
          final activeSubscriptions =
              subscriptions.where((s) => s.isActive).toList();

          if (activeSubscriptions.isNotEmpty) {
            state = AsyncValue.data(
              (state.valueOrNull ?? const PremiumState()).copyWith(
                currentSubscription: activeSubscriptions.first,
              ),
            );
          }
        }

        state = AsyncValue.data(
          (state.valueOrNull ?? const PremiumState()).copyWith(
            isLoading: false,
            clearOperation: true,
          ),
        );
        return true;
      },
    );
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
    state = AsyncValue.data(
      (state.valueOrNull ?? const PremiumState()).copyWith(clearError: true),
    );
  }

  void clearCurrentOperation() {
    state = AsyncValue.data(
      (state.valueOrNull ?? const PremiumState()).copyWith(
        clearOperation: true,
      ),
    );
  }
}
@riverpod
ISubscriptionRepository subscriptionRepository(Ref ref) {
  return GetIt.instance<ISubscriptionRepository>();
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  return GetIt.instance<IAuthRepository>();
}

@riverpod
SimpleSubscriptionSyncService? simpleSubscriptionSyncService(Ref ref) {
  try {
    return GetIt.instance<SimpleSubscriptionSyncService>();
  } catch (e) {
    return null; // Service is optional
  }
}

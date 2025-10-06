import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/widgets/loading_overlay.dart';

part 'premium_notifier.g.dart';

/// State para gerenciamento Premium básico
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

  PremiumState copyWith({
    SubscriptionEntity? currentSubscription,
    List<ProductInfo>? availableProducts,
    bool? isLoading,
    String? errorMessage,
    PurchaseOperation? currentOperation,
  }) {
    return PremiumState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentOperation: currentOperation,
    );
  }
}

/// Notifier para gerenciamento Premium básico do Plantis
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
    _simpleSubscriptionSyncService = ref.read(
      simpleSubscriptionSyncServiceProvider,
    );
    _setupSubscriptions();
    await _loadAvailableProducts();
    await _checkCurrentSubscription();

    return const PremiumState();
  }

  void _setupSubscriptions() {
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream = _simpleSubscriptionSyncService
          .subscriptionStatus
          .listen((subscription) {
            final currentState = state.valueOrNull ?? const PremiumState();
            state = AsyncValue.data(
              currentState.copyWith(currentSubscription: subscription),
            );
          });
    } else {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen((
        subscription,
      ) {
        final currentState = state.valueOrNull ?? const PremiumState();
        state = AsyncValue.data(
          currentState.copyWith(currentSubscription: subscription),
        );
      });
    }
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        final currentState = state.valueOrNull ?? const PremiumState();
        state = AsyncValue.data(
          currentState.copyWith(currentSubscription: null),
        );
      }
    });
    ref.onDispose(() {
      _subscriptionStream?.cancel();
      _syncSubscriptionStream?.cancel();
      _authStream?.cancel();
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
    final currentState = state.valueOrNull ?? const PremiumState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.loadProducts,
      ),
    );
    if (_simpleSubscriptionSyncService != null) {
      final result = await _simpleSubscriptionSyncService
          .hasActiveSubscriptionForApp('plantis');

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: failure.message,
              isLoading: false,
              currentOperation: null,
            ),
          );
        },
        (_) {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, currentOperation: null),
          );
        },
      );
    } else {
      final result = await _subscriptionRepository.getCurrentSubscription();

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              errorMessage: failure.message,
              isLoading: false,
              currentOperation: null,
            ),
          );
        },
        (subscription) {
          state = AsyncValue.data(
            currentState.copyWith(
              currentSubscription: subscription,
              isLoading: false,
              currentOperation: null,
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
        final currentState = state.valueOrNull ?? const PremiumState();
        state = AsyncValue.data(
          currentState.copyWith(availableProducts: products),
        );
      },
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    final currentState = state.valueOrNull ?? const PremiumState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.purchase,
      ),
    );

    final result = await _subscriptionRepository.purchaseProduct(
      productId: productId,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
        return false;
      },
      (subscription) {
        state = AsyncValue.data(
          currentState.copyWith(
            currentSubscription: subscription,
            isLoading: false,
            currentOperation: null,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> restorePurchases() async {
    final currentState = state.valueOrNull ?? const PremiumState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: PurchaseOperation.restore,
      ),
    );

    final result = await _subscriptionRepository.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
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
              currentState.copyWith(
                currentSubscription: activeSubscriptions.first,
                isLoading: false,
                currentOperation: null,
              ),
            );
          }
        } else {
          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, currentOperation: null),
          );
        }
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
    final currentState = state.valueOrNull ?? const PremiumState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }

  void clearCurrentOperation() {
    final currentState = state.valueOrNull ?? const PremiumState();
    state = AsyncValue.data(currentState.copyWith(currentOperation: null));
  }
  bool canCreateUnlimitedPlants() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool canAccessAdvancedFeatures() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool canExportData() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool canUseCustomReminders() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool canAccessPremiumThemes() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool canBackupToCloud() {
    final currentState = state.valueOrNull;
    return currentState?.isPremium ?? false;
  }

  bool hasFeature(String featureId) {
    final currentState = state.valueOrNull;
    if (!(currentState?.isPremium ?? false)) return false;

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
    return null;
  }
}

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/widgets/loading_overlay.dart';

// Add top‑level error handling types
enum PremiumErrorType { network, auth, purchase, unknown }

class PremiumError {
  final PremiumErrorType type;
  final String message;
  const PremiumError({required this.type, required this.message});
}

class PremiumProvider extends ChangeNotifier {
  final ISubscriptionRepository _subscriptionRepository;
  final IAuthRepository _authRepository;
  final SimpleSubscriptionSyncService? _simpleSubscriptionSyncService;

  SubscriptionEntity? _currentSubscription;
  List<ProductInfo> _availableProducts = [];
  bool _isLoading = false;
  PremiumError? _error; // New typed error field
  PurchaseOperation? _currentOperation;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<SubscriptionEntity?>? _syncSubscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;

  PremiumProvider({
    required ISubscriptionRepository subscriptionRepository,
    required IAuthRepository authRepository,
    SimpleSubscriptionSyncService? simpleSubscriptionSyncService,
  }) : _subscriptionRepository = subscriptionRepository,
       _authRepository = authRepository,
       _simpleSubscriptionSyncService = simpleSubscriptionSyncService {
    _initialize();
  }
  SubscriptionEntity? get currentSubscription => _currentSubscription;
  List<ProductInfo> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  PremiumError? get error => _error;
  bool get isPremium => _currentSubscription?.isActive ?? false;
  bool get isInTrial => _currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => !_isAnonymousUser;
  PurchaseOperation? get currentOperation => _currentOperation;

  bool get _isAnonymousUser {
    return false; // Simplificado por agora - pode ser expandido depois
  }

  String get subscriptionStatus {
    if (_currentSubscription == null) return 'Gratuito';
    if (_currentSubscription!.isActive) {
      if (_currentSubscription!.isInTrial) return 'Trial';
      return 'Premium';
    }
    return 'Expirado';
  }

  DateTime? get expirationDate => _currentSubscription?.expirationDate;

  void _initialize() {
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream = _simpleSubscriptionSyncService
          .subscriptionStatus
          .listen(
            (subscription) {
              _currentSubscription = subscription;
              notifyListeners();
            },
            onError: (Object error) {
              _error = PremiumError(
                type: PremiumErrorType.unknown,
                message: error.toString(),
              );
              notifyListeners();
            },
          );
    } else {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
        (subscription) async {
          _currentSubscription = subscription;
          notifyListeners();
        },
        onError: (Object error) {
          _error = PremiumError(
            type: PremiumErrorType.unknown,
            message: error.toString(),
          );
          notifyListeners();
        },
      );
    }
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        _currentSubscription = null;
        notifyListeners();
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
    _isLoading = true;
    _error = null;
    _currentOperation = operation;
    notifyListeners();

    final result = await action();

    result.fold((failure) {
      // Map generic failure to typed error (could be refined later)
      _error = PremiumError(
        type: PremiumErrorType.unknown,
        message: failure.message,
      );
    }, (_) {});

    _isLoading = false;
    _currentOperation = null;
    notifyListeners();
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
        _availableProducts = products;
        notifyListeners();
      },
    );
  }

  // Refactor _checkCurrentSubscription
  Future<void> _checkCurrentSubscription() async {
    if (_simpleSubscriptionSyncService != null) {
      await _runOperation<bool>(
        PurchaseOperation.loadProducts,
        () => _simpleSubscriptionSyncService.hasActiveSubscriptionForApp(
          'plantis',
        ),
      );
    } else {
      final result = await _runOperation<SubscriptionEntity?>(
        PurchaseOperation.loadProducts,
        () => _subscriptionRepository.getCurrentSubscription(),
      );
      result.fold((failure) {}, (subscription) {
        _currentSubscription = subscription;
        notifyListeners();
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
      _currentSubscription = subscription;
      notifyListeners();
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
          _currentSubscription = active.first;
        }
      }
      notifyListeners();
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
    _error = null;
    notifyListeners();
  }

  void clearCurrentOperation() {
    _currentOperation = null;
    notifyListeners();
  }

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

  @override
  void dispose() {
    _subscriptionStream?.cancel();
    _subscriptionStream = null;

    _syncSubscriptionStream?.cancel();
    _syncSubscriptionStream = null;

    _authStream?.cancel();
    _authStream = null;

    if (kDebugMode) {
      debugPrint('[PremiumProvider] Disposed successfully');
    }

    super.dispose();
  }
}

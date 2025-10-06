import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../data/services/subscription_sync_service.dart';

/// Provider melhorado para gerenciamento Premium do Plantis com sincronização cross-device real
class PremiumProviderImproved extends ChangeNotifier {
  final ISubscriptionRepository _subscriptionRepository;
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analytics;
  late final SubscriptionSyncService _syncService;

  SubscriptionEntity? _currentSubscription;
  List<ProductInfo> _availableProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  PurchaseOperation? _currentOperation;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;
  StreamSubscription<PlantisSubscriptionSyncEvent>? _syncEventsStream;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  List<String> _premiumFeaturesEnabled = [];
  Map<String, dynamic>? _plantLimits;
  int _syncRetryCount = 0;
  PlantisSubscriptionSyncEvent? _lastSyncEvent;

  PremiumProviderImproved({
    required ISubscriptionRepository subscriptionRepository,
    required IAuthRepository authRepository,
    required IAnalyticsRepository analytics,
  }) : _subscriptionRepository = subscriptionRepository,
       _authRepository = authRepository,
       _analytics = analytics {
    _syncService = SubscriptionSyncService(
      authRepository: authRepository,
      subscriptionRepository: subscriptionRepository,
      analytics: analytics,
    );
    _initialize();
  }
  SubscriptionEntity? get currentSubscription => _currentSubscription;
  List<ProductInfo> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _currentSubscription?.isActive ?? false;
  bool get isInTrial => _currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => !_isAnonymousUser;
  PurchaseOperation? get currentOperation => _currentOperation;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  List<String> get premiumFeaturesEnabled => _premiumFeaturesEnabled;
  Map<String, dynamic>? get plantLimits => _plantLimits;
  int get syncRetryCount => _syncRetryCount;
  PlantisSubscriptionSyncEvent? get lastSyncEvent => _lastSyncEvent;
  bool get hasSyncErrors =>
      _lastSyncEvent?.type == PlantisSubscriptionSyncEventType.failed;
  String? get syncErrorMessage => hasSyncErrors ? _lastSyncEvent?.error : null;

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
    _syncEventsStream = _syncService.syncEventsStream.listen(
      (event) async {
        _lastSyncEvent = event;

        switch (event.type) {
          case PlantisSubscriptionSyncEventType.success:
            _isSyncing = false;
            _lastSyncAt = event.syncedAt;
            _syncRetryCount = 0;
            _premiumFeaturesEnabled = event.premiumFeaturesEnabled ?? [];
            await _loadPlantLimits();
            break;

          case PlantisSubscriptionSyncEventType.failed:
            _isSyncing = false;
            _syncRetryCount = event.retryCount ?? 0;
            _errorMessage = event.error;
            break;

          case PlantisSubscriptionSyncEventType.purchased:
            await _handlePurchaseEvent(event);
            break;

          case PlantisSubscriptionSyncEventType.cancelled:
            await _handleCancellationEvent(event);
            break;

          case PlantisSubscriptionSyncEventType.expired:
            await _handleExpirationEvent(event);
            break;

          default:
            break;
        }

        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Erro na sincronização: $error';
        _isSyncing = false;
        notifyListeners();
      },
    );
    _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
      (subscription) async {
        _currentSubscription = subscription;
        await _triggerSync();

        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
    _syncService.getRealtimeSubscriptionStream().listen(
      (subscription) {
        if (subscription != _currentSubscription) {
          _currentSubscription = subscription;
          notifyListeners();
        }
      },
      onError: (Object error) {
        debugPrint('[PremiumProvider] Erro no stream Firebase: $error');
      },
    );
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        _resetSubscriptionState();
      }
    });
    _loadAvailableProducts();
    _checkCurrentSubscription();
    _syncService.startAutoSync();
  }

  Future<void> _syncUserSubscription(String userId) async {
    try {
      await _subscriptionRepository.setUser(
        userId: userId,
        attributes: {
          'app': 'plantis',
          'platform': defaultTargetPlatform.name,
          'version': await _getAppVersion(),
          'syncEnabled': 'true',
        },
      );
      await _checkCurrentSubscription();
      await _triggerSync();
    } catch (e) {
      debugPrint('[PremiumProvider] Erro ao sincronizar usuário: $e');
    }
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      notifyListeners();

      await _syncService.syncSubscriptionStatus();
    } catch (e) {
      debugPrint('[PremiumProvider] Erro na sincronização: $e');
      _errorMessage = 'Erro na sincronização: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _resetSubscriptionState() {
    _currentSubscription = null;
    _premiumFeaturesEnabled = [];
    _plantLimits = null;
    _lastSyncAt = null;
    _syncRetryCount = 0;
    _lastSyncEvent = null;
    notifyListeners();
  }

  Future<void> _checkCurrentSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = PurchaseOperation.loadProducts;
    notifyListeners();

    final result = await _subscriptionRepository.getCurrentSubscription();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
      (subscription) {
        _currentSubscription = subscription;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
    );
  }

  Future<void> _loadAvailableProducts() async {
    final result = await _subscriptionRepository.getPlantisProducts();

    result.fold(
      (failure) {
        debugPrint('Erro ao carregar produtos: ${failure.message}');
      },
      (products) {
        _availableProducts = products;
        notifyListeners();
      },
    );
  }

  Future<bool> purchaseProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = PurchaseOperation.purchase;
    notifyListeners();

    final result = await _subscriptionRepository.purchaseProduct(
      productId: productId,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
        return false;
      },
      (subscription) async {
        _currentSubscription = subscription;
        await _triggerSync();
        final product = _availableProducts.firstWhere(
          (p) => p.productId == productId,
          orElse:
              () => ProductInfo(
                productId: productId,
                title: '',
                description: '',
                price: 0.0,
                priceString: '',
                currencyCode: 'BRL',
              ),
        );

        await _syncService.logPurchaseEvent(
          productId: productId,
          price: product.price,
          currency: product.currencyCode,
        );

        await _analytics.logEvent(
          'plantis_purchase_success',
          parameters: {
            'product_id': productId,
            'price': product.price.toString(),
            'tier': subscription.tier.name,
          },
        );

        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = PurchaseOperation.restore;
    notifyListeners();

    final result = await _subscriptionRepository.restorePurchases();

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
        return false;
      },
      (subscriptions) {
        if (subscriptions.isNotEmpty) {
          final activeSubscriptions =
              subscriptions.where((s) => s.isActive).toList();

          if (activeSubscriptions.isNotEmpty) {
            _currentSubscription = activeSubscriptions.first;
          }
        }
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
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
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentOperation() {
    _currentOperation = null;
    notifyListeners();
  }
  bool canCreateUnlimitedPlants() {
    final maxPlants = _plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 || isPremium;
  }

  bool canAccessAdvancedFeatures() =>
      isPremium && _premiumFeaturesEnabled.contains('advanced_reminders');
  bool canExportData() =>
      isPremium && _premiumFeaturesEnabled.contains('export_data');
  bool canUseCustomReminders() =>
      isPremium && _premiumFeaturesEnabled.contains('advanced_reminders');
  bool canAccessPremiumThemes() =>
      isPremium && _premiumFeaturesEnabled.contains('custom_themes');
  bool canBackupToCloud() =>
      isPremium && _premiumFeaturesEnabled.contains('cloud_backup');
  bool canIdentifyPlants() =>
      isPremium && _premiumFeaturesEnabled.contains('plant_identification');
  bool canDiagnoseDiseases() =>
      isPremium && _premiumFeaturesEnabled.contains('disease_diagnosis');
  bool canUseWeatherNotifications() =>
      isPremium &&
      _premiumFeaturesEnabled.contains('weather_based_notifications');
  bool canUseCareCalendar() =>
      isPremium && _premiumFeaturesEnabled.contains('care_calendar');
  bool hasFeature(String featureId) {
    if (!isPremium) return false;
    return _premiumFeaturesEnabled.contains(featureId);
  }
  int getCurrentPlantLimit() {
    final maxPlants = _plantLimits?['maxPlants'] as int?;
    return maxPlants == -1 ? 999999 : (maxPlants ?? 5); // 5 é o limite gratuito
  }
  bool canCreateMorePlants(int currentPlantCount) {
    if (canCreateUnlimitedPlants()) return true;
    return currentPlantCount < getCurrentPlantLimit();
  }

  Future<void> _handlePurchaseEvent(PlantisSubscriptionSyncEvent event) async {
    await _analytics.logEvent(
      'plantis_purchase_synced',
      parameters: {
        'product_id': event.productId ?? 'unknown',
        'purchased_at': event.purchasedAt?.toIso8601String() ?? 'unknown',
      },
    );
    await _checkCurrentSubscription();
    await _loadPlantLimits();
  }

  Future<void> _handleCancellationEvent(
    PlantisSubscriptionSyncEvent event,
  ) async {
    await _analytics.logEvent(
      'plantis_cancellation_synced',
      parameters: {
        'reason': event.reason ?? 'unknown',
        'expires_at': event.expiresAt?.toIso8601String() ?? 'unknown',
      },
    );
  }

  Future<void> _handleExpirationEvent(
    PlantisSubscriptionSyncEvent event,
  ) async {
    await _analytics.logEvent(
      'plantis_expiration_synced',
      parameters: {
        'expired_at': event.expiredAt?.toIso8601String() ?? 'unknown',
      },
    );
    _premiumFeaturesEnabled = [];
    _plantLimits = {'maxPlants': 5, 'canCreateCustomCategories': false};
    notifyListeners();
  }

  Future<void> _loadPlantLimits() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return;
      _plantLimits = {
        'maxPlants': isPremium ? -1 : 5,
        'canCreateCustomCategories': isPremium,
        'canImportPlantData': isPremium,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('[PremiumProvider] Erro ao carregar limites: $e');
    }
  }

  Future<String> _getAppVersion() async {
    return '1.0.0';
  }

  /// Força uma nova sincronização manual
  Future<void> forceSyncSubscription() async {
    await _triggerSync();
  }

  /// Limpa todos os erros de sincronização
  void clearSyncErrors() {
    _errorMessage = null;
    _syncRetryCount = 0;
    _lastSyncEvent = null;
    notifyListeners();
  }

  /// Obtém status de sincronização para UI
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncAt': _lastSyncAt?.toIso8601String(),
      'hasErrors': hasSyncErrors,
      'errorMessage': syncErrorMessage,
      'retryCount': _syncRetryCount,
      'featuresCount': _premiumFeaturesEnabled.length,
    };
  }

  /// Obtém estatísticas detalhadas para debug/admin
  Map<String, dynamic> getDebugInfo() {
    return {
      'subscription': {
        'isActive': isPremium,
        'isInTrial': isInTrial,
        'tier': _currentSubscription?.tier.name,
        'productId': _currentSubscription?.productId,
        'expirationDate': expirationDate?.toIso8601String(),
      },
      'sync': getSyncStatus(),
      'features': {
        'enabled': _premiumFeaturesEnabled,
        'plantLimits': _plantLimits,
      },
      'products':
          _availableProducts
              .map((p) => {'id': p.productId, 'price': p.priceString})
              .toList(),
    };
  }

  @override
  void dispose() {
    _syncService.stopAutoSync();
    _subscriptionStream?.cancel();
    _subscriptionStream = null;

    _authStream?.cancel();
    _authStream = null;

    _syncEventsStream?.cancel();
    _syncEventsStream = null;
    _syncService.dispose();

    if (kDebugMode) {
      debugPrint('[PremiumProviderImproved] Disposed successfully');
    }

    super.dispose();
  }
}

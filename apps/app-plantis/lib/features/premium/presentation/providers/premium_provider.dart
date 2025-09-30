import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/widgets/loading_overlay.dart';
// import '../../data/services/subscription_sync_service.dart'; // Removido - usar PremiumProviderImproved para sincronização

class PremiumProvider extends ChangeNotifier {
  final ISubscriptionRepository _subscriptionRepository;
  final IAuthRepository _authRepository;
  final SimpleSubscriptionSyncService? _simpleSubscriptionSyncService;

  SubscriptionEntity? _currentSubscription;
  List<ProductInfo> _availableProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
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

  // Getters
  SubscriptionEntity? get currentSubscription => _currentSubscription;
  List<ProductInfo> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _currentSubscription?.isActive ?? false;
  bool get isInTrial => _currentSubscription?.isInTrial ?? false;
  bool get canPurchasePremium => !_isAnonymousUser;
  PurchaseOperation? get currentOperation => _currentOperation;

  bool get _isAnonymousUser {
    // Verifica se o usuário atual é anônimo através do AuthRepository
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
    // Escuta mudanças na assinatura via SimpleSubscriptionSyncService (NOVO)
    if (_simpleSubscriptionSyncService != null) {
      _syncSubscriptionStream = _simpleSubscriptionSyncService
          .subscriptionStatus
          .listen(
            (subscription) {
              _currentSubscription = subscription;
              notifyListeners();
            },
            onError: (Object error) {
              _errorMessage = error.toString();
              notifyListeners();
            },
          );
    } else {
      // Fallback para versão original (compatibilidade)
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
        (subscription) async {
          _currentSubscription = subscription;
          notifyListeners();
        },
        onError: (Object error) {
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    }

    // Escuta mudanças de autenticação para sincronizar usuário
    _authStream = _authRepository.currentUser.listen((user) {
      if (user != null) {
        _syncUserSubscription(user.id);
      } else {
        _currentSubscription = null;
        notifyListeners();
      }
    });

    // Carrega produtos disponíveis
    _loadAvailableProducts();

    // Verifica assinatura atual
    _checkCurrentSubscription();
  }

  Future<void> _syncUserSubscription(String userId) async {
    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'platform': defaultTargetPlatform.name},
    );
    await _checkCurrentSubscription();
  }

  Future<void> _checkCurrentSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = PurchaseOperation.loadProducts;
    notifyListeners();

    // Usa SimpleSubscriptionSyncService se disponível (NOVO)
    if (_simpleSubscriptionSyncService != null) {
      final result = await _simpleSubscriptionSyncService
          .hasActiveSubscriptionForApp('plantis');

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _isLoading = false;
          _currentOperation = null;
          notifyListeners();
        },
        (hasSubscription) {
          // A subscription será atualizada via stream
          // Apenas atualiza estado de loading
          _isLoading = false;
          _currentOperation = null;
          notifyListeners();
        },
      );
    } else {
      // Fallback para versão original
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

        // Nota: Versão simplificada - sem sincronização avançada
        // Use PremiumProviderImproved para funcionalidades completas

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
          // Pega a assinatura mais recente ativa
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

  // Métodos para verificar funcionalidades específicas
  bool canCreateUnlimitedPlants() => isPremium;
  bool canAccessAdvancedFeatures() => isPremium;
  bool canExportData() => isPremium;
  bool canUseCustomReminders() => isPremium;
  bool canAccessPremiumThemes() => isPremium;
  bool canBackupToCloud() => isPremium;

  // Verifica se uma funcionalidade específica está disponível
  bool hasFeature(String featureId) {
    if (!isPremium) return false;

    // Lista de features premium
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
    // Cancel all stream subscriptions to prevent memory leaks
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

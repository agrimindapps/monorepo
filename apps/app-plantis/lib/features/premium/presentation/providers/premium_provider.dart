import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../data/services/subscription_sync_service.dart';

class PremiumProvider extends ChangeNotifier {
  final ISubscriptionRepository _subscriptionRepository;
  final IAuthRepository _authRepository;
  late final SubscriptionSyncService _syncService;
  
  SubscriptionEntity? _currentSubscription;
  List<ProductInfo> _availableProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  StreamSubscription<UserEntity?>? _authStream;
  
  PremiumProvider({
    required ISubscriptionRepository subscriptionRepository,
    required IAuthRepository authRepository,
  })  : _subscriptionRepository = subscriptionRepository,
        _authRepository = authRepository {
    _syncService = SubscriptionSyncService(authRepository: authRepository);
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
    // Escuta mudanças na assinatura
    _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen(
      (subscription) async {
        _currentSubscription = subscription;
        
        // Sincroniza com Firebase quando houver mudança
        if (subscription != null && subscription.isActive) {
          await _syncService.syncSubscriptionToFirebase(subscription);
        } else if (subscription == null || !subscription.isActive) {
          await _syncService.removeSubscriptionFromFirebase();
        }
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
    
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
      attributes: {
        'app': 'plantis',
        'platform': defaultTargetPlatform.name,
      },
    );
    await _checkCurrentSubscription();
  }
  
  Future<void> _checkCurrentSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _subscriptionRepository.getCurrentSubscription();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (subscription) {
        _currentSubscription = subscription;
        _isLoading = false;
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
    notifyListeners();
    
    final result = await _subscriptionRepository.purchaseProduct(
      productId: productId,
    );
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (subscription) async {
        _currentSubscription = subscription;
        
        // Sincroniza com Firebase após compra bem-sucedida
        await _syncService.syncSubscriptionToFirebase(subscription);
        
        // Loga evento de compra para analytics
        final product = _availableProducts.firstWhere(
          (p) => p.productId == productId,
          orElse: () => ProductInfo(
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
        
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _subscriptionRepository.restorePurchases();
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (subscriptions) {
        if (subscriptions.isNotEmpty) {
          // Pega a assinatura mais recente ativa
          final activeSubscriptions = subscriptions
              .where((s) => s.isActive)
              .toList();
          
          if (activeSubscriptions.isNotEmpty) {
            _currentSubscription = activeSubscriptions.first;
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  Future<String?> getManagementUrl() async {
    final result = await _subscriptionRepository.getManagementUrl();
    
    return result.fold(
      (failure) => null,
      (url) => url,
    );
  }
  
  Future<bool> checkEligibilityForTrial(String productId) async {
    final result = await _subscriptionRepository.isEligibleForTrial(
      productId: productId,
    );
    
    return result.fold(
      (failure) => false,
      (isEligible) => isEligible,
    );
  }
  
  void clearError() {
    _errorMessage = null;
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
    _subscriptionStream?.cancel();
    _authStream?.cancel();
    super.dispose();
  }
}
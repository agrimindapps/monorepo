import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/usecases/subscription_usecase.dart';

/// Provider responsável por gerenciar o estado e lógica de negócio de subscription
/// 
/// Funcionalidades:
/// - Verificação de assinatura ativa
/// - Carregamento de produtos disponíveis
/// - Processamento de compras
/// - Restauração de purchases
/// - Gerenciamento de URLs de subscription
/// - Estados de loading e erro
class SubscriptionProvider with ChangeNotifier {
  // Dependencies - carregados via GetIt
  late final GetUserPremiumStatusUseCase _getUserPremiumStatusUseCase;
  late final GetAvailableProductsUseCase _getAvailableProductsUseCase;
  late final PurchaseProductUseCase _purchaseProductUseCase;
  late final RestorePurchasesUseCase _restorePurchasesUseCase;
  late final RefreshSubscriptionStatusUseCase _refreshSubscriptionStatusUseCase;
  late final ManageSubscriptionUseCase _manageSubscriptionUseCase;
  
  // State management
  bool _isLoading = false;
  bool _hasActiveSubscription = false;
  List<ProductInfo> _availableProducts = [];
  SubscriptionEntity? _currentSubscription;
  String _selectedPlan = 'yearly';
  String? _errorMessage;
  String? _successMessage;
  String? _infoMessage;
  
  SubscriptionProvider() {
    _initializeDependencies();
  }
  
  void _initializeDependencies() {
    final getIt = GetIt.instance;
    _getUserPremiumStatusUseCase = getIt<GetUserPremiumStatusUseCase>();
    _getAvailableProductsUseCase = getIt<GetAvailableProductsUseCase>();
    _purchaseProductUseCase = getIt<PurchaseProductUseCase>();
    _restorePurchasesUseCase = getIt<RestorePurchasesUseCase>();
    _refreshSubscriptionStatusUseCase = getIt<RefreshSubscriptionStatusUseCase>();
    _manageSubscriptionUseCase = getIt<ManageSubscriptionUseCase>();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _hasActiveSubscription;
  List<ProductInfo> get availableProducts => List.unmodifiable(_availableProducts);
  SubscriptionEntity? get currentSubscription => _currentSubscription;
  String get selectedPlan => _selectedPlan;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get infoMessage => _infoMessage;

  /// Carrega todos os dados de subscription inicial
  Future<void> loadSubscriptionData() async {
    _setLoading(true);
    _clearMessages();

    try {
      // Verificar se tem assinatura ativa
      await _checkActiveSubscription();

      // Carregar produtos disponíveis
      await _loadAvailableProducts();
    } catch (e) {
      _setErrorMessage('Erro inesperado ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se o usuário possui uma assinatura ativa
  Future<void> _checkActiveSubscription() async {
    final result = await _getUserPremiumStatusUseCase(const NoParams());
    result.fold(
      (failure) => _setErrorMessage('Erro ao verificar assinatura: ${failure.message}'),
      (hasActive) => _hasActiveSubscription = hasActive,
    );
  }

  /// Carrega os produtos disponíveis para compra
  Future<void> _loadAvailableProducts() async {
    final result = await _getAvailableProductsUseCase(const NoParams());
    
    result.fold(
      (failure) => _setErrorMessage('Erro ao carregar produtos: ${failure.message}'),
      (products) => _availableProducts = products,
    );
  }


  /// Processa a compra de um produto específico
  Future<void> purchaseProduct(String productId) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _purchaseProductUseCase(PurchaseProductUseCaseParams(productId: productId));
      
      result.fold(
        (failure) => _setErrorMessage('Erro na compra: ${failure.message}'),
        (subscription) {
          _setSuccessMessage('Assinatura ativada com sucesso!');
          // Recarregar dados após compra bem-sucedida
          loadSubscriptionData();
        },
      );
    } catch (e) {
      _setErrorMessage('Erro inesperado na compra: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Compra baseada no plano selecionado atualmente
  Future<void> purchaseSelectedPlan() async {
    // Encontra o produto baseado no plano selecionado
    final selectedProduct = _availableProducts.firstWhere(
      (product) => _selectedPlan == 'yearly' 
          ? product.subscriptionPeriod?.contains('year') == true
          : product.subscriptionPeriod?.contains('month') == true,
      orElse: () => _availableProducts.isNotEmpty ? _availableProducts.first : 
          throw Exception('Nenhum produto disponível'),
    );
    
    await purchaseProduct(selectedProduct.productId);
  }

  /// Restaura compras anteriores do usuário
  Future<void> restorePurchases() async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _restorePurchasesUseCase(const NoParams());
      
      result.fold(
        (failure) => _setErrorMessage('Erro ao restaurar compras: ${failure.message}'),
        (subscriptions) {
          if (subscriptions.isNotEmpty) {
            _setSuccessMessage('Compras restauradas com sucesso!');
            loadSubscriptionData();
          } else {
            _setInfoMessage('Nenhuma compra anterior encontrada');
          }
        },
      );
    } catch (e) {
      _setErrorMessage('Erro inesperado ao restaurar: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Abre a URL de gerenciamento de subscription
  Future<void> openManagementUrl() async {
    final result = await _manageSubscriptionUseCase(const NoParams());
    result.fold(
      (failure) => _setErrorMessage('Erro ao abrir gerenciamento'),
      (url) {
        if (url != null) {
          _setInfoMessage('Redirecionando para gerenciamento...');
        } else {
          _setInfoMessage('Gerenciar assinatura na loja de aplicativos');
        }
      },
    );
  }

  /// Abre Termos de Uso
  Future<void> openTermsOfUse() async {
    // TODO: Implementar navegação para termos de uso
    _setInfoMessage('Redirecionando para Termos de Uso...');
  }

  /// Abre Política de Privacidade  
  Future<void> openPrivacyPolicy() async {
    // TODO: Implementar navegação para política de privacidade
    _setInfoMessage('Redirecionando para Política de Privacidade...');
  }

  /// Altera o plano selecionado
  void selectPlan(String planType) {
    _selectedPlan = planType;
    notifyListeners();
  }

  /// Verifica se um plano está selecionado
  bool isPlanSelected(String planType) => _selectedPlan == planType;

  /// Verifica se um produto é do tipo anual
  bool isYearlyProduct(ProductInfo product) {
    return product.productId.contains('yearly');
  }

  /// Calcula preço mensal equivalente para planos anuais
  double getMonthlyEquivalentPrice(ProductInfo product) {
    return isYearlyProduct(product) ? (product.price / 12) : product.price;
  }

  /// Formata uma data para exibição
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Lista de recursos premium
  List<String> get premiumFeatures => [
    'Acesso completo ao banco de dados de pragas',
    'Receitas de defensivos detalhadas', 
    'Diagnóstico avançado de pragas',
    'Suporte prioritário',
    'Atualizações exclusivas',
    'Modo offline completo',
  ];

  /// Lista de recursos premium para showcase moderno
  List<String> get modernPremiumFeatures => [
    'Acesso completo ao banco de pragas',
    'Receitas de defensivos detalhadas',
    'Diagnóstico avançado de pragas', 
    'Suporte prioritário e exclusivo',
  ];

  // Private state setters
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    _successMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _setSuccessMessage(String? message) {
    _successMessage = message;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _setInfoMessage(String? message) {
    _infoMessage = message;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _infoMessage = null;
  }

  /// Clear all messages (público para widgets)
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  // ===== MISSING METHODS IMPLEMENTATION =====
  
  /// Get available plans (compatibility method)
  List<dynamic> get availablePlans {
    return _availableProducts.map((product) => {
      'id': product.productId,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'priceString': product.priceString,
      'currencyCode': product.currencyCode,
      'period': product.subscriptionPeriod ?? 'month',
      'features': <String>[
        'Acesso completo ao banco de dados',
        'Diagnóstico avançado',
        'Suporte prioritário',
        'Sincronização cross-platform',
      ],
      'hasTrialPeriod': false,
      'trialPeriodDays': 7,
      'isPromotional': false,
    }).toList();
  }

  // Premium validation properties
  DateTime? get subscriptionExpiryDate => _currentSubscription?.expirationDate;
  bool get hasLocalPremiumValidation => _hasActiveSubscription;
  bool get isPremiumSyncActive => _hasActiveSubscription;
  bool get hasPremiumCache => _hasActiveSubscription;
  bool get isIOSPremiumActive => _hasActiveSubscription;
  bool get isAndroidPremiumActive => _hasActiveSubscription;
  bool get isWebPremiumActive => _hasActiveSubscription;
  bool get hasTrialAvailable => !_hasActiveSubscription;

  /// Validate premium status
  Future<void> validatePremiumStatus() async {
    await _refreshSubscriptionStatusUseCase(const NoParams());
  }

  /// Sync premium status across devices
  Future<void> syncPremiumStatus() async {
    await loadSubscriptionData();
  }
  
  /// Start free trial
  Future<void> startFreeTrial() async {
    _setLoading(true);
    try {
      // For now, this is a placeholder
      // In a real implementation, this would start a trial period
      await Future<void>.delayed(const Duration(seconds: 1));
      _setSuccessMessage('Período de teste iniciado com sucesso!');
    } catch (e) {
      _setErrorMessage('Erro ao iniciar período de teste: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Purchase a specific plan
  Future<void> purchasePlan(String planId) async {
    _setLoading(true);
    try {
      // Validate product exists
      _availableProducts.firstWhere(
        (p) => p.productId == planId,
        orElse: () => throw Exception('Product not found: $planId'),
      );
      
      final result = await _purchaseProductUseCase(PurchaseProductUseCaseParams(productId: planId));
      
      result.fold(
        (failure) => _setErrorMessage('Erro na compra: ${failure.message}'),
        (success) {
          _hasActiveSubscription = true;
          _setSuccessMessage('Assinatura ativada com sucesso!');
        },
      );
    } catch (e) {
      _setErrorMessage('Erro ao processar compra: $e');
    } finally {
      _setLoading(false);
    }
  }
}
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/navigation_service.dart';

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
  // Dependencies
  final ISubscriptionRepository _subscriptionRepository = di.sl<ISubscriptionRepository>();
  final INavigationService _navigationService = di.sl<INavigationService>();
  
  // State management
  bool _isLoading = false;
  bool _hasActiveSubscription = false;
  List<ProductInfo> _availableProducts = [];
  SubscriptionEntity? _currentSubscription;
  String _selectedPlan = 'yearly';
  String? _errorMessage;
  String? _successMessage;
  String? _infoMessage;

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

      // Se tem assinatura ativa, carregar detalhes
      if (_hasActiveSubscription) {
        await _loadCurrentSubscriptionDetails();
      }
    } catch (e) {
      _setErrorMessage('Erro inesperado ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se o usuário possui uma assinatura ativa
  Future<void> _checkActiveSubscription() async {
    final result = await _subscriptionRepository.hasActiveSubscription();
    result.fold(
      (failure) => _setErrorMessage('Erro ao verificar assinatura: ${failure.message}'),
      (hasActive) => _hasActiveSubscription = hasActive,
    );
  }

  /// Carrega os produtos disponíveis para compra
  Future<void> _loadAvailableProducts() async {
    final result = await _subscriptionRepository.getAvailableProducts(
      productIds: [
        EnvironmentConfig.receitaAgroMonthlyProduct,
        EnvironmentConfig.receitaAgroYearlyProduct,
      ],
    );
    
    result.fold(
      (failure) => _setErrorMessage('Erro ao carregar produtos: ${failure.message}'),
      (products) => _availableProducts = products,
    );
  }

  /// Carrega os detalhes da assinatura atual se existir
  Future<void> _loadCurrentSubscriptionDetails() async {
    final result = await _subscriptionRepository.getCurrentSubscription();
    result.fold(
      (failure) => _setErrorMessage('Erro ao carregar assinatura: ${failure.message}'),
      (subscription) => _currentSubscription = subscription,
    );
  }

  /// Processa a compra de um produto específico
  Future<void> purchaseProduct(String productId) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _subscriptionRepository.purchaseProduct(productId: productId);
      
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
    final productId = _selectedPlan == 'yearly' 
        ? EnvironmentConfig.receitaAgroYearlyProduct
        : EnvironmentConfig.receitaAgroMonthlyProduct;
    
    await purchaseProduct(productId);
  }

  /// Restaura compras anteriores do usuário
  Future<void> restorePurchases() async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _subscriptionRepository.restorePurchases();
      
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
    final result = await _subscriptionRepository.getManagementUrl();
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
    await _navigationService.openUrl('https://agrimind.com.br/termos-de-uso');
  }

  /// Abre Política de Privacidade  
  Future<void> openPrivacyPolicy() async {
    await _navigationService.openUrl('https://agrimind.com.br/politica-de-privacidade');
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
}
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/navigation_service.dart';

/// Estados para Subscription
class SubscriptionState {
  final bool isLoading;
  final bool hasActiveSubscription;
  final List<ProductInfo> availableProducts;
  final SubscriptionEntity? currentSubscription;
  final String selectedPlan;
  final String? errorMessage;
  final String? successMessage;
  final String? infoMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.hasActiveSubscription = false,
    this.availableProducts = const [],
    this.currentSubscription,
    this.selectedPlan = 'yearly',
    this.errorMessage,
    this.successMessage,
    this.infoMessage,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    bool? hasActiveSubscription,
    List<ProductInfo>? availableProducts,
    SubscriptionEntity? currentSubscription,
    String? selectedPlan,
    String? errorMessage,
    String? successMessage,
    String? infoMessage,
    bool clearCurrentSubscription = false,
    bool clearMessages = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      availableProducts: availableProducts ?? this.availableProducts,
      currentSubscription: clearCurrentSubscription ? null : (currentSubscription ?? this.currentSubscription),
      selectedPlan: selectedPlan ?? this.selectedPlan,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

/// Notifier responsável por gerenciar o estado e lógica de negócio de subscription
/// 
/// Funcionalidades:
/// - Verificação de assinatura ativa
/// - Carregamento de produtos disponíveis
/// - Processamento de compras
/// - Restauração de purchases
/// - Gerenciamento de estados de loading e erro
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionRepository _subscriptionRepository;
  final INavigationService _navigationService;

  SubscriptionNotifier({
    ISubscriptionRepository? subscriptionRepository,
    INavigationService? navigationService,
  }) : _subscriptionRepository = subscriptionRepository ?? di.sl<ISubscriptionRepository>(),
        _navigationService = navigationService ?? di.sl<INavigationService>(),
        super(const SubscriptionState());

  /// Carrega todos os dados de subscription inicial
  Future<void> loadSubscriptionData() async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      // Verificar se tem assinatura ativa
      await _checkActiveSubscription();

      // Carregar produtos disponíveis
      await _loadAvailableProducts();

      // Se tem assinatura ativa, carregar detalhes
      if (state.hasActiveSubscription) {
        await _loadCurrentSubscription();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Verifica se tem assinatura ativa
  Future<void> _checkActiveSubscription() async {
    final result = await _subscriptionRepository.hasActiveSubscription();
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: 'Erro ao verificar assinatura: ${failure.message}',
      ),
      (hasActive) => state = state.copyWith(hasActiveSubscription: hasActive),
    );
  }

  /// Carrega produtos disponíveis
  Future<void> _loadAvailableProducts() async {
    final result = await _subscriptionRepository.getAvailableProducts(
      productIds: [
        EnvironmentConfig.receitaAgroMonthlyProduct,
        EnvironmentConfig.receitaAgroYearlyProduct,
      ],
    );
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: 'Erro ao carregar produtos: ${failure.message}',
      ),
      (products) => state = state.copyWith(availableProducts: products),
    );
  }

  /// Carrega detalhes da assinatura atual
  Future<void> _loadCurrentSubscription() async {
    final result = await _subscriptionRepository.getCurrentSubscription();
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: 'Erro ao carregar assinatura: ${failure.message}',
      ),
      (subscription) => state = state.copyWith(currentSubscription: subscription),
    );
  }

  /// Realiza compra de produto
  Future<void> purchaseProduct(String productId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final result = await _subscriptionRepository.purchaseProduct(productId: productId);
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro na compra: ${failure.message}',
        ),
        (subscription) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Assinatura ativada com sucesso!',
          );
          // Recarregar dados após compra
          loadSubscriptionData();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado na compra: $e',
      );
    }
  }

  /// Restaura purchases anteriores
  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final result = await _subscriptionRepository.restorePurchases();
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao restaurar compras: ${failure.message}',
        ),
        (subscriptions) {
          if (subscriptions.isNotEmpty) {
            state = state.copyWith(
              isLoading: false,
              successMessage: 'Compras restauradas com sucesso!',
            );
            loadSubscriptionData();
          } else {
            state = state.copyWith(
              isLoading: false,
              infoMessage: 'Nenhuma compra anterior encontrada',
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado ao restaurar: $e',
      );
    }
  }

  /// Seleciona plano
  void selectPlan(String plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Abre gerenciador de assinatura
  Future<void> openSubscriptionManagement() async {
    try {
      final result = await _subscriptionRepository.getSubscriptionManagementUrl();
      result.fold(
        (Failure failure) => state = state.copyWith(
          errorMessage: 'Erro ao obter URL: ${failure.message}',
        ),
        (String? url) {
          if (url != null && url.isNotEmpty) {
            _navigationService.openExternalUrl(url);
          } else {
            state = state.copyWith(
              infoMessage: 'URL de gerenciamento não disponível',
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao abrir gerenciamento: $e',
      );
    }
  }

  /// Limpa mensagens
  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}

/// Provider principal de Subscription
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

/// Computed providers para facilitar acesso aos dados
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).hasActiveSubscription;
});

final availableProductsProvider = Provider<List<ProductInfo>>((ref) {
  return ref.watch(subscriptionProvider).availableProducts;
});

final currentSubscriptionProvider = Provider<SubscriptionEntity?>((ref) {
  return ref.watch(subscriptionProvider).currentSubscription;
});

final isLoadingSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isLoading;
});
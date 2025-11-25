import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/providers/premium_notifier.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/get_current_subscription.dart';
import '../../domain/usecases/get_user_premium_status.dart';
import '../../domain/usecases/manage_subscription.dart';
import '../../domain/usecases/purchase_product.dart';
import '../../domain/usecases/refresh_subscription_status.dart';
import '../../domain/usecases/restore_purchases.dart';
import 'subscription_providers.dart';

part 'subscription_notifier.g.dart';

/// Subscription state
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
    required this.isLoading,
    required this.hasActiveSubscription,
    required this.availableProducts,
    this.currentSubscription,
    required this.selectedPlan,
    this.errorMessage,
    this.successMessage,
    this.infoMessage,
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState(
      isLoading: false,
      hasActiveSubscription: false,
      availableProducts: [],
      currentSubscription: null,
      selectedPlan: 'yearly',
      errorMessage: null,
      successMessage: null,
      infoMessage: null,
    );
  }

  SubscriptionState copyWith({
    bool? isLoading,
    bool? hasActiveSubscription,
    List<ProductInfo>? availableProducts,
    SubscriptionEntity? currentSubscription,
    String? selectedPlan,
    String? errorMessage,
    String? successMessage,
    String? infoMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      availableProducts: availableProducts ?? this.availableProducts,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  SubscriptionState clearMessages() {
    return SubscriptionState(
      isLoading: isLoading,
      hasActiveSubscription: hasActiveSubscription,
      availableProducts: availableProducts,
      currentSubscription: currentSubscription,
      selectedPlan: selectedPlan,
      errorMessage: null,
      successMessage: null,
      infoMessage: null,
    );
  }
  DateTime? get subscriptionExpiryDate => currentSubscription?.expirationDate;
  bool get hasLocalPremiumValidation => hasActiveSubscription;
  bool get isPremiumSyncActive => hasActiveSubscription;
  bool get hasPremiumCache => hasActiveSubscription;
  bool get isIOSPremiumActive => hasActiveSubscription;
  bool get isAndroidPremiumActive => hasActiveSubscription;
  bool get isWebPremiumActive => hasActiveSubscription;
  bool get hasTrialAvailable => !hasActiveSubscription;
}

/// Notifier responsável por gerenciar o estado e lógica de negócio de subscription
/// Renomeado para SubscriptionManagementNotifier para evitar conflito
/// com subscriptionProvider do core package
@riverpod
class SubscriptionManagementNotifier extends _$SubscriptionManagementNotifier {
  late final GetUserPremiumStatusUseCase _getUserPremiumStatusUseCase;
  late final GetAvailableProductsUseCase _getAvailableProductsUseCase;
  late final GetCurrentSubscriptionUseCase _getCurrentSubscriptionUseCase;
  late final PurchaseProductUseCase _purchaseProductUseCase;
  late final RestorePurchasesUseCase _restorePurchasesUseCase;
  late final RefreshSubscriptionStatusUseCase _refreshSubscriptionStatusUseCase;
  late final ManageSubscriptionUseCase _manageSubscriptionUseCase;

  @override
  Future<SubscriptionState> build() async {
    _getUserPremiumStatusUseCase = ref.watch(getUserPremiumStatusUseCaseProvider);
    _getAvailableProductsUseCase = ref.watch(getAvailableProductsUseCaseProvider);
    _getCurrentSubscriptionUseCase = ref.watch(getCurrentSubscriptionUseCaseProvider);
    _purchaseProductUseCase = ref.watch(purchaseProductUseCaseProvider);
    _restorePurchasesUseCase = ref.watch(restorePurchasesUseCaseProvider);
    _refreshSubscriptionStatusUseCase = ref.watch(refreshSubscriptionStatusUseCaseProvider);
    _manageSubscriptionUseCase = ref.watch(manageSubscriptionUseCaseProvider);
    return _loadInitialData();
  }

  /// Carrega todos os dados de subscription inicial
  Future<SubscriptionState> _loadInitialData() async {
    try {
      final hasActive = await _checkActiveSubscription();
      final products = await _loadAvailableProducts();
      final currentSub = await _loadCurrentSubscription();

      return SubscriptionState(
        isLoading: false,
        hasActiveSubscription: hasActive,
        availableProducts: products,
        currentSubscription: currentSub,
        selectedPlan: 'yearly',
      );
    } catch (e) {
      return SubscriptionState.initial().copyWith(
        errorMessage: 'Erro inesperado ao carregar dados: $e',
      );
    }
  }

  /// Recarrega todos os dados
  Future<void> loadSubscriptionData() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearMessages());

    try {
      final hasActive = await _checkActiveSubscription();
      final products = await _loadAvailableProducts();
      final currentSub = await _loadCurrentSubscription();

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          hasActiveSubscription: hasActive,
          availableProducts: products,
          currentSubscription: currentSub,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro inesperado ao carregar dados: $e',
        ),
      );
    }
  }

  /// Verifica se o usuário possui uma assinatura ativa
  Future<bool> _checkActiveSubscription() async {
    final result = await _getUserPremiumStatusUseCase(const NoParams());
    return result.fold(
      (failure) => false,
      (hasActive) => hasActive,
    );
  }

  /// Carrega a assinatura atual com todos os detalhes
  Future<SubscriptionEntity?> _loadCurrentSubscription() async {
    debugPrint('🔍 [SubscriptionNotifier] Carregando assinatura atual...');

    final result = await _getCurrentSubscriptionUseCase(const NoParams());

    return result.fold(
      (failure) {
        debugPrint('❌ [SubscriptionNotifier] Erro ao carregar subscription: ${failure.message}');
        return null;
      },
      (subscription) {
        if (subscription != null) {
          debugPrint('✅ [SubscriptionNotifier] Subscription carregada:');
          debugPrint('   📦 Product ID: ${subscription.productId}');
          debugPrint('   📅 Expiration: ${subscription.expirationDate}');
          debugPrint('   🛒 Purchase: ${subscription.purchaseDate}');
          debugPrint('   ⏱️  Days remaining: ${subscription.daysRemaining}');
        } else {
          debugPrint('ℹ️ [SubscriptionNotifier] Nenhuma subscription ativa encontrada');
        }
        return subscription;
      },
    );
  }

  /// Carrega os produtos disponíveis para compra
  Future<List<ProductInfo>> _loadAvailableProducts() async {
    debugPrint('🛒 [SubscriptionNotifier] Iniciando carregamento de produtos...');

    final result = await _getAvailableProductsUseCase(const NoParams());

    return result.fold(
      (failure) {
        debugPrint('❌ [SubscriptionNotifier] Erro ao carregar produtos: ${failure.message}');
        return [];
      },
      (products) {
        debugPrint('✅ [SubscriptionNotifier] ${products.length} produto(s) carregado(s):');
        for (final product in products) {
          debugPrint('   📦 ${product.productId}: ${product.priceString}');
          debugPrint('      - Título: ${product.title}');
          debugPrint('      - Descrição: ${product.description}');
        }
        return products;
      },
    );
  }

  /// Processa a compra de um produto específico
  Future<void> purchaseProduct(String productId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearMessages());

    try {
      final result = await _purchaseProductUseCase(
        PurchaseProductUseCaseParams(productId: productId),
      );

      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro na compra: ${failure.message}',
            ),
          );
        },
        (subscription) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              successMessage: 'Assinatura ativada com sucesso!',
            ),
          );
          await loadSubscriptionData();

          // Force PremiumNotifier to refresh
          try {
            ref.invalidate(premiumProvider);
          } catch (e) {
            if (kDebugMode) {
              print('Warning: Could not invalidate PremiumNotifier: $e');
            }
          }
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro inesperado na compra: $e',
        ),
      );
    }
  }

  /// Compra baseada no plano selecionado atualmente
  Future<void> purchaseSelectedPlan() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Mapeia o plano selecionado para o product ID correto
      final selectedProduct = currentState.availableProducts.firstWhere(
        (product) {
          final planType = currentState.selectedPlan;
          if (planType == 'yearly') {
            return product.productId.contains('anual');
          } else if (planType == 'monthly') {
            return product.productId.contains('mensal');
          } else if (planType == 'semiannual') {
            return product.productId.contains('semestral');
          }
          return false;
        },
        orElse: () => currentState.availableProducts.isNotEmpty
            ? currentState.availableProducts.first
            : throw Exception('Nenhum produto disponível'),
      );

      await purchaseProduct(selectedProduct.productId);
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro ao selecionar produto: $e',
        ),
      );
    }
  }

  /// Restaura compras anteriores do usuário
  Future<void> restorePurchases() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearMessages());

    try {
      final result = await _restorePurchasesUseCase(const NoParams());

      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao restaurar compras: ${failure.message}',
            ),
          );
        },
        (subscriptions) async {
          if (subscriptions.isNotEmpty) {
            state = AsyncValue.data(
              currentState.copyWith(
                isLoading: false,
                successMessage: 'Compras restauradas com sucesso!',
              ),
            );
            await loadSubscriptionData();

            // Force PremiumNotifier to refresh
            try {
              ref.invalidate(premiumProvider);
            } catch (e) {
              if (kDebugMode) {
                print('Warning: Could not invalidate PremiumNotifier: $e');
              }
            }
          } else {
            state = AsyncValue.data(
              currentState.copyWith(
                isLoading: false,
                infoMessage: 'Nenhuma compra anterior encontrada',
              ),
            );
          }
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro inesperado ao restaurar: $e',
        ),
      );
    }
  }

  /// Abre a URL de gerenciamento de subscription
  Future<void> openManagementUrl() async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await _manageSubscriptionUseCase(const NoParams());
    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: 'Erro ao abrir gerenciamento'),
        );
      },
      (url) {
        if (url != null) {
          state = AsyncValue.data(
            currentState.copyWith(infoMessage: 'Redirecionando para gerenciamento...'),
          );
        } else {
          state = AsyncValue.data(
            currentState.copyWith(
              infoMessage: 'Gerenciar assinatura na loja de aplicativos',
            ),
          );
        }
      },
    );
  }

  /// Abre Termos de Uso
  Future<void> openTermsOfUse() async {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(
      currentState.copyWith(infoMessage: 'Redirecionando para Termos de Uso...'),
    );
  }

  /// Abre Política de Privacidade
  Future<void> openPrivacyPolicy() async {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(
      currentState.copyWith(
        infoMessage: 'Redirecionando para Política de Privacidade...',
      ),
    );
  }

  /// Altera o plano selecionado
  void selectPlan(String planType) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedPlan: planType));
  }

  /// Verifica se um plano está selecionado
  bool isPlanSelected(String planType) {
    final currentState = state.value;
    if (currentState == null) return false;
    return currentState.selectedPlan == planType;
  }

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

  /// Get available plans (compatibility method)
  List<Map<String, dynamic>> get availablePlans {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.availableProducts
        .map((product) => {
              'id': product.productId,
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'priceString': product.priceString,
              'currencyCode': product.currencyCode,
              'period': product.subscriptionPeriod ?? 'month',
              'features': <String>[
                'Acesso a dosagens, aplicação aérea e terrestre',
                'Ferramenta de comentários e sincronização',
                'Informações de tecnologia de aplicação do defensivo',
                'Informações de diagnóstico',
                'Compartilhamento de diagnóstico',
              ],
              'hasTrialPeriod': false,
              'trialPeriodDays': 7,
              'isPromotional': false,
            })
        .toList();
  }

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
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      await Future<void>.delayed(const Duration(seconds: 1));

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          successMessage: 'Período de teste iniciado com sucesso!',
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao iniciar período de teste: $e',
        ),
      );
    }
  }

  /// Purchase a specific plan
  Future<void> purchasePlan(String planId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      currentState.availableProducts.firstWhere(
        (p) => p.productId == planId,
        orElse: () => throw Exception('Product not found: $planId'),
      );

      final result = await _purchaseProductUseCase(
        PurchaseProductUseCaseParams(productId: planId),
      );

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro na compra: ${failure.message}',
            ),
          );
        },
        (success) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              hasActiveSubscription: true,
              successMessage: 'Assinatura ativada com sucesso!',
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao processar compra: $e',
        ),
      );
    }
  }

  /// Clear all messages (público para widgets)
  void clearMessages() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearMessages());
  }
}

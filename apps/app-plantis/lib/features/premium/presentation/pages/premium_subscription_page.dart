import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../managers/premium_managers_providers.dart';
import '../providers/premium_notifier.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_plans_widget.dart';

/// Riverpod Provider alias - PremiumProvider is now managed by Riverpod
/// Use PremiumProvider (which maps to premiumNotifierProvider) directly

/// Página de subscription premium para Plantis - Inspirada no ReceitaAgro
///
/// Responsabilidades:
/// - Orchestração da UI principal com design moderno
/// - Gerenciamento de mensagens/snackbars
/// - Loading state management
/// - Navegação entre diferentes views (ativo vs planos)
///
/// Estrutura:
/// - Header com gradiente verde Plantis e botão de fechar
/// - Loading indicator quando necessário
/// - View ativa: Status da subscription
/// - View planos: Seleção de planos + Benefícios + Ações
/// - Design inspirado no app-receituagro com cores do Plantis
class PremiumSubscriptionPage extends ConsumerStatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  ConsumerState<PremiumSubscriptionPage> createState() =>
      _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState
    extends ConsumerState<PremiumSubscriptionPage>
    with LoadingPageMixin {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsyncState = ref.watch(premiumNotifierProvider);

    return Scaffold(
      backgroundColor: PlantisColors.primary,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PlantisColors.primary, // Verde Plantis principal
              PlantisColors.primaryDark, // Verde escuro
              PlantisColors.leaf, // Verde folha
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: premiumAsyncState.when(
                  loading: () => _buildLoadingView(),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Erro ao carregar premium\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  data: (premiumState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showMessages(context, premiumState);
                    });

                    return premiumState.isPremium
                        ? _buildActiveSubscriptionView(premiumState)
                        : _buildPlansView(premiumState);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header estilo ReceitaAgro com cores Plantis
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Premium Plantis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Loading view centralizado
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  /// View para usuários com subscription ativa
  Widget _buildActiveSubscriptionView(PremiumState premiumState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPremiumStatusCard(),

          const SizedBox(height: 32),
          const PlantisSubscriptionBenefitsWidget(showModernStyle: false),

          const SizedBox(height: 32),
          PlantisPaymentActionsWidget(
            isPremium: true,
            isLoading: premiumState.isLoading,
            showSubscriptionManagement: true,
            onManageSubscription: () => _manageSubscription(premiumState),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// View para seleção de planos (usuário sem subscription)
  Widget _buildPlansView(PremiumState premiumState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Desbloqueie todo o potencial\ndo seu jardim digital',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 32),
          PlantisSubscriptionPlansWidget(
            availableProducts: premiumState.availableProducts,
            selectedPlanId: _selectedPlanId,
            onPlanSelected: (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
          ),

          const SizedBox(height: 40),
          const PlantisSubscriptionBenefitsWidget(showModernStyle: true),

          const SizedBox(height: 40),
          PlantisPaymentActionsWidget(
            selectedPlanId: _selectedPlanId,
            isPremium: false,
            isLoading: premiumState.isLoading,
            showPurchaseButton: true,
            showFooterLinks: true,
            onPurchase: () => _purchaseSelectedPlan(premiumState),
            onRestore: () => _restorePurchases(premiumState),
            onPrivacyPolicy: () => _openPrivacyPolicy(),
            onTermsOfService: () => _openTermsOfService(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Card de status premium ativo
  Widget _buildPremiumStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Ativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você tem acesso a todos os recursos premium do Plantis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Compra o plano selecionado
  Future<void> _purchaseSelectedPlan(PremiumState premiumState) async {
    if (_selectedPlanId == null) return;

    startContextualLoading(
      LoadingContexts.premium,
      message: 'Processando compra...',
      type: LoadingType.purchase,
    );

    try {
      final purchaseManager = ref.read(premiumPurchaseManagerProvider);
      final success = await purchaseManager.purchaseProduct(_selectedPlanId!);

      if (mounted) {
        stopContextualLoading(LoadingContexts.premium);

        if (success) {
          _showSuccessSnackBar(purchaseManager.getPurchaseSuccessMessage());
        }
      }
    } catch (e) {
      if (mounted) {
        stopContextualLoading(LoadingContexts.premium);
      }
    }
  }

  /// Restaura compras anteriores
  Future<void> _restorePurchases(PremiumState premiumState) async {
    startContextualLoading(
      LoadingContexts.premium,
      message: 'Restaurando compras...',
      type: LoadingType.purchase,
    );

    try {
      final purchaseManager = ref.read(premiumPurchaseManagerProvider);
      final success = await purchaseManager.restorePurchases();

      if (mounted) {
        stopContextualLoading(LoadingContexts.premium);

        if (success && premiumState.isPremium) {
          _showSuccessSnackBar(purchaseManager.getRestoreSuccessMessage());
        } else if (success) {
          _showInfoSnackBar(purchaseManager.getRestoreNotFoundMessage());
        }
      }
    } catch (e) {
      if (mounted) {
        stopContextualLoading(LoadingContexts.premium);
      }
    }
  }

  /// Abre gerenciamento de assinatura
  Future<void> _manageSubscription(PremiumState premiumState) async {
    _showInfoSnackBar('Redirecionando para gerenciamento...');
  }

  /// Abre política de privacidade
  Future<void> _openPrivacyPolicy() async {
    _showInfoSnackBar('Abrindo política de privacidade...');
  }

  /// Abre termos de serviço
  Future<void> _openTermsOfService() async {
    _showInfoSnackBar('Abrindo termos de serviço...');
  }

  /// Exibe mensagens de erro, sucesso ou informação
  // Update error handling to use the new PremiumError type
  void _showMessages(BuildContext context, PremiumState premiumState) {
    if (premiumState.error != null) {
      _showErrorSnackBar(premiumState.error!.message);
      ref.read(premiumNotifierProvider.notifier).clearError();
    }
  }

  /// SnackBar de sucesso
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// SnackBar de erro
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// SnackBar de informação
  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

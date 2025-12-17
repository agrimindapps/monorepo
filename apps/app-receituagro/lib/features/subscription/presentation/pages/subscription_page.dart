import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/receituagro_loading_widget.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_info_card.dart';
import '../widgets/subscription_plans_widget.dart';

/// Página principal de subscription refatorada
///
/// Responsabilidades:
/// - Orchestração da UI principal
/// - Gerenciamento de mensagens/snackbars
/// - Loading state management
/// - Navegação entre diferentes views (ativo vs planos)
///
/// Estrutura:
/// - Header com título e botão de fechar
/// - Loading indicator quando necessário
/// - View ativa: SubscriptionStatusWidget
/// - View planos: SubscriptionPlansWidget + SubscriptionBenefitsWidget
/// - Footer com ações: PaymentActionsWidget
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionManagementProvider.notifier).loadSubscriptionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionManagementProvider);

    // Listen to state changes and show messages only when they change
    ref.listen<AsyncValue<SubscriptionState>>(subscriptionManagementProvider, (
      previous,
      next,
    ) {
      next.whenData((state) {
        if (state.errorMessage != null) {
          _showSnackBar(context, state.errorMessage!, Colors.red);
          ref.read(subscriptionManagementProvider.notifier).clearMessages();
        } else if (state.successMessage != null) {
          _showSnackBar(context, state.successMessage!, Colors.green);
          ref.read(subscriptionManagementProvider.notifier).clearMessages();
        } else if (state.infoMessage != null) {
          _showSnackBar(context, state.infoMessage!, Colors.blue);
          ref.read(subscriptionManagementProvider.notifier).clearMessages();
        }
      });
    });

    return subscriptionState.when(
      data: (state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B5E20), // Green 900
                  Color(0xFF2E7D32), // Green 800
                  Color(0xFF388E3C), // Green 700
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    ModernHeaderWidget(
                      title: 'Planos',
                      subtitle: 'Gerencie sua assinatura premium',
                      leftIcon: Icons.workspace_premium,
                      isDark: true, // Force dark mode style for white text
                      showBackButton: true,
                      showActions: false,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: state.isLoading
                          ? _buildLoadingView()
                          : state.hasActiveSubscription
                          ? _buildActiveSubscriptionView(state)
                          : _buildPlansView(state),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(body: _buildLoadingView()),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Erro ao carregar dados: $error'))),
    );
  }

  /// Loading view centralizado
  Widget _buildLoadingView() {
    return const ReceitaAgroLoadingWidget(
      message: 'Carregando informações...',
      submessage: 'Verificando status da assinatura',
    );
  }

  /// View para usuários com subscription ativa
  Widget _buildActiveSubscriptionView(SubscriptionState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (state.currentSubscription != null)
            SubscriptionInfoCard(subscription: state.currentSubscription!),

          const SizedBox(height: 12),
          const SubscriptionBenefitsWidget(
            showModernStyle: false, // Estilo card para subscription ativa
          ),

          const SizedBox(height: 12),
          PaymentActionsWidget(
            showSubscriptionManagement: true,
            isLoading: state.isLoading,
            onManageSubscription: () => _manageSubscription(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// View para seleção de planos (usuário sem subscription)
  Widget _buildPlansView(SubscriptionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tenha acesso ilimitado\na todos os recursos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 24),
          SubscriptionPlansWidget(
            availableProducts: state.availableProducts,
            selectedPlanId: _selectedPlanId,
            onPlanSelected: (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
          ),

          const SizedBox(height: 24),
          const SubscriptionBenefitsWidget(
            showModernStyle: true, // Estilo moderno para marketing
          ),

          const SizedBox(height: 32),
          PaymentActionsWidget(
            selectedPlanId: _selectedPlanId,
            showPurchaseButton: true,
            isLoading: state.isLoading,
            onPurchase: () => _purchaseSelectedPlan(),
            onRestore: () => _restorePurchases(),
            onPrivacyPolicy: () => _openPrivacyPolicy(),
            onTermsOfService: () => _openTermsOfService(),
          ),

          const SizedBox(height: 16),
          PaymentActionsWidget(
            showFooterLinks: true,
            isLoading: state.isLoading,
            onRestore: () => _restorePurchases(),
            onPrivacyPolicy: () => _openPrivacyPolicy(),
            onTermsOfService: () => _openTermsOfService(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _purchaseSelectedPlan() async {
    if (_selectedPlanId == null) return;
    await ref
        .read(subscriptionManagementProvider.notifier)
        .purchaseProduct(_selectedPlanId!);
  }

  Future<void> _restorePurchases() async {
    await ref.read(subscriptionManagementProvider.notifier).restorePurchases();
  }

  Future<void> _manageSubscription() async {
    await ref
        .read(subscriptionManagementProvider.notifier)
        .manageSubscription();
  }

  Future<void> _openPrivacyPolicy() async {
    _showSnackBar(context, 'Abrindo política de privacidade...', Colors.blue);
  }

  Future<void> _openTermsOfService() async {
    _showSnackBar(context, 'Abrindo termos de serviço...', Colors.blue);
  }

  /// Helper para mostrar snackbars
  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    if (mounted) {
      // Clear any existing snackbars to prevent duplicates
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

import 'package:core/core.dart'
    hide Column, SubscriptionState, SubscriptionInfo, subscriptionProvider;
import 'package:flutter/material.dart';
import '../state/subscription_notifier.dart';
import '../state/subscription_state.dart';
import '../widgets/petiveti_payment_actions_widget.dart';
import '../widgets/petiveti_subscription_benefits_widget.dart';
import '../widgets/petiveti_subscription_plans_widget.dart';

/// Página de subscription premium para PetiVeti - Inspirada no Plantis
///
/// Responsabilidades:
/// - Orchestração da UI principal com design moderno
/// - Gerenciamento de mensagens/snackbars
/// - Loading state management
/// - Navegação entre diferentes views (ativo vs planos)
///
/// Estrutura:
/// - Header com gradiente roxo PetiVeti e botão de fechar
/// - Loading indicator quando necessário
/// - View ativa: Status da subscription
/// - View planos: Seleção de planos + Benefícios + Ações
/// - Design inspirado no app-plantis com cores do PetiVeti
class PremiumSubscriptionPage extends ConsumerStatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  ConsumerState<PremiumSubscriptionPage> createState() =>
      _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState
    extends ConsumerState<PremiumSubscriptionPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);

    // Listen for errors
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A2E), // Very dark purple (Premium)
              Color(0xFF4A148C), // Dark purple
              Color(0xFF6A1B9A), // PetiVeti Primary
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: state.isLoading
                    ? _buildLoadingView()
                    : state.isPremium
                    ? _buildActiveSubscriptionView(state)
                    : _buildPlansView(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header estilo Plantis com cores PetiVeti
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Premium PetiVeti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
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
  Widget _buildActiveSubscriptionView(SubscriptionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPremiumStatusCard(state),

          const SizedBox(height: 32),
          const PetivetiSubscriptionBenefitsWidget(showModernStyle: false),

          const SizedBox(height: 32),
          PetivetiPaymentActionsWidget(
            isPremium: true,
            isLoading: state.isLoading,
            showSubscriptionManagement: true,
            onManageSubscription: () => _manageSubscription(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// View para seleção de planos (usuário sem subscription)
  Widget _buildPlansView(SubscriptionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Cuide dos seus pets\ncom o melhor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'Desbloqueie recursos premium para cuidar melhor\ndos seus companheiros de quatro patas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),
          PetivetiSubscriptionPlansWidget(
            availableProducts: state.availablePlans,
            selectedPlanId: _selectedPlanId,
            onPlanSelected: (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
          ),

          const SizedBox(height: 40),
          const PetivetiSubscriptionBenefitsWidget(showModernStyle: true),

          const SizedBox(height: 40),
          PetivetiPaymentActionsWidget(
            selectedPlanId: _selectedPlanId,
            isPremium: false,
            isLoading: state.isLoading,
            showPurchaseButton: true,
            showFooterLinks: true,
            onPurchase: () => _purchaseSelectedPlan(),
            onRestore: () => _restorePurchases(),
            onPrivacyPolicy: () => _openPrivacyPolicy(),
            onTermsOfService: () => _openTermsOfService(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Card de status premium ativo
  Widget _buildPremiumStatusCard(SubscriptionState state) {
    final subscription = state.currentSubscription;

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
            'Você tem acesso a todos os recursos premium do PetiVeti',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          if (subscription != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Produto: ${subscription.productId}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (subscription.expirationDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expira em: ${_formatDate(subscription.expirationDate!)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (subscription.isTrialPeriod) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '🎁 Período de avaliação',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Compra o plano selecionado
  Future<void> _purchaseSelectedPlan() async {
    if (_selectedPlanId == null) {
      _showInfoSnackBar('Selecione um plano primeiro');
      return;
    }

    final result = await ref
        .read(subscriptionProvider.notifier)
        .purchaseProduct(_selectedPlanId!);

    if (!mounted) return;

    result.fold(
      (error) => _showErrorSnackBar(error),
      (_) => _showSuccessSnackBar('Compra realizada com sucesso!'),
    );
  }

  /// Restaura compras anteriores
  Future<void> _restorePurchases() async {
    final result = await ref
        .read(subscriptionProvider.notifier)
        .restorePurchases();

    if (!mounted) return;

    result.fold((error) => _showErrorSnackBar(error), (_) {
      final state = ref.read(subscriptionProvider);
      if (state.isPremium) {
        _showSuccessSnackBar('Compras restauradas com sucesso!');
      } else {
        _showInfoSnackBar('Nenhuma compra anterior encontrada');
      }
    });
  }

  /// Abre gerenciamento de assinatura
  Future<void> _manageSubscription() async {
    _showInfoSnackBar('Redirecionando para gerenciamento...');
    // TODO: Implementar abertura do gerenciamento de assinatura da loja
  }

  /// Abre política de privacidade
  Future<void> _openPrivacyPolicy() async {
    _showInfoSnackBar('Abrindo política de privacidade...');
    // TODO: Implementar abertura da política de privacidade
  }

  /// Abre termos de serviço
  Future<void> _openTermsOfService() async {
    _showInfoSnackBar('Abrindo termos de serviço...');
    // TODO: Implementar abertura dos termos de serviço
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscription/domain/entities/user_subscription_info.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../widgets/premium_benefits_widget.dart';
import '../widgets/premium_plans_widget.dart';

/// Página de subscription premium para NebulaList
///
/// Responsabilidades:
/// - Apresentar planos de assinatura com design atraente
/// - Permitir seleção de planos (mockado)
/// - Realizar compra via RevenueCat
/// - Design moderno com gradiente Deep Purple → Indigo
///
/// Estrutura:
/// - Header com gradiente e botão de fechar
/// - Título hero centralizado
/// - Seção de planos (3 cards lado a lado)
/// - Seção de benefícios (8 items)
/// - Botões de ação (Começar Agora, Restaurar)
/// - Footer com links de termos e privacidade
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    // Listen to subscription status
    final subscriptionAsync = ref.watch(subscriptionStatusProvider);
    final purchaseState = ref.watch(subscriptionProvider);

    // Handle purchase state changes
    ref.listen<PurchaseState>(
      subscriptionProvider,
      (previous, next) {
        if (next is PurchaseSuccess) {
          _showSnackBar(next.message, Colors.green);
          // Close page after successful purchase
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        } else if (next is PurchaseError) {
          _showSnackBar(next.message, Colors.red);
        }
      },
    );

    return subscriptionAsync.when(
      data: (subscriptionInfo) {
        // If already premium, show premium active screen
        if (subscriptionInfo.isPremium) {
          return _buildPremiumActiveScreen(subscriptionInfo);
        }

        // Otherwise, show upgrade screen
        return _buildUpgradeScreen(purchaseState);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
    );
  }

  Widget _buildUpgradeScreen(PurchaseState purchaseState) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF673AB7), // Deep Purple
              Color(0xFF5E35B1), // Deep Purple 600
              Color(0xFF3F51B5), // Indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(purchaseState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header com botão de fechar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'NebulaList Premium',
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

  /// Conteúdo principal scrollável
  Widget _buildContent(PurchaseState purchaseState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeroTitle(),
          const SizedBox(height: 32),
          _buildPlansSection(),
          const SizedBox(height: 40),
          const PremiumBenefitsWidget(),
          const SizedBox(height: 40),
          _buildActionButtons(purchaseState),
          const SizedBox(height: 24),
          _buildFooterLinks(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Título hero centralizado
  Widget _buildHeroTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Organize sua vida\nsem limites',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  /// Seção de planos
  Widget _buildPlansSection() {
    return PremiumPlansWidget(
      selectedPlanId: _selectedPlanId,
      onPlanSelected: (planId) {
        setState(() {
          _selectedPlanId = planId;
        });
      },
    );
  }

  /// Botões de ação
  Widget _buildActionButtons(PurchaseState purchaseState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Botão principal - Começar Agora
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: purchaseState is PurchaseLoading ? null : _onStartNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: purchaseState is PurchaseLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                    )
                  : const Text(
                      'Começar Agora',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Botão secundário - Restaurar Compras
          TextButton(
            onPressed: purchaseState is PurchaseLoading ? null : _onRestorePurchases,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Restaurar Compras',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer com links
  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _onTermsOfService,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Termos',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '•',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          TextButton(
            onPressed: _onPrivacyPolicy,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Privacidade',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Handler para começar agora
  /// Handler para começar agora (comprar plano)
  Future<void> _onStartNow() async {
    if (_selectedPlanId == null) {
      _showSnackBar('Selecione um plano primeiro', Colors.orange);
      return;
    }

    // Call the subscription notifier to purchase
    await ref
        .read(subscriptionProvider.notifier)
        .purchasePlan(_selectedPlanId!);
  }

  /// Handler para restaurar compras
  Future<void> _onRestorePurchases() async {
    await ref.read(subscriptionProvider.notifier).restorePurchases();
  }

  /// Handler para termos de serviço
  void _onTermsOfService() {
    _showSnackBar(
      'Termos de Serviço - Em breve',
      Colors.blue,
    );
  }

  /// Handler para política de privacidade
  void _onPrivacyPolicy() {
    _showSnackBar(
      'Política de Privacidade - Em breve',
      Colors.blue,
    );
  }

  /// Exibe SnackBar com mensagem
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Tela de loading enquanto verifica subscription
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF673AB7),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Tela de erro
  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      backgroundColor: const Color(0xFF673AB7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar informações',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tela quando usuário já é premium
  Widget _buildPremiumActiveScreen(UserSubscriptionInfo info) {
    return Scaffold(
      backgroundColor: const Color(0xFF673AB7),
      appBar: AppBar(
        title: const Text('NebulaList Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Você é Premium!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (info.productId != null) ...[
                      _buildInfoRow('Plano', info.productId!),
                      const SizedBox(height: 8),
                    ],
                    if (info.expirationDate != null) ...[
                      _buildInfoRow(
                        'Expira em',
                        _formatDate(info.expirationDate!),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (info.isInTrialPeriod)
                      _buildInfoRow('Status', 'Em período de teste')
                    else if (info.willRenew)
                      _buildInfoRow('Renovação', 'Automática')
                    else
                      _buildInfoRow('Status', 'Cancelado (ativo até o fim)'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '✨ Aproveite todos os benefícios premium! ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

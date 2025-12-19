import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/nebula_colors.dart';
import '../providers/premium_notifier.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_plans_widget.dart';

/// Página de subscription premium para Nebulalist
///
/// Responsabilidades:
/// - Orchestração da UI principal com design Nebula
/// - Gerenciamento de mensagens/snackbars
/// - Loading state management
/// - Navegação entre diferentes views (ativo vs planos)
///
/// Estrutura:
/// - Header com gradiente nebula e botão de fechar
/// - Loading indicator quando necessário
/// - View ativa: Status da subscription
/// - View planos: Seleção de planos + Benefícios + Ações
/// - Design com tema nebula (roxo/ciano)
class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage>
    with SingleTickerProviderStateMixin {
  String? _selectedPlanId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Load available products on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(premiumNotifierProvider.notifier)
          .loadAvailableProducts(NebulalistProductIds.all);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsyncState = ref.watch(premiumNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: NebulaColors.paywallGradient,
        ),
        child: Stack(
          children: [
            // Animated nebula background elements
            _buildNebulaBackground(),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: premiumAsyncState.when(
                  loading: () => _buildLoadingView(),
                  error: (error, _) => _buildErrorView(error.toString()),
                  data: (state) => Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: state.isLoading
                            ? _buildLoadingView()
                            : state.isPremium
                                ? _buildActiveSubscriptionView(state.isLoading)
                                : _buildPlansView(state.availableProducts, state.isLoading),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error view
  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: NebulaColors.error),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(premiumNotifierProvider.notifier)
                  .loadAvailableProducts(NebulalistProductIds.all);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NebulaColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Animated nebula background with floating orbs
  Widget _buildNebulaBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _NebulaPainter(),
      ),
    );
  }

  /// Header estilo Nebula
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
          ShaderMask(
            shaderCallback: (bounds) => NebulaColors.primaryGradient
                .createShader(bounds),
            child: const Text(
              'Nebulalist Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Loading view centralizado
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NebulaColors.accentCyan),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Carregando...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// View para usuários com subscription ativa
  Widget _buildActiveSubscriptionView(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPremiumStatusCard(),
          const SizedBox(height: 32),
          const SubscriptionBenefitsWidget(showModernStyle: false),
          const SizedBox(height: 32),
          PaymentActionsWidget(
            isPremium: true,
            isLoading: isLoading,
            showSubscriptionManagement: true,
            onManageSubscription: _manageSubscription,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// View para seleção de planos (usuário sem subscription)
  Widget _buildPlansView(List<ProductInfo> availableProducts, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeroSection(),
          const SizedBox(height: 32),
          SubscriptionPlansWidget(
            availableProducts: availableProducts,
            selectedPlanId: _selectedPlanId,
            onPlanSelected: (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
          ),
          const SizedBox(height: 40),
          const SubscriptionBenefitsWidget(showModernStyle: true),
          const SizedBox(height: 40),
          PaymentActionsWidget(
            selectedPlanId: _selectedPlanId,
            isPremium: false,
            isLoading: isLoading,
            showPurchaseButton: true,
            showFooterLinks: true,
            onPurchase: _purchaseSelectedPlan,
            onRestore: _restorePurchases,
            onPrivacyPolicy: _openPrivacyPolicy,
            onTermsOfService: _openTermsOfService,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Hero section with animated title
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Animated icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NebulaColors.primaryPurple.withValues(alpha: 0.3),
                  NebulaColors.accentCyan.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: NebulaColors.accentCyan.withValues(alpha: 0.3),
              ),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  NebulaColors.primaryGradient.createShader(bounds),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, NebulaColors.accentCyan],
            ).createShader(bounds),
            child: const Text(
              'Organize sua vida\nsem limites',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Desbloqueie todo o potencial do Nebulalist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NebulaColors.primaryPurple.withValues(alpha: 0.3),
            NebulaColors.accentCyan.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: NebulaColors.accentCyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: NebulaColors.primaryPurple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: NebulaColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) =>
                NebulaColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Premium Ativo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você tem acesso a todos os recursos premium do Nebulalist',
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
  Future<void> _purchaseSelectedPlan() async {
    if (_selectedPlanId == null) {
      _showSnackBar('Selecione um plano primeiro', Colors.orange);
      return;
    }

    final success = await ref
        .read(premiumNotifierProvider.notifier)
        .purchaseProduct(_selectedPlanId!);

    if (mounted) {
      if (success) {
        _showSuccessSnackBar('Compra realizada com sucesso!');
        Navigator.of(context).pop();
      } else {
        final error = ref.read(premiumNotifierProvider).maybeWhen(
              data: (state) => state.error?.message,
              orElse: () => null,
            );
        _showErrorSnackBar(error ?? 'Erro ao processar compra');
      }
    }
  }

  /// Restaura compras anteriores
  Future<void> _restorePurchases() async {
    final hasSubscriptions =
        await ref.read(premiumNotifierProvider.notifier).restorePurchases();

    if (mounted) {
      if (hasSubscriptions) {
        _showSuccessSnackBar('Compras restauradas com sucesso!');
        Navigator.of(context).pop();
      } else {
        _showInfoSnackBar('Nenhuma compra encontrada para restaurar');
      }
    }
  }

  /// Abre gerenciamento de assinatura
  Future<void> _manageSubscription() async {
    _showInfoSnackBar('Redirecionando para gerenciamento...');
    // Open app store subscription management
    // iOS: app-settings:
    // Android: https://play.google.com/store/account/subscriptions
  }

  /// Abre política de privacidade
  Future<void> _openPrivacyPolicy() async {
    const url = 'https://nebulalist.app/privacy';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      _showErrorSnackBar('Não foi possível abrir a política de privacidade');
    }
  }

  /// Abre termos de serviço
  Future<void> _openTermsOfService() async {
    const url = 'https://nebulalist.app/terms';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      _showErrorSnackBar('Não foi possível abrir os termos de serviço');
    }
  }

  /// SnackBar de sucesso
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NebulaColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// SnackBar de erro
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NebulaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// SnackBar de informação
  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: NebulaColors.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// SnackBar genérico
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

/// Custom painter for nebula background effects
class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Purple nebula glow (top-left)
    paint.shader = RadialGradient(
      center: const Alignment(-0.8, -0.6),
      radius: 0.8,
      colors: [
        NebulaColors.primaryPurple.withValues(alpha: 0.3),
        NebulaColors.primaryPurple.withValues(alpha: 0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Cyan nebula glow (bottom-right)
    paint.shader = RadialGradient(
      center: const Alignment(0.7, 0.8),
      radius: 0.6,
      colors: [
        NebulaColors.accentCyan.withValues(alpha: 0.2),
        NebulaColors.accentCyan.withValues(alpha: 0.05),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Pink accent glow (center)
    paint.shader = RadialGradient(
      center: const Alignment(0.0, 0.2),
      radius: 0.5,
      colors: [
        NebulaColors.nebulaPink.withValues(alpha: 0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

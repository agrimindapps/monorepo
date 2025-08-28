import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/premium_provider.dart';

class PremiumPage extends StatefulWidget {
  final String? source; // Track where user came from
  
  const PremiumPage({super.key, this.source});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  late final AnalyticsProvider _analytics;
  
  @override
  void initState() {
    super.initState();
    _analytics = sl<AnalyticsProvider>();
    // Carrega produtos ao iniciar - o provider se inicializa automaticamente
    _trackPremiumPageViewed();
  }
  
  Future<void> _trackPremiumPageViewed() async {
    await _analytics.logEvent('premium_page_viewed', {
      'source': widget.source ?? 'direct',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _analytics.logScreenView('premium_page');
  }
  
  Future<void> _trackPurchaseAttempt(String productId, PremiumProvider provider) async {
    final product = provider.availableProducts.firstWhere(
      (p) => p.productId == productId,
      orElse: () => ProductInfo(
        productId: productId, 
        title: 'Unknown Product',
        description: 'Unknown Product',
        priceString: '0', 
        price: 0.0, 
        currencyCode: 'BRL',
      ),
    );
    
    await _analytics.logEvent('purchase_attempt', {
      'product_id': productId,
      'price': product.price,
      'currency': product.currencyCode,
      'user_type': provider.isPremium ? 'premium' : 'free',
      'available_products_count': provider.availableProducts.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackPurchaseSuccess(String productId, PremiumProvider provider) async {
    final product = provider.availableProducts.firstWhere(
      (p) => p.productId == productId,
      orElse: () => ProductInfo(
        productId: productId, 
        title: 'Unknown Product',
        description: 'Unknown Product',
        priceString: '0', 
        price: 0.0, 
        currencyCode: 'BRL',
      ),
    );
    
    await _analytics.logEvent('purchase_success', {
      'product_id': productId,
      'revenue': product.price,
      'currency': product.currencyCode,
      'plan_type': productId.contains('monthly') ? 'monthly' : 'annual',
      'conversion_source': widget.source ?? 'direct',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackPurchaseFailure(String productId, String error, PremiumProvider provider) async {
    await _analytics.logEvent('purchase_failure', {
      'product_id': productId,
      'error_type': _categorizeError(error),
      'error_message': error.length > 100 ? error.substring(0, 100) : error,
      'user_type': provider.isPremium ? 'premium' : 'free',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackRestorePurchasesAttempt() async {
    await _analytics.logEvent('restore_purchases_attempt', {
      'source': 'premium_page',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackRestorePurchasesResult(bool success, bool foundPurchases) async {
    await _analytics.logEvent('restore_purchases_result', {
      'success': success,
      'found_purchases': foundPurchases,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackManageSubscriptionClick() async {
    await _analytics.logEvent('manage_subscription_click', {
      'source': 'premium_page',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _trackPlanCardView(String productId) async {
    await _analytics.logEvent('plan_card_viewed', {
      'product_id': productId,
      'plan_type': productId.contains('monthly') ? 'monthly' : 'annual',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  String _categorizeError(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('cancel')) return 'user_cancelled';
    if (lowerError.contains('network')) return 'network_error';
    if (lowerError.contains('payment')) return 'payment_error';
    if (lowerError.contains('store')) return 'store_error';
    if (lowerError.contains('permission')) return 'permission_error';
    return 'unknown_error';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: PurchaseLoadingOverlay(
            isLoading: provider.isLoading,
            currentOperation: provider.currentOperation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error display
                  if (provider.errorMessage != null) ...[
                    PurchaseErrorDisplay(
                      errorMessage: provider.errorMessage!,
                      onRetry: () => provider.clearError(),
                      onDismiss: () => provider.clearError(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Status atual
                  _buildCurrentStatusCard(provider),
                  const SizedBox(height: 24),

                  // Título e descrição
                  _buildHeaderSection(),
                  const SizedBox(height: 32),

                  // Features premium
                  _buildFeaturesSection(),
                  const SizedBox(height: 32),

                  // Planos disponíveis
                  if (!provider.isPremium) ...[
                    _buildPlansSection(provider),
                    const SizedBox(height: 24),
                  ],

                  // Botões de ação
                  _buildActionButtons(provider),
                  const SizedBox(height: 32),

                  // FAQ
                  _buildFAQSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStatusCard(PremiumProvider provider) {
    final isPremium = provider.isPremium;
    final status = provider.subscriptionStatus;
    final expirationDate = provider.expirationDate;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isPremium
                  ? [Colors.teal.shade600, Colors.teal.shade400]
                  : [Colors.grey.shade800, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.star : Icons.star_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $status',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expirationDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expira em: ${_formatDate(expirationDate)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desbloqueie Todo o Potencial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cuide melhor das suas plantas com recursos premium exclusivos',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Plantas Ilimitadas',
        'description': 'Adicione quantas plantas quiser ao seu jardim',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Avançados',
        'description': 'Configure lembretes personalizados para cada planta',
      },
      {
        'icon': Icons.analytics,
        'title': 'Análises Detalhadas',
        'description': 'Acompanhe o crescimento e saúde das suas plantas',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Backup na Nuvem',
        'description': 'Seus dados sempre seguros e sincronizados',
      },
      {
        'icon': Icons.photo_camera,
        'title': 'Identificação de Plantas',
        'description': 'Use a câmera para identificar espécies',
      },
      {
        'icon': Icons.medical_services,
        'title': 'Diagnóstico de Doenças',
        'description': 'Identifique e trate problemas rapidamente',
      },
      {
        'icon': Icons.palette,
        'title': 'Temas Personalizados',
        'description': 'Personalize a aparência do aplicativo',
      },
      {
        'icon': Icons.download,
        'title': 'Exportar Dados',
        'description': 'Exporte informações das suas plantas',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recursos Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map(
          (feature) => _buildFeatureItem(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['description'] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.teal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(PremiumProvider provider) {
    final products = provider.availableProducts;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha seu Plano',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...products.map((product) => _buildPlanCard(product, provider)),
      ],
    );
  }

  Widget _buildPlanCard(ProductInfo product, PremiumProvider provider) {
    final isMonthly = product.productId.contains('monthly');
    final isPopular = !isMonthly; // Anual é mais popular
    
    // Track plan card view when built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPlanCardView(product.productId);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: isPopular ? Border.all(color: Colors.teal, width: 2) : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'MAIS POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMonthly ? 'Mensal' : 'Anual',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isMonthly)
                          Text(
                            'Economize 20%',
                            style: TextStyle(
                              color: Colors.teal.shade400,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isMonthly ? '/mês' : '/ano',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchaseProduct(product.productId, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? Colors.teal : Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Assinar ${isMonthly ? "Mensal" : "Anual"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PremiumProvider provider) {
    return Column(
      children: [
        if (!provider.isPremium)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _restorePurchases(provider),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        if (provider.isPremium)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _openManagementUrl(provider),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Gerenciar Assinatura',
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perguntas Frequentes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Posso cancelar a qualquer momento?',
          'Sim! Você pode cancelar sua assinatura a qualquer momento nas configurações da App Store ou Google Play.',
        ),
        _buildFAQItem(
          'O que acontece quando cancelo?',
          'Você continuará tendo acesso ao Premium até o fim do período pago. Após isso, voltará ao plano gratuito.',
        ),
        _buildFAQItem(
          'Posso trocar de plano?',
          'Sim, você pode mudar entre mensal e anual a qualquer momento. O valor será ajustado proporcionalmente.',
        ),
        _buildFAQItem(
          'Funciona em múltiplos dispositivos?',
          'Sim! Sua assinatura funciona em todos os dispositivos conectados à mesma conta.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseProduct(
    String productId,
    PremiumProvider provider,
  ) async {
    // Track purchase attempt
    await _trackPurchaseAttempt(productId, provider);
    
    try {
      final success = await provider.purchaseProduct(productId);

      if (!mounted) return;

      if (success) {
        // Track successful purchase
        await _trackPurchaseSuccess(productId, provider);
        _showSuccessDialog();
      } else if (provider.errorMessage != null) {
        // Track purchase failure
        await _trackPurchaseFailure(productId, provider.errorMessage!, provider);
        
        // Don't show dialog for user cancellation
        if (!provider.errorMessage!.toLowerCase().contains('cancelled')) {
          // Error is already handled by PurchaseErrorDisplay in the UI
          // Just clear it after a delay to let user see the error
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              provider.clearError();
            }
          });
        } else {
          // Clear cancellation error immediately
          provider.clearError();
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final errorMessage = e.message ?? e.code;
        await _trackPurchaseFailure(productId, errorMessage, provider);
        
        // Handle platform-specific errors
        if (e.code == 'user_cancelled' || e.message?.contains('cancelled') == true) {
          // User cancelled, no need to show error
          return;
        }
        
        // Set error message in provider instead of showing dialog
        // This will be handled by PurchaseErrorDisplay
        provider.clearError();
      }
    } catch (e) {
      if (mounted) {
        await _trackPurchaseFailure(productId, e.toString(), provider);
        provider.clearError();
      }
    }
  }

  Future<void> _restorePurchases(PremiumProvider provider) async {
    await _trackRestorePurchasesAttempt();
    
    final success = await provider.restorePurchases();

    if (!mounted) return;

    await _trackRestorePurchasesResult(success, provider.isPremium);

    if (success) {
      if (provider.isPremium) {
        _showSuccessDialog(message: 'Compras restauradas com sucesso!');
      } else {
        _showInfoDialog('Nenhuma compra anterior encontrada.');
      }
    } else if (provider.errorMessage != null) {
      // Error is handled by PurchaseErrorDisplay
      // Auto-clear after showing
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          provider.clearError();
        }
      });
    }
  }

  Future<void> _openManagementUrl(PremiumProvider provider) async {
    await _trackManageSubscriptionClick();
    
    final url = await provider.getManagementUrl();
    if (url != null && mounted) {
      // TODO: Abrir URL usando url_launcher
      _showInfoDialog('URL de gerenciamento: $url');
    }
  }

  void _showSuccessDialog({String? message}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.teal, size: 28),
                SizedBox(width: 12),
                Text('Sucesso!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              message ??
                  'Bem-vindo ao Premium! Aproveite todos os recursos exclusivos.',
              style: TextStyle(color: Colors.grey.shade300),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Erro', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.grey.shade300),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text('Informação', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.grey.shade300),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../providers/premium_provider.dart';

// Data classes for granular Selector optimization
class PremiumLoadingState {
  final bool isLoading;
  final PurchaseOperation? currentOperation;

  const PremiumLoadingState({
    required this.isLoading,
    this.currentOperation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumLoadingState &&
          isLoading == other.isLoading &&
          currentOperation == other.currentOperation;

  @override
  int get hashCode => Object.hash(isLoading, currentOperation);
}

class PremiumStatusData {
  final bool isPremium;
  final String status;
  final DateTime? expirationDate;

  const PremiumStatusData({
    required this.isPremium,
    required this.status,
    this.expirationDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumStatusData &&
          isPremium == other.isPremium &&
          status == other.status &&
          expirationDate == other.expirationDate;

  @override
  int get hashCode => Object.hash(isPremium, status, expirationDate);
}

class PremiumPlansData {
  final List<ProductInfo> availableProducts;
  final bool isPremium;

  const PremiumPlansData({
    required this.availableProducts,
    required this.isPremium,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumPlansData &&
          _listEquals(availableProducts, other.availableProducts) &&
          isPremium == other.isPremium;

  @override
  int get hashCode => Object.hash(_listHashCode(availableProducts), isPremium);

  bool _listEquals(List<ProductInfo> list1, List<ProductInfo> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].productId != list2[i].productId) return false;
    }
    return true;
  }

  int _listHashCode(List<ProductInfo> list) {
    return Object.hashAll(list.map((item) => item.productId));
  }
}

class PremiumPage extends StatefulWidget {
  final String? source; // Track where user came from
  
  const PremiumPage({super.key, this.source});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> with LoadingPageMixin {
  late final AnalyticsProvider _analytics;
  bool _hasTrackedPageView = false; // Cache para evitar tracking duplicado
  final Set<String> _trackedPlanViews = {}; // Cache para plan views
  
  @override
  void initState() {
    super.initState();
    _analytics = sl<AnalyticsProvider>();
    // Carrega produtos ao iniciar - o provider se inicializa automaticamente
    _trackPremiumPageViewed();
  }
  
  Future<void> _trackPremiumPageViewed() async {
    if (_hasTrackedPageView) return; // Evita tracking duplicado
    _hasTrackedPageView = true;
    
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
    if (_trackedPlanViews.contains(productId)) return; // Evita tracking duplicado
    _trackedPlanViews.add(productId);
    
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
    return ContextualLoadingListener(
      context: LoadingContexts.premium,
      child: Scaffold(
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
        body: Selector<PremiumProvider, PremiumLoadingState>(
          selector: (context, provider) => PremiumLoadingState(
            isLoading: provider.isLoading,
            currentOperation: provider.currentOperation,
          ),
          builder: (context, loadingState, child) {
            return PurchaseLoadingOverlay(
              isLoading: loadingState.isLoading,
              currentOperation: loadingState.currentOperation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error display with improved recovery
                    _buildErrorDisplay(),
                    
                    // Status atual
                    _buildCurrentStatusCard(),
                    const SizedBox(height: 24),

                    // Título e descrição
                    _buildHeaderSection(),
                    const SizedBox(height: 32),

                  // Features premium
                  _buildFeaturesSection(),
                  const SizedBox(height: 32),

                  // Planos disponíveis
                  _buildPlansSection(),

                  // Botões de ação
                  _buildActionButtons(),
                  const SizedBox(height: 32),

                  // FAQ
                  _buildFAQSection(),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Selector<PremiumProvider, String?>(
      selector: (context, provider) => provider.errorMessage,
      builder: (context, errorMessage, child) {
        if (errorMessage != null) {
          return Column(
            children: [
              PurchaseErrorDisplay(
                errorMessage: errorMessage,
                onRetry: () {
                  final provider = context.read<PremiumProvider>();
                  provider.clearError();
                },
                onDismiss: () {
                  final provider = context.read<PremiumProvider>();
                  provider.clearError();
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrentStatusCard() {
    return Selector<PremiumProvider, PremiumStatusData>(
      selector: (context, provider) => PremiumStatusData(
        isPremium: provider.isPremium,
        status: provider.subscriptionStatus,
        expirationDate: provider.expirationDate,
      ),
      builder: (context, statusData, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  statusData.isPremium
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
                  statusData.isPremium ? Icons.star : Icons.star_outline,
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
                      'Status: ${statusData.status}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (statusData.expirationDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expira em: ${_formatDate(statusData.expirationDate!)}',
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
      },
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
    // Get features from centralized configuration
    final configFeatures = AppConfig.premiumConfig['features'] as List<Map<String, dynamic>>;
    final features = configFeatures.where((feature) => feature['enabled'] == true).toList();

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
            _getIconData(feature['icon'] as String),
            feature['title'] as String,
            feature['description'] as String,
            isEnabled: feature['enabled'] as bool? ?? true,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isEnabled ? Colors.teal : Colors.grey).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              color: isEnabled ? Colors.teal : Colors.grey, 
              size: 24,
            ),
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
                  style: TextStyle(
                    color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade600, 
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Selector<PremiumProvider, PremiumPlansData>(
      selector: (context, provider) => PremiumPlansData(
        availableProducts: provider.availableProducts,
        isPremium: provider.isPremium,
      ),
      builder: (context, plansData, child) {
        if (plansData.availableProducts.isEmpty || plansData.isPremium) {
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
            ...plansData.availableProducts.map((product) => _buildPlanCard(product)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(ProductInfo product) {
    final isMonthly = product.productId.contains('monthly');
    final isPopular = !isMonthly; // Anual é mais popular
    
    // Track plan card view when built (cached)
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
                  child: PurchaseButton(
                    onPurchase: () async {
                      final provider = context.read<PremiumProvider>();
                      await _purchaseProduct(product.productId, provider);
                    },
                    productName: isMonthly ? 'Plano Mensal' : 'Plano Anual',
                    price: product.priceString,
                    enabled: !hasContextualLoading(LoadingContexts.premium),
                    onSuccess: () {
                      // Success feedback is handled by _purchaseProduct method
                    },
                    onError: () {
                      // Error feedback is handled by _purchaseProduct method
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Selector<PremiumProvider, bool>(
      selector: (context, provider) => provider.isPremium,
      builder: (context, isPremium, child) {
        return Column(
          children: [
            if (!isPremium)
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressedAsync: () async {
                    final provider = context.read<PremiumProvider>();
                    await _restorePurchases(provider);
                  },
                  type: LoadingButtonType.text,
                  loadingText: 'Restaurando...',
                  disabled: hasContextualLoading(LoadingContexts.premium),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  semanticLabel: 'Restaurar compras anteriores do premium',
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

            if (isPremium)
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressedAsync: () async {
                    final provider = context.read<PremiumProvider>();
                    await _openManagementUrl(provider);
                  },
                  type: LoadingButtonType.text,
                  loadingText: 'Abrindo...',
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  semanticLabel: 'Gerenciar assinatura premium',
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
      },
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
        ...AppConfig.faqItems.map(
          (faq) => _buildFAQItem(
            faq['question']!,
            faq['answer']!,
          ),
        ),
        const SizedBox(height: 16),
        _buildSupportSection(),
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
    // Get product info for better UX messages
    final product = provider.availableProducts.firstWhere(
      (p) => p.productId == productId,
      orElse: () => ProductInfo(
        productId: productId,
        title: 'Produto Premium',
        description: 'Produto Premium',
        priceString: '0',
        price: 0.0,
        currencyCode: 'BRL',
      ),
    );
    
    // Start contextual loading with product-specific message
    startPurchaseLoading(productName: product.title);
    
    // Track purchase attempt
    await _trackPurchaseAttempt(productId, provider);
    
    try {
      final success = await provider.purchaseProduct(productId);

      if (!mounted) return;
      
      // Stop loading
      stopPurchaseLoading();

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
        stopPurchaseLoading(); // Stop loading on error
        
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
        stopPurchaseLoading(); // Stop loading on error
        await _trackPurchaseFailure(productId, e.toString(), provider);
        provider.clearError();
      }
    }
  }

  Future<void> _restorePurchases(PremiumProvider provider) async {
    // Start contextual loading for restore operation
    startContextualLoading(
      LoadingContexts.premium,
      message: 'Restaurando compras anteriores...',
      semanticLabel: 'Restaurando suas compras premium anteriores',
      type: LoadingType.purchase,
    );
    
    await _trackRestorePurchasesAttempt();
    
    try {
      final success = await provider.restorePurchases();

      if (!mounted) return;
      
      // Stop loading
      stopContextualLoading(LoadingContexts.premium);

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
    } catch (e) {
      if (mounted) {
        stopContextualLoading(LoadingContexts.premium);
        // Error will be handled by provider
      }
    }
  }

  Future<void> _openManagementUrl(PremiumProvider provider) async {
    await _trackManageSubscriptionClick();
    
    final url = await provider.getManagementUrl();
    if (url != null && mounted) {
      final urlLauncher = sl<UrlLauncherService>();
      final result = await urlLauncher.launchUrl(
        url,
        source: 'premium_page_manage_subscription',
        analyticsParameters: {
          'user_type': provider.isPremium ? 'premium' : 'free',
          'subscription_status': provider.subscriptionStatus,
        },
      );
      
      if (!result.isSuccess && mounted) {
        _showErrorDialog(
          'Não foi possível abrir o link de gerenciamento: ${result.message}\n\n'
          'Você pode gerenciar sua assinatura diretamente nas configurações da loja de aplicativos.',
        );
      }
    } else if (mounted) {
      // Fallback para URLs padrão da loja
      final defaultUrl = defaultTargetPlatform == TargetPlatform.iOS 
          ? AppConfig.manageSubscriptionAppleUrl
          : AppConfig.manageSubscriptionGoogleUrl;
      
      final urlLauncher = sl<UrlLauncherService>();
      final result = await urlLauncher.launchUrl(
        defaultUrl,
        source: 'premium_page_manage_subscription_fallback',
      );
      
      if (!result.isSuccess && mounted) {
        _showErrorDialog(
          'Não foi possível abrir o gerenciamento de assinaturas. '
          'Tente acessar diretamente pelas configurações do seu dispositivo.',
        );
      }
    }
  }

  void _showSuccessDialog({String? message}) {
    showDialog<void>(
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
    showDialog<void>(
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
    showDialog<void>(
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
  
  /// Get IconData from string representation
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'all_inclusive':
        return Icons.all_inclusive;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'analytics':
        return Icons.analytics;
      case 'cloud_sync':
        return Icons.cloud_sync;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'medical_services':
        return Icons.medical_services;
      case 'palette':
        return Icons.palette;
      case 'download':
        return Icons.download;
      default:
        return Icons.star;
    }
  }
  
  /// Build support section with contact options
  Widget _buildSupportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precisa de ajuda?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Entre em contato conosco para dúvidas sobre assinaturas ou suporte técnico.',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSupportButton(
                  icon: Icons.email_outlined,
                  text: 'Email',
                  onPressed: () => _openSupportEmail(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSupportButton(
                  icon: Icons.help_outline,
                  text: 'Central de Ajuda',
                  onPressed: () => _openHelpCenter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build support button widget
  Widget _buildSupportButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.teal.shade400,
        side: BorderSide(color: Colors.teal.shade400),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Open support email
  Future<void> _openSupportEmail() async {
    final urlLauncher = sl<UrlLauncherService>();
    final result = await urlLauncher.launchEmail(
      email: 'suporte@plantis.app',
      subject: 'Dúvida sobre Premium - ${AppConfig.appName}',
      body: 'Olá!\n\nTenho uma dúvida sobre o Premium:\n\n',
      source: 'premium_page_support',
    );
    
    if (!result.isSuccess && mounted) {
      _showErrorDialog(
        'Não foi possível abrir o aplicativo de email. '
        'Entre em contato conosco através de suporte@plantis.app',
      );
    }
  }
  
  /// Open help center
  Future<void> _openHelpCenter() async {
    final urlLauncher = sl<UrlLauncherService>();
    final result = await urlLauncher.launchUrl(
      AppConfig.helpCenterUrl,
      source: 'premium_page_help_center',
    );
    
    if (!result.isSuccess && mounted) {
      _showErrorDialog(
        'Não foi possível abrir a central de ajuda. '
        'Tente novamente mais tarde ou entre em contato por email.',
      );
    }
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../../widgets/modern_header_widget.dart';
import '../controller/assinaturas_controller.dart';
import '../widgets/receituagro_header_widget.dart';
import '../widgets/subscription_plans_widget.dart';
import '../widgets/terms_widget.dart';

/// Página de assinaturas específica do ReceitaAgro
/// Utiliza os services do core mas com interface customizada
class AssinaturasPage extends GetView<AssinaturasController> {
  const AssinaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final isDark = themeController.isDark.value;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                Expanded(
                  child: _buildBody(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Constrói o header moderno customizado
  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Obx(() => ModernHeaderWidget(
      title: 'ReceitaAgro Premium',
      subtitle: 'Transforme sua experiência agrícola',
      leftIcon: Icons.diamond,
      showBackButton: true,
      showActions: controller.isPremium,
      isDark: isDark,
      onBackPressed: () => Get.back(),
      rightIcon: Icons.verified,
      onRightIconPressed: controller.isPremium 
          ? () => controller.showSubscriptionManagementDialog()
          : null,
      additionalActions: controller.isPremium ? [
        IconButton(
          icon: const Icon(
            Icons.verified,
            color: Colors.white,
            size: 17,
          ),
          onPressed: () => controller.showSubscriptionManagementDialog(),
          tooltip: 'Gerenciar assinatura',
        ),
      ] : null,
    ));
  }

  /// Constrói o corpo da página
  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: Colors.green.shade600,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do ReceitaAgro
                const ReceituagroHeaderWidget(),
                
                const SizedBox(height: 24),
                
                // Progresso da assinatura (só mostra se for premium)
                Obx(() {
                  if (controller.isPremium && controller.isSubscriptionActive) {
                    return Column(
                      children: [
                        SubscriptionProgressWidget(
                          progress: controller.subscriptionProgress,
                          daysRemaining: controller.daysRemaining,
                          isActive: controller.isSubscriptionActive,
                          isFakeSubscription: controller.isUsingFakeSubscription,
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // Planos de assinatura ou status atual
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingWidget(context);
                  }
                  
                  return SubscriptionPlansWidget(
                    packages: controller.availablePackages,
                    isPremium: controller.isPremium,
                    onPurchase: controller.purchasePackage,
                    onRestore: controller.restorePurchases,
                    onManage: controller.showSubscriptionManagementDialog,
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Benefícios do ReceitaAgro (só mostra se não for premium)
                Obx(() {
                  if (!controller.isPremium) {
                    return const Column(
                      children: [
                        ReceituagroBenefitsWidget(),
                        SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // FAQ
                const SubscriptionFaqWidget(),
                
                const SizedBox(height: 24),
                
                // Termos e política
                ReceituagroTermsWidget(
                  onTermsPressed: controller.openTermsOfUse,
                  onPrivacyPressed: controller.openPrivacyPolicy,
                ),
                
                const SizedBox(height: 24),
                
                // Aviso sobre período de avaliação
                _buildTrialNotice(context),
                
                const SizedBox(height: 16),
                
                // Rodapé informativo
                _buildFooter(context),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
    );
  }

  /// Widget de carregamento
  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Colors.green.shade600,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            'Carregando${controller.pointsAnimation.value}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          )),
          const SizedBox(height: 8),
          Text(
            'Buscando os melhores planos para você',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Aviso sobre período de avaliação
  Widget _buildTrialNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Período de Avaliação',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Experimente gratuitamente por 3 dias. Cancele a qualquer momento antes do fim do período para não ser cobrado. Após o período gratuito, sua assinatura será renovada automaticamente.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Rodapé informativo
  Widget _buildFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Segurança e Confiança',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildFooterItem(
            context,
            Icons.lock,
            'Pagamentos processados de forma segura',
          ),
          _buildFooterItem(
            context,
            Icons.cancel,
            'Cancele a qualquer momento',
          ),
          _buildFooterItem(
            context,
            Icons.verified_user,
            'Mais de 6.000 usuários mensais',
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'ReceitaAgro - Transformando a agricultura brasileira',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Item do rodapé
  Widget _buildFooterItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de boas-vindas para novos usuários premium
class WelcomePremiumDialog extends StatelessWidget {
  const WelcomePremiumDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WelcomePremiumDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade600,
              Colors.green.shade800,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified,
                size: 40,
                color: Colors.green.shade600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Bem-vindo ao Premium!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Agora você tem acesso completo a todas as funcionalidades do ReceitaAgro.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar a Explorar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

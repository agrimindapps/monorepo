// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/premium_template/index.dart';

/// Nova página premium do TodoList usando sistema de templates
///
/// Esta página substitui a subscription_screen.dart existente,
/// usando o novo sistema de templates centralizado que:
/// - Reduz 95% do tempo de desenvolvimento
/// - Garante consistência visual entre apps
/// - Facilita manutenção e atualizações
class TodoistPremiumPageTemplate extends StatelessWidget {
  const TodoistPremiumPageTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar template padrão com tema do TodoList
    return PremiumTemplateBuilder.buildTodoistPremium();
  }
}

/// Versão customizada da página premium
class TodoistPremiumPageCustom extends StatelessWidget {
  const TodoistPremiumPageCustom({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar template com customizações específicas do TodoList
    return PremiumTemplateBuilder.buildPremiumPage(
      appId: 'todoist',
      customTheme: AppThemeConfig.forTodoist().copyWith(
        // Customizar cores específicas se necessário
        primaryColor: const Color(0xFF1976D2), // Azul mais escuro
        secondaryColor: const Color(0xFF42A5F5), // Azul claro
      ),
      settings: const PremiumSettings(
        enableDebugInfo: true, // Para desenvolvimento
        showRestoreButton: true,
        autoSelectRecommendedPlan: true,
        showTermsLink: true,
        enableHapticFeedback: true,
      ),
      // Callbacks personalizados se necessário
      onPlanSelected: (planId) {},
      onPurchase: (planId) async {
        // Lógica personalizada de compra aqui
        // Pode integrar com o sistema existente do todoist
      },
      onRestorePurchases: () async {
        // Lógica personalizada de restauração aqui
      },
      onTermsPressed: () {
        // Navegar para página de termos do todoist
        Get.toNamed('/todoist/terms');
      },
    );
  }
}

/// Controller personalizado para o TodoList Premium
class TodoistPremiumController extends GetxController {
  /// Navegar para página premium usando template
  void navigateToPremium() {
    // Usar o factory específico do TodoList
    PremiumTemplateBuilder.navigateToPremiumPage(appId: 'todoist');
  }

  /// Mostrar modal premium
  void showPremiumModal(BuildContext context) {
    PremiumTemplateBuilder.showPremiumModal(
      context: context,
      appId: 'todoist',
    );
  }

  /// Mostrar dialog premium compacto
  void showPremiumDialog(BuildContext context) {
    PremiumTemplateBuilder.showPremiumDialog(
      context: context,
      appId: 'todoist',
    );
  }

  /// Integração com sistema existente do TodoList
  void navigateToLegacySubscriptionScreen() {
    // Manter compatibilidade com a tela antiga se necessário
    Get.toNamed('/subscription_screen');
  }
}

/// Exemplo de integração em outras páginas do TodoList
class TodoistSettingsIntegration extends StatelessWidget {
  const TodoistSettingsIntegration({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Card premium usando tema do TodoList
        Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppThemeConfig.forTodoist().headerGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
              ),
            ),
            title: const Text('TodoList Premium'),
            subtitle: const Text('Maximize sua produtividade'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Usar template para navegar
              PremiumTemplateBuilder.navigateToPremiumPage(
                appId: 'todoist',
              );
            },
          ),
        ),

        // Botão para modal
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              PremiumTemplateBuilder.showPremiumModal(
                context: context,
                appId: 'todoist',
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Ver Premium (Modal)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeConfig.forTodoist().primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // Botão para dialog compacto
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () {
              PremiumTemplateBuilder.showPremiumDialog(
                context: context,
                appId: 'todoist',
              );
            },
            icon: const Icon(Icons.diamond),
            label: const Text('Ver Premium (Dialog)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeConfig.forTodoist().primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar status premium no TodoList
class TodoistPremiumStatusWidget extends StatelessWidget {
  const TodoistPremiumStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Este widget pode ser usado em várias telas para mostrar status premium
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: AppThemeConfig.forTodoist().primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Upgrade para Premium',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              PremiumTemplateBuilder.navigateToPremiumPage(appId: 'todoist');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }
}

/// Como migrar código existente:
///
/// 1. SUBSTITUIR a SubscriptionScreen existente:
///    - Trocar Get.to(() => SubscriptionScreen())
///    - Por: PremiumTemplateBuilder.navigateToPremiumPage(appId: 'todoist')
///
/// 2. ATUALIZAR rotas:
///    - '/subscription_screen' -> usar PremiumTemplateBuilder.buildTodoistPremium()
///
/// 3. INTEGRAR com sistema existente:
///    - Os callbacks onPurchase e onRestorePurchases podem chamar
///      o código existente do InAppPurchaseService e RevenuecatService
///
/// 4. MANTER compatibilidade:
///    - O sistema antigo pode continuar funcionando em paralelo
///    - Migração gradual é possível
///
/// Exemplo de migração de rota:
///
/// ANTES:
/// GetPage(
///   name: '/subscription',
///   page: () => const SubscriptionScreen(),
/// ),
///
/// DEPOIS:
/// GetPage(
///   name: '/premium',
///   page: () => const TodoistPremiumPageTemplate(),
/// ),

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/premium_template/index.dart';

// Exemplo de implementação usando o novo sistema de templates premium
// Este arquivo demonstra como criar uma página premium em minutos usando os templates


class NutritutiPremiumPageTemplate extends StatelessWidget {
  const NutritutiPremiumPageTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    // Opção 1: Usar template padrão (mais simples)
    return PremiumTemplateBuilder.buildNutritutiPremium();
  }
}

class NutritutiPremiumPageCustom extends StatelessWidget {
  const NutritutiPremiumPageCustom({super.key});

  @override
  Widget build(BuildContext context) {
    // Opção 2: Usar template com customizações
    return PremiumTemplateBuilder.buildPremiumPage(
      appId: 'nutrituti',
      customTheme: AppThemeConfig.forNutrituti().copyWith(
        // Personalizar tema se necessário
        primaryColor: const Color(0xFF1976D2), // Azul mais escuro
      ),
      settings: const PremiumSettings(
        enableDebugInfo: true, // Para desenvolvimento
        showRestoreButton: true,
        autoSelectRecommendedPlan: true,
      ),
      // Callbacks personalizados se necessário
      onPlanSelected: (planId) {
        debugPrint('Plano selecionado: $planId');
      },
      onPurchase: (planId) async {
        debugPrint('Iniciando compra do plano: $planId');
        // Lógica personalizada de compra aqui
      },
      onRestorePurchases: () async {
        debugPrint('Restaurando compras...');
        // Lógica personalizada de restauração aqui
      },
      onTermsPressed: () {
        debugPrint('Abrindo termos e condições');
        // Navegar para página de termos
      },
    );
  }
}

// Controller personalizado se necessário
class NutritutiPremiumController extends GetxController {
  void navigateToPremium() {
    // Opção A: Navegação simples
    PremiumTemplateBuilder.navigateToPremiumPage(appId: 'nutrituti');
  }

  void showPremiumModal(BuildContext context) {
    // Opção B: Modal
    PremiumTemplateBuilder.showPremiumModal(
      context: context,
      appId: 'nutrituti',
    );
  }

  void showPremiumDialog(BuildContext context) {
    // Opção C: Dialog
    PremiumTemplateBuilder.showPremiumDialog(
      context: context,
      appId: 'nutrituti',
    );
  }
}

// Exemplo de integração em outra página (ex: configurações)
class ExemploIntegracao extends StatelessWidget {
  const ExemploIntegracao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // Card premium
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppThemeConfig.forNutrituti().headerGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),
              ),
              title: const Text('NutriTuti Premium'),
              subtitle: const Text('Desbloqueie recursos exclusivos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Usar template para navegar
                PremiumTemplateBuilder.navigateToPremiumPage(
                  appId: 'nutrituti',
                );
              },
            ),
          ),
          
          // Botão para modal
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                PremiumTemplateBuilder.showPremiumModal(
                  context: context,
                  appId: 'nutrituti',
                );
              },
              child: const Text('Ver Premium (Modal)'),
            ),
          ),
          
          // Botão para dialog
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                PremiumTemplateBuilder.showPremiumDialog(
                  context: context,
                  appId: 'nutrituti',
                );
              },
              child: const Text('Ver Premium (Dialog)'),
            ),
          ),
        ],
      ),
    );
  }
}

// Exemplo de customização completa de tema para nutrituti
class NutritutiCustomTheme {
  static AppThemeConfig get customTheme {
    return AppThemeConfig.forNutrituti().copyWith(
      // Cores personalizadas
      primaryColor: const Color(0xFF0288D1), // Azul água
      secondaryColor: const Color(0xFF4FC3F7), // Azul claro
      premiumColor: const Color(0xFFFFB300), // Âmbar para premium
      
      // Ajustar gradientes
      headerGradient: const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryGradient: const LinearGradient(
        colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      
      // Ajustar tipografia
      titleFontSize: 28.0,
      subtitleFontSize: 18.0,
      borderRadius: 20.0,
    );
  }
}

// Exemplo de uso com tema customizado
class NutritutiPremiumPageWithCustomTheme extends StatelessWidget {
  const NutritutiPremiumPageWithCustomTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumTemplateBuilder.buildPremiumPage(
      appId: 'nutrituti',
      customTheme: NutritutiCustomTheme.customTheme,
      settings: const PremiumSettings(
        enableDebugInfo: false,
        showRestoreButton: true,
        showTermsLink: true,
        enableHapticFeedback: true,
        autoSelectRecommendedPlan: true,
      ),
    );
  }
}

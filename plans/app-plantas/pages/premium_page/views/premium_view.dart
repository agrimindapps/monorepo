// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/premium_controller.dart';
import '../widgets/premium_features_widget.dart';
import '../widgets/premium_footer_widget.dart';
import '../widgets/premium_header_widget.dart';
import '../widgets/premium_plans_widget.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: PlantasColors.backgroundColor,
            ),
            child: SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PlantasColors.primaryColor,
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // Header com botão de voltar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      snap: true,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: PlantasColors.textColor,
                        ),
                        onPressed: () => controller.goBack(),
                      ),
                      actions: [
                        if (!controller.hasValidApiKeys)
                          IconButton(
                            icon: const Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            onPressed: () => _showConfigurationWarning(context),
                          ),
                      ],
                    ),

                    // Conteúdo principal
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Header com título e descrição
                            const PremiumHeaderWidget(),

                            const SizedBox(height: 16.0),

                            // Recursos premium
                            const PremiumFeaturesWidget(),

                            const SizedBox(height: 32.0),

                            // Planos de assinatura
                            const PremiumPlansWidget(),

                            const SizedBox(height: 16.0),

                            // Footer com termos e restaurar
                            const PremiumFooterWidget(),

                            const SizedBox(height: 16.0),

                            // Debug info (apenas em desenvolvimento)
                            if (_shouldShowDebugInfo()) _buildDebugInfo(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ));
  }

  void _showConfigurationWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuração Necessária'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('As API keys do RevenueCat não estão configuradas.'),
            const SizedBox(height: 12),
            const Text('Erros encontrados:'),
            const SizedBox(height: 8),
            ...controller.configurationErrors.map(
              (error) => Text('• $error', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDebugInfo() {
    // Mostrar info de debug apenas em desenvolvimento
    return !controller.hasValidApiKeys;
  }

  Widget _buildDebugInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PlantasColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PlantasColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: PlantasColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          ...controller.debugInfo.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: PlantasColors.subtitleColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

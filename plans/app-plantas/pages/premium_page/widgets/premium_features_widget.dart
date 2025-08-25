// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../controller/premium_controller.dart';

class PremiumFeaturesWidget extends GetView<PremiumController> {
  const PremiumFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);
    final plantasTextStyles = PlantasDesignTokens.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Recursos Premium',
          style: plantasTextStyles['h1']?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ) ??
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: plantasCores['texto'],
              ),
        ),

        const SizedBox(height: 20),

        // Lista de recursos
        Obx(() => Column(
              children: controller.advantages
                  .map(
                    (advantage) => _buildFeatureItem(
                      advantage['img'] as String,
                      advantage['desc'] as String,
                    ),
                  )
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildFeatureItem(String iconName, String description) {
    return Builder(
      builder: (context) {
        final plantasCores = PlantasDesignTokens.cores(context);
        final plantasGradientes = PlantasDesignTokens.gradientes(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: plantasCores['fundoCard'],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: plantasCores['primaria']!.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícone do recurso
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: plantasGradientes['primario'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromImageName(iconName),
                  size: 28,
                  color: plantasCores['textoClaro'],
                ),
              ),

              const SizedBox(width: 16),

              // Descrição do recurso
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: plantasCores['texto'],
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Ícone de check
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: plantasCores['sucesso'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: plantasCores['textoClaro'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconFromImageName(String imageName) {
    switch (imageName) {
      case 'unlimited_plants.png':
        return Icons.local_florist;
      case 'advanced_reminders.png':
        return Icons.notifications_active;
      case 'sync_devices.png':
        return Icons.sync;
      case 'plant_insights.png':
        return Icons.analytics;
      case 'priority_support.png':
        return Icons.support_agent;
      case 'sem_anuncio.png':
        return Icons.block;
      default:
        return Icons.star;
    }
  }
}

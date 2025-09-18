import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../providers/premium_provider.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium para Plantis
/// 
/// Funcionalidades:
/// - Listar recursos premium específicos para plantas
/// - Dois estilos: moderno (marketing) e card (subscription ativa)
/// - Icons temáticos de plantas
/// - Integração com provider para lista de recursos
/// 
/// Estilos:
/// - Modern: Para marketing/conversão (fundo transparente)
/// - Card: Para usuários ativos (background card)
class PlantisSubscriptionBenefitsWidget extends StatelessWidget {
  final PremiumProvider provider;
  final bool showModernStyle;

  const PlantisSubscriptionBenefitsWidget({
    super.key,
    required this.provider,
    this.showModernStyle = false,
  });

  /// Features premium específicas para Plantis
  List<Map<String, dynamic>> get premiumFeatures => [
    {
      'icon': Icons.all_inclusive,
      'title': 'Plantas Ilimitadas',
      'description': 'Adicione quantas plantas quiser ao seu jardim digital'
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Lembretes Personalizados',
      'description': 'Configure notificações específicas para cada planta'
    },
    {
      'icon': Icons.analytics,
      'title': 'Acompanhamento Avançado',
      'description': 'Monitore o crescimento e saúde das suas plantas'
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização na Nuvem',
      'description': 'Seus dados sempre seguros e sincronizados'
    },
    {
      'icon': Icons.photo_camera,
      'title': 'Galeria de Fotos',
      'description': 'Documente o crescimento com fotos ilimitadas'
    },
    {
      'icon': Icons.eco,
      'title': 'Diagnósticos Avançados',
      'description': 'Identifique problemas e receba soluções personalizadas'
    },
    {
      'icon': Icons.palette,
      'title': 'Temas Personalizados',
      'description': 'Personalize a aparência do aplicativo'
    },
    {
      'icon': Icons.download,
      'title': 'Exportação de Dados',
      'description': 'Exporte suas informações em diversos formatos'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return showModernStyle 
        ? _buildModernFeaturesList()
        : _buildCardFeaturesList();
  }

  /// Estilo moderno para marketing/conversão
  Widget _buildModernFeaturesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que está incluído',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...premiumFeatures.take(3).map((feature) => _buildModernFeatureItem(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['description'] as String,
          )),
        ],
      ),
    );
  }

  /// Estilo card para usuários com subscription ativa
  Widget _buildCardFeaturesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos Premium Ativados:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...premiumFeatures.map((feature) => _buildCardFeatureItem(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
            )),
          ],
        ),
      ),
    );
  }

  /// Item de recurso para estilo moderno
  Widget _buildModernFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
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
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item de recurso para estilo card
  Widget _buildCardFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PlantisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: PlantisColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
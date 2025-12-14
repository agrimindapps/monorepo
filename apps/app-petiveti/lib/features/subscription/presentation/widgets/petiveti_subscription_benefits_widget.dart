import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium para PetiVeti
///
/// Funcionalidades:
/// - Listar recursos premium específicos para pets
/// - Dois estilos: moderno (marketing) e card (subscription ativa)
/// - Icons temáticos de pets/veterinária
class PetivetiSubscriptionBenefitsWidget extends StatelessWidget {
  final bool showModernStyle;

  const PetivetiSubscriptionBenefitsWidget({
    super.key,
    this.showModernStyle = false,
  });

  /// Features premium específicas para PetiVeti
  List<Map<String, dynamic>> get premiumFeatures => [
    {
      'icon': Icons.pets,
      'title': 'Pets Ilimitados',
      'description': 'Adicione quantos pets quiser ao seu gerenciador',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Lembretes Personalizados',
      'description': 'Configure notificações de vacinas, medicamentos e consultas',
    },
    {
      'icon': Icons.medical_services,
      'title': 'Histórico Veterinário',
      'description': 'Acompanhe todo histórico de saúde dos seus pets',
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização na Nuvem',
      'description': 'Seus dados sempre seguros e sincronizados',
    },
    {
      'icon': Icons.photo_camera,
      'title': 'Galeria de Fotos',
      'description': 'Documente a vida dos seus pets com fotos ilimitadas',
    },
    {
      'icon': Icons.calculate,
      'title': 'Calculadoras Premium',
      'description': 'Acesso a todas as calculadoras veterinárias',
    },
    {
      'icon': Icons.analytics,
      'title': 'Relatórios Avançados',
      'description': 'Exportação de dados e relatórios detalhados',
    },
    {
      'icon': Icons.block,
      'title': 'Sem Anúncios',
      'description': 'Experiência livre de propagandas',
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
          ...premiumFeatures
              .take(4)
              .map(
                (feature) => _buildModernFeatureItem(
                  feature['icon'] as IconData,
                  feature['title'] as String,
                  feature['description'] as String,
                ),
              ),
        ],
      ),
    );
  }

  /// Estilo card para usuários com subscription ativa
  Widget _buildCardFeaturesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recursos Premium Ativados:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...premiumFeatures.map(
            (feature) => _buildCardFeatureItem(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
            ),
          ),
        ],
      ),
    );
  }

  /// Item de recurso para estilo moderno
  Widget _buildModernFeatureItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
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
  Widget _buildCardFeatureItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
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

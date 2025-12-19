import 'package:flutter/material.dart';

import '../../../../core/theme/nebula_colors.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium para Nebulalist
///
/// Funcionalidades:
/// - Listar recursos premium específicos para listas e tarefas
/// - Dois estilos: moderno (marketing) e card (subscription ativa)
/// - Icons temáticos de produtividade
///
/// Estilos:
/// - Modern: Para marketing/conversão (fundo transparente)
/// - Card: Para usuários ativos (background card)
class SubscriptionBenefitsWidget extends StatelessWidget {
  final bool showModernStyle;

  const SubscriptionBenefitsWidget({
    super.key,
    this.showModernStyle = false,
  });

  /// Features premium específicas para Nebulalist
  List<Map<String, dynamic>> get premiumFeatures => [
        {
          'icon': Icons.all_inclusive,
          'title': 'Listas Ilimitadas',
          'description': 'Crie quantas listas e tarefas precisar',
        },
        {
          'icon': Icons.folder_special,
          'title': 'Categorias Premium',
          'description': 'Organize com categorias e tags personalizadas',
        },
        {
          'icon': Icons.notifications_active,
          'title': 'Lembretes Inteligentes',
          'description': 'Notificações baseadas em localização e contexto',
        },
        {
          'icon': Icons.cloud_sync,
          'title': 'Sincronização na Nuvem',
          'description': 'Seus dados sempre seguros e sincronizados',
        },
        {
          'icon': Icons.people,
          'title': 'Listas Compartilhadas',
          'description': 'Colabore com família e amigos em tempo real',
        },
        {
          'icon': Icons.analytics,
          'title': 'Estatísticas Detalhadas',
          'description': 'Acompanhe sua produtividade e hábitos',
        },
        {
          'icon': Icons.auto_awesome,
          'title': 'Temas Exclusivos',
          'description': 'Personalize com temas nebula únicos',
        },
        {
          'icon': Icons.download,
          'title': 'Exportação de Dados',
          'description': 'Exporte suas listas em diversos formatos',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return showModernStyle
        ? _buildModernFeaturesList()
        : _buildCardFeaturesList(context);
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
          ...premiumFeatures.take(4).map(
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
  Widget _buildCardFeaturesList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos Premium Ativados:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...premiumFeatures.map(
            (feature) => _buildCardFeatureItem(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
              isDark,
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
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NebulaColors.primaryPurple.withValues(alpha: 0.2),
                  NebulaColors.accentCyan.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: NebulaColors.primaryPurple,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
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

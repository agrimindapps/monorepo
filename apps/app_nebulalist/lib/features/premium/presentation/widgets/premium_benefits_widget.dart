import 'package:flutter/material.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium para NebulaList
///
/// Funcionalidades:
/// - Listar recursos premium específicos para listas/tarefas
/// - Design moderno com ícones e descrições
/// - Estilo compatível com gradiente Deep Purple → Indigo
class PremiumBenefitsWidget extends StatelessWidget {
  const PremiumBenefitsWidget({super.key});

  /// Features premium específicas para NebulaList
  List<Map<String, dynamic>> get premiumFeatures => [
        {
          'icon': Icons.list_alt,
          'title': 'Listas Ilimitadas',
          'description': 'Crie quantas listas quiser sem limitações',
        },
        {
          'icon': Icons.check_box,
          'title': 'Itens Ilimitados',
          'description': 'Adicione infinitos itens em suas listas',
        },
        {
          'icon': Icons.cloud_sync,
          'title': 'Sincronização em Nuvem',
          'description': 'Seus dados seguros e sincronizados',
        },
        {
          'icon': Icons.notifications_active,
          'title': 'Lembretes Personalizados',
          'description': 'Configure notificações para cada tarefa',
        },
        {
          'icon': Icons.palette,
          'title': 'Temas Premium',
          'description': 'Acesse temas exclusivos e personalize',
        },
        {
          'icon': Icons.file_download,
          'title': 'Exportação de Dados',
          'description': 'Exporte suas listas em PDF, Excel e mais',
        },
        {
          'icon': Icons.support_agent,
          'title': 'Prioridade no Suporte',
          'description': 'Atendimento prioritário e dedicado',
        },
        {
          'icon': Icons.block,
          'title': 'Sem Anúncios',
          'description': 'Experiência sem interrupções',
        },
      ];

  @override
  Widget build(BuildContext context) {
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
          ...premiumFeatures.map(
            (feature) => _buildFeatureItem(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
            ),
          ),
        ],
      ),
    );
  }

  /// Item de recurso premium
  Widget _buildFeatureItem(
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
}

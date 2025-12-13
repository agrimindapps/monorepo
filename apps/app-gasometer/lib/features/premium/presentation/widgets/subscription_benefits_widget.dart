import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';

class SubscriptionBenefitsWidget extends ConsumerStatefulWidget {
  const SubscriptionBenefitsWidget({
    super.key,
    this.showModernStyle = false,
  });

  final bool showModernStyle;

  @override
  ConsumerState<SubscriptionBenefitsWidget> createState() =>
      _SubscriptionBenefitsWidgetState();
}

class _SubscriptionBenefitsWidgetState
    extends ConsumerState<SubscriptionBenefitsWidget> {
  bool _isExpanded = true;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.directions_car,
      'title': 'Veículos Ilimitados',
      'description': 'Cadastre quantos veículos quiser',
    },
    {
      'icon': Icons.analytics,
      'title': 'Relatórios Avançados',
      'description': 'Análises detalhadas de consumo e gastos',
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização em Nuvem',
      'description': 'Seus dados seguros e acessíveis em qualquer lugar',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Alertas Personalizados',
      'description': 'Lembretes de manutenção e vencimentos',
    },
    {
      'icon': Icons.file_download,
      'title': 'Exportação de Dados',
      'description': 'Exporte seus registros em PDF e Excel',
    },
    {
      'icon': Icons.support_agent,
      'title': 'Suporte Prioritário',
      'description': 'Atendimento exclusivo para assinantes',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return widget.showModernStyle
        ? _buildModernFeaturesList()
        : _buildCardFeaturesList();
  }

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
          ..._features.take(4).map(
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

  Widget _buildCardFeaturesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ..._features.map(
              (feature) => _buildCardFeatureItem(
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['description'] as String,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              color: GasometerDesignTokens.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: GasometerDesignTokens.colorPrimary,
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

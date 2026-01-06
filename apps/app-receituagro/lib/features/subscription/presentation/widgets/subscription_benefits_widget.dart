import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/receituagro_colors.dart';

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
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.description,
      'title': 'Receituários Ilimitados',
      'description': 'Emita quantos receituários agronômicos precisar',
    },
    {
      'icon': Icons.offline_pin,
      'title': 'Acesso Offline',
      'description': 'Consulte e emita receitas mesmo sem internet',
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Backup em Nuvem',
      'description': 'Seus dados seguros e sincronizados entre dispositivos',
    },
    {
      'icon': Icons.picture_as_pdf,
      'title': 'PDF Personalizado',
      'description': 'Receitas com sua logo e assinatura digital',
    },
    {
      'icon': Icons.library_books,
      'title': 'Bula Completa',
      'description': 'Acesso à base de dados atualizada de defensivos',
    },
    {
      'icon': Icons.support_agent,
      'title': 'Suporte Prioritário',
      'description': 'Atendimento exclusivo via WhatsApp',
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
              color: ReceitaAgroColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ReceitaAgroColors.primary,
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

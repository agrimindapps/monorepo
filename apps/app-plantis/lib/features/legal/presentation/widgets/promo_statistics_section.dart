import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

class PromoStatisticsSection extends StatelessWidget {
  const PromoStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    final statistics = [
      {'number': '50K+', 'label': 'Plantas Cadastradas', 'icon': Icons.eco},
      {'number': '10K+', 'label': 'Jardineiros Ativos', 'icon': Icons.people},
      {'number': '500K+', 'label': 'Lembretes Enviados', 'icon': Icons.notifications},
      {'number': '4.8★', 'label': 'Avaliação Média', 'icon': Icons.star},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.1),
            PlantisColors.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Números que impressionam',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: statistics.map((stat) {
                  return _buildStatCard(
                    stat['number'] as String,
                    stat['label'] as String,
                    stat['icon'] as IconData,
                    isMobile,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? 150 : 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isMobile ? 32 : 48,
            color: PlantisColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            number,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: PlantisColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
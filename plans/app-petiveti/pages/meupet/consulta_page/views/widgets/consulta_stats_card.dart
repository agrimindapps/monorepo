// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_page_controller.dart';
import '../styles/consulta_page_styles.dart';

class ConsultaStatsCard extends StatelessWidget {
  final ConsultaPageController controller;

  const ConsultaStatsCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasConsultas) {
        return const SizedBox.shrink();
      }

      final stats = controller.getConsultaStats();
      final total = stats['total'] as int;
      final thisMonth = stats['thisMonth'] as int;
      final thisYear = stats['thisYear'] as int;

      return Card(
        elevation: ConsultaPageStyles.cardElevation,
        shape: ConsultaPageStyles.cardShape,
        child: Padding(
          padding: ConsultaPageStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: ConsultaPageStyles.primaryColor,
                    size: ConsultaPageStyles.iconSize,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Estatísticas',
                    style: ConsultaPageStyles.subtitleStyle,
                  ),
                  const Spacer(),
                  if (controller.hasActiveFilters())
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ConsultaPageStyles.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Filtrado',
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          color: ConsultaPageStyles.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total',
                      total.toString(),
                      Icons.medical_services,
                      ConsultaPageStyles.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Este mês',
                      thisMonth.toString(),
                      Icons.calendar_month,
                      ConsultaPageStyles.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Este ano',
                      thisYear.toString(),
                      Icons.calendar_today,
                      ConsultaPageStyles.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              if (controller.hasActiveFilters()) ...[
                const SizedBox(height: 12),
                const Divider(color: ConsultaPageStyles.dividerColor),
                const SizedBox(height: 8),
                Text(
                  controller.getFilterSummary(),
                  style: ConsultaPageStyles.captionStyle,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: ConsultaPageStyles.iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: ConsultaPageStyles.titleStyle.copyWith(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ConsultaPageStyles.captionStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

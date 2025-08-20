// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class HealthInsightsWidget extends StatelessWidget {
  final DashboardController controller;

  const HealthInsightsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSelectedPet) {
      return const SizedBox.shrink();
    }

    final statistics = controller.statistics;

    return Card(
      elevation: DashboardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DashboardHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights de Saúde',
              style: DashboardHelpers.getCardTitleStyle(context),
            ),
            const SizedBox(height: 16),
            ...statistics.saudeMetrics.entries.map((entry) => _buildSaudeItem(
                  label: entry.key,
                  percentual: entry.value,
                )),
            const SizedBox(height: 24),
            _buildRecomendacoesVet(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaudeItem({required String label, required double percentual}) {
    final color = DashboardConstants.getHealthColor(percentual);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '$percentual%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentual / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacoesVet() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Recomendações do Veterinário',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Aumentar as atividades físicas diárias e manter o controle de peso. Próxima vacina em 12 dias.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

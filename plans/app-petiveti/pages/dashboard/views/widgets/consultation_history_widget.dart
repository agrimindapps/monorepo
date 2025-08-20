// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_data_model.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class ConsultationHistoryWidget extends StatelessWidget {
  final DashboardController controller;

  const ConsultationHistoryWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Histórico de Consultas',
          style: DashboardHelpers.getCardTitleStyle(context),
        ),
        TextButton.icon(
          onPressed: () => controller.navigateToConsultationHistory(context),
          icon: const Icon(Icons.history, size: 16),
          label: const Text('Ver tudo'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!controller.hasSelectedPet) {
      return const SizedBox.shrink();
    }

    if (controller.consultas.isEmpty) {
      return DashboardHelpers.buildEmptyState(
        icon: Icons.medical_services_outlined,
        title: 'Nenhuma consulta registrada',
      );
    }

    return Column(
      children: List.generate(
        controller.consultas.length,
        (index) {
          final consulta = controller.consultas[index];
          return Column(
            children: [
              _buildConsultaItem(consulta),
              if (index < controller.consultas.length - 1)
                const Divider(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConsultaItem(ConsultaData consulta) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medical_services,
            color: Colors.blue[700],
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                consulta.motivo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Veterinário: ${consulta.veterinario}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                consulta.diagnostico,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              consulta.dataFormatada,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                DashboardHelpers.formatCurrency(consulta.valor),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

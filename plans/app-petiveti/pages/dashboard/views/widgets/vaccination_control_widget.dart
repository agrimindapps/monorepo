// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../services/chart_data_service.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class VaccinationControlWidget extends StatelessWidget {
  final DashboardController controller;

  const VaccinationControlWidget({
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
            Text(
              'Controle de Vacinas',
              style: DashboardHelpers.getCardTitleStyle(context),
            ),
            const SizedBox(height: 16),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!controller.hasSelectedPet) {
      return const SizedBox.shrink();
    }

    if (controller.vacinas.isEmpty) {
      return DashboardHelpers.buildEmptyState(
        icon: Icons.vaccines_outlined,
        title: 'Nenhuma vacina registrada',
        action: TextButton.icon(
          onPressed: () => controller.navigateToAddVaccination(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nova vacina'),
        ),
      );
    }

    return Column(
      children: [
        _buildVacinasTable(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => controller.navigateToAddVaccination(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nova vacina'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVacinasTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 12,
        columns: const [
          DataColumn(
            label: Text(
              'Vacina',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Data Aplicação',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Próxima Dose',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: controller.vacinas.map((vacina) {
          final statusColor = ChartDataService.getVaccinationStatusColor(vacina);

          return DataRow(cells: [
            DataCell(Text(vacina.nome)),
            DataCell(Text(vacina.dataFormatada)),
            DataCell(Text(vacina.proximaFormatada)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vacina.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

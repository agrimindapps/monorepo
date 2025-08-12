// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../utils/dashboard_helpers.dart';

class SummaryCardsWidget extends StatelessWidget {
  final DashboardController controller;

  const SummaryCardsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSelectedPet) {
      return const SizedBox.shrink();
    }

    final statistics = controller.statistics;
    final isSmallScreen = DashboardHelpers.isSmallScreen(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: DashboardHelpers.getGridColumns(context),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: DashboardHelpers.getGridAspectRatio(context),
      children: [
        _buildInfoCard(
          icon: Icons.medical_services,
          title: 'Consultas',
          value: '${statistics.totalConsultas}',
          subtitle: 'no ano',
          color: Colors.blue,
        ),
        _buildInfoCard(
          icon: Icons.event,
          title: 'Próxima Consulta',
          value: '${statistics.diasProximaConsulta}',
          subtitle: 'dias restantes',
          color: Colors.orange,
        ),
        _buildInfoCard(
          icon: Icons.vaccines,
          title: 'Vacinas Pendentes',
          value: '${statistics.vacinasPendentes}',
          subtitle: statistics.vacinasPendentes == 1 ? 'vacina' : 'vacinas',
          color: Colors.red,
        ),
        _buildInfoCard(
          icon: Icons.favorite,
          title: 'Índice de Saúde',
          value: '${statistics.indiceSaude}%',
          subtitle: 'score geral',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DashboardHelpers.getCardPadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: DashboardHelpers.getValueStyle(),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: DashboardHelpers.getStatLabelStyle(),
            ),
            Text(
              subtitle,
              style: DashboardHelpers.getStatSubtitleStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class QuickActionsWidget extends StatelessWidget {
  final DashboardController controller;

  const QuickActionsWidget({
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
              'Ações Rápidas',
              style: DashboardHelpers.getCardTitleStyle(context),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.monitor_weight,
                  label: 'Registrar Peso',
                  color: Colors.blue,
                  onTap: () => controller.navigateToWeightRegistration(context),
                ),
                _buildActionButton(
                  icon: Icons.medical_services,
                  label: 'Nova Consulta',
                  color: Colors.green,
                  onTap: () => controller.navigateToConsultationRegistration(context),
                ),
                _buildActionButton(
                  icon: Icons.vaccines,
                  label: 'Registrar Vacina',
                  color: Colors.orange,
                  onTap: () => controller.navigateToVaccinationRegistration(context),
                ),
                _buildActionButton(
                  icon: Icons.medication,
                  label: 'Medicamento',
                  color: Colors.red,
                  onTap: () => controller.navigateToMedicationRegistration(context),
                ),
                _buildActionButton(
                  icon: Icons.receipt_long,
                  label: 'Nova Despesa',
                  color: Colors.purple,
                  onTap: () => controller.navigateToExpenseRegistration(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: DashboardConstants.actionButtonWidth,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: DashboardConstants.actionButtonIconSize,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color.withRed((color.red * 0.8).round()),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

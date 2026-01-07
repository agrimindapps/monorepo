// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../shared/widgets/share_button.dart';
import '../../domain/entities/emergency_reserve_calculation.dart';

/// Card displaying emergency reserve calculation results
class EmergencyReserveResultCard extends StatelessWidget {
  final EmergencyReserveCalculation calculation;

  const EmergencyReserveResultCard({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                const SizedBox(width: 8),
                Text(
                  'Resultado do Cálculo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Monthly Expenses
            _buildResultRow(
              context,
              'Despesas Mensais Básicas',
              formatter.format(calculation.monthlyExpenses),
            ),
            if (calculation.extraExpenses > 0)
              _buildResultRow(
                context,
                'Despesas Extras',
                formatter.format(calculation.extraExpenses),
              ),

            const SizedBox(height: 8),

            _buildResultRow(
              context,
              'Total de Despesas Mensais',
              formatter.format(calculation.totalMonthlyExpenses),
              isBold: true,
            ),

            const Divider(height: 24),

            _buildResultRow(
              context,
              'Meses de Cobertura Desejados',
              '${calculation.desiredMonths} ${calculation.desiredMonths == 1 ? "mês" : "meses"}',
            ),

            const Divider(height: 24, thickness: 2),

            // Total Reserve Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meta da Reserva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(calculation.totalReserveAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor(calculation.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categoria: ${calculation.category}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calculation.categoryDescription,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Construction Time
            if (calculation.monthlySavings > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tempo para Construir a Reserva',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Poupando ${formatter.format(calculation.monthlySavings)} por mês:',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${calculation.constructionYears} ${calculation.constructionYears == 1 ? "ano" : "anos"} e ${calculation.constructionMonths} ${calculation.constructionMonths == 1 ? "mês" : "meses"}',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Summary Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recomendações',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Invista em aplicações de liquidez diária',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Mantenha em investimentos de baixo risco',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Não utilize exceto em emergências reais',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Reponha imediatamente após uso',
                    style: _detailTextStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ShareButton(
              text: ShareFormatter.formatEmergencyReserve(
                monthlyExpenses: calculation.totalMonthlyExpenses,
                monthsToCover: calculation.desiredMonths,
                totalReserve: calculation.totalReserveAmount,
                monthlySavings: calculation.monthlySavings,
              ),
              subject: 'Reserva de Emergência',
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mínima':
        return Colors.red.shade600;
      case 'Básica':
        return Colors.orange.shade600;
      case 'Confortável':
        return Colors.green.shade600;
      case 'Robusta':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _detailTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }
}

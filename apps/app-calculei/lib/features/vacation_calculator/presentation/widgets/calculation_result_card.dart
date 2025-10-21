import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vacation_calculation.dart';

/// Card displaying vacation calculation results
class CalculationResultCard extends StatelessWidget {
  final VacationCalculation calculation;

  const CalculationResultCard({
    super.key,
    required this.calculation,
  });

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
                Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                  size: 28,
                ),
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

            // Base Values
            _buildResultRow(
              context,
              'Valor Base das Férias',
              formatter.format(calculation.baseValue),
            ),
            _buildResultRow(
              context,
              'Adicional 1/3 Constitucional',
              formatter.format(calculation.constitutionalBonus),
            ),

            if (calculation.soldDaysValue > 0) ...[
              _buildResultRow(
                context,
                'Abono Pecuniário (1/3 vendido)',
                formatter.format(calculation.soldDaysValue),
                isHighlight: true,
              ),
            ],

            const Divider(height: 20),

            // Gross Total
            _buildResultRow(
              context,
              'Total Bruto',
              formatter.format(calculation.grossTotal),
              isBold: true,
            ),

            const SizedBox(height: 12),

            // Deductions
            _buildResultRow(
              context,
              'Desconto INSS',
              '- ${formatter.format(calculation.inssDiscount)}',
              isDeduction: true,
            ),
            _buildResultRow(
              context,
              'Desconto IR',
              '- ${formatter.format(calculation.irDiscount)}',
              isDeduction: true,
            ),

            const Divider(height: 24, thickness: 2),

            // Net Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Valor Líquido a Receber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(calculation.netTotal),
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

            // Summary Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes do Cálculo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${calculation.vacationDays} dias de férias',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '• Salário base: ${formatter.format(calculation.grossSalary)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  if (calculation.sellVacationDays)
                    Text(
                      '• Com venda de 1/3 das férias (abono)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
    bool isDeduction = false,
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
                color: isDeduction
                    ? Colors.red[700]
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isDeduction
                  ? Colors.red[700]
                  : isHighlight
                      ? Colors.green[700]
                      : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

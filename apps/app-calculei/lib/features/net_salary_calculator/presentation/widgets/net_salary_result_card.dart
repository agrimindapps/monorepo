// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../shared/widgets/share_button.dart';
import '../../domain/entities/net_salary_calculation.dart';

/// Card displaying net salary calculation results
class NetSalaryResultCard extends StatelessWidget {
  final NetSalaryCalculation calculation;

  const NetSalaryResultCard({super.key, required this.calculation});

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

            // Gross Salary
            _buildResultRow(
              context,
              'Salário Bruto',
              formatter.format(calculation.grossSalary),
              isBold: true,
            ),

            const SizedBox(height: 12),

            // Deductions Section
            Text(
              'Descontos Obrigatórios',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),

            _buildResultRow(
              context,
              'INSS (${(calculation.inssRate * 100).toStringAsFixed(1)}%)',
              '- ${formatter.format(calculation.inssDiscount)}',
              isDeduction: true,
            ),
            _buildResultRow(
              context,
              'IRRF (${(calculation.irrfRate * 100).toStringAsFixed(1)}%)',
              '- ${formatter.format(calculation.irrfDiscount)}',
              isDeduction: true,
            ),

            if (calculation.transportationVoucher > 0 ||
                calculation.healthInsurance > 0 ||
                calculation.otherDiscounts > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Descontos Voluntários',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (calculation.transportationVoucher > 0)
              _buildResultRow(
                context,
                'Vale Transporte',
                '- ${formatter.format(calculation.transportationVoucherDiscount)}',
                isDeduction: true,
              ),

            if (calculation.healthInsurance > 0)
              _buildResultRow(
                context,
                'Plano de Saúde',
                '- ${formatter.format(calculation.healthInsurance)}',
                isDeduction: true,
              ),

            if (calculation.otherDiscounts > 0)
              _buildResultRow(
                context,
                'Outros Descontos',
                '- ${formatter.format(calculation.otherDiscounts)}',
                isDeduction: true,
              ),

            const Divider(height: 20),

            _buildResultRow(
              context,
              'Total de Descontos',
              '- ${formatter.format(calculation.totalDiscounts)}',
              isBold: true,
              isDeduction: true,
            ),

            const Divider(height: 24, thickness: 2),

            // Net Salary
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
                    'Salário Líquido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(calculation.netSalary),
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
                    'Detalhes do Cálculo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Base de cálculo IRRF: ${formatter.format(calculation.irrfCalculationBase)}',
                    style: _detailTextStyle(context),
                  ),
                  if (calculation.dependents > 0)
                    Text(
                      '• Dependentes: ${calculation.dependents}',
                      style: _detailTextStyle(context),
                    ),
                  Text(
                    '• Percentual de descontos: ${((calculation.totalDiscounts / calculation.grossSalary) * 100).toStringAsFixed(1)}%',
                    style: _detailTextStyle(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            ShareButton(
              text: ShareFormatter.formatNetSalary(
                grossSalary: calculation.grossSalary,
                inss: calculation.inssDiscount,
                ir: calculation.irrfDiscount,
                netSalary: calculation.netSalary,
                discounts:
                    calculation.totalDiscounts -
                    calculation.inssDiscount -
                    calculation.irrfDiscount,
              ),
              subject: 'Cálculo de Salário Líquido',
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
              fontWeight: isBold || isHighlight
                  ? FontWeight.bold
                  : FontWeight.w500,
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

  TextStyle _detailTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }
}

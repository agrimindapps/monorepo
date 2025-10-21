// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../domain/entities/thirteenth_salary_calculation.dart';

/// Card displaying 13th salary calculation results
class ThirteenthSalaryResultCard extends StatelessWidget {
  final ThirteenthSalaryCalculation calculation;

  const ThirteenthSalaryResultCard({
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
              'Valor por Mês',
              formatter.format(calculation.valuePerMonth),
            ),
            _buildResultRow(
              context,
              'Meses Considerados',
              '${calculation.consideredMonths} ${calculation.consideredMonths == 1 ? "mês" : "meses"}',
            ),

            const Divider(height: 20),

            // Gross 13th Salary
            _buildResultRow(
              context,
              '13º Salário Bruto',
              formatter.format(calculation.grossThirteenthSalary),
              isBold: true,
            ),

            const SizedBox(height: 12),

            // Deductions
            _buildResultRow(
              context,
              'Desconto INSS (${(calculation.inssRate * 100).toStringAsFixed(1)}%)',
              '- ${formatter.format(calculation.inssDiscount)}',
              isDeduction: true,
            ),
            _buildResultRow(
              context,
              'Desconto IRRF (${(calculation.irrfRate * 100).toStringAsFixed(1)}%)',
              '- ${formatter.format(calculation.irrfDiscount)}',
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
                    '13º Líquido a Receber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(calculation.netThirteenthSalary),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Installments (if advance payment)
            if (calculation.isAdvancePayment) ...[
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
                        Icon(Icons.payments, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Pagamento em 2 Parcelas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstallmentRow(
                      context,
                      '1ª Parcela',
                      formatter.format(calculation.firstInstallment),
                      'Até 30 de Novembro',
                    ),
                    const Divider(height: 12),
                    _buildInstallmentRow(
                      context,
                      '2ª Parcela',
                      formatter.format(calculation.secondInstallment),
                      'Até 20 de Dezembro',
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
                    '• Salário base: ${formatter.format(calculation.grossSalary)}',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Meses trabalhados: ${calculation.monthsWorked}',
                    style: _detailTextStyle(context),
                  ),
                  if (calculation.unjustifiedAbsences > 0)
                    Text(
                      '• Faltas não justificadas: ${calculation.unjustifiedAbsences}',
                      style: _detailTextStyle(context),
                    ),
                  if (calculation.dependents > 0)
                    Text(
                      '• Dependentes: ${calculation.dependents}',
                      style: _detailTextStyle(context),
                    ),
                  if (calculation.monthsWorked != calculation.consideredMonths)
                    Text(
                      '• Desconto por faltas: ${calculation.monthsWorked - calculation.consideredMonths} ${calculation.monthsWorked - calculation.consideredMonths == 1 ? "mês" : "meses"}',
                      style: _detailTextStyle(context).copyWith(
                        color: Colors.red[700],
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

  Widget _buildInstallmentRow(
    BuildContext context,
    String label,
    String value,
    String deadline,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deadline,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
      ],
    );
  }

  TextStyle _detailTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }
}

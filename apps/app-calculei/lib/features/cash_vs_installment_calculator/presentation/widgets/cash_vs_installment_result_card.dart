// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../domain/entities/cash_vs_installment_calculation.dart';

/// Card displaying cash vs installment calculation results
class CashVsInstallmentResultCard extends StatelessWidget {
  final CashVsInstallmentCalculation calculation;

  const CashVsInstallmentResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final percentFormatter = NumberFormat.percentPattern('pt_BR');

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
                  'Resultado da Comparação',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Cash Option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calculation.bestOption == 'À Vista'
                    ? Colors.green[50]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: calculation.bestOption == 'À Vista'
                      ? Colors.green
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.money_off,
                            color: calculation.bestOption == 'À Vista'
                                ? Colors.green[700]
                                : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'À Vista',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: calculation.bestOption == 'À Vista'
                                  ? Colors.green[900]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (calculation.bestOption == 'À Vista')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'MELHOR OPÇÃO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(calculation.cashPrice),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: calculation.bestOption == 'À Vista'
                          ? Colors.green[900]
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Installment Option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calculation.bestOption == 'Parcelado'
                    ? Colors.green[50]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: calculation.bestOption == 'Parcelado'
                      ? Colors.green
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: calculation.bestOption == 'Parcelado'
                                ? Colors.green[700]
                                : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Parcelado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: calculation.bestOption == 'Parcelado'
                                  ? Colors.green[900]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (calculation.bestOption == 'Parcelado')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'MELHOR OPÇÃO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.numberOfInstallments}x ${formatter.format(calculation.installmentPrice)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: calculation.bestOption == 'Parcelado'
                          ? Colors.green[900]
                          : Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Total: ${formatter.format(calculation.totalInstallmentPrice)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: calculation.bestOption == 'Parcelado'
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Analysis Details
            _buildResultRow(
              context,
              'Taxa de juros implícita',
              '${(calculation.implicitRate * 100).toStringAsFixed(2)}% ao mês',
            ),
            _buildResultRow(
              context,
              'Valor presente das parcelas',
              formatter.format(calculation.presentValueOfInstallments),
            ),

            const Divider(height: 24, thickness: 2),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        calculation.bestOption == 'À Vista'
                            ? 'Economize pagando à vista'
                            : 'Vantajoso parcelar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calculation.bestOption == 'À Vista'
                        ? 'Você economiza ${formatter.format(calculation.savingsOrAdditionalCost)} pagando à vista!'
                        : 'Parcelando, o custo adicional é de apenas ${formatter.format(calculation.savingsOrAdditionalCost)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional Info
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
                    'Considerações Importantes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Análise baseada em taxa mensal de ${calculation.monthlyInterestRate.toStringAsFixed(2)}%',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Considere sua reserva de emergência',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Valor presente considera o custo de oportunidade',
                    style: _detailTextStyle(context),
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
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }
}

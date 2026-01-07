// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../shared/widgets/share_button.dart';
import '../../domain/entities/overtime_calculation.dart';

/// Card displaying overtime calculation results
class OvertimeResultCard extends StatelessWidget {
  final OvertimeCalculation calculation;

  const OvertimeResultCard({super.key, required this.calculation});

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

            // Base Values
            _buildResultRow(
              context,
              'Salário Base',
              formatter.format(calculation.grossSalary),
            ),
            _buildResultRow(
              context,
              'Valor Hora Normal',
              formatter.format(calculation.normalHourValue),
            ),

            const Divider(height: 20),

            // Overtime Values
            Text(
              'Horas Extras Trabalhadas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),

            if (calculation.hours50 > 0) ...[
              _buildResultRow(
                context,
                'Horas 50% (${calculation.hours50}h × ${formatter.format(calculation.hour50Value)})',
                formatter.format(calculation.total50),
                isHighlight: true,
              ),
            ],

            if (calculation.hours100 > 0) ...[
              _buildResultRow(
                context,
                'Horas 100% (${calculation.hours100}h × ${formatter.format(calculation.hour100Value)})',
                formatter.format(calculation.total100),
                isHighlight: true,
              ),
            ],

            if (calculation.nightHours > 0) ...[
              _buildResultRow(
                context,
                'Adicional Noturno (${calculation.nightHours}h)',
                formatter.format(calculation.totalNightAdditional),
                isHighlight: true,
              ),
            ],

            if (calculation.sundayHolidayHours > 0) ...[
              _buildResultRow(
                context,
                'Domingo/Feriado (${calculation.sundayHolidayHours}h)',
                formatter.format(calculation.totalSundayHoliday),
                isHighlight: true,
              ),
            ],

            const Divider(height: 20),

            // Reflections
            Text(
              'Reflexos das Horas Extras',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),

            _buildResultRow(
              context,
              'DSR (Descanso Remunerado)',
              formatter.format(calculation.dsrOvertime),
            ),
            _buildResultRow(
              context,
              'Reflexo em Férias',
              formatter.format(calculation.vacationReflection),
            ),
            _buildResultRow(
              context,
              'Reflexo no 13º Salário',
              formatter.format(calculation.thirteenthReflection),
            ),

            const Divider(height: 20),

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
                    'Total Líquido a Receber',
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
                    'Resumo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Total de horas extras: ${calculation.totalOvertimeHours.toStringAsFixed(0)}h',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Jornada semanal: ${calculation.weeklyHours}h',
                    style: _detailTextStyle(context),
                  ),
                  Text(
                    '• Valor acréscimo: ${formatter.format(calculation.netTotal - calculation.grossSalary)}',
                    style: _detailTextStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ShareButton(
              text: ShareFormatter.formatOvertime(
                grossSalary: calculation.grossSalary,
                weeklyHours: calculation.weeklyHours,
                totalOvertimeValue: calculation.totalOvertime,
              ),
              subject: 'Cálculo de Horas Extras',
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

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../constants/abastecimento_strings.dart';
import '../controller/abastecimento_page_controller.dart';

class AbastecimentoMetricsWidget extends GetView<AbastecimentoPageController> {
  final DateTime date;

  const AbastecimentoMetricsWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final abastecimentosDoMes = controller.getAbastecimentosForDate(date);
    final metricas =
        controller.calcularMetricasMensais(date, abastecimentosDoMes);

    final totalGastoMes = metricas['totalGastoMes'] as double;
    final totalLitrosMes = metricas['totalLitrosMes'] as double;
    final precoMedioLitro = metricas['precoMedioLitro'] as double;
    final mediaConsumoMes = metricas['mediaConsumoMes'] as double;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnStyle.backgroundColor,
          borderRadius: ShadcnStyle.borderRadius,
          border: Border.all(color: ShadcnStyle.borderColor),
        ),
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfo(
                    icon: Icons.attach_money,
                    label: AbastecimentoStrings.totalSpent,
                    value: controller.formatCurrency(totalGastoMes),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildHeaderInfo(
                    icon: Icons.local_gas_station,
                    label: AbastecimentoStrings.totalLiters,
                    value:
                        '${totalLitrosMes.toStringAsFixed(1)} ${AbastecimentoStrings.litersUnit}',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildHeaderInfo(
                    icon: Icons.speed,
                    label: AbastecimentoStrings.monthlyAverage,
                    value: mediaConsumoMes > 0
                        ? '${mediaConsumoMes.toStringAsFixed(1)} ${AbastecimentoStrings.kmPerLiterUnit}'
                        : AbastecimentoStrings.notApplicable,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildHeaderInfo(
                    icon: Icons.trending_up,
                    label: AbastecimentoStrings.averagePrice,
                    value: precoMedioLitro > 0
                        ? controller.formatCurrency(precoMedioLitro)
                        : AbastecimentoStrings.notApplicable,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ShadcnStyle.textColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ShadcnStyle.textColor, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: ShadcnStyle.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ShadcnStyle.mutedTextColor,
          ),
        ),
      ],
    );
  }
}

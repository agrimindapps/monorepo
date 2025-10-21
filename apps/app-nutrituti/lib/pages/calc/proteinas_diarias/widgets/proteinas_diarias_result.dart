// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/proteinas_diarias_controller.dart';
import '../model/proteinas_diarias_model.dart';

class ProteinasDiariasResult extends StatelessWidget {
  final ProteinasDiariasModel model;
  final ProteinasDiariasController controller;

  const ProteinasDiariasResult({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: model.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: model.calculado,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultHeader(context),
                const SizedBox(height: 16),
                _buildResultValues(context),
                const SizedBox(height: 16),
                _buildInfoSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              'Resultado do Cálculo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => controller.compartilhar(),
          tooltip: 'Compartilhar resultado',
        ),
      ],
    );
  }

  Widget _buildResultValues(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ShadcnStyle.borderColor : Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumo Diário Recomendado de Proteínas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueDisplay(
                'Mínimo',
                '${model.numberFormat.format(model.proteinasMinimas)} g/dia',
                isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              _buildValueDisplay(
                'Máximo',
                '${model.numberFormat.format(model.proteinasMaximas)} g/dia',
                isDark ? Colors.green.shade300 : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.shade900.withValues(alpha: 0.2)
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.amber.shade900 : Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
              ),
              const SizedBox(width: 8),
              Text(
                'Observações Importantes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Esses valores são apenas uma referência geral\n'
            '• As necessidades individuais podem variar\n'
            '• Consulte um profissional de saúde para recomendações específicas',
            style: TextStyle(
              color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

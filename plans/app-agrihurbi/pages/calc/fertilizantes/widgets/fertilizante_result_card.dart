// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/fertilizantes_controller.dart';

class FertilizanteResultCard extends StatelessWidget {
  FertilizanteResultCard({super.key}) {
    _numberFormat = NumberFormat('#,##0.00', 'pt_BR');
  }

  late final NumberFormat _numberFormat;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FertilizantesController>(
      builder: (controller) {
        final model = controller.model;

        return AnimatedOpacity(
          opacity: model.calculado ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: model.calculado,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultHeader(context),
                    const Divider(thickness: 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildResultValues(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildInfoSection(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    final controller = Get.find<FertilizantesController>();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        TextButton.icon(
          onPressed: controller.compartilhar,
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Compartilhar'),
          style: ShadcnStyle.primaryButtonStyle,
        ),
      ],
    );
  }

  Widget _buildResultValues(BuildContext context) {
    final controller = Get.find<FertilizantesController>();
    final model = controller.model;
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultItem(
            'DAP (Fosfato Diamônico)',
            model.resultadoDap,
            Icons.science,
            isDark ? Colors.amber.shade300 : Colors.amber,
            controller,
          ),
          _buildResultItem(
            'U (Ureia)',
            model.resultadoU,
            Icons.science,
            isDark ? Colors.green.shade300 : Colors.green,
            controller,
          ),
          _buildResultItem(
            'MOP (Cloreto de Potássio)',
            model.resultadoMop,
            Icons.science,
            isDark ? Colors.blue.shade300 : Colors.blue,
            controller,
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, num value, IconData icon, Color color,
      FertilizantesController controller) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
                        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                  ),
                  Text(
                    '${_numberFormat.format(value)} Kgs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
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

  Widget _buildInfoSection(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(top: isLargeScreen ? 16 : 0),
      decoration: BoxDecoration(
        color: isDark
            ? ShadcnStyle.borderColor.withOpacity(0.3)
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
            'Legenda:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'DAP - Fosfato Diamônico (18% N, 46% P₂O₅)',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'U - Ureia (46% N)',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'MOP - Cloreto de Potássio (60% K₂O)',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
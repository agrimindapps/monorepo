// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/volume_sanguineo_controller.dart';
import '../formatters/volume_formatter.dart';

class VolumeSanguineoResultCard extends StatelessWidget {
  const VolumeSanguineoResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VolumeSanguineoController>();

    // Verifica se o cálculo foi realizado
    if (!controller.isCalculated) {
      return const SizedBox();
    }

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(controller),
            const Divider(thickness: 1),
            _buildResultValues(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(VolumeSanguineoController controller) {
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

  Widget _buildResultValues(VolumeSanguineoController controller) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            isDark,
            title: 'Tipo de Pessoa',
            value: controller.model.generoDef['text'] as String,
            color: Colors.red,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildResultCard(
            isDark,
            title: 'Peso',
            value: VolumeSanguineoFormatter.formatWeight(controller.model.peso),
            color: Colors.indigo,
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          _buildResultCard(
            isDark,
            title: 'Volume Sanguíneo',
            value: VolumeSanguineoFormatter.formatVolume(
                controller.model.resultado),
            description:
                'Fator utilizado: ${controller.model.generoDef['value']} ml/kg',
            color: Colors.orange,
            icon: Icons.opacity_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    bool isDark, {
    required String title,
    required String value,
    String? description,
    required MaterialColor color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isDark ? color.shade900.withValues(alpha: 0.15) : color.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? color.shade900 : color.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? color.shade300 : color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? color.shade300 : color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

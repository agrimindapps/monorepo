// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/nivel_dano_economico_controller.dart';

class ResultCardWidget extends StatelessWidget {
  final NivelDanoEconomicoController controller;

  const ResultCardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return AnimatedOpacity(
      opacity: controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.calculado,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resultados da Análise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.compartilhar(),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Compartilhar'),
                      style: ShadcnStyle.textButtonStyle,
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                _buildResultadoPrincipal(isDark),
                const SizedBox(height: 16),
                _buildInterpretacao(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultadoPrincipal(bool isDark) {
    return Card(
      elevation: 0,
      color:
          isDark ? Colors.amber.withValues(alpha: 0.1) : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.amber.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.pest_control,
              color: isDark ? Colors.amber.shade300 : Colors.amber,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Nível de Dano Econômico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.formatNumber(controller.resultado)} unidades/ha',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretacao(bool isDark) {
    Color getColorForNivel() {
      switch (controller.nivelRisco) {
        case 'baixo':
          return isDark ? Colors.red.shade300 : Colors.red;
        case 'moderado':
          return isDark ? Colors.amber.shade300 : Colors.amber;
        case 'alto':
          return isDark ? Colors.green.shade300 : Colors.green;
        default:
          return isDark ? Colors.blue.shade300 : Colors.blue;
      }
    }

    IconData getIconForNivel() {
      switch (controller.nivelRisco) {
        case 'baixo':
          return Icons.error_outline;
        case 'moderado':
          return Icons.warning_amber_outlined;
        case 'alto':
          return Icons.check_circle_outline;
        default:
          return Icons.info_outline;
      }
    }

    final color = getColorForNivel();
    final icon = getIconForNivel();

    return Card(
      elevation: 0,
      color:
          isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.interpretacao,
                style: TextStyle(
                  fontSize: 14,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

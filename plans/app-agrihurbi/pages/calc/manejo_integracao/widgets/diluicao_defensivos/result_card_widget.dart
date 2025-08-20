// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/diluicao_defensivos_controller.dart';
import 'recomendacoes_widget.dart';

class ResultCardWidget extends StatelessWidget {
  final DiluicaoDefensivosController controller;

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
                      'Resultados da Diluição',
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ResultItemWidget(
                          title: 'Quantidade do Defensivo',
                          value:
                              '${controller.formatNumber(controller.resultado)} ${controller.unidadeSelecionada}',
                          icon: Icons.local_drink_outlined,
                          color: isDark ? Colors.amber.shade300 : Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ResultItemWidget(
                          title: 'Área Tratada',
                          value:
                              '${controller.formatNumber(controller.areaAtingida)} ha',
                          icon: Icons.crop_outlined,
                          color: isDark ? Colors.green.shade300 : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const RecomendacoesWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultItemWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultItemWidget({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
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
}

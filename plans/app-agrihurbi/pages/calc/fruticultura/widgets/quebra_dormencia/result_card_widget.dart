// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/quebra_dormencia_controller.dart';

class ResultCardWidget extends StatelessWidget {
  final QuebraDormenciaController controller;

  const ResultCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return AnimatedOpacity(
      opacity: controller.model.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.model.calculado,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: isDark ? Colors.blue.shade300 : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          SharePlus.instance.share(ShareParams(text: controller.compartilharTexto())),
                      icon: Icon(
                        Icons.share,
                        color: ShadcnStyle.textColor,
                      ),
                      tooltip: 'Compartilhar resultados',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Déficit de Horas de Frio
                _buildHorasFrioItem(
                  'Déficit de Horas de Frio',
                  '${controller.numberFormat.format(controller.model.deficitHorasFrio)} horas',
                  Icons.ac_unit,
                  controller.getDeficitColor(isDark),
                ),
                const SizedBox(height: 16),

                // Recomendação
                Text(
                  'Recomendação:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.model.recomendacaoPrincipal,
                  style: TextStyle(
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Produtos e Dosagens
                Text(
                  'Produtos e Dosagens:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.model.dosagensProdutos.entries.map(
                  (e) => _buildProductRow(e.key, e.value),
                ),
                const SizedBox(height: 16),

                // Custos
                Text(
                  'Custos Estimados:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCustoItem(
                  'Por hectare:',
                  controller.currencyFormat.format(
                    controller.model.custoEstimadoPorHectare,
                  ),
                ),
                _buildCustoItem(
                  'Total:',
                  controller.currencyFormat.format(controller.model.custoTotal),
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorasFrioItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  Text(
                    value,
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

  Widget _buildProductRow(String produto, String dosagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.science, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              produto,
              style: TextStyle(
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
          Text(
            dosagem,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustoItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ShadcnStyle.textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ShadcnStyle.textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

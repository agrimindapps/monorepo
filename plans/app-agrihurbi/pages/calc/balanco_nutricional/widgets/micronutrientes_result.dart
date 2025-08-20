// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controllers/micronutrientes_controller.dart';

class MicronutrientesResult extends StatelessWidget {
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  MicronutrientesResult({super.key});

  Widget _buildResultItem(
      String title, String value, IconData icon, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.08),
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

  Widget _buildRecomendacoes() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: isDark ? Colors.amber.shade300 : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recomendações para aplicação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecomendacaoItem(
              'Aplicar os micronutrientes de forma uniforme',
              Icons.grid_on_outlined,
              isDark ? Colors.green.shade300 : Colors.green,
            ),
            _buildRecomendacaoItem(
              'Considerar a interação entre os nutrientes',
              Icons.compare_arrows_outlined,
              isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            _buildRecomendacaoItem(
              'Monitorar o pH do solo para melhor absorção',
              Icons.analytics_outlined,
              isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            _buildRecomendacaoItem(
              'Realizar análise foliar periodicamente',
              Icons.eco_outlined,
              isDark ? Colors.orange.shade300 : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacaoItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final controller = Get.find<MicronutrientesController>();

    return GetBuilder<MicronutrientesController>(
      builder: (_) {
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
                      'Resultados do Cálculo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => SharePlus.instance.share(ShareParams(text: controller.compartilhar())),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Compartilhar'),
                      style: ShadcnStyle.textButtonStyle,
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultItem(
                              'Zinco por Hectare',
                              '${_numberFormat.format(controller.model.necessidadeZinco)} kg/ha',
                              Icons.science_outlined,
                              isDark ? Colors.blue.shade300 : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultItem(
                              'Zinco Total',
                              '${_numberFormat.format(controller.model.totalZinco)} kg',
                              Icons.inventory_2_outlined,
                              isDark ? Colors.blue.shade300 : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultItem(
                              'Boro por Hectare',
                              '${_numberFormat.format(controller.model.necessidadeBoro)} kg/ha',
                              Icons.science_outlined,
                              isDark ? Colors.green.shade300 : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultItem(
                              'Boro Total',
                              '${_numberFormat.format(controller.model.totalBoro)} kg',
                              Icons.inventory_2_outlined,
                              isDark ? Colors.green.shade300 : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultItem(
                              'Cobre por Hectare',
                              '${_numberFormat.format(controller.model.necessidadeCobre)} kg/ha',
                              Icons.science_outlined,
                              isDark ? Colors.orange.shade300 : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultItem(
                              'Cobre Total',
                              '${_numberFormat.format(controller.model.totalCobre)} kg',
                              Icons.inventory_2_outlined,
                              isDark ? Colors.orange.shade300 : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultItem(
                              'Manganês por Hectare',
                              '${_numberFormat.format(controller.model.necessidadeManganes)} kg/ha',
                              Icons.science_outlined,
                              isDark ? Colors.purple.shade300 : Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultItem(
                              'Manganês Total',
                              '${_numberFormat.format(controller.model.totalManganes)} kg',
                              Icons.inventory_2_outlined,
                              isDark ? Colors.purple.shade300 : Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultItem(
                              'Ferro por Hectare',
                              '${_numberFormat.format(controller.model.necessidadeFerro)} kg/ha',
                              Icons.science_outlined,
                              isDark ? Colors.red.shade300 : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultItem(
                              'Ferro Total',
                              '${_numberFormat.format(controller.model.totalFerro)} kg',
                              Icons.inventory_2_outlined,
                              isDark ? Colors.red.shade300 : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildRecomendacoes(),
              ],
            ),
          ),
        ),
            ),
          );
      },
    );
  }
}

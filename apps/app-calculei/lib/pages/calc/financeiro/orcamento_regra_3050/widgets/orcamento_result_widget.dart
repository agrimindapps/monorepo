// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/orcamento_regra_3050/widgets/controllers/orcamento_controller.dart';

class OrcamentoResultWidget extends StatelessWidget {
  const OrcamentoResultWidget({super.key});

  Widget _buildLegendItem(Color color, String label) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.8 : 1),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(
      String label, num value, Color color, String prefix) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.pie_chart_outline,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
            Text(
              '$prefix ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrcamentoController>();
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AnimatedOpacity(
      opacity: controller.resultadoVisivel ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.resultadoVisivel,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.situacaoGeralColor
                        .withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.situacaoGeralColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: controller.situacaoGeralColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.situacaoGeral,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: controller.situacaoGeralColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                isMobile
                    ? Column(
                        children: [
                          _buildPieChartSection(
                            'Distribuição Ideal',
                            [
                              PieChartSectionData(
                                value: 50,
                                title: '50%',
                                color: Colors.blue,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: 30,
                                title: '30%',
                                color: Colors.green,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: 20,
                                title: '20%',
                                color: Colors.orange,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildPieChartSection(
                            'Sua Distribuição',
                            controller.graficoSections,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildPieChartSection(
                              'Distribuição Ideal',
                              [
                                PieChartSectionData(
                                  value: 50,
                                  title: '50%',
                                  color: Colors.blue,
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 30,
                                  title: '30%',
                                  color: Colors.green,
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 20,
                                  title: '20%',
                                  color: Colors.orange,
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildPieChartSection(
                              'Sua Distribuição',
                              controller.graficoSections,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                _buildResultSection(
                  'Despesas Essenciais',
                  controller.despesasEssenciaisPercentual,
                  Colors.blue,
                  '%',
                ),
                _buildResultSection(
                  'Despesas Não Essenciais',
                  controller.despesasNaoEssenciaisPercentual,
                  Colors.green,
                  '%',
                ),
                _buildResultSection(
                  'Investimentos',
                  controller.investimentosPercentual,
                  Colors.orange,
                  '%',
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () =>
                        _compartilharResultados(context, controller),
                    tooltip: 'Compartilhar resultados',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(
      String title, List<PieChartSectionData> sections) {
    final isDark = ThemeManager().isDark.value;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendItem(Colors.blue, 'Despesas Essenciais'),
            _buildLegendItem(Colors.green, 'Despesas Não Essenciais'),
            _buildLegendItem(Colors.orange, 'Investimentos'),
          ],
        ),
      ],
    );
  }

  void _compartilharResultados(
      BuildContext context, OrcamentoController controller) {
    final text = '''
Orçamento Pessoal - Regra 50-30-20

Situação Geral: ${controller.situacaoGeral}

Distribuição Atual:
• Despesas Essenciais: ${controller.despesasEssenciaisPercentual.toStringAsFixed(1)}%
• Despesas Não Essenciais: ${controller.despesasNaoEssenciaisPercentual.toStringAsFixed(1)}%
• Investimentos: ${controller.investimentosPercentual.toStringAsFixed(1)}%

Distribuição Ideal:
• Despesas Essenciais: 50%
• Despesas Não Essenciais: 30%
• Investimentos: 20%
''';

    Share.share(text);
  }
}

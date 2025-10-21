// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/widgets/controllers/custo_efetivo_total_controller.dart';

class CustoEfetivoTotalResult extends StatelessWidget {
  final CustoEfetivoTotalController controller;

  const CustoEfetivoTotalResult({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final model = controller.model;

    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resultado da Análise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: controller.compartilhar,
                      tooltip: 'Compartilhar resultados',
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 16),
                _buildMainResult(isDark, model),
                const SizedBox(height: 20),
                _buildComparisonTable(isDark, model),
                const SizedBox(height: 20),
                _buildCostDetails(isDark, model),
                const SizedBox(height: 20),
                _buildRecommendationCard(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainResult(bool isDark, dynamic model) {
    return Card(
      color: isDark ? Colors.amber.withAlpha(26) : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.amber.withAlpha(77) : Colors.amber.shade100,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Custo Efetivo Total (CET)',
              style: TextStyle(
                fontSize: 16,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.formatadorPercentual.format(model.cetAnual),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                ),
                Text(
                  '/ano',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            Text(
              '(${controller.formatadorPercentual.format(model.cetMensal)}/mês)',
              style: TextStyle(
                fontSize: 16,
                color: ShadcnStyle.mutedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(bool isDark, dynamic model) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: DataTable(
        columnSpacing: 15,
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        columns: [
          DataColumn(
            label: Text(
              '',
              style: TextStyle(color: ShadcnStyle.textColor),
            ),
          ),
          DataColumn(
            label: Text(
              'Anual',
              style: TextStyle(color: ShadcnStyle.textColor),
            ),
          ),
          DataColumn(
            label: Text(
              'Mensal',
              style: TextStyle(color: ShadcnStyle.textColor),
            ),
          ),
        ],
        rows: [
          _buildDataRow(
            'Taxa nominal',
            '${controller.taxaJurosAnualController.text}%',
            controller.formatadorPercentual
                .format(model.taxaJurosEfetivaMensal),
            isDark,
          ),
          _buildDataRow(
            'Taxa efetiva',
            controller.formatadorPercentual.format(model.taxaJurosEfetivaAnual),
            controller.formatadorPercentual
                .format(model.taxaJurosEfetivaMensal),
            isDark,
          ),
          _buildDataRow(
            'CET',
            controller.formatadorPercentual.format(model.cetAnual),
            controller.formatadorPercentual.format(model.cetMensal),
            isDark,
            highlight: true,
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
      String label, String annual, String monthly, bool isDark,
      {bool highlight = false}) {
    final textStyle = TextStyle(
      color: ShadcnStyle.textColor,
      fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
    );

    return DataRow(
      cells: [
        DataCell(Text(label, style: textStyle)),
        DataCell(Text(annual, style: textStyle)),
        DataCell(Text(monthly, style: textStyle)),
      ],
    );
  }

  Widget _buildCostDetails(bool isDark, dynamic model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do empréstimo:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildCostItem(
          'Valor da parcela',
          controller.formatadorMoeda.format(model.valorParcela),
          Icons.payments_outlined,
          isDark ? Colors.blue.shade300 : Colors.blue,
          isDark,
        ),
        _buildCostItem(
          'Valor total pago',
          controller.formatadorMoeda.format(model.custoTotalEmprestimo),
          Icons.account_balance_wallet_outlined,
          isDark ? Colors.green.shade300 : Colors.green,
          isDark,
        ),
        _buildCostItem(
          'Total em juros',
          controller.formatadorMoeda.format(model.totalJuros),
          Icons.trending_up,
          isDark ? Colors.orange.shade300 : Colors.orange,
          isDark,
        ),
        _buildCostItem(
          'Total em taxas/encargos',
          controller.formatadorMoeda.format(model.totalTaxasEncargos),
          Icons.request_quote_outlined,
          isDark ? Colors.purple.shade300 : Colors.purple,
          isDark,
        ),
        const Divider(thickness: 1),
        _buildCostItem(
          'Custo final',
          controller.formatadorMoeda
              .format(model.totalJuros + model.totalTaxasEncargos),
          Icons.money_off_outlined,
          isDark ? Colors.red.shade300 : Colors.red,
          isDark,
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildCostItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    bool highlight = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: color,
                fontSize: highlight ? 16 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(bool isDark) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color:
          isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Compare o CET com outras instituições financeiras para encontrar a melhor opção de crédito. Considere também o prazo e as condições de pagamento.',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

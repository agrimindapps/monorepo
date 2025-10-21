// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/widgets/controllers/custo_real_credito_controller.dart';

class CustoRealCreditoResultWidget extends StatelessWidget {
  final CustoRealCreditoController controller;

  const CustoRealCreditoResultWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDark = ThemeManager().isDark.value;

    if (model == null) {
      return const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  onPressed: () {}, // TODO: Implementar compartilhamento
                  tooltip: 'Compartilhar resultados',
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            _buildResultItem(
              'Valor Total Pago',
              formatoMoeda.format(model.valorTotalPago),
              Icons.account_balance_wallet_outlined,
              isDark ? Colors.blue.shade300 : Colors.blue,
              isDark,
            ),
            _buildResultItem(
              'Total de Juros Pagos',
              formatoMoeda.format(model.totalJurosPagos),
              Icons.trending_up,
              isDark ? Colors.orange.shade300 : Colors.orange,
              isDark,
            ),
            _buildResultItem(
              'Rendimento do Investimento',
              formatoMoeda.format(model.ganhoInvestimento),
              Icons.savings_outlined,
              isDark ? Colors.green.shade300 : Colors.green,
              isDark,
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            _buildResultItem(
              'Custo Real Efetivo',
              formatoMoeda.format(model.custoRealEfetivo),
              Icons.calculate_outlined,
              isDark ? Colors.purple.shade300 : Colors.purple,
              isDark,
              highlight: true,
            ),
            const SizedBox(height: 20),
            _buildConclusion(model.custoRealEfetivo, formatoMoeda, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
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
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildConclusion(
    double custoRealEfetivo,
    NumberFormat formatoMoeda,
    bool isDark,
  ) {
    final positivo = custoRealEfetivo > 0;
    final color = positivo ? Colors.green : Colors.blue;
    final icon = positivo ? Icons.trending_up : Icons.credit_card;
    final texto = positivo
        ? 'É mais vantajoso PAGAR À VISTA E INVESTIR a diferença. '
            'O parcelamento custa ${formatoMoeda.format(custoRealEfetivo)} a mais no total.'
        : 'É mais vantajoso PARCELAR a compra. '
            'Você economiza ${formatoMoeda.format(-custoRealEfetivo)} em relação ao pagamento à vista.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? color.shade300 : color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? color.shade100 : color.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../model/previsao_simples_model.dart';

class PrevisaoSimplesResultCard extends StatelessWidget {
  final PrevisaoSimplesModel model;
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  PrevisaoSimplesResultCard({
    super.key,
    required this.model,
  });

  void _compartilhar() {
    final shareText = '''
    Previsão de Custos Agrícolas

    Valores
    Área Plantada: ${_numberFormat.format(model.areaPlantada)} ha
    Custo por Hectare: R\$ ${_numberFormat.format(model.custoPorHa)}
    Sacas Previstas por Ha: ${_numberFormat.format(model.sacasPrevistas)}
    Valor da Saca: R\$ ${_numberFormat.format(model.valorSaca)}

    Resultados
    Custo Total: R\$ ${_numberFormat.format(model.custoTotal)}
    Lucro Total: R\$ ${_numberFormat.format(model.lucroTotal)}
    Custo por Saca: R\$ ${_numberFormat.format(model.custoPorSaca)}
    Lucro por Saca: R\$ ${_numberFormat.format(model.lucroPorSaca)}
    Sacas Gastas por Ha: ${_numberFormat.format(model.sacasGastasPorHa)}
    Saldo Geral: R\$ ${_numberFormat.format(model.saldoGeral)}
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  Widget _buildResultHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ShadcnStyle.textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: _compartilhar,
            icon: Icon(
              Icons.share,
              color: ShadcnStyle.textColor,
            ),
            tooltip: 'Compartilhar resultados',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: ShadcnStyle.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(context),
            _buildResultItem(
              context,
              label: 'Custo Total:',
              value: 'R\$ ${_numberFormat.format(model.custoTotal)}',
              color: isDark ? Colors.red.shade300 : Colors.red,
              icon: Icons.trending_down,
            ),
            _buildResultItem(
              context,
              label: 'Lucro Total:',
              value: 'R\$ ${_numberFormat.format(model.lucroTotal)}',
              color: model.lucroTotal >= 0
                  ? (isDark ? Colors.green.shade300 : Colors.green)
                  : (isDark ? Colors.red.shade300 : Colors.red),
              icon: model.lucroTotal >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
            ),
            const Divider(),
            _buildResultItem(
              context,
              label: 'Saldo Geral:',
              value: 'R\$ ${_numberFormat.format(model.saldoGeral)}',
              isBold: true,
              color: model.saldoGeral >= 0
                  ? (isDark ? Colors.green.shade300 : Colors.green)
                  : (isDark ? Colors.red.shade300 : Colors.red),
              boxShadow: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
    bool isBold = false,
    bool boxShadow = false,
    IconData? icon,
  }) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: ShadcnStyle.textColor,
        );

    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: color ?? ShadcnStyle.textColor,
        );

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
              ],
              Text(value, style: valueStyle),
            ],
          ),
        ],
      ),
    );

    if (boxShadow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ShadcnStyle.borderColor),
          color: Theme.of(context).cardColor,
        ),
        child: content,
      );
    }

    return content;
  }
}

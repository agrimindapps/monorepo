// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/widgets/controllers/valor_futuro_controller.dart';

class ValorFuturoResult extends StatelessWidget {
  final bool isMobile;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  ValorFuturoResult({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ValorFuturoController>();

    return AnimatedOpacity(
      opacity: controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.calculado,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? _buildMobileLayout(context, controller)
                : _buildDesktopLayout(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, ValorFuturoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoSection(controller),
        const SizedBox(height: 16),
        _buildResultValues(context, controller),
      ],
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, ValorFuturoController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildInfoSection(controller),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 7,
          child: _buildResultValues(context, controller),
        ),
      ],
    );
  }

  Widget _buildResultValues(
      BuildContext context, ValorFuturoController controller) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultHeader(controller),
          const SizedBox(height: 16),
          _buildResultItem(
            'Valor Futuro',
            controller.valorFuturo,
            Icons.attach_money_outlined,
            controller.getColorForValorFuturo(isDark),
            isCurrency: true,
          ),
          _buildResultItem(
            'Lucro',
            controller.lucro,
            Icons.trending_up_outlined,
            controller.getColorForValorFuturo(isDark),
            isCurrency: true,
          ),
          _buildResultCategory(
            'Classificação',
            controller.classificacao,
            Icons.category_outlined,
            controller.getColorForValorFuturo(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(ValorFuturoController controller) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: controller.getColorForValorFuturo(isDark),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: controller.compartilhar,
          tooltip: 'Compartilhar resultados',
        ),
      ],
    );
  }

  Widget _buildResultItem(
      String label, double value, IconData icon, Color color,
      {bool isCurrency = false}) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
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
              isCurrency
                  ? _currencyFormat.format(value)
                  : value.toStringAsFixed(2),
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

  Widget _buildResultCategory(
      String label, String category, IconData icon, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
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
              category,
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

  Widget _buildInfoSection(ValorFuturoController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados do Cálculo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Valor Inicial:',
              _currencyFormat.format(controller.valorInicial)),
          _buildInfoRow('Taxa de Juros:',
              '${controller.taxa}% ${controller.ehAnual ? 'ao ano' : 'ao mês'}'),
          _buildInfoRow('Período:', controller.periodoFormatado),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/independencia_financeira_theme.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/controllers/independencia_financeira_controller.dart';

class ResultadoWidget extends StatelessWidget {
  final IndependenciaFinanceiraController controller;

  const ResultadoWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.calculoRealizado || controller.modelo == null) {
      return const SizedBox();
    }

    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  color: IndependenciaFinanceiraTheme.getResultColor(isDark),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: IndependenciaFinanceiraTheme.getResultColor(isDark),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {/* TODO: Add share functionality */},
              tooltip: 'Compartilhar resultados',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: isDark ? Colors.black.withAlpha(51) : Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildItemResultado(
                  'Patrimônio Necessário',
                  'R\$ ${controller.formatarNumero(controller.modelo!.patrimonioAlvo)}',
                  Icons.account_balance_outlined,
                  isDark ? Colors.blue.shade300 : Colors.blue,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildItemResultado(
                  'Tempo para Independência',
                  controller.modelo!.anosParaIndependencia > 0
                      ? '${controller.modelo!.anosParaIndependencia} anos'
                      : 'Você já atingiu a independência financeira!',
                  Icons.timeline_outlined,
                  IndependenciaFinanceiraTheme.getResultColor(isDark),
                  isDark,
                  destaque: true,
                ),
                const SizedBox(height: 24),
                _buildSugestoes(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSugestoes(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark
          ? Colors.green.shade900.withValues(alpha: 0.2)
          : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.green.shade700 : Colors.green.shade200,
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
                  Icons.lightbulb_outline,
                  size: 20,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sugestões',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.green.shade300 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.getSugestaoTexto(),
              style: TextStyle(
                color: isDark ? Colors.green.shade100 : Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemResultado(
    String label,
    String valor,
    IconData icon,
    Color color,
    bool isDark, {
    bool destaque = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1,
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
              valor,
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
}

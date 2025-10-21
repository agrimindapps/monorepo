// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/widgets/controller/reserva_emergencia_controller.dart';
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/widgets/utils/reserva_emergencia_utils.dart';

class ReservaEmergenciaResultCard extends StatelessWidget {
  const ReservaEmergenciaResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReservaEmergenciaController>();

    return AnimatedOpacity(
      opacity: controller.resultadoVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.resultadoVisible,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(controller),
                const SizedBox(height: 16),
                _buildResults(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ReservaEmergenciaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultado da Reserva',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: controller.getColorForCategoria(isDark),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: controller.compartilharResultados,
          tooltip: 'Compartilhar resultados',
        ),
      ],
    );
  }

  Widget _buildResults(ReservaEmergenciaController controller) {
    final isDark = ThemeManager().isDark.value;
    final numberFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildValueCard(
          'Reserva Total',
          numberFormat.format(controller.modelo.valorTotalReserva),
          Icons.account_balance_wallet_outlined,
          controller.getColorForCategoria(isDark),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          controller.modelo.categoriaReserva,
          controller.modelo.descricaoCategoria,
          controller.getColorForCategoria(isDark),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildDetailsCard(controller, isDark),
        if (controller.tempoConstrucao['anos']! > 0 ||
            controller.tempoConstrucao['meses']! > 0) ...[
          const SizedBox(height: 12),
          _buildTimeEstimateCard(controller, isDark),
        ],
        const SizedBox(height: 12),
        _buildInvestmentOptionsCard(isDark),
      ],
    );
  }

  Widget _buildValueCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String category,
    String description,
    Color color,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_outlined, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Categoria: $category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
      ReservaEmergenciaController controller, bool isDark) {
    return Card(
      elevation: 0,
      color:
          isDark ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.grey.shade100,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Despesas Mensais',
              ReservaEmergenciaUtils.formatarMoeda(
                controller.modelo.despesasMensais,
              ),
              isDark,
            ),
            const SizedBox(height: 6),
            _buildDetailRow(
              'Despesas Extras',
              controller.modelo.despesasExtras > 0
                  ? ReservaEmergenciaUtils.formatarMoeda(
                      controller.modelo.despesasExtras,
                    )
                  : 'Nenhuma',
              isDark,
            ),
            const SizedBox(height: 6),
            _buildDetailRow(
              'Total Mensal',
              ReservaEmergenciaUtils.formatarMoeda(
                controller.modelo.totalMensal,
              ),
              isDark,
            ),
            const SizedBox(height: 6),
            _buildDetailRow(
              'Período',
              '${controller.modelo.mesesDesejados} meses',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeEstimateCard(
    ReservaEmergenciaController controller,
    bool isDark,
  ) {
    String tempoTexto = '';
    if (controller.tempoConstrucao['anos']! > 0) {
      tempoTexto +=
          '${controller.tempoConstrucao['anos']} ${controller.tempoConstrucao['anos']! == 1 ? 'ano' : 'anos'}';
    }
    if (controller.tempoConstrucao['meses']! > 0) {
      if (tempoTexto.isNotEmpty) tempoTexto += ' e ';
      tempoTexto +=
          '${controller.tempoConstrucao['meses']} ${controller.tempoConstrucao['meses']! == 1 ? 'mês' : 'meses'}';
    }

    return Card(
      elevation: 0,
      color: isDark ? Colors.purple.withValues(alpha: 0.15) : Colors.purple.shade50,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              isDark ? Colors.purple.withValues(alpha: 0.3) : Colors.purple.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.hourglass_bottom,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tempo para Construção',
                    style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tempoTexto,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
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

  Widget _buildInvestmentOptionsCard(bool isDark) {
    final options = [
      {
        'title': 'Tesouro Selic',
        'description': 'Segurança do governo + liquidez em D+1',
        'icon': Icons.monetization_on_outlined,
      },
      {
        'title': 'CDBs com liquidez diária',
        'description': 'Bom rendimento com garantia do FGC',
        'icon': Icons.account_balance_outlined,
      },
    ];

    return Card(
      elevation: 0,
      color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.shade200,
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
                  Icons.account_balance,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Onde Investir',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...options
                .map((option) => Padding(
                      padding: const EdgeInsets.only(left: 32, top: 8),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            size: 16,
                            color: isDark ? Colors.blue.shade300 : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  option['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

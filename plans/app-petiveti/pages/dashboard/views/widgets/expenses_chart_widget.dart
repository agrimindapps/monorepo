// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/dashboard_controller.dart';
import '../../services/chart_data_service.dart';
import '../../utils/dashboard_constants.dart';
import '../../utils/dashboard_helpers.dart';

class ExpensesChartWidget extends StatelessWidget {
  final DashboardController controller;

  const ExpensesChartWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSelectedPet || controller.despesas.isEmpty) {
      return _buildEmptyState();
    }

    final expensesByCategory = controller.expensesByCategory;

    return Card(
      elevation: DashboardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DashboardHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(expensesByCategory),
            const SizedBox(height: 24),
            SizedBox(
              height: DashboardConstants.pieChartHeight,
              child: PieChart(
                PieChartData(
                  sections: ChartDataService.prepareExpensesChartData(expensesByCategory),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(expensesByCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic expensesByCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Despesas por Categoria',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Total: ${DashboardHelpers.formatCurrency(expensesByCategory.total)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(dynamic expensesByCategory) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: expensesByCategory.categorias.keys.map<Widget>((categoria) {
        final valor = expensesByCategory.categorias[categoria];
        final color = DashboardConstants.getCategoryColor(categoria);
        
        return DashboardHelpers.buildLegendItem(
          categoria,
          color,
          DashboardHelpers.formatCurrency(valor),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: DashboardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: DashboardHelpers.getCardBorderRadius(),
      ),
      child: SizedBox(
        height: DashboardConstants.pieChartHeight + 120,
        child: DashboardHelpers.buildEmptyState(
          icon: Icons.receipt_long,
          title: 'Nenhuma despesa registrada',
          subtitle: 'Adicione despesas para visualizar o gráfico',
        ),
      ),
    );
  }
}

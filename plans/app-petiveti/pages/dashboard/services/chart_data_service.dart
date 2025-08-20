// Dart imports:
import 'dart:math';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/dashboard_data_model.dart';
import '../models/dashboard_statistics_model.dart';
import '../utils/dashboard_constants.dart';

class ChartDataService {
  static List<FlSpot> prepareWeightChartData(List<PesoData> historicoPeso) {
    return List.generate(
      historicoPeso.length,
      (index) => FlSpot(index.toDouble(), historicoPeso[index].peso),
    );
  }

  static double calculateMinWeight(List<PesoData> historicoPeso) {
    if (historicoPeso.isEmpty) return 0;
    return (historicoPeso.map((e) => e.peso).reduce(min) - 1)
        .clamp(0, double.infinity);
  }

  static double calculateMaxWeight(List<PesoData> historicoPeso) {
    if (historicoPeso.isEmpty) return 100;
    return historicoPeso.map((e) => e.peso).reduce(max) + 1;
  }

  static List<PieChartSectionData> prepareExpensesChartData(
      ExpensesByCategory expensesByCategory) {
    final sections = <PieChartSectionData>[];
    
    expensesByCategory.categorias.forEach((categoria, valor) {
      final porcentagem = expensesByCategory.getPercentage(categoria);
      sections.add(
        PieChartSectionData(
          value: valor,
          title: '$porcentagem%',
          color: DashboardConstants.getCategoryColor(categoria),
          radius: DashboardConstants.pieChartRadius,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  static String formatWeightChartLabel(
      double value, List<PesoData> historicoPeso) {
    if (value.toInt() >= 0 && value.toInt() < historicoPeso.length) {
      final date = historicoPeso[value.toInt()].data;
      return '${date.day}/${date.month}';
    }
    return '';
  }

  static Color getVaccinationStatusColor(VacinaData vacina) {
    if (vacina.status == 'Pendente') {
      return vacina.isVencida ? Colors.red : Colors.orange;
    }
    return Colors.green;
  }
}

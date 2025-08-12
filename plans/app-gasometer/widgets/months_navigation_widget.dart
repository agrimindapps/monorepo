// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';
import '../../core/themes/manager.dart';

/// Widget reutilizável para navegação por meses
/// Gera uma lista de meses baseada no registro mais antigo e mais recente
/// Funciona mesmo quando não há registros, servindo como referência para inclusão de dados
class MonthsNavigationWidget extends StatelessWidget {
  final List<DateTime> monthsList;
  final int currentIndex;
  final Function(int) onMonthTap;
  final EdgeInsets? padding;
  final double? borderRadius;

  const MonthsNavigationWidget({
    super.key,
    required this.monthsList,
    required this.currentIndex,
    required this.onMonthTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Se não há meses na lista, gera um mês padrão (atual) para servir de referência
    final List<DateTime> displayMonths =
        monthsList.isEmpty ? [DateTime.now()] : monthsList;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: ThemeManager().isDark.value ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            ...List.generate(
              displayMonths.length,
              (index) =>
                  _buildMonthButton(context, index, displayMonths[index]),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthButton(BuildContext context, int index, DateTime month) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onMonthTap(index),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 6.0,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (ThemeManager().isDark.value
                  ? Colors.grey[800]
                  : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _formatMonth(month),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ShadcnStyle.textColor,
          ),
        ),
      ),
    );
  }

  String _formatMonth(DateTime month) {
    return DateFormat('MMM yy', 'pt_BR').format(month).toUpperCase();
  }
}

/// Classe utilitária para geração de lista de meses
class MonthsListGenerator {
  /// Gera uma lista de meses baseada na data mais antiga e mais recente
  /// dos registros fornecidos. Se não houver registros, retorna uma lista
  /// com o mês atual para servir de referência.
  static List<DateTime> generate<T>({
    required List<T> records,
    required DateTime Function(T) getDate,
  }) {
    if (records.isEmpty) {
      return [DateTime.now()];
    }

    final dates = records.map(getDate).toList();
    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    return _generateMonthsBetween(oldestDate, newestDate);
  }

  /// Gera uma lista de meses baseada em um Map de dados agrupados por mês
  static List<DateTime> generateFromGroupedData<T>(
    Map<DateTime, List<T>> groupedData,
  ) {
    if (groupedData.isEmpty) {
      return [DateTime.now()];
    }

    final dates = groupedData.keys.toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  /// Método auxiliar para gerar todos os meses entre duas datas
  static List<DateTime> _generateMonthsBetween(DateTime start, DateTime end) {
    List<DateTime> months = [];
    DateTime currentDate = DateTime(start.year, start.month);
    final lastDate = DateTime(end.year, end.month);

    while (!currentDate.isAfter(lastDate)) {
      months.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return months.reversed.toList();
  }
}

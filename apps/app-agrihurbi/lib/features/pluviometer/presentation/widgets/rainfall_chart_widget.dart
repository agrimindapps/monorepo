import 'package:flutter/material.dart';

/// Widget para exibir gráficos de precipitação
/// Usa implementação customizada sem dependência de fl_chart
class RainfallChartWidget extends StatelessWidget {
  const RainfallChartWidget._({
    required this.data,
    required this.labels,
    this.showLabels = false,
    this.color = Colors.blue,
    this.isYearly = false,
  });

  /// Gráfico de barras mensais
  factory RainfallChartWidget.monthly({
    required Map<int, double> monthlyTotals,
    bool showLabels = false,
  }) {
    final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final data = List.generate(12, (i) => monthlyTotals[i + 1] ?? 0.0);

    return RainfallChartWidget._(
      data: data,
      labels: months,
      showLabels: showLabels,
      color: Colors.blue,
      isYearly: false,
    );
  }

  /// Gráfico de barras anuais
  factory RainfallChartWidget.yearly({
    required Map<int, double> yearlyTotals,
  }) {
    final sortedYears = yearlyTotals.keys.toList()..sort();
    final labels = sortedYears.map((y) => y.toString().substring(2)).toList();
    final data = sortedYears.map((y) => yearlyTotals[y] ?? 0.0).toList();

    return RainfallChartWidget._(
      data: data,
      labels: labels,
      showLabels: true,
      color: Colors.indigo,
      isYearly: true,
    );
  }

  final List<double> data;
  final List<String> labels;
  final bool showLabels;
  final Color color;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxValue > 0 ? maxValue : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = isYearly
            ? (constraints.maxWidth - 40) / data.length - 8
            : (constraints.maxWidth - 24) / data.length - 4;

        return Column(
          children: [
            // Escala Y
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Labels do eixo Y
                  SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          effectiveMax.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          (effectiveMax / 2).toStringAsFixed(0),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '0',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Barras
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(data.length, (index) {
                        final value = data[index];
                        final heightPercent = effectiveMax > 0
                            ? (value / effectiveMax).clamp(0.0, 1.0)
                            : 0.0;

                        return _AnimatedBar(
                          width: barWidth.clamp(12.0, 40.0),
                          heightPercent: heightPercent,
                          value: value,
                          color: color,
                          showValue: showLabels && value > 0,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Labels do eixo X
            Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: labels.map((label) {
                      return SizedBox(
                        width: barWidth.clamp(12.0, 40.0),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Unidade
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Precipitação (mm)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barra animada do gráfico
class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.width,
    required this.heightPercent,
    required this.value,
    required this.color,
    this.showValue = false,
  });

  final double width;
  final double heightPercent;
  final double value;
  final Color color;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showValue && value > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: width,
          height: heightPercent > 0
              ? (heightPercent * 150).clamp(4.0, 150.0)
              : 4.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            boxShadow: value > 0
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

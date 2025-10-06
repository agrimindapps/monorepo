import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/weight.dart';
import '../providers/weights_provider.dart';

/// Enhanced weight chart visualization with interactive features
class WeightChartVisualization extends ConsumerStatefulWidget {
  final String? animalId;
  final bool showInteractiveMode;
  
  const WeightChartVisualization({
    super.key,
    this.animalId,
    this.showInteractiveMode = true,
  });

  @override
  ConsumerState<WeightChartVisualization> createState() => _WeightChartVisualizationState();
}

class _WeightChartVisualizationState extends ConsumerState<WeightChartVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  ChartPeriod _selectedPeriod = ChartPeriod.lastThreeMonths;
  ChartType _selectedType = ChartType.line;
  bool _showTrendLine = true;
  bool _showGoalLine = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightsState = ref.watch(weightsProvider);
    final weights = weightsState.sortedWeights;
    
    if (weights.isEmpty) {
      return _buildEmptyChartState(theme);
    }

    final filteredWeights = _filterWeightsByPeriod(weights, _selectedPeriod);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(theme),
          if (widget.showInteractiveMode) _buildChartControls(theme),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 280),
                  painter: WeightChartPainter(
                    weights: filteredWeights,
                    chartType: _selectedType,
                    showTrendLine: _showTrendLine,
                    showGoalLine: _showGoalLine,
                    animation: _animation,
                    theme: theme,
                  ),
                );
              },
            ),
          ),
          _buildChartLegend(theme, filteredWeights),
          _buildChartInsights(theme, filteredWeights),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Dados Insuficientes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione mais registros para visualizar o gráfico',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timeline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evolução do Peso',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _selectedPeriod.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showChartSettings(context),
            tooltip: 'Configurações do gráfico',
          ),
        ],
      ),
    );
  }

  Widget _buildChartControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ChartPeriod.values.map((period) {
                final isSelected = period == _selectedPeriod;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(period.shortName),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                        _animationController.reset();
                        _animationController.forward();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<ChartType>(
                  segments: ChartType.values.map((type) => ButtonSegment<ChartType>(
                    value: type,
                    icon: Icon(type.icon, size: 18),
                    label: Text(type.shortName),
                  )).toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (Set<ChartType> selection) {
                    setState(() {
                      _selectedType = selection.first;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(ThemeData theme, List<Weight> weights) {
    if (weights.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLegendItem(theme, Colors.blue, 'Peso registrado'),
              const SizedBox(width: 16),
              if (_showTrendLine)
                _buildLegendItem(theme, Colors.orange, 'Tendência'),
              if (_showGoalLine) ...[
                const SizedBox(width: 16),
                _buildLegendItem(theme, Colors.green, 'Meta'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildChartInsights(ThemeData theme, List<Weight> weights) {
    if (weights.length < 2) return const SizedBox.shrink();
    
    final insights = _calculateInsights(weights);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights do Período',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInsightChip(
                theme,
                'Variação Total',
                insights.totalChange,
                insights.totalChangeColor,
                insights.totalChangeIcon,
              ),
              _buildInsightChip(
                theme,
                'Média Período',
                insights.averageWeight,
                Colors.blue,
                Icons.bar_chart,
              ),
              _buildInsightChip(
                theme,
                'Tendência',
                insights.trendDescription,
                insights.trendColor,
                insights.trendIcon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChartSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações do Gráfico',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Linha de tendência'),
              subtitle: const Text('Mostra a tendência geral dos dados'),
              value: _showTrendLine,
              onChanged: (value) {
                setState(() {
                  _showTrendLine = value;
                });
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Linha de meta'),
              subtitle: const Text('Mostra a meta de peso ideal'),
              value: _showGoalLine,
              onChanged: (value) {
                setState(() {
                  _showGoalLine = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Weight> _filterWeightsByPeriod(List<Weight> weights, ChartPeriod period) {
    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (period) {
      case ChartPeriod.lastWeek:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.lastMonth:
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case ChartPeriod.lastThreeMonths:
        cutoffDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case ChartPeriod.lastSixMonths:
        cutoffDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartPeriod.lastYear:
        cutoffDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case ChartPeriod.all:
        return weights;
    }
    
    return weights.where((weight) => weight.date.isAfter(cutoffDate)).toList();
  }

  WeightInsights _calculateInsights(List<Weight> weights) {
    if (weights.length < 2) {
      return const WeightInsights(
        totalChange: '0.0 kg',
        totalChangeColor: Colors.grey,
        totalChangeIcon: Icons.trending_flat,
        averageWeight: '0.0 kg',
        trendDescription: 'Estável',
        trendColor: Colors.green,
        trendIcon: Icons.trending_flat,
      );
    }
    
    final firstWeight = weights.last.weight;
    final lastWeight = weights.first.weight;
    final totalChange = lastWeight - firstWeight;
    final averageWeight = weights.map((w) => w.weight).reduce((a, b) => a + b) / weights.length;
    
    Color totalChangeColor;
    IconData totalChangeIcon;
    
    if (totalChange > 0) {
      totalChangeColor = Colors.blue;
      totalChangeIcon = Icons.trending_up;
    } else if (totalChange < 0) {
      totalChangeColor = Colors.red;
      totalChangeIcon = Icons.trending_down;
    } else {
      totalChangeColor = Colors.green;
      totalChangeIcon = Icons.trending_flat;
    }
    String trendDescription;
    Color trendColor;
    IconData trendIcon;
    
    if (totalChange.abs() < 0.1) {
      trendDescription = 'Estável';
      trendColor = Colors.green;
      trendIcon = Icons.trending_flat;
    } else if (totalChange > 0) {
      trendDescription = 'Crescente';
      trendColor = Colors.blue;
      trendIcon = Icons.trending_up;
    } else {
      trendDescription = 'Decrescente';
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    }
    
    return WeightInsights(
      totalChange: '${totalChange.toStringAsFixed(1)} kg',
      totalChangeColor: totalChangeColor,
      totalChangeIcon: totalChangeIcon,
      averageWeight: '${averageWeight.toStringAsFixed(1)} kg',
      trendDescription: trendDescription,
      trendColor: trendColor,
      trendIcon: trendIcon,
    );
  }
}

/// Chart painter for custom weight visualization
class WeightChartPainter extends CustomPainter {
  final List<Weight> weights;
  final ChartType chartType;
  final bool showTrendLine;
  final bool showGoalLine;
  final Animation<double> animation;
  final ThemeData theme;
  
  WeightChartPainter({
    required this.weights,
    required this.chartType,
    required this.showTrendLine,
    required this.showGoalLine,
    required this.animation,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    const padding = EdgeInsets.all(40);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );
    _drawAxes(canvas, chartRect);
    if (chartType == ChartType.line) {
      _drawLineChart(canvas, chartRect, paint, pointPaint);
    } else {
      _drawBarChart(canvas, chartRect, paint);
    }
    if (showTrendLine && weights.length > 1) {
      _drawTrendLine(canvas, chartRect);
    }
    _drawLabels(canvas, chartRect);
  }

  void _drawAxes(Canvas canvas, Rect chartRect) {
    final axisPaint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );
  }

  void _drawLineChart(Canvas canvas, Rect chartRect, Paint linePaint, Paint pointPaint) {
    if (weights.length < 2) return;
    
    final minWeight = weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxWeight = weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b) * 1.1;
    final weightRange = maxWeight - minWeight;
    
    final path = Path();
    final animatedProgress = animation.value;
    
    for (int i = 0; i < weights.length; i++) {
      final weight = weights[i];
      final progress = (i + 1) / weights.length;
      
      if (progress > animatedProgress) break;
      
      final x = chartRect.left + (i / (weights.length - 1)) * chartRect.width;
      final y = chartRect.bottom - ((weight.weight - minWeight) / weightRange) * chartRect.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    canvas.drawPath(path, linePaint);
  }

  void _drawBarChart(Canvas canvas, Rect chartRect, Paint paint) {
    final minWeight = weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxWeight = weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b) * 1.1;
    final weightRange = maxWeight - minWeight;
    
    final barWidth = chartRect.width / weights.length * 0.7;
    final animatedProgress = animation.value;
    
    for (int i = 0; i < weights.length; i++) {
      final progress = (i + 1) / weights.length;
      if (progress > animatedProgress) break;
      
      final weight = weights[i];
      final x = chartRect.left + (i + 0.5) / weights.length * chartRect.width - barWidth / 2;
      final barHeight = ((weight.weight - minWeight) / weightRange) * chartRect.height;
      final y = chartRect.bottom - barHeight;
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  void _drawTrendLine(Canvas canvas, Rect chartRect) {
    final trendPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final firstWeight = weights.last.weight;
    final lastWeight = weights.first.weight;
    
    final minWeight = weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxWeight = weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b) * 1.1;
    final weightRange = maxWeight - minWeight;
    
    final startY = chartRect.bottom - ((firstWeight - minWeight) / weightRange) * chartRect.height;
    final endY = chartRect.bottom - ((lastWeight - minWeight) / weightRange) * chartRect.height;
    
    canvas.drawLine(
      Offset(chartRect.left, startY),
      Offset(chartRect.right, endY),
      trendPaint,
    );
  }

  void _drawLabels(Canvas canvas, Rect chartRect) {
  }

  @override
  bool shouldRepaint(WeightChartPainter oldDelegate) {
    return weights != oldDelegate.weights ||
           animation.value != oldDelegate.animation.value ||
           chartType != oldDelegate.chartType ||
           showTrendLine != oldDelegate.showTrendLine;
  }
}

/// Data class for weight insights with type safety
class WeightInsights {
  final String totalChange;
  final Color totalChangeColor;
  final IconData totalChangeIcon;
  final String averageWeight;
  final String trendDescription;
  final Color trendColor;
  final IconData trendIcon;
  
  const WeightInsights({
    required this.totalChange,
    required this.totalChangeColor,
    required this.totalChangeIcon,
    required this.averageWeight,
    required this.trendDescription,
    required this.trendColor,
    required this.trendIcon,
  });
}

enum ChartPeriod {
  lastWeek,
  lastMonth,
  lastThreeMonths,
  lastSixMonths,
  lastYear,
  all,
}

extension ChartPeriodExtension on ChartPeriod {
  String get displayName {
    switch (this) {
      case ChartPeriod.lastWeek:
        return 'Última Semana';
      case ChartPeriod.lastMonth:
        return 'Último Mês';
      case ChartPeriod.lastThreeMonths:
        return 'Últimos 3 Meses';
      case ChartPeriod.lastSixMonths:
        return 'Últimos 6 Meses';
      case ChartPeriod.lastYear:
        return 'Último Ano';
      case ChartPeriod.all:
        return 'Todo o Período';
    }
  }
  
  String get shortName {
    switch (this) {
      case ChartPeriod.lastWeek:
        return '7d';
      case ChartPeriod.lastMonth:
        return '1m';
      case ChartPeriod.lastThreeMonths:
        return '3m';
      case ChartPeriod.lastSixMonths:
        return '6m';
      case ChartPeriod.lastYear:
        return '1a';
      case ChartPeriod.all:
        return 'Tudo';
    }
  }
}

enum ChartType {
  line,
  bar,
}

extension ChartTypeExtension on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.line:
        return 'Linha';
      case ChartType.bar:
        return 'Barras';
    }
  }
  
  String get shortName {
    switch (this) {
      case ChartType.line:
        return 'Linha';
      case ChartType.bar:
        return 'Barras';
    }
  }
  
  IconData get icon {
    switch (this) {
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.bar:
        return Icons.bar_chart;
    }
  }
}

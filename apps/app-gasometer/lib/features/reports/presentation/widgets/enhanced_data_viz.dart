import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Enhanced trend indicator with visual appeal
class TrendIndicator extends StatelessWidget {
  final double value;
  final String label;
  final bool isPositive;
  final IconData? customIcon;
  final Color? customColor;

  const TrendIndicator({
    super.key,
    required this.value,
    required this.label,
    required this.isPositive,
    this.customIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? (isPositive ? Colors.green : Colors.red);
    final icon = customIcon ?? (isPositive ? Icons.trending_up : Icons.trending_down);
    final displayValue = '${value.abs().toStringAsFixed(1)}%';
    
    return SemanticStatusIndicator(
      status: isPositive ? 'Crescimento' : 'Declínio',
      description: '$label teve ${isPositive ? 'aumento' : 'diminuição'} de $displayValue',
      isSuccess: isPositive,
      isError: !isPositive,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated progress bar for visual comparisons
class AnimatedProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double height;
  final String? label;
  final String? valueText;
  final Duration animationDuration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.label,
    this.valueText,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.valueText != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              if (widget.valueText != null)
                Text(
                  widget.valueText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: widget.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              minHeight: widget.height,
              borderRadius: BorderRadius.circular(widget.height / 2),
            );
          },
        ),
      ],
    );
  }
}

/// Enhanced statistics card with micro-visualizations
class VisualStatisticCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final List<DataPoint>? chartData;
  final TrendData? trend;
  final List<ComparisonItem>? comparisons;
  final VoidCallback? onTap;

  const VisualStatisticCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.chartData,
    this.trend,
    this.comparisons,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SemanticCard(
      semanticLabel: 'Estatística visual: $title, valor $mainValue',
      semanticHint: trend != null 
          ? 'Tendência ${trend!.isPositive ? 'positiva' : 'negativa'} de ${trend!.percentage}%'
          : 'Clique para ver detalhes',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SemanticText.heading(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (trend != null) ...[
                        const SizedBox(height: 4),
                        TrendIndicator(
                          value: trend!.percentage,
                          label: title,
                          isPositive: trend!.isPositive,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main value
            SemanticText(
              mainValue,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              SemanticText.subtitle(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            
            // Mini chart visualization
            if (chartData?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: MiniLineChart(
                  data: chartData!,
                  color: iconColor,
                ),
              ),
            ],
            
            // Comparisons
            if (comparisons?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              ...comparisons!.map((comparison) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedProgressBar(
                  value: comparison.percentage / 100,
                  color: comparison.color ?? iconColor,
                  label: comparison.label,
                  valueText: comparison.value,
                  height: 6,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mini line chart for trend visualization
class MiniLineChart extends StatelessWidget {
  final List<DataPoint> data;
  final Color color;
  final double strokeWidth;

  const MiniLineChart({
    super.key,
    required this.data,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: MiniLineChartPainter(
        data: data,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Custom painter for mini line chart
class MiniLineChartPainter extends CustomPainter {
  final List<DataPoint> data;
  final Color color;
  final double strokeWidth;

  MiniLineChartPainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final gradientPath = Path();
    
    final minY = data.map((e) => e.value).reduce(math.min);
    final maxY = data.map((e) => e.value).reduce(math.max);
    final range = maxY - minY;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i].value - minY) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }
    
    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();
    
    // Draw gradient area
    canvas.drawPath(gradientPath, gradientPaint);
    
    // Draw line
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i].value - minY) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      
      canvas.drawCircle(
        Offset(x, y),
        2.5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Enhanced summary dashboard
class EnhancedSummaryDashboard extends StatelessWidget {
  final List<SummaryMetric> metrics;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final bool showTrends;

  const EnhancedSummaryDashboard({
    super.key,
    required this.metrics,
    this.title,
    this.subtitle,
    this.headerAction,
    this.showTrends = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticText.heading(
                      title!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      SemanticText.subtitle(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (headerAction != null) headerAction!,
            ],
          ),
          const SizedBox(height: 24),
        ],
        
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 800;
            final isMobile = constraints.maxWidth < 600;
            
            if (isMobile) {
              return Column(
                children: metrics
                    .map((metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMetricCard(context, metric),
                        ))
                    .toList(),
              );
            } else if (isTablet) {
              // Grid layout for tablet
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) => _buildMetricCard(context, metrics[index]),
              );
            } else {
              // Row layout for desktop
              return Row(
                children: metrics
                    .asMap()
                    .entries
                    .map((entry) => [
                          Expanded(child: _buildMetricCard(context, entry.value)),
                          if (entry.key < metrics.length - 1) const SizedBox(width: 16),
                        ])
                    .expand((widgets) => widgets)
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, SummaryMetric metric) {
    return VisualStatisticCard(
      title: metric.title,
      mainValue: metric.mainValue,
      subtitle: metric.subtitle,
      icon: metric.icon,
      iconColor: metric.color,
      chartData: showTrends ? metric.trendData : null,
      trend: metric.trend,
      comparisons: metric.comparisons,
      onTap: metric.onTap,
    );
  }
}

/// Data models for visualizations
class DataPoint {
  final double value;
  final DateTime timestamp;
  final String? label;

  const DataPoint({
    required this.value,
    required this.timestamp,
    this.label,
  });
}

class TrendData {
  final double percentage;
  final bool isPositive;
  final String period;

  const TrendData({
    required this.percentage,
    required this.isPositive,
    required this.period,
  });
}

class ComparisonItem {
  final String label;
  final String value;
  final double percentage;
  final Color? color;

  const ComparisonItem({
    required this.label,
    required this.value,
    required this.percentage,
    this.color,
  });
}

class SummaryMetric {
  final String title;
  final String mainValue;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<DataPoint>? trendData;
  final TrendData? trend;
  final List<ComparisonItem>? comparisons;
  final VoidCallback? onTap;

  const SummaryMetric({
    required this.title,
    required this.mainValue,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trendData,
    this.trend,
    this.comparisons,
    this.onTap,
  });
}
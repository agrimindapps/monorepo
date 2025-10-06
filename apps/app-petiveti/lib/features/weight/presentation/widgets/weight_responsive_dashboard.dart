import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/weight.dart';
import '../providers/weights_provider.dart';
import 'weight_chart_visualization.dart';

/// Responsive dashboard that adapts to different screen sizes and orientations
class WeightResponsiveDashboard extends ConsumerWidget {
  final String? selectedAnimalId;
  
  const WeightResponsiveDashboard({
    super.key,
    this.selectedAnimalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    final weightsState = ref.watch(weightsProvider);
    final weights = weightsState.sortedWeights;

    if (weights.isEmpty) {
      return _buildEmptyDashboard(context);
    }
    if (isTablet && isLandscape) {
      return _buildTabletLandscapeLayout(context, weightsState, weights);
    } else if (isTablet) {
      return _buildTabletPortraitLayout(context, weightsState, weights);
    } else if (isLandscape) {
      return _buildPhoneLandscapeLayout(context, weightsState, weights);
    } else {
      return _buildPhonePortraitLayout(context, weightsState, weights);
    }
  }

  Widget _buildEmptyDashboard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Dashboard Vazio',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione registros de peso para visualizar insights',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPhonePortraitLayout(
    BuildContext context,
    WeightsState state,
    List<Weight> weights,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQuickStats(context, state, compact: true),
          const SizedBox(height: 8),
          WeightChartVisualization(animalId: selectedAnimalId),
          _buildRecentRecords(context, weights, maxItems: 3),
          _buildInsightsPanel(context, weights),
        ],
      ),
    );
  }
  Widget _buildPhoneLandscapeLayout(
    BuildContext context,
    WeightsState state,
    List<Weight> weights,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildQuickStats(context, state, compact: true),
                    const SizedBox(height: 8),
                    _buildInsightsPanel(context, weights),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: WeightChartVisualization(animalId: selectedAnimalId),
              ),
            ],
          ),
          _buildRecentRecords(context, weights, maxItems: 2),
        ],
      ),
    );
  }
  Widget _buildTabletPortraitLayout(
    BuildContext context,
    WeightsState state,
    List<Weight> weights,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildQuickStats(context, state, compact: false),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      WeightChartVisualization(animalId: selectedAnimalId),
                      const SizedBox(height: 16),
                      _buildInsightsPanel(context, weights),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildRecentRecords(context, weights, maxItems: 5),
                      const SizedBox(height: 16),
                      _buildGoalsPanel(context, weights),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    WeightsState state,
    List<Weight> weights,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickStats(context, state, compact: false),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: WeightChartVisualization(animalId: selectedAnimalId),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildInsightsPanel(context, weights),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildRecentRecords(context, weights, maxItems: 8),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildGoalsPanel(context, weights),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WeightsState state, {required bool compact}) {
    final theme = Theme.of(context);
    final statistics = state.statistics;
    
    if (statistics == null) return const SizedBox.shrink();
    
    final stats = [
      _StatItem(
        label: 'Peso Atual',
        value: statistics.currentWeight?.toStringAsFixed(1) ?? 'N/A',
        unit: 'kg',
        icon: Icons.monitor_weight,
        color: Colors.blue,
      ),
      _StatItem(
        label: 'Peso Médio',
        value: statistics.averageWeight?.toStringAsFixed(1) ?? 'N/A',
        unit: 'kg',
        icon: Icons.timeline,
        color: Colors.green,
      ),
      _StatItem(
        label: 'Registros',
        value: statistics.totalRecords.toString(),
        unit: '',
        icon: Icons.history,
        color: Colors.orange,
      ),
      if (statistics.overallTrend != null)
        _StatItem(
          label: 'Tendência',
          value: statistics.overallTrend!.displayName,
          unit: '',
          icon: _getTrendIcon(statistics.overallTrend!),
          color: _getTrendColor(statistics.overallTrend!),
        ),
    ];
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: compact 
          ? _buildCompactStats(theme, stats)
          : _buildExpandedStats(theme, stats),
    );
  }

  Widget _buildCompactStats(ThemeData theme, List<_StatItem> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: stats.map((stat) => Expanded(
            child: Column(
              children: [
                Icon(stat.icon, color: stat.color, size: 20),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stat.color,
                  ),
                ),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildExpandedStats(ThemeData theme, List<_StatItem> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: stat.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                    children: [
                      if (stat.unit.isNotEmpty)
                        TextSpan(
                          text: ' ${stat.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentRecords(BuildContext context, List<Weight> weights, {int maxItems = 5}) {
    final theme = Theme.of(context);
    final recentWeights = weights.take(maxItems).toList();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Registros Recentes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...recentWeights.map((weight) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    weight.weight.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                title: Text('${weight.weight.toStringAsFixed(1)} kg'),
                subtitle: Text(_formatDate(weight.date)),
                trailing: weight.notes?.isNotEmpty == true
                    ? Icon(
                        Icons.note,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      )
                    : null,
              )),
        ],
      ),
    );
  }

  Widget _buildInsightsPanel(BuildContext context, List<Weight> weights) {
    final theme = Theme.of(context);
    
    if (weights.length < 2) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights,
                size: 40,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Insights Indisponíveis',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione mais registros para ver insights detalhados',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    final insights = _calculateInsights(weights);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: insight.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: insight.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(insight.icon, color: insight.color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              insight.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPanel(BuildContext context, List<Weight> weights) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Metas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Meta de peso ideal ainda não definida',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Definir Meta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_InsightItem> _calculateInsights(List<Weight> weights) {
    final insights = <_InsightItem>[];
    
    if (weights.length < 2) return insights;
    
    final currentWeight = weights.first.weight;
    final previousWeight = weights[1].weight;
    final change = currentWeight - previousWeight;
    
    if (change.abs() > 0.1) {
      insights.add(_InsightItem(
        title: change > 0 ? 'Ganho de peso recente' : 'Perda de peso recente',
        description: 'Variação de ${change.abs().toStringAsFixed(1)} kg desde o último registro',
        icon: change > 0 ? Icons.trending_up : Icons.trending_down,
        color: change > 0 ? Colors.blue : Colors.red,
      ));
    }
    if (weights.length >= 3) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentWeights = weights.where((w) => w.date.isAfter(weekAgo)).toList();
      
      if (recentWeights.length >= 2) {
        final weeklyChange = recentWeights.first.weight - recentWeights.last.weight;
        insights.add(_InsightItem(
          title: 'Tendência semanal',
          description: weeklyChange.abs() < 0.1 
              ? 'Peso estável na última semana'
              : 'Variação de ${weeklyChange.toStringAsFixed(1)} kg na última semana',
          icon: weeklyChange > 0 
              ? Icons.trending_up 
              : weeklyChange < 0 
                  ? Icons.trending_down 
                  : Icons.trending_flat,
          color: weeklyChange > 0 
              ? Colors.blue 
              : weeklyChange < 0 
                  ? Colors.red 
                  : Colors.green,
        ));
      }
    }
    
    return insights;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTrendColor(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Colors.blue;
      case WeightTrend.losing:
        return Colors.orange;
      case WeightTrend.stable:
        return Colors.green;
    }
  }

  IconData _getTrendIcon(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Icons.trending_up;
      case WeightTrend.losing:
        return Icons.trending_down;
      case WeightTrend.stable:
        return Icons.trending_flat;
    }
  }
}

class _StatItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class _InsightItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InsightItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
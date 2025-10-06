import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/plantis_colors.dart';
import '../../../../domain/entities/plant.dart';
import '../../../../domain/entities/plant_task.dart';

/// Aba de estatísticas com gráficos, conquistas e insights personalizados
class PlantTaskHistoryStatsTab extends StatefulWidget {
  final Plant plant;
  final List<PlantTask> completedTasks;

  const PlantTaskHistoryStatsTab({
    super.key,
    required this.plant,
    required this.completedTasks,
  });

  @override
  State<PlantTaskHistoryStatsTab> createState() =>
      _PlantTaskHistoryStatsTabState();
}

class _PlantTaskHistoryStatsTabState extends State<PlantTaskHistoryStatsTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Criar animações escalonadas
    _itemAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            index * 0.15,
            0.7 + (index * 0.05),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _fadeController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  /// Calcula estatísticas de frequência semanal
  List<Map<String, dynamic>> _calculateWeeklyFrequency() {
    final weeklyData = <int, int>{}; // weekday -> count

    // Inicializar com 0 para todos os dias da semana
    for (int i = 1; i <= 7; i++) {
      weeklyData[i] = 0;
    }

    // Contar tarefas por dia da semana
    for (final task in widget.completedTasks) {
      if (task.completedDate != null) {
        final weekday = task.completedDate!.weekday;
        weeklyData[weekday] = (weeklyData[weekday] ?? 0) + 1;
      }
    }

    // Converter para lista de mapas
    final weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return List.generate(7, (index) {
      final weekday = index + 1;
      return {
        'day': weekDays[index],
        'count': weeklyData[weekday] ?? 0,
        'weekday': weekday,
      };
    });
  }

  /// Calcula distribuição percentual por tipo
  Map<TaskType, double> _calculateTypeDistribution() {
    final typeCounts = <TaskType, int>{};
    final total = widget.completedTasks.length;

    if (total == 0) return {};

    // Contar por tipo
    for (final task in widget.completedTasks) {
      typeCounts[task.type] = (typeCounts[task.type] ?? 0) + 1;
    }

    // Converter para percentual
    final distribution = <TaskType, double>{};
    for (final entry in typeCounts.entries) {
      distribution[entry.key] = (entry.value / total) * 100;
    }

    return distribution;
  }

  /// Calcula conquistas baseadas nas tarefas
  List<Map<String, dynamic>> _calculateAchievements() {
    final achievements = <Map<String, dynamic>>[];
    final total = widget.completedTasks.length;

    // Conquistas por total de tarefas
    achievements.addAll([
      {
        'title': 'Primeiro Cuidado',
        'description': 'Complete sua primeira tarefa',
        'icon': Icons.stars,
        'color': Colors.amber,
        'achieved': total >= 1,
        'progress': math.min(total / 1.0, 1.0),
        'target': 1,
        'current': total,
      },
      {
        'title': 'Cuidador Iniciante',
        'description': 'Complete 10 tarefas',
        'icon': Icons.psychology,
        'color': Colors.green,
        'achieved': total >= 10,
        'progress': math.min(total / 10.0, 1.0),
        'target': 10,
        'current': total,
      },
      {
        'title': 'Especialista em Plantas',
        'description': 'Complete 50 tarefas',
        'icon': Icons.emoji_events,
        'color': Colors.purple,
        'achieved': total >= 50,
        'progress': math.min(total / 50.0, 1.0),
        'target': 50,
        'current': total,
      },
      {
        'title': 'Mestre Jardineiro',
        'description': 'Complete 100 tarefas',
        'icon': Icons.workspace_premium,
        'color': Colors.orange,
        'achieved': total >= 100,
        'progress': math.min(total / 100.0, 1.0),
        'target': 100,
        'current': total,
      },
    ]);

    // Conquista por sequência
    final currentStreak = _calculateCurrentStreak();
    achievements.add({
      'title': 'Constância',
      'description': 'Mantenha uma sequência de 7 dias',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'achieved': currentStreak >= 7,
      'progress': math.min(currentStreak / 7.0, 1.0),
      'target': 7,
      'current': currentStreak,
    });

    // Conquista por especialização
    final typeDistribution = _calculateTypeDistribution();
    final maxTypePercentage =
        typeDistribution.values.isEmpty
            ? 0.0
            : typeDistribution.values.reduce(math.max);

    achievements.add({
      'title': 'Especialização',
      'description': 'Seja expert em um tipo de cuidado (70%)',
      'icon': Icons.school,
      'color': Colors.indigo,
      'achieved': maxTypePercentage >= 70,
      'progress': math.min(maxTypePercentage / 70.0, 1.0),
      'target': 70,
      'current': maxTypePercentage.round(),
    });

    return achievements;
  }

  /// Calcula sequência atual
  int _calculateCurrentStreak() {
    if (widget.completedTasks.isEmpty) return 0;

    final tasks = [...widget.completedTasks];
    tasks.sort(
      (a, b) => (b.completedDate ?? DateTime(1970)).compareTo(
        a.completedDate ?? DateTime(1970),
      ),
    );

    final uniqueDates = <String>{};
    for (final task in tasks) {
      if (task.completedDate != null) {
        final dateKey =
            '${task.completedDate!.year}-${task.completedDate!.month}-${task.completedDate!.day}';
        uniqueDates.add(dateKey);
      }
    }

    if (uniqueDates.isEmpty) return 0;

    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    int streak = 1;
    DateTime? lastDate;

    for (int i = 0; i < sortedDates.length; i++) {
      final parts = sortedDates[i].split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (lastDate == null) {
        lastDate = date;
      } else {
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Gera insights personalizados
  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];
    final total = widget.completedTasks.length;
    final typeDistribution = _calculateTypeDistribution();
    final weeklyData = _calculateWeeklyFrequency();

    if (total == 0) {
      insights.add({
        'icon': Icons.lightbulb_outline,
        'color': Colors.blue,
        'title': 'Comece sua jornada',
        'description':
            'Complete sua primeira tarefa para ver insights personalizados!',
      });
      return insights;
    }

    // Insight sobre tipo mais comum
    if (typeDistribution.isNotEmpty) {
      final mostCommonType = typeDistribution.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      insights.add({
        'icon': _getTaskTypeIcon(mostCommonType.key),
        'color': _getTaskTypeColor(mostCommonType.key),
        'title': 'Seu cuidado favorito',
        'description':
            '${mostCommonType.value.toStringAsFixed(1)}% das suas tarefas são ${mostCommonType.key.displayName.toLowerCase()}.',
      });
    }

    // Insight sobre dia mais ativo
    final mostActiveDay = weeklyData.reduce(
      (a, b) => (a['count'] as int) > (b['count'] as int) ? a : b,
    );

    if ((mostActiveDay['count'] as int) > 0) {
      insights.add({
        'icon': Icons.calendar_today,
        'color': PlantisColors.primary,
        'title': 'Dia mais ativo',
        'description':
            'Você cuida mais da sua planta nas ${mostActiveDay['day']}s (${mostActiveDay['count']} cuidados).',
      });
    }

    // Insight sobre consistência
    final currentStreak = _calculateCurrentStreak();
    if (currentStreak > 1) {
      insights.add({
        'icon': Icons.trending_up,
        'color': Colors.green,
        'title': 'Excelente consistência!',
        'description':
            'Você está numa sequência de $currentStreak dias. Continue assim!',
      });
    }

    // Insight sobre total
    if (total >= 10) {
      insights.add({
        'icon': Icons.celebration,
        'color': Colors.purple,
        'title': 'Parabéns!',
        'description':
            'Você já completou $total cuidados. Sua planta está muito bem cuidada!',
      });
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final weeklyData = _calculateWeeklyFrequency();
    final typeDistribution = _calculateTypeDistribution();
    final achievements = _calculateAchievements();
    final insights = _generateInsights();

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gráfico de frequência semanal
            AnimatedBuilder(
              animation: _itemAnimations[0],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _itemAnimations[0],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_itemAnimations[0]),
                    child: _buildWeeklyChart(context, weeklyData),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Distribuição por tipo
            AnimatedBuilder(
              animation: _itemAnimations[1],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _itemAnimations[1],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_itemAnimations[1]),
                    child: _buildTypeDistribution(context, typeDistribution),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Conquistas
            AnimatedBuilder(
              animation: _itemAnimations[2],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _itemAnimations[2],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_itemAnimations[2]),
                    child: _buildAchievements(context, achievements),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Insights personalizados
            AnimatedBuilder(
              animation: _itemAnimations[3],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _itemAnimations[3],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_itemAnimations[3]),
                    child: _buildInsights(context, insights),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData,
  ) {
    final theme = Theme.of(context);
    final maxCount = weeklyData.map((d) => d['count'] as int).reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequência Semanal',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Gráfico de barras
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      weeklyData.map((data) {
                        final count = data['count'] as int;
                        final day = data['day'] as String;
                        final height =
                            maxCount > 0 ? (count / maxCount) * 160 : 0.0;

                        return AnimatedBuilder(
                          animation: _chartController,
                          builder: (context, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Valor
                                Text(
                                  '$count',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        count > 0
                                            ? PlantisColors.primary
                                            : theme.colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Barra
                                Container(
                                  width: 24,
                                  height: height * _chartController.value,
                                  decoration: BoxDecoration(
                                    gradient:
                                        count > 0
                                            ? const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                PlantisColors.primary,
                                                PlantisColors.primaryLight,
                                              ],
                                            )
                                            : null,
                                    color:
                                        count == 0
                                            ? theme.colorScheme.outline
                                                .withValues(alpha: 0.2)
                                            : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Label do dia
                                Text(
                                  day,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDistribution(
    BuildContext context,
    Map<TaskType, double> typeDistribution,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribuição por Tipo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (typeDistribution.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Nenhum dado disponível ainda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...typeDistribution.entries.map((entry) {
            final type = entry.key;
            final percentage = entry.value;
            final color = _getTaskTypeColor(type);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getTaskTypeIcon(type), color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: color.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    List<Map<String, dynamic>> achievements,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(context, achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Map<String, dynamic> achievement,
  ) {
    final theme = Theme.of(context);
    final achieved = achievement['achieved'] as bool;
    final progress = achievement['progress'] as double;
    final color = achievement['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            achieved
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                )
                : null,
        color:
            achieved
                ? null
                : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              achieved
                  ? color.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                achievement['icon'] as IconData,
                color:
                    achieved
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                size: 24,
              ),
              const Spacer(),
              if (achieved) Icon(Icons.check_circle, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement['title'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: achieved ? color : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement['description'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                achieved
                    ? color.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              achieved ? color : theme.colorScheme.onSurfaceVariant,
            ),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '${achievement['current']}/${achievement['target']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  achieved
                      ? color
                      : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(
    BuildContext context,
    List<Map<String, dynamic>> insights,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights Personalizados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) {
          final color = insight['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return PlantisColors.water;
      case TaskType.fertilizing:
        return PlantisColors.soil;
      case TaskType.pruning:
        return PlantisColors.leaf;
      case TaskType.sunlightCheck:
        return PlantisColors.sun;
      case TaskType.pestInspection:
        return Colors.red;
      case TaskType.replanting:
        return PlantisColors.primary;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlightCheck:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.replanting:
        return Icons.change_circle;
    }
  }
}

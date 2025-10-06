import 'package:flutter/material.dart';
import '../../../../../../core/theme/plantis_colors.dart';
import '../../../../domain/entities/plant.dart';
import '../../../../domain/entities/plant_task.dart';

/// Aba de resumo com grid de tipos de cuidados, estatísticas e últimos cuidados
class PlantTaskHistoryOverviewTab extends StatefulWidget {
  final Plant plant;
  final List<PlantTask> completedTasks;

  const PlantTaskHistoryOverviewTab({
    super.key,
    required this.plant,
    required this.completedTasks,
  });

  @override
  State<PlantTaskHistoryOverviewTab> createState() =>
      _PlantTaskHistoryOverviewTabState();
}

class _PlantTaskHistoryOverviewTabState
    extends State<PlantTaskHistoryOverviewTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Criar animações escalonadas para os itens
    _itemAnimations = List.generate(8, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(
            index * 0.1,
            0.8 + (index * 0.02),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Calcula estatísticas por tipo de cuidado
  Map<TaskType, Map<String, dynamic>> _calculateCareTypeStats() {
    final stats = <TaskType, Map<String, dynamic>>{};

    // Inicializar estatísticas para todos os tipos
    for (final type in TaskType.values) {
      stats[type] = {
        'count': 0,
        'lastDate': null as DateTime?,
        'averageInterval': 0.0,
        'streak': 0,
      };
    }

    // Calcular estatísticas
    for (final task in widget.completedTasks) {
      final typeStats = stats[task.type]!;
      typeStats['count'] = (typeStats['count'] as int) + 1;

      if (task.completedDate != null) {
        final lastDate = typeStats['lastDate'] as DateTime?;
        if (lastDate == null || task.completedDate!.isAfter(lastDate)) {
          typeStats['lastDate'] = task.completedDate;
        }
      }
    }

    return stats;
  }

  /// Calcula sequência atual de dias consecutivos
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

  /// Obtém os últimos 5 cuidados realizados
  List<PlantTask> _getRecentTasks() {
    final tasks = [...widget.completedTasks];
    tasks.sort(
      (a, b) => (b.completedDate ?? DateTime(1970)).compareTo(
        a.completedDate ?? DateTime(1970),
      ),
    );
    return tasks.take(5).toList();
  }

  /// Calcula estatísticas do mês atual
  Map<String, dynamic> _calculateMonthStats() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final monthTasks =
        widget.completedTasks.where((task) {
          if (task.completedDate == null) return false;
          return task.completedDate!.isAfter(currentMonth) &&
              task.completedDate!.isBefore(nextMonth);
        }).toList();

    final typeCount = <TaskType, int>{};
    for (final task in monthTasks) {
      typeCount[task.type] = (typeCount[task.type] ?? 0) + 1;
    }

    return {
      'total': monthTasks.length,
      'byType': typeCount,
      'daysWithCare':
          monthTasks
              .map(
                (t) =>
                    '${t.completedDate!.year}-${t.completedDate!.month}-${t.completedDate!.day}',
              )
              .toSet()
              .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final careStats = _calculateCareTypeStats();
    final currentStreak = _calculateCurrentStreak();
    final recentTasks = _getRecentTasks();
    final monthStats = _calculateMonthStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de estatísticas principais
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
                  child: _buildMainStatsCards(
                    context,
                    currentStreak,
                    monthStats,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Grid de tipos de cuidado
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
                  child: _buildCareTypesGrid(context, careStats),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Progresso da sequência
          if (currentStreak > 0)
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
                    child: _buildStreakProgress(context, currentStreak),
                  ),
                );
              },
            ),

          if (currentStreak > 0) const SizedBox(height: 24),

          // Últimos cuidados realizados
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
                  child: _buildRecentCare(context, recentTasks),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCards(
    BuildContext context,
    int currentStreak,
    Map<String, dynamic> monthStats,
  ) {
    Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.task_alt,
            value: '${widget.completedTasks.length}',
            label: 'Total de cuidados',
            color: PlantisColors.primary,
            subtitle: 'Desde o início',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            value: '${currentStreak}d',
            label: 'Sequência atual',
            color: Colors.orange,
            subtitle: 'Dias consecutivos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_month,
            value: '${monthStats['total']}',
            label: 'Este mês',
            color: PlantisColors.secondary,
            subtitle: '${monthStats['daysWithCare']} dias',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareTypesGrid(
    BuildContext context,
    Map<TaskType, Map<String, dynamic>> careStats,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de cuidados',
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
            childAspectRatio: 1.2,
          ),
          itemCount: TaskType.values.length,
          itemBuilder: (context, index) {
            final type = TaskType.values[index];
            final stats = careStats[type]!;
            return _buildCareTypeCard(context, type, stats);
          },
        ),
      ],
    );
  }

  Widget _buildCareTypeCard(
    BuildContext context,
    TaskType type,
    Map<String, dynamic> stats,
  ) {
    final theme = Theme.of(context);
    final color = _getTaskTypeColor(type);
    final count = stats['count'] as int;
    final lastDate = stats['lastDate'] as DateTime?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getTaskTypeIcon(type), color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            type.displayName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (lastDate != null)
            Text(
              'Último: ${_formatDate(lastDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              'Nunca realizado',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakProgress(BuildContext context, int currentStreak) {
    final theme = Theme.of(context);
    final nextMilestone = _getNextStreakMilestone(currentStreak);
    final progress = currentStreak / nextMilestone;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sequência de cuidados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Próxima meta: $nextMilestone dias',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$currentStreak / $nextMilestone',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.orange.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCare(BuildContext context, List<PlantTask> recentTasks) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos cuidados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (recentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum cuidado realizado ainda',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return AnimatedBuilder(
              animation: _itemAnimations[4 + index],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _itemAnimations[4 + index],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(_itemAnimations[4 + index]),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildRecentCareItem(context, task),
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }

  Widget _buildRecentCareItem(BuildContext context, PlantTask task) {
    final theme = Theme.of(context);
    final color = _getTaskTypeColor(task.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getTaskTypeIcon(task.type), color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (task.completedDate != null)
                Text(
                  _formatDate(task.completedDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (task.completedDate != null)
                Text(
                  _formatTime(task.completedDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
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

  int _getNextStreakMilestone(int currentStreak) {
    if (currentStreak < 7) return 7;
    if (currentStreak < 14) return 14;
    if (currentStreak < 30) return 30;
    if (currentStreak < 60) return 60;
    if (currentStreak < 100) return 100;
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == yesterday) {
      return 'Ontem';
    } else {
      final months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

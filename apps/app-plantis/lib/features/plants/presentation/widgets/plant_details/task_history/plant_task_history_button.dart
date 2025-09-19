import 'package:flutter/material.dart';
import '../../../../../../core/theme/plantis_colors.dart';
import '../../../../domain/entities/plant_task.dart';

/// Botão interativo que substitui o "Ver todas" simples
/// Mostra um card com preview de estatísticas e animações
class PlantTaskHistoryButton extends StatefulWidget {
  final List<PlantTask> completedTasks;
  final VoidCallback onPressed;

  const PlantTaskHistoryButton({
    super.key,
    required this.completedTasks,
    required this.onPressed,
  });

  @override
  State<PlantTaskHistoryButton> createState() => _PlantTaskHistoryButtonState();
}

class _PlantTaskHistoryButtonState extends State<PlantTaskHistoryButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de escala para tap
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Animação de glow pulsante
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animação de glow
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  /// Calcula o streak atual de dias consecutivos
  int _calculateCurrentStreak() {
    if (widget.completedTasks.isEmpty) return 0;

    final tasks = [...widget.completedTasks];
    tasks.sort((a, b) => (b.completedDate ?? DateTime(1970))
        .compareTo(a.completedDate ?? DateTime(1970)));

    int streak = 0;
    DateTime? lastDate;

    for (final task in tasks) {
      if (task.completedDate == null) continue;

      final taskDate = DateTime(
        task.completedDate!.year,
        task.completedDate!.month,
        task.completedDate!.day,
      );

      if (lastDate == null) {
        lastDate = taskDate;
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(taskDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = taskDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Calcula estatísticas do mês atual
  Map<String, int> _calculateMonthStats() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final monthTasks = widget.completedTasks.where((task) {
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
      'watering': typeCount[TaskType.watering] ?? 0,
      'fertilizing': typeCount[TaskType.fertilizing] ?? 0,
      'pruning': typeCount[TaskType.pruning] ?? 0,
      'others': monthTasks.length -
          (typeCount[TaskType.watering] ?? 0) -
          (typeCount[TaskType.fertilizing] ?? 0) -
          (typeCount[TaskType.pruning] ?? 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStreak = _calculateCurrentStreak();
    final monthStats = _calculateMonthStats();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Glow effect
                      BoxShadow(
                        color: PlantisColors.primary.withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      // Sombra normal
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          PlantisColors.primary.withOpacity(0.1),
                          PlantisColors.primaryLight.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PlantisColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header do card
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PlantisColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: PlantisColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Histórico de cuidados',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toque para ver detalhes completos',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: PlantisColors.primary,
                              size: 16,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Estatísticas principais
                        Row(
                          children: [
                            // Total de tarefas
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.task_alt,
                                value: '${widget.completedTasks.length}',
                                label: 'Total',
                                color: PlantisColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Streak atual
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.local_fire_department,
                                value: '${currentStreak}d',
                                label: 'Sequência',
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Mês atual
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.calendar_month,
                                value: '${monthStats['total']}',
                                label: 'Este mês',
                                color: PlantisColors.secondary,
                              ),
                            ),
                          ],
                        ),

                        if (monthStats['total']! > 0) ...[
                          const SizedBox(height: 16),

                          // Preview de tipos de cuidado do mês
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat(
                                  context,
                                  Icons.water_drop,
                                  monthStats['watering']!,
                                  PlantisColors.water,
                                ),
                                _buildMiniStat(
                                  context,
                                  Icons.grass,
                                  monthStats['fertilizing']!,
                                  PlantisColors.soil,
                                ),
                                _buildMiniStat(
                                  context,
                                  Icons.content_cut,
                                  monthStats['pruning']!,
                                  PlantisColors.leaf,
                                ),
                                _buildMiniStat(
                                  context,
                                  Icons.more_horiz,
                                  monthStats['others']!,
                                  theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    IconData icon,
    int count,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
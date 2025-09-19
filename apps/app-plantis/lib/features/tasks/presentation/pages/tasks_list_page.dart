import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/feedback/feedback.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../../plants/presentation/providers/plants_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';
import '../widgets/empty_tasks_widget.dart';
import '../widgets/task_completion_dialog.dart';
// import '../widgets/task_creation_dialog.dart'; // Removido - tarefas geradas automaticamente
import '../widgets/tasks_error_boundary.dart';
// import '../widgets/tasks_fab.dart'; // Removido - tarefas geradas automaticamente

// Helper classes for optimized state management
class TasksListState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isEmpty;
  final bool hasActiveOperations;
  final String? currentOperationMessage;

  const TasksListState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.isEmpty,
    required this.hasActiveOperations,
    this.currentOperationMessage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TasksListState &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isEmpty == isEmpty &&
        other.hasActiveOperations == hasActiveOperations &&
        other.currentOperationMessage == currentOperationMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      hasError,
      errorMessage,
      isEmpty,
      hasActiveOperations,
      currentOperationMessage,
    );
  }
}

class TasksListData {
  final List<task_entity.Task> filteredTasks;
  final bool isLoading;
  final TasksFilterType currentFilter;
  final int totalTasks;

  const TasksListData({
    required this.filteredTasks,
    required this.isLoading,
    required this.currentFilter,
    required this.totalTasks,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TasksListData &&
        other.isLoading == isLoading &&
        other.currentFilter == currentFilter &&
        other.totalTasks == totalTasks &&
        _listEquals(other.filteredTasks, filteredTasks);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(filteredTasks.map((t) => t.id)),
      isLoading,
      currentFilter,
      totalTasks,
    );
  }

  bool _listEquals(List<task_entity.Task> a, List<task_entity.Task> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}

class TaskDateGroup {
  final String dateKey;
  final List<task_entity.Task> tasks;

  TaskDateGroup({required this.dateKey, required this.tasks});

  DateTime get date {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> with AccessibilityFocusMixin, LoadingPageMixin, UnifiedFeedbackMixin {
  // Cache for date formatting to avoid recreation
  static const List<String> _weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
  
  static const List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  
  // Date formatting cache
  final Map<String, String> _dateFormattingCache = <String, String>{};
  @override
  void initState() {
    super.initState();

    // Load tasks on initialization with delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      context.read<TasksProvider>().loadTasks();
      // Set default filter to "Today"
      context.read<TasksProvider>().setFilter(TasksFilterType.today);
    });
  }

  @override
  void dispose() {
    // CRITICAL MEMORY LEAK FIX: Clear date formatting cache to prevent memory leaks
    _dateFormattingCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return UnifiedFeedbackProvider(
      child: ContextualLoadingListener(
        context: LoadingContexts.taskComplete,
        child: TasksErrorBoundary(
        onRetry: () {
          final provider = context.read<TasksProvider>();
          provider.clearError();
          provider.loadTasks();
        },
        child: BasePageScaffold(
          body: ResponsiveLayout(
            child: Column(
              children: [
              // Header estilo ReceitaAgro
              _buildHeader(context),
              
              // Simple filter section
              _buildSimpleFilters(context),
              
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                  child: Selector<TasksProvider, TasksListState>(
          selector: (_, provider) => TasksListState(
            isLoading: provider.isLoading,
            hasError: provider.hasError,
            errorMessage: provider.errorMessage,
            isEmpty: provider.allTasks.isEmpty,
            hasActiveOperations: provider.hasActiveOperations,
            currentOperationMessage: provider.currentOperationMessage,
          ),
          builder: (context, state, child) {
            if (state.isLoading && state.isEmpty) {
              return LoadingPresets.taskListSkeleton(
                count: LoadingConstants.listSkeletonCount,
              );
            }

            if (state.hasError) {
              return ErrorRecovery(
                errorMessage: state.errorMessage,
                onRetry: () {
                  final provider = context.read<TasksProvider>();
                  provider.clearError();
                  provider.loadTasks();
                },
                style: ErrorRecoveryStyle.card,
                showRetryButton: true,
              );
            }

            return RefreshIndicator(
              onRefresh: context.read<TasksProvider>().refresh,
              child: Stack(
                children: [
                  _buildTasksList(),
                  // Operation feedback overlay
                  if (state.hasActiveOperations || state.currentOperationMessage != null)
                    Consumer<TasksProvider>(
                      builder: (context, provider, child) => _buildOperationOverlay(provider),
                    ),
                ],
              ),
            );
          }, // Selector builder
          ), // Selector
                    ), // Padding
                  ), // ConstrainedBox  
                ), // Center
              ), // Expanded
            ],
            ), // Column
          ), // ResponsiveLayout
        ), // BasePageScaffold
        ), // TasksErrorBoundary
      ), // ContextualLoadingListener
    ); // UnifiedFeedbackProvider
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, _) {
        return PlantisHeader(
          title: 'Minhas Tarefas',
          subtitle: '${tasksProvider.allTasks.length} tarefas cadastradas',
          leading: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.task_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleFilters(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Hoje'),
                selected: provider.currentFilter == TasksFilterType.today,
                onSelected: (selected) {
                  provider.setFilter(TasksFilterType.today);
                },
                selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
                checkmarkColor: PlantisColors.primary,
                backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                labelStyle: TextStyle(
                  color: provider.currentFilter == TasksFilterType.today 
                      ? PlantisColors.primary 
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: provider.currentFilter == TasksFilterType.today 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Próximas'),
                selected: provider.currentFilter == TasksFilterType.upcoming,
                onSelected: (selected) {
                  provider.setFilter(TasksFilterType.upcoming);
                },
                selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
                checkmarkColor: PlantisColors.primary,
                backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                labelStyle: TextStyle(
                  color: provider.currentFilter == TasksFilterType.upcoming 
                      ? PlantisColors.primary 
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: provider.currentFilter == TasksFilterType.upcoming 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksList() {
    return Selector<TasksProvider, TasksListData>(
      selector: (_, provider) => TasksListData(
        filteredTasks: provider.filteredTasks,
        isLoading: provider.isLoading,
        currentFilter: provider.currentFilter,
        totalTasks: provider.totalTasks,
      ),
      builder: (context, data, child) {
        if (data.filteredTasks.isEmpty && !data.isLoading) {
          return EmptyTasksWidget(
            filterType: data.currentFilter,
            onAddTask: () {}, // Removido - tarefas geradas automaticamente
          );
        }

        // Agrupar tarefas por data
        final groupedTasks = _groupTasksByDate(data.filteredTasks);
        
        // Verificar se deve mostrar botão "Ver todas"
        final shouldShowViewAllButton = data.currentFilter == TasksFilterType.upcoming && 
                                       data.totalTasks > data.filteredTasks.length;

        return CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: groupedTasks.length + (shouldShowViewAllButton ? 1 : 0),
              itemBuilder: (context, index) {
                // Se é o último item e deve mostrar o botão
                if (shouldShowViewAllButton && index == groupedTasks.length) {
                  return _buildViewAllButton();
                }
                
                final dateGroup = groupedTasks[index];
                return _buildDateGroup(dateGroup);
              },
            ),
          ],
        );
      },
    );
  }

  List<TaskDateGroup> _groupTasksByDate(List<task_entity.Task> tasks) {
    final Map<String, List<task_entity.Task>> grouped = {};

    for (final task in tasks) {
      final dateKey = _getDateKey(task.dueDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(task);
    }

    return grouped.entries
        .map((entry) => TaskDateGroup(dateKey: entry.key, tasks: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateGroup(TaskDateGroup dateGroup) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey(dateGroup.dateKey),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da data
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: PlantisColors.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDateHeader(dateGroup.date),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Lista de tarefas desta data
        ...dateGroup.tasks.map((task) => _buildTaskCard(task)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTaskCard(task_entity.Task task) {
    final theme = Theme.of(context);

    return Selector<TasksProvider, bool>(
      selector: (_, provider) => provider.isTaskOperationLoading(task.id),
      builder: (context, isLoading, child) {
        
        return Semantics(
          label: 'Tarefa: ${task.title} para ${task.plantName}',
          hint: isLoading ? 'Tarefa sendo processada' : 'Toque duas vezes para marcar como concluída',
          button: true,
          enabled: !isLoading,
          onTap: isLoading ? null : () => _showTaskCompletionDialog(context, task),
          child: PlantisCard(
            key: ValueKey(task.id),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            padding: const EdgeInsets.all(12),
            onTap: isLoading ? null : () {
              AccessibilityTokens.performHapticFeedback('light');
              _showTaskCompletionDialog(context, task);
            },
            child: Row(
            children: [
              // Check button (moved to left)
              GestureDetector(
                onTap: isLoading ? null : () => _showTaskCompletionDialog(context, task),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PlantisColors.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.check_circle, 
                          color: PlantisColors.primary, 
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Task information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: isLoading ? 0.6 : 1.0,
                        ),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.plantName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    Consumer<PlantsProvider>(
                      builder: (context, plantsProvider, _) {
                        final plants = plantsProvider.plants.where((p) => p.id == task.plantId);
                        final plant = plants.isNotEmpty ? plants.first : null;
                        
                        String? plantDescription;
                        if (plant != null) {
                          if (plant.species?.isNotEmpty == true && plant.notes?.isNotEmpty == true) {
                            plantDescription = '${plant.species} • ${plant.notes}';
                          } else if (plant.species?.isNotEmpty == true) {
                            plantDescription = plant.species;
                          } else if (plant.notes?.isNotEmpty == true) {
                            plantDescription = plant.notes;
                          }
                        }
                        
                        if (plantDescription != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 1),
                              Text(
                                plantDescription,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Processando...',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Ícone da tarefa (moved to right)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTaskIcon(task.type), color: PlantisColors.primary, size: 18),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Future<void> _showTaskCompletionDialog(BuildContext context, task_entity.Task task) async {
    final result = await TaskCompletionDialog.show(
      context: context,
      task: task,
    );

    if (result != null && context.mounted) {
      // Use unified feedback system for task completion
      await UnifiedFeedbackSystem.completeTask(
        context: context,
        completeOperation: () async {
          // Use the completion date and notes from the dialog
          final success = await context.read<TasksProvider>().completeTask(
            task.id, 
            notes: result.notes,
          );
          
          if (!success) {
            throw Exception('Falha ao concluir tarefa');
          }
          
          // Anunciar para screen readers
          if (context.mounted) {
            AccessibilityTokens.announceForAccessibility(
              context, 
              'Tarefa "${task.title}" marcada como concluída',
            );
          }
          
          return success;
        },
        taskName: task.title,
      );
    }
  }

  IconData _getTaskIcon(task_entity.TaskType type) {
    switch (type) {
      case task_entity.TaskType.watering:
        return Icons.water_drop;
      case task_entity.TaskType.fertilizing:
        return Icons.eco;
      case task_entity.TaskType.pruning:
        return Icons.content_cut;
      case task_entity.TaskType.pestInspection:
        return Icons.search;
      case task_entity.TaskType.repotting:
        return Icons.grass;
      default:
        return Icons.task_alt;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      // Use cache to avoid recreating the same date string
      final cacheKey = '${date.year}-${date.month}-${date.day}-${date.weekday}';
      
      if (_dateFormattingCache.containsKey(cacheKey)) {
        return _dateFormattingCache[cacheKey]!;
      }

      final weekday = _weekdays[date.weekday - 1];
      final day = date.day;
      final month = _months[date.month - 1];

      final formatted = '$weekday, $day de $month';
      _dateFormattingCache[cacheKey] = formatted;
      
      return formatted;
    }
  }

  // Método removido - tarefas são geradas automaticamente quando concluídas
  // Future<void> _showAddTaskDialog(BuildContext context) async {}

  Widget _buildViewAllButton() {
    final theme = Theme.of(context);
    
    return Selector<TasksProvider, int>(
      selector: (_, provider) => provider.totalTasks - provider.filteredTasks.length,
      builder: (context, remainingTasks, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<TasksProvider>().setFilter(TasksFilterType.all);
              },
              icon: const Icon(Icons.visibility),
              label: Text('Ver todas as tarefas (+$remainingTasks)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperationOverlay(TasksProvider provider) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                provider.currentOperationMessage ?? 'Processando...',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

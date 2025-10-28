import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'tasks_state.freezed.dart';

/// View states for tasks feature
enum TasksViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Filtro de visualização de tarefas
enum TasksViewFilter {
  all('Todas'),
  pending('Pendentes'),
  overdue('Atrasadas'),
  today('Hoje'),
  week('Esta Semana');

  const TasksViewFilter(this.displayName);
  final String displayName;
}

/// State imutável para gerenciamento de tarefas
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
class TasksState with _$TasksState {
  const TasksState._();

  const factory TasksState({
    /// Lista de tarefas
    @Default([]) List<Task> tasks,

    /// Tarefa selecionada
    Task? selectedTask,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro de visualização
    @Default(TasksViewFilter.all) TasksViewFilter viewFilter,

    /// Filtro por planta
    String? selectedPlantId,

    /// Filtro por tipo de tarefa
    TaskType? selectedTaskType,

    /// Filtro por prioridade
    TaskPriority? selectedPriority,

    /// Filtro de busca
    @Default('') String searchQuery,

    /// Ordenação (dueDate, priority, type)
    @Default('dueDate') String sortBy,

    /// Ordem ascendente
    @Default(true) bool isAscending,

    /// Mostrar tarefas concluídas
    @Default(false) bool showCompleted,
  }) = _TasksState;

  /// Factory para estado inicial
  factory TasksState.initial() => const TasksState();

  // ========== Computed Properties ==========

  /// Tarefas filtradas
  List<Task> get filteredTasks {
    var filtered = tasks;

    // Filtrar por status completado
    if (!showCompleted) {
      filtered = filtered.where((t) => t.status != TaskStatus.completed).toList();
    }

    // Filtrar por tipo de visualização
    switch (viewFilter) {
      case TasksViewFilter.pending:
        filtered = filtered.where((t) => t.status == TaskStatus.pending).toList();
        break;
      case TasksViewFilter.overdue:
        filtered = filtered.where((t) => t.isOverdue).toList();
        break;
      case TasksViewFilter.today:
        filtered = filtered.where((t) => t.isDueToday).toList();
        break;
      case TasksViewFilter.week:
        final endOfWeek = DateTime.now().add(const Duration(days: 7));
        filtered = filtered
            .where((t) => t.dueDate.isBefore(endOfWeek) || t.dueDate.isAtSameMomentAs(endOfWeek))
            .toList();
        break;
      case TasksViewFilter.all:
        break;
    }

    // Filtrar por planta
    if (selectedPlantId != null) {
      filtered = filtered.where((t) => t.plantId == selectedPlantId).toList();
    }

    // Filtrar por tipo de tarefa
    if (selectedTaskType != null) {
      filtered = filtered.where((t) => t.type == selectedTaskType).toList();
    }

    // Filtrar por prioridade
    if (selectedPriority != null) {
      filtered = filtered.where((t) => t.priority == selectedPriority).toList();
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'dueDate':
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case 'priority':
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case 'type':
          comparison = a.type.displayName.compareTo(b.type.displayName);
          break;
        default:
          comparison = a.dueDate.compareTo(b.dueDate);
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Tarefas pendentes
  List<Task> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.pending).toList();

  /// Tarefas atrasadas
  List<Task> get overdueTasks => tasks.where((t) => t.isOverdue).toList();

  /// Tarefas para hoje
  List<Task> get todayTasks => tasks.where((t) => t.isDueToday).toList();

  /// Tarefas para amanhã
  List<Task> get tomorrowTasks => tasks.where((t) => t.isDueTomorrow).toList();

  /// Tarefas concluídas
  List<Task> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  /// Conta total de tarefas
  int get totalTasks => tasks.length;

  /// Conta de tarefas filtradas
  int get filteredCount => filteredTasks.length;

  /// Conta de tarefas pendentes
  int get pendingCount => pendingTasks.length;

  /// Conta de tarefas atrasadas
  int get overdueCount => overdueTasks.length;

  /// Conta de tarefas de hoje
  int get todayCount => todayTasks.length;

  /// Conta de tarefas concluídas
  int get completedCount => completedTasks.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => tasks.isEmpty;

  /// Verifica se há tarefas filtradas
  bool get hasFilteredTasks => filteredTasks.isNotEmpty;

  /// Verifica se há busca ativa
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Verifica se há filtros ativos
  bool get hasActiveFilters =>
      viewFilter != TasksViewFilter.all ||
      selectedPlantId != null ||
      selectedTaskType != null ||
      selectedPriority != null ||
      hasSearchQuery;

  /// Estado da view baseado nos dados
  TasksViewState get viewState {
    if (isLoading) return TasksViewState.loading;
    if (hasError) return TasksViewState.error;
    if (isEmpty) return TasksViewState.empty;
    if (hasFilteredTasks) return TasksViewState.loaded;
    return TasksViewState.initial;
  }

  /// Verifica se há tarefa selecionada
  bool get hasSelectedTask => selectedTask != null;

  /// Verifica se há alertas (tarefas atrasadas)
  bool get hasAlerts => overdueCount > 0;

  /// Tarefas por prioridade
  Map<TaskPriority, List<Task>> get tasksByPriority {
    final map = <TaskPriority, List<Task>>{};
    for (final priority in TaskPriority.values) {
      map[priority] = tasks.where((t) => t.priority == priority).toList();
    }
    return map;
  }

  /// Tarefas por tipo
  Map<TaskType, List<Task>> get tasksByType {
    final map = <TaskType, List<Task>>{};
    for (final type in TaskType.values) {
      map[type] = tasks.where((t) => t.type == type).toList();
    }
    return map;
  }
}

/// Extension para métodos de transformação do state
extension TasksStateX on TasksState {
  /// Limpa mensagem de erro
  TasksState clearError() => copyWith(error: null);

  /// Limpa busca
  TasksState clearSearch() => copyWith(searchQuery: '');

  /// Limpa seleção
  TasksState clearSelection() => copyWith(selectedTask: null);

  /// Reseta filtros
  TasksState resetFilters() => copyWith(
        viewFilter: TasksViewFilter.all,
        selectedPlantId: null,
        selectedTaskType: null,
        selectedPriority: null,
        searchQuery: '',
        sortBy: 'dueDate',
        isAscending: true,
      );
}

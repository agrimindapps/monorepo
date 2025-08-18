import 'package:flutter/foundation.dart';
import 'package:core/src/shared/utils/failure.dart';
import 'package:core/src/domain/usecases/base_usecase.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../../../core/services/task_notification_service.dart';

enum TasksFilterType {
  all('Todas'),
  today('Hoje'),
  overdue('Atrasadas'),
  upcoming('Próximas'),
  completed('Concluídas'),
  byPlant('Por Planta');

  const TasksFilterType(this.displayName);
  final String displayName;
}

class TasksProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  // final GetTasksByPlantIdUseCase _getTasksByPlantIdUseCase;
  // final GetTasksByStatusUseCase _getTasksByStatusUseCase;
  // final GetOverdueTasksUseCase _getOverdueTasksUseCase;
  // final GetTodayTasksUseCase _getTodayTasksUseCase;
  // final GetUpcomingTasksUseCase _getUpcomingTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  // final UpdateTaskUseCase _updateTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  // final DeleteTaskUseCase _deleteTaskUseCase;
  final TaskNotificationService _notificationService;

  TasksProvider({
    required GetTasksUseCase getTasksUseCase,
    // required GetTasksByPlantIdUseCase getTasksByPlantIdUseCase,
    // required GetTasksByStatusUseCase getTasksByStatusUseCase,
    // required GetOverdueTasksUseCase getOverdueTasksUseCase,
    // required GetTodayTasksUseCase getTodayTasksUseCase,
    // required GetUpcomingTasksUseCase getUpcomingTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    // required UpdateTaskUseCase updateTaskUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
    // required DeleteTaskUseCase deleteTaskUseCase,
    TaskNotificationService? notificationService,
  })  : _getTasksUseCase = getTasksUseCase,
        // _getTasksByPlantIdUseCase = getTasksByPlantIdUseCase,
        // _getTasksByStatusUseCase = getTasksByStatusUseCase,
        // _getOverdueTasksUseCase = getOverdueTasksUseCase,
        // _getTodayTasksUseCase = getTodayTasksUseCase,
        // _getUpcomingTasksUseCase = getUpcomingTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        // _updateTaskUseCase = updateTaskUseCase,
        _completeTaskUseCase = completeTaskUseCase,
        // _deleteTaskUseCase = deleteTaskUseCase,
        _notificationService = notificationService ?? TaskNotificationService();

  // Estado
  List<task_entity.Task> _allTasks = [];
  List<task_entity.Task> _filteredTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TasksFilterType _currentFilter = TasksFilterType.all;
  String? _selectedPlantId;
  String _searchQuery = '';

  // Getters
  List<task_entity.Task> get allTasks => _allTasks;
  List<task_entity.Task> get filteredTasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TasksFilterType get currentFilter => _currentFilter;
  String? get selectedPlantId => _selectedPlantId;
  String get searchQuery => _searchQuery;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _filteredTasks.isEmpty && !_isLoading;

  // Estatísticas
  int get totalTasks => _allTasks.length;
  int get completedTasks => _allTasks.where((t) => t.status == task_entity.TaskStatus.completed).length;
  int get pendingTasks => _allTasks.where((t) => t.status == task_entity.TaskStatus.pending).length;
  int get overdueTasks => _allTasks.where((t) => t.isOverdue && t.status == task_entity.TaskStatus.pending).length;
  int get todayTasks => _allTasks.where((t) => t.isDueToday && t.status == task_entity.TaskStatus.pending).length;
  int get upcomingTasksCount {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _allTasks.where((t) => 
      t.status == task_entity.TaskStatus.pending &&
      t.dueDate.isAfter(now) &&
      t.dueDate.isBefore(nextWeek)
    ).length;
  }

  // Tarefas por prioridade
  List<task_entity.Task> get highPriorityTasks => _filteredTasks.where((t) => 
      t.priority == task_entity.TaskPriority.high || t.priority == task_entity.TaskPriority.urgent).toList();
  
  List<task_entity.Task> get mediumPriorityTasks => _filteredTasks.where((t) => 
      t.priority == task_entity.TaskPriority.medium).toList();
  
  List<task_entity.Task> get lowPriorityTasks => _filteredTasks.where((t) => 
      t.priority == task_entity.TaskPriority.low).toList();

  // Carregar tarefas
  Future<void> loadTasks() async {
    // Só mostrar loading se não temos tarefas ainda
    final shouldShowLoading = _allTasks.isEmpty;
    
    if (shouldShowLoading) {
      _setLoading(true);
    }
    _clearError();

    try {
      final result = await _getTasksUseCase(NoParams());
      
      result.fold(
        (failure) => _setError(_mapFailureToMessage(failure)),
        (tasks) {
          _allTasks = tasks;
          _applyFilters();
          // Verificar tarefas em atraso e enviar notificações
          _notificationService.checkOverdueTasks(tasks);
          // Reagendar todas as notificações
          _notificationService.rescheduleTaskNotifications(tasks);
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar tarefas');
    } finally {
      if (shouldShowLoading) {
        _setLoading(false);
      }
    }
  }

  // Adicionar tarefa
  Future<bool> addTask(task_entity.Task task) async {
    _clearError();

    try {
      final result = await _addTaskUseCase(AddTaskParams(task: task));
      
      return result.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return false;
        },
        (addedTask) {
          _allTasks.add(addedTask);
          _applyFilters();
          // Agendar notificação para a nova tarefa
          _notificationService.scheduleTaskNotification(addedTask);
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao adicionar tarefa');
      return false;
    }
  }

  // Completar tarefa
  Future<bool> completeTask(String taskId, {String? notes}) async {
    _clearError();

    try {
      final result = await _completeTaskUseCase(
        CompleteTaskParams(taskId: taskId, notes: notes),
      );
      
      return result.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          return false;
        },
        (completedTask) {
          final index = _allTasks.indexWhere((t) => t.id == taskId);
          if (index >= 0) {
            _allTasks[index] = completedTask;
            _applyFilters();
            // Cancelar notificações da tarefa completada
            _notificationService.cancelTaskNotifications(taskId);
            // Reagendar notificações para tarefas restantes
            _notificationService.rescheduleTaskNotifications(_allTasks);
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao completar tarefa');
      return false;
    }
  }

  // Buscar tarefas
  void searchTasks(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Definir filtro
  void setFilter(TasksFilterType filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  // Refresh
  Future<void> refresh() async {
    await loadTasks();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setLoading(false);
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<task_entity.Task> tasks = List.from(_allTasks);

    // Aplicar filtro por tipo
    switch (_currentFilter) {
      case TasksFilterType.all:
        break;
      case TasksFilterType.today:
        tasks = tasks.where((t) => t.isDueToday && t.status == task_entity.TaskStatus.pending).toList();
        break;
      case TasksFilterType.overdue:
        tasks = tasks.where((t) => t.isOverdue).toList();
        break;
      case TasksFilterType.upcoming:
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        tasks = tasks.where((t) => 
          t.status == task_entity.TaskStatus.pending &&
          t.dueDate.isAfter(now) &&
          t.dueDate.isBefore(nextWeek)
        ).toList();
        break;
      case TasksFilterType.completed:
        tasks = tasks.where((t) => t.status == task_entity.TaskStatus.completed).toList();
        break;
      case TasksFilterType.byPlant:
        if (_selectedPlantId != null) {
          tasks = tasks.where((t) => t.plantId == _selectedPlantId).toList();
        }
        break;
    }

    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery) ||
               task.plantName.toLowerCase().contains(_searchQuery) ||
               (task.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Ordenar por prioridade e data
    tasks.sort((a, b) {
      // Primeiro por status (pendentes primeiro)
      if (a.status != b.status) {
        if (a.status == task_entity.TaskStatus.pending) return -1;
        if (b.status == task_entity.TaskStatus.pending) return 1;
      }

      // Depois por prioridade
      final aPriorityIndex = task_entity.TaskPriority.values.indexOf(a.priority);
      final bPriorityIndex = task_entity.TaskPriority.values.indexOf(b.priority);
      if (aPriorityIndex != bPriorityIndex) {
        return bPriorityIndex.compareTo(aPriorityIndex); // Maior prioridade primeiro
      }

      // Por último por data de vencimento
      return a.dueDate.compareTo(b.dueDate);
    });

    _filteredTasks = tasks;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.userMessage;
  }

}
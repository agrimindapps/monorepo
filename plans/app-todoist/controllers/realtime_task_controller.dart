// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../constants/timeout_constants.dart';
import '../models/conflict_resolution.dart';
import '../models/task_model.dart';
import '../repository/task_repository.dart';
import '../services/debug_info_service.dart';

/// Controller para gerenciamento de Tasks usando SyncFirebaseService
/// Migrado para GetX para consistência de estado reativo
class RealtimeTaskController extends GetxController {
  // Repository injected via constructor
  final TaskRepository _repository;

  /// Constructor with dependency injection
  RealtimeTaskController(this._repository);

  // Stream subscriptions for proper disposal
  final List<StreamSubscription> _subscriptions = [];

  // Estados observáveis reativos com GetX
  final RxList<Task> _items = <Task>[].obs;
  final RxBool _isLoading = RxBool(false);
  final Rx<SyncStatus> _syncStatus = Rx<SyncStatus>(SyncStatus.offline);
  final RxBool _isOnline = RxBool(false);

  // Estados específicos para tasks
  final RxList<Task> _todayTasks = <Task>[].obs;
  final RxList<Task> _starredTasks = <Task>[].obs;
  final RxList<Task> _overdueTasks = <Task>[].obs;
  final RxInt _completedTasksCount = RxInt(0);
  final RxInt _pendingTasksCount = RxInt(0);

  // Getters para acessar os estados
  List<Task> get items => _items;
  bool get isLoading => _isLoading.value;
  SyncStatus get syncStatus => _syncStatus.value;
  bool get isOnline => _isOnline.value;
  List<Task> get todayTasks => _todayTasks;
  List<Task> get starredTasks => _starredTasks;
  List<Task> get overdueTasks => _overdueTasks;
  int get completedTasksCount => _completedTasksCount.value;
  int get pendingTasksCount => _pendingTasksCount.value;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
  }

  /// Inicializar repository e streams
  void _initializeRepository() async {
    try {
      // Inicializar repository
      await _repository.initialize();

      // Setup streams
      _setupStreams();
    } catch (e) {
      // Log error
    }
  }

  void _setupStreams() {
    // Stream de dados principais
    _subscriptions.add(
      _repository.tasksStream.listen((data) {
        _items.assignAll(data);
        _updateDerivedStates();
      }),
    );

    // Stream de status de sync
    _subscriptions.add(
      _repository.syncStatusStream.listen((status) {
        _syncStatus.value = status;
      }),
    );

    // Stream de conectividade
    _subscriptions.add(
      _repository.connectivityStream.listen((isOnline) {
        _isOnline.value = isOnline;
      }),
    );
  }

  void _updateDerivedStates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(TimeoutConstants.oneDay);

    // Tarefas de hoje
    _todayTasks.assignAll(
      _items.where((task) {
        if (task.dueDate == null) return false;
        final dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return dueDate.isAtSameMomentAs(today) ||
            (dueDate.isBefore(tomorrow) && dueDate.isAfter(today.subtract(TimeoutConstants.oneDay)));
      }).toList(),
    );

    // Tarefas favoritas
    _starredTasks.assignAll(
      _items.where((task) => task.isStarred && !task.isCompleted).toList(),
    );

    // Tarefas atrasadas
    _overdueTasks.assignAll(
      _items.where((task) => task.isOverdue).toList(),
    );

    // Contadores
    _completedTasksCount.value = _items.where((task) => task.isCompleted).length;
    _pendingTasksCount.value = _items.where((task) => !task.isCompleted).length;
  }

  // ========== CRUD Operations ==========

  /// Criar nova task
  Future<bool> createTask(Task task) async {
    _isLoading.value = true;
    try {
      await _repository.create(task);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Atualizar task existente
  Future<bool> updateTask(String id, Task task) async {
    _isLoading.value = true;
    try {
      final result = await _repository.updateWithConflictCheck(id, task);
      
      if (result.result == ConflictResolutionResult.needsManualResolution) {
        // TODO: Mostrar dialog de resolução manual
        return false;
      }
      
      return result.result == ConflictResolutionResult.noConflict ||
             result.result == ConflictResolutionResult.resolved;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Deletar task
  Future<bool> deleteTask(String id) async {
    _isLoading.value = true;
    try {
      await _repository.delete(id);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Task Operations ==========

  /// Completar/Descompletar task
  Future<bool> toggleTaskComplete(String taskId) async {
    final task = _items.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return false;

    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return await updateTask(taskId, updatedTask);
  }

  /// Manter método legado por compatibilidade
  Future<bool> toggleTaskCompletion(String taskId) async {
    return await toggleTaskComplete(taskId);
  }

  /// Favoritar/Desfavoritar task
  Future<bool> toggleTaskStar(String taskId) async {
    final task = _items.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return false;

    final updatedTask = task.copyWith(isStarred: !task.isStarred);
    return await updateTask(taskId, updatedTask);
  }

  /// Atualizar prioridade da task
  Future<bool> updateTaskPriority(String taskId, TaskPriority priority) async {
    final task = _items.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return false;

    final updatedTask = task.copyWith(priority: priority);
    return await updateTask(taskId, updatedTask);
  }

  /// Mover task para outra lista
  Future<bool> moveTaskToList(String taskId, String newListId) async {
    final task = _items.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return false;

    final updatedTask = task.copyWith(listId: newListId);
    return await updateTask(taskId, updatedTask);
  }

  // ========== Batch Operations ==========

  /// Completar múltiplas tasks
  Future<bool> completeMultipleTasks(List<String> taskIds) async {
    _isLoading.value = true;
    try {
      final tasksToUpdate = _items
          .where((task) => taskIds.contains(task.id))
          .map((task) => task.copyWith(isCompleted: true))
          .toList();

      final result = await _repository.updateBatchSafe(tasksToUpdate);
      return result.failureCount == 0;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Deletar múltiplas tasks
  Future<bool> deleteMultipleTasks(List<String> taskIds) async {
    _isLoading.value = true;
    try {
      for (final taskId in taskIds) {
        await _repository.delete(taskId);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ========== Filtering and Sorting ==========

  /// Filtrar tasks por lista
  List<Task> getTasksByListId(String listId) {
    return _items.where((task) => task.listId == listId).toList();
  }

  /// Filtrar tasks por prioridade
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _items.where((task) => task.priority == priority).toList();
  }

  /// Filtrar tasks por status
  List<Task> getTasksByStatus({required bool completed}) {
    return _items.where((task) => task.isCompleted == completed).toList();
  }

  /// Buscar tasks por texto
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _items.toList();
    
    final lowerQuery = query.toLowerCase();
    return _items.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
             (task.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // ========== Sync Operations ==========

  /// Forçar sincronização
  Future<void> forcSync() async {
    _isLoading.value = true;
    try {
      // Implementar lógica de force sync se disponível no repository
      await Future.delayed(TimeoutConstants.placeholderDelay); // Placeholder
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verificar status de sincronização
  bool get hasPendingSync {
    return _items.any((task) => task.needsSync);
  }

  // ========== Statistics ==========

  /// Obter estatísticas das tasks
  Map<String, dynamic> getTaskStats() {
    final total = _items.length;
    final completed = _completedTasksCount.value;
    final pending = _pendingTasksCount.value;
    final overdue = _overdueTasks.length;
    final starred = _starredTasks.length;

    final priorityStats = <String, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority.name] = _items
          .where((task) => task.priority == priority && !task.isCompleted)
          .length;
    }

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'starred': starred,
      'completion_rate': total > 0 ? (completed / total * 100).round() : 0,
      'priority_stats': priorityStats,
      'sync_status': syncStatus.toString(),
      'is_online': isOnline,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ========== Debug Helpers ==========

  /// Informações de debug (apenas em debug mode)
  Map<String, dynamic> getDebugInfo() {
    final debugService = DebugInfoService();
    
    final rawData = {
      'controller_state': {
        'items_count': _items.length,
        'is_loading': isLoading,
        'sync_status': syncStatus.toString(),
        'is_online': isOnline,
      },
      'repository_info': _repository.getDebugInfo(),
      'derived_states': {
        'today_tasks': _todayTasks.length,
        'starred_tasks': _starredTasks.length,
        'overdue_tasks': _overdueTasks.length,
        'completed_count': _completedTasksCount.value,
        'pending_count': _pendingTasksCount.value,
      },
      'subscriptions': _subscriptions.length,
      'component': 'RealtimeTaskController',
    };
    
    return debugService.getDebugInfo(rawData);
  }

  @override
  void onClose() {
    // Cancelar todas as subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    super.onClose();
  }
}

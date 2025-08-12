// Dart imports:
import 'dart:async';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../constants/error_messages.dart';
import '../constants/timeout_constants.dart';
import '../models/conflict_resolution.dart';
import '../models/task_model.dart';
import '../services/batch_operation_service.dart';
import '../services/conflict_resolution_service.dart';
import '../services/debug_info_service.dart';

/// Repository para Tasks usando SyncFirebaseService unificado
class TaskRepository {
  //#region === PROPERTIES ===
  late final SyncFirebaseService<Task> _syncService;
  late final ConflictResolutionService _conflictService;
  late final BatchOperationService _batchService;
  //#endregion

  TaskRepository({
    ConflictDetectionConfig? conflictConfig,
  }) {
    _syncService = SyncFirebaseService.getInstance<Task>(
      'tasks',
      Task.fromMap,
      (task) => task.toMap(),
    );
    _conflictService = ConflictResolutionService(
      config: conflictConfig ?? const ConflictDetectionConfig(),
    );
    _batchService = BatchOperationService();
  }

  //#region === INITIALIZATION ===
  /// Inicializar o repositório
  Future<void> initialize() async {
    await _syncService.initialize();
  }
  //#endregion

  //#region === DATA ACCESS ===
  /// Stream de todas as tasks
  Stream<List<Task>> get tasksStream => _syncService.dataStream;

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;

  /// Stream de conectividade
  Stream<bool> get connectivityStream => _syncService.connectivityStream;

  /// Buscar todas as tasks
  Future<List<Task>> findAll() => _syncService.findAll();

  /// Buscar task por ID
  Future<Task?> findById(String id) => _syncService.findById(id);

  /// Criar nova task
  Future<String> create(Task task) => _syncService.create(task);

  /// Atualizar task
  Future<void> update(String id, Task task) => _syncService.update(id, task);

  /// Atualizar task com verificação de conflitos (optimistic locking)
  Future<ConflictResolutionOutcome> updateWithConflictCheck(
      String id, Task updatedTask) async {
    // Buscar a versão atual no repositório
    final currentTask = await findById(id);
    if (currentTask == null) {
      throw Exception(ErrorMessages.formatErrorWithId(ErrorMessages.taskNotFoundForUpdate, id));
    }

    // Detectar conflitos
    final conflict = _conflictService.detectConflict(currentTask, updatedTask);

    if (conflict == null) {
      // Nenhum conflito detectado, prosseguir com a atualização
      await update(id, updatedTask);
      return ConflictResolutionOutcome(
        result: ConflictResolutionResult.noConflict,
        resolvedTask: updatedTask,
        appliedStrategy: ConflictResolutionStrategy.lastWriteWins,
        message: 'Task atualizada com sucesso',
      );
    }

    // Conflito detectado, tentar resolvê-lo
    final resolution = _conflictService.resolveConflict(conflict, null);

    if (resolution.isSuccess && resolution.resolvedTask != null) {
      // Conflito resolvido automaticamente
      await update(id, resolution.resolvedTask!);
    }

    return resolution;
  }

  /// Deletar task
  Future<void> delete(String id) => _syncService.delete(id);

  /// Criar múltiplas tasks
  Future<void> createBatch(List<Task> tasks) => _syncService.createBatch(tasks);

  /// Atualizar múltiplas tasks com verificação de conflitos e thread-safety
  Future<BatchOperationResult> updateBatchSafe(List<Task> tasks) async {
    // Usar BatchOperationService para operações thread-safe
    final operationId = 'update_batch_${DateTime.now().millisecondsSinceEpoch}';
    
    return await _batchService.executeBatchOperation(
      operationId,
      tasks,
      (task) => updateWithConflictCheck(task.id, task),
      useTransactions: true,
      maxConcurrency: 3, // Limitar concorrência para evitar overload
    );
  }

  /// Limpar todas as tasks
  Future<void> clear() => _syncService.clear();

  /// Forçar sincronização
  Future<void> forceSync() => _syncService.forceSync();

  // Métodos específicos para Tasks

  /// Stream de tasks por lista
  Stream<List<Task>> watchTasksByList(String listId) {
    return tasksStream.map((tasks) => tasks
        .where((task) => task.listId == listId && task.parentTaskId == null)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position)));
  }

  /// Stream de subtasks
  Stream<List<Task>> watchSubtasks(String parentTaskId) {
    return tasksStream.map((tasks) =>
        tasks.where((task) => task.parentTaskId == parentTaskId).toList()
          ..sort((a, b) => a.position.compareTo(b.position)));
  }

  /// Stream de tasks favoritas
  Stream<List<Task>> watchStarredTasks() {
    return tasksStream.map((tasks) =>
        tasks.where((task) => task.isStarred && !task.isCompleted).toList()
          ..sort((a, b) => (a.dueDate ?? DateTime(2099))
              .compareTo(b.dueDate ?? DateTime(2099))));
  }

  /// Stream de tasks para hoje
  Stream<List<Task>> watchTodayTasks() {
    return tasksStream.map((tasks) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(TimeoutConstants.oneDay);

      return tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.isAfter(startOfDay) &&
              task.dueDate!.isBefore(endOfDay) &&
              !task.isCompleted)
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    });
  }

  /// Stream de tasks atrasadas
  Stream<List<Task>> watchOverdueTasks() {
    return tasksStream.map((tasks) {
      final now = DateTime.now();
      return tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              !task.isCompleted)
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    });
  }

  /// Stream de tasks da semana
  Stream<List<Task>> watchWeekTasks() {
    return tasksStream.map((tasks) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(TimeoutConstants.oneWeek);

      return tasks
          .where((task) =>
              task.dueDate != null &&
              task.dueDate!.isAfter(weekStart) &&
              task.dueDate!.isBefore(weekEnd))
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    });
  }

  /// Stream de tasks por tag
  Stream<List<Task>> watchTasksByTag(String tag) {
    return tasksStream.map((tasks) =>
        tasks.where((task) => task.tags.contains(tag)).toList()
          ..sort((a, b) => a.position.compareTo(b.position)));
  }

  /// Buscar tasks por status
  Future<List<Task>> findByStatus(bool isCompleted) async {
    final tasks = await findAll();
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  /// Buscar tasks por prioridade
  Future<List<Task>> findByPriority(TaskPriority priority) async {
    final tasks = await findAll();
    return tasks.where((task) => task.priority == priority).toList();
  }

  /// Buscar subtasks de uma task pai
  Future<List<Task>> findSubtasks(String parentTaskId) async {
    final allTasks = await findAll();
    return allTasks.where((task) => task.parentTaskId == parentTaskId).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Atualizar status de uma task
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    final task = await findById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(isCompleted: isCompleted);
      updatedTask.markAsModified();
      await update(taskId, updatedTask);
    }
  }

  /// Atualizar status de uma task com verificação de conflitos
  Future<ConflictResolutionOutcome> updateTaskStatusSafe(
      String taskId, bool isCompleted) async {
    final task = await findById(taskId);
    if (task == null) {
      throw Exception(ErrorMessages.formatErrorWithId(ErrorMessages.taskNotFound, taskId));
    }

    final updatedTask = task.copyWith(isCompleted: isCompleted);
    updatedTask.markAsModified();

    return await updateWithConflictCheck(taskId, updatedTask);
  }

  /// Alternar status de favorito da task
  Future<void> toggleTaskStar(String taskId, bool isStarred) async {
    final task = await findById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(isStarred: isStarred);
      updatedTask.markAsModified();
      await update(taskId, updatedTask);
    }
  }

  /// Alternar status de favorito da task com verificação de conflitos
  Future<ConflictResolutionOutcome> toggleTaskStarSafe(
      String taskId, bool isStarred) async {
    final task = await findById(taskId);
    if (task == null) {
      throw Exception(ErrorMessages.formatErrorWithId(ErrorMessages.taskNotFound, taskId));
    }

    final updatedTask = task.copyWith(isStarred: isStarred);
    updatedTask.markAsModified();

    return await updateWithConflictCheck(taskId, updatedTask);
  }

  /// Atualizar posição da task (para drag & drop)
  Future<void> updateTaskPosition(String taskId, int newPosition) async {
    final task = await findById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(position: newPosition);
      updatedTask.markAsModified();
      await update(taskId, updatedTask);
    }
  }

  /// Criar subtask
  Future<String> createSubtask(String parentId, Task subtask) async {
    final subtaskWithParent = subtask.copyWith(parentTaskId: parentId);
    subtaskWithParent.markAsModified();
    return await create(subtaskWithParent);
  }

  /// Mover task para outra lista
  Future<void> moveTaskToList(String taskId, String newListId) async {
    final task = await findById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        listId: newListId,
        position: 0, // Resetar posição na nova lista
      );
      updatedTask.markAsModified();
      await update(taskId, updatedTask);
    }
  }

  /// Duplicar task
  Future<String> duplicateTask(String taskId) async {
    final originalTask = await findById(taskId);
    if (originalTask == null) {
      throw Exception(ErrorMessages.formatErrorWithId(ErrorMessages.taskNotFoundForDuplicate, taskId));
    }

    // Criar nova task baseada na original
    final duplicatedTask = Task(
      title: '${originalTask.title} (cópia)',
      description: originalTask.description,
      listId: originalTask.listId,
      createdById: originalTask.createdById,
      assignedToId: originalTask.assignedToId,
      dueDate: originalTask.dueDate,
      reminderDate: originalTask.reminderDate,
      isCompleted: false, // Sempre iniciar como não completa
      isStarred: originalTask.isStarred,
      priority: originalTask.priority,
      position: originalTask.position,
      tags: originalTask.tags,
      attachments: [], // Não duplicar attachments
      comments: [], // Não duplicar comments
      parentTaskId: originalTask.parentTaskId,
    );

    return await create(duplicatedTask);
  }

  /// Buscar tasks atrasadas
  Future<List<Task>> findOverdueTasks() async {
    final allTasks = await findAll();
    final now = DateTime.now();

    return allTasks
        .where((task) =>
            task.dueDate != null &&
            task.dueDate!.isBefore(now) &&
            !task.isCompleted)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  /// Buscar tasks por tag
  Future<List<Task>> findTasksByTag(String tag) async {
    final allTasks = await findAll();
    return allTasks.where((task) => task.tags.contains(tag)).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Obter informações de debug (apenas em debug mode)
  Map<String, dynamic> getDebugInfo() {
    final debugService = DebugInfoService();
    
    final rawData = {
      'sync_service_info': _syncService.getDebugInfo(),
      'component': 'TaskRepository',
    };
    
    return debugService.getDebugInfo(rawData);
  }

  /// Limpar recursos
  void dispose() {
    _syncService.dispose();
  }
}

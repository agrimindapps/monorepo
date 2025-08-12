// Dart imports:
import 'dart:async';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../constants/error_messages.dart';
import '../models/72_task_list.dart';

/// Repository para TaskList usando SyncFirebaseService unificado
class TaskListRepository {
  late final SyncFirebaseService<TaskList> _syncService;

  TaskListRepository() {
    _syncService = SyncFirebaseService.getInstance<TaskList>(
      'task_lists',
      TaskList.fromMap,
      (taskList) => taskList.toMap(),
    );
  }

  /// Inicializar o repositório
  Future<void> initialize() async {
    await _syncService.initialize();
  }

  /// Stream de todas as listas
  Stream<List<TaskList>> get taskListsStream => _syncService.dataStream;

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;

  /// Stream de conectividade
  Stream<bool> get connectivityStream => _syncService.connectivityStream;

  /// Buscar todas as listas
  Future<List<TaskList>> findAll() => _syncService.findAll();

  /// Buscar lista por ID
  Future<TaskList?> findById(String id) => _syncService.findById(id);

  /// Criar nova lista
  Future<String> create(TaskList taskList) => _syncService.create(taskList);

  /// Atualizar lista
  Future<void> update(String id, TaskList taskList) =>
      _syncService.update(id, taskList);

  /// Deletar lista
  Future<void> delete(String id) => _syncService.delete(id);

  /// Criar múltiplas listas
  Future<void> createBatch(List<TaskList> taskLists) =>
      _syncService.createBatch(taskLists);

  /// Limpar todas as listas
  Future<void> clear() => _syncService.clear();

  /// Forçar sincronização
  Future<void> forceSync() => _syncService.forceSync();

  // Métodos específicos para TaskList

  /// Stream de listas do usuário atual (não arquivadas)
  Stream<List<TaskList>> watchActiveTaskLists() {
    return taskListsStream.map((lists) =>
        lists.where((list) => !list.isArchived).toList()
          ..sort((a, b) => a.position.compareTo(b.position)));
  }

  /// Stream de listas arquivadas
  Stream<List<TaskList>> watchArchivedTaskLists() {
    return taskListsStream.map((lists) =>
        lists.where((list) => list.isArchived).toList()
          ..sort((a, b) => a.title.compareTo(b.title)));
  }

  /// Stream de listas compartilhadas
  Stream<List<TaskList>> watchSharedTaskLists() {
    return taskListsStream.map((lists) =>
        lists.where((list) => list.isShared).toList()
          ..sort((a, b) => a.title.compareTo(b.title)));
  }

  /// Stream de listas do usuário
  Stream<List<TaskList>> watchUserTaskLists(String userId) {
    return taskListsStream.map((lists) => lists
        .where(
            (list) => list.ownerId == userId || list.memberIds.contains(userId))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position)));
  }

  /// Buscar listas por owner
  Future<List<TaskList>> findByOwner(String ownerId) async {
    final lists = await findAll();
    return lists.where((list) => list.ownerId == ownerId).toList();
  }

  /// Buscar listas onde o usuário é membro
  Future<List<TaskList>> findByMember(String memberId) async {
    final lists = await findAll();
    return lists
        .where((list) =>
            list.ownerId == memberId || list.memberIds.contains(memberId))
        .toList();
  }

  /// Buscar listas por cor
  Future<List<TaskList>> findByColor(String color) async {
    final lists = await findAll();
    return lists.where((list) => list.color == color).toList();
  }

  /// Arquivar lista
  Future<void> archiveTaskList(String listId) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(isArchived: true);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Desarquivar lista
  Future<void> unarchiveTaskList(String listId) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(isArchived: false);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Compartilhar lista
  Future<void> shareTaskList(String listId, List<String> memberIds) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(
        isShared: true,
        memberIds: memberIds,
      );
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Parar de compartilhar lista
  Future<void> unshareTaskList(String listId) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(
        isShared: false,
        memberIds: [],
      );
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Adicionar membro à lista
  Future<void> addMember(String listId, String memberId) async {
    final taskList = await findById(listId);
    if (taskList != null && !taskList.memberIds.contains(memberId)) {
      final newMemberIds = [...taskList.memberIds, memberId];
      final updatedList = taskList.copyWith(memberIds: newMemberIds);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Remover membro da lista
  Future<void> removeMember(String listId, String memberId) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final newMemberIds =
          taskList.memberIds.where((id) => id != memberId).toList();
      final updatedList = taskList.copyWith(memberIds: newMemberIds);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Atualizar posição da lista
  Future<void> updatePosition(String listId, int newPosition) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(position: newPosition);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Atualizar cor da lista
  Future<void> updateColor(String listId, String newColor) async {
    final taskList = await findById(listId);
    if (taskList != null) {
      final updatedList = taskList.copyWith(color: newColor);
      updatedList.markAsModified();
      await update(listId, updatedList);
    }
  }

  /// Duplicar lista (sem as tasks)
  Future<String> duplicateTaskList(String listId) async {
    final originalList = await findById(listId);
    if (originalList == null) {
      throw Exception(ErrorMessages.formatErrorWithId(ErrorMessages.taskListNotFoundForDuplicate, listId));
    }

    final duplicatedList = TaskList(
      title: '${originalList.title} (cópia)',
      description: originalList.description,
      color: originalList.color,
      ownerId: originalList.ownerId,
      memberIds: [], // Não duplicar membros
      isShared: false, // Não compartilhar a cópia
      isArchived: false,
      position: 0,
    );

    return await create(duplicatedList);
  }

  /// Verificar se usuário tem acesso à lista
  Future<bool> hasAccess(String listId, String userId) async {
    final taskList = await findById(listId);
    if (taskList == null) return false;

    return taskList.ownerId == userId || taskList.memberIds.contains(userId);
  }

  /// Obter informações de debug
  Map<String, dynamic> getDebugInfo() => _syncService.getDebugInfo();

  /// Limpar recursos
  void dispose() {
    _syncService.dispose();
  }
}

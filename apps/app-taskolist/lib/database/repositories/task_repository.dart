import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../taskolist_database.dart';
import '../tables/tasks_table.dart';
import '../../features/tasks/domain/task_entity.dart';

/// ============================================================================
/// TASK REPOSITORY - Padrão DriftRepositoryBase
/// ============================================================================
///
/// Repository de Tasks usando DriftRepositoryBase do core.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos (watchAll, watchById)
/// - Queries tipadas type-safe
/// - Sync helpers (getDirty, markAsSynced)
/// - Conversão TaskData <-> TaskEntity
///
/// **USO:**
/// ```dart
/// final repo = TaskRepository(database);
/// final result = await repo.getTasksByList(listId, userId);
/// ```
/// ============================================================================

class TaskRepository extends DriftRepositoryBase<TaskData, Tasks> {
  TaskRepository(TaskolistDatabase db)
      : _db = db,
        super(
          database: db,
          table: db.tasks,
        );

  final TaskolistDatabase _db;

  @override
  String get tableName => 'tasks';

  @override
  GeneratedColumn get idColumn => _db.tasks.id;

  // ==================== QUERIES POR LISTA ====================

  /// Busca tasks de uma lista específica
  Future<Result<List<TaskData>>> getTasksByList(
    String listId,
    String userId,
  ) async {
    return findWhere(
      (t) =>
          t.listId.equals(listId) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Stream de tasks de uma lista (reativo)
  Stream<List<TaskData>> watchTasksByList(String listId, String userId) {
    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.listId.equals(listId) &
                t.isDeleted.equals(false) &
                (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  // ==================== QUERIES POR STATUS ====================

  /// Busca tasks pendentes
  Future<Result<List<TaskData>>> getPendingTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.pending.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks em progresso
  Future<Result<List<TaskData>>> getInProgressTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.inProgress.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks completadas
  Future<Result<List<TaskData>>> getCompletedTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.completed.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks com estrela
  Future<Result<List<TaskData>>> getStarredTasks(String userId) async {
    return findWhere(
      (t) =>
          t.isStarred.equals(true) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  // ==================== QUERIES ESPECIAIS ====================

  /// Busca tasks vencidas
  Future<Result<List<TaskData>>> getOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      final results = await (_db.select(_db.tasks)
            ..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.dueDate.isSmallerThanValue(now) &
                  t.status.isNotValue(TaskStatus.completed.index) &
                  t.status.isNotValue(TaskStatus.cancelled.index) &
                  (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
            ))
          .get();

      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca task pelo firebaseId
  Future<Result<TaskData?>> getByFirebaseId(String firebaseId) async {
    try {
      final result = await (_db.select(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .getSingleOrNull();

      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== SYNC HELPERS ====================

  /// Busca tasks dirty (pendentes de sync)
  Future<Result<List<TaskData>>> getDirtyTasks() async {
    return findWhere((t) => t.isDirty.equals(true));
  }

  /// Marca task como sincronizada
  Future<Result<int>> markAsSynced(String firebaseId) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ),
      );

      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Marca múltiplas tasks como sincronizadas
  Future<Result<int>> markAllAsSynced(List<String> firebaseIds) async {
    try {
      int total = 0;
      for (final id in firebaseIds) {
        final result = await markAsSynced(id);
        if (result.isSuccess) total += result.data!;
      }
      return Result.success(total);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== UPSERT ====================

  /// Upsert por firebaseId
  Future<Result<int>> upsertByFirebaseId(TasksCompanion task) async {
    try {
      final existing = await getByFirebaseId(task.firebaseId.value);

      if (existing.isSuccess && existing.data != null) {
        // Update
        final updated = await (_db.update(_db.tasks)
              ..where((t) => t.firebaseId.equals(task.firebaseId.value)))
            .write(task);
        return Result.success(updated);
      } else {
        // Insert
        final id = await _db.into(_db.tasks).insert(task);
        return Result.success(id);
      }
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== SOFT DELETE ====================

  /// Soft delete de task
  Future<Result<int>> softDelete(String firebaseId) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          isDeleted: const Value(true),
          isDirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== UPDATE HELPERS ====================

  /// Atualiza status da task
  Future<Result<int>> updateStatus(String firebaseId, TaskStatus status) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          status: Value(status.index),
          isDirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Toggle estrela
  Future<Result<int>> toggleStar(String firebaseId, bool isStarred) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          isStarred: Value(isStarred),
          isDirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Atualiza prioridade
  Future<Result<int>> updatePriority(
    String firebaseId,
    TaskPriority priority,
  ) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          priority: Value(priority.index),
          isDirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta tasks por status
  Future<Result<Map<TaskStatus, int>>> getTaskCountsByStatus(
    String userId,
  ) async {
    try {
      final counts = <TaskStatus, int>{};

      for (final status in TaskStatus.values) {
        final count = _db.tasks.id.count();
        final query = _db.selectOnly(_db.tasks)
          ..addColumns([count])
          ..where(
            _db.tasks.status.equals(status.index) &
                _db.tasks.isDeleted.equals(false) &
                (_db.tasks.createdById.equals(userId) |
                    _db.tasks.assignedToId.equals(userId)),
          );

        final result = await query.getSingle();
        counts[status] = result.read(count) ?? 0;
      }

      return Result.success(counts);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}

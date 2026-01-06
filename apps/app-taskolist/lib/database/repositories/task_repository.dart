import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../tables/tasks_table.dart';
import '../taskolist_database.dart';

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
  Future<Either<Failure, List<TaskData>>> getTasksByList(
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
  Future<Either<Failure, List<TaskData>>> getPendingTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.pending.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks em progresso
  Future<Either<Failure, List<TaskData>>> getInProgressTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.inProgress.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks completadas
  Future<Either<Failure, List<TaskData>>> getCompletedTasks(String userId) async {
    return findWhere(
      (t) =>
          t.status.equals(TaskStatus.completed.index) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  /// Busca tasks com estrela
  Future<Either<Failure, List<TaskData>>> getStarredTasks(String userId) async {
    return findWhere(
      (t) =>
          t.isStarred.equals(true) &
          t.isDeleted.equals(false) &
          (t.createdById.equals(userId) | t.assignedToId.equals(userId)),
    );
  }

  // ==================== QUERIES ESPECIAIS ====================

  /// Busca tasks vencidas
  Future<Either<Failure, List<TaskData>>> getOverdueTasks(String userId) async {
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

      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca task pelo firebaseId
  Future<Either<Failure, TaskData?>> getByFirebaseId(String firebaseId) async {
    try {
      final result = await (_db.select(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .getSingleOrNull();

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== SYNC HELPERS ====================

  /// Busca tasks dirty (pendentes de sync)
  Future<Either<Failure, List<TaskData>>> getDirtyTasks() async {
    return findWhere((t) => t.isDirty.equals(true));
  }

  /// Marca task como sincronizada
  Future<Either<Failure, int>> markAsSynced(String firebaseId) async {
    try {
      final updated = await (_db.update(_db.tasks)
            ..where((t) => t.firebaseId.equals(firebaseId)))
          .write(
        TasksCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ),
      );

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Marca múltiplas tasks como sincronizadas
  Future<Either<Failure, int>> markAllAsSynced(List<String> firebaseIds) async {
    try {
      int total = 0;
      for (final id in firebaseIds) {
        final result = await markAsSynced(id);
        result.fold(
          (l) => null,
          (count) => total += count,
        );
      }
      return Right(total);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== UPSERT ====================

  /// Upsert por firebaseId
  Future<Either<Failure, int>> upsertByFirebaseId(TasksCompanion task) async {
    try {
      final existing = await getByFirebaseId(task.firebaseId.value);

      return existing.fold(
        (failure) async {
          // Insert (não encontrou)
          final id = await _db.into(_db.tasks).insert(task);
          return Right(id);
        },
        (taskData) async {
          if (taskData != null) {
            // Update
            final updated = await (_db.update(_db.tasks)
                  ..where((t) => t.firebaseId.equals(task.firebaseId.value)))
                .write(task);
            return Right(updated);
          } else {
            // Insert
            final id = await _db.into(_db.tasks).insert(task);
            return Right(id);
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== SOFT DELETE ====================

  /// Soft delete de task
  Future<Either<Failure, int>> softDelete(String firebaseId) async {
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

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== UPDATE HELPERS ====================

  /// Atualiza status da task
  Future<Either<Failure, int>> updateStatus(String firebaseId, TaskStatus status) async {
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

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Toggle estrela
  Future<Either<Failure, int>> toggleStar(String firebaseId, bool isStarred) async {
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

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Atualiza prioridade
  Future<Either<Failure, int>> updatePriority(
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

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta tasks por status
  Future<Either<Failure, Map<TaskStatus, int>>> getTaskCountsByStatus(
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

      return Right(counts);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }
}

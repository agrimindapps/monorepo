import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

import '../../features/tasks/data/my_day_task_extensions.dart';
import '../../features/tasks/domain/my_day_repository.dart';
import '../../features/tasks/domain/my_day_task_entity.dart';
import '../taskolist_database.dart';

/// ============================================================================
/// MY DAY REPOSITORY - Implementação Drift
/// ============================================================================
///
/// Repository para gerenciar tarefas do "Meu Dia".
///
/// **CARACTERÍSTICAS:**
/// - CRUD com Result/Either para error handling
/// - Queries otimizadas (índices composite)
/// - Conversão MyDayTaskData <-> MyDayTaskEntity
/// - Histórico de dias (para estatísticas)
///
/// **USO:**
/// ```dart
/// final repo = MyDayTaskRepository(database);
/// final result = await repo.getActiveByDate(today);
/// ```
/// ============================================================================

class MyDayTaskRepository implements MyDayRepository {
  final TaskolistDatabase _db;

  MyDayTaskRepository(this._db);

  /// Helper para normalizar data (00:00:00)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Future<Either<Failure, MyDayTaskEntity>> add(MyDayTaskEntity myDayTask) async {
    try {
      await _db.into(_db.myDayTasks).insert(myDayTask.toCompanion());
      return Right(myDayTask);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao adicionar tarefa ao Meu Dia: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(MyDayTaskEntity myDayTask) async {
    try {
      await (_db.update(_db.myDayTasks)
            ..where((t) => t.id.equals(myDayTask.id)))
          .write(myDayTask.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao atualizar tarefa do Meu Dia: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MyDayTaskEntity>>> getActiveByDate(
    DateTime date,
  ) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final query = _db.select(_db.myDayTasks)
        ..where((t) =>
            t.dayDate.isBiggerOrEqualValue(normalizedDate) &
            t.dayDate.isSmallerThanValue(nextDay) &
            t.wasCompleted.equals(false) &
            t.wasRemoved.equals(false) &
            t.isArchived.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.addedAt)]);

      final results = await query.get();
      return Right(results.map((data) => data.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Erro ao buscar tarefas do Meu Dia: $e'));
    }
  }

  @override
  Future<MyDayTaskEntity?> getByTaskAndDate(
    String taskId,
    DateTime date,
  ) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final query = _db.select(_db.myDayTasks)
        ..where((t) =>
            t.taskId.equals(taskId) &
            t.dayDate.isBiggerOrEqualValue(normalizedDate) &
            t.dayDate.isSmallerThanValue(nextDay))
        ..limit(1);

      final results = await query.get();
      return results.isEmpty ? null : results.first.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> archiveOldTasks() async {
    try {
      final today = _normalizeDate(DateTime.now());

      await (_db.update(_db.myDayTasks)
            ..where((t) => t.dayDate.isSmallerThanValue(today)))
          .write(const MyDayTasksCompanion(isArchived: Value(true)));

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao arquivar tarefas antigas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MyDayTaskEntity>>> getHistoryByDate(
    DateTime date,
  ) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final query = _db.select(_db.myDayTasks)
        ..where((t) =>
            t.dayDate.isBiggerOrEqualValue(normalizedDate) &
            t.dayDate.isSmallerThanValue(nextDay))
        ..orderBy([(t) => OrderingTerm.asc(t.addedAt)]);

      final results = await query.get();
      return Right(results.map((data) => data.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Erro ao buscar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String taskId, DateTime date) async {
    try {
      final existing = await getByTaskAndDate(taskId, date);
      
      if (existing == null) {
        return Left(NotFoundFailure('Tarefa não encontrada no Meu Dia'));
      }

      final updated = existing.markAsRemoved();
      return await update(updated);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao remover tarefa do Meu Dia: $e'));
    }
  }

  /// Stream reativo de tarefas do Meu Dia de uma data
  Stream<List<MyDayTaskEntity>> watchActiveByDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    return (_db.select(_db.myDayTasks)
          ..where((t) =>
              t.dayDate.isBiggerOrEqualValue(normalizedDate) &
              t.dayDate.isSmallerThanValue(nextDay) &
              t.wasCompleted.equals(false) &
              t.wasRemoved.equals(false) &
              t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.addedAt)]))
        .watch()
        .map((list) => list.map((data) => data.toEntity()).toList());
  }
}

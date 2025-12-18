import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/typedef.dart';
import '../domain/task_list_entity.dart';
import '../domain/task_list_repository.dart';
import 'task_list_firebase_datasource.dart';

class TaskListRepositoryImpl implements TaskListRepository {
  final TaskListFirebaseDatasource _remoteDatasource;

  const TaskListRepositoryImpl({
    required TaskListFirebaseDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  ResultFuture<String> createTaskList(TaskListEntity taskList) async {
    try {
      final id = await _remoteDatasource.createTaskList(taskList);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure('Erro ao criar lista: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<TaskListEntity> getTaskList(String id) async {
    try {
      final taskList = await _remoteDatasource.getTaskList(id);
      return Right(taskList);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar lista: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<TaskListEntity>> getTaskLists({
    String? userId,
    bool? isArchived,
  }) async {
    try {
      final taskLists = await _remoteDatasource.getTaskLists();
      return Right(taskLists);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar listas: ${e.toString()}'));
    }
  }

  @override
  Stream<List<TaskListEntity>> watchTaskLists({
    String? userId,
    bool? isArchived,
  }) {
    return _remoteDatasource.watchTaskLists(
      userId: userId,
      isArchived: isArchived ?? false,
    );
  }

  @override
  ResultFuture<void> updateTaskList(TaskListEntity taskList) async {
    try {
      await _remoteDatasource.updateTaskList(taskList);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar lista: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteTaskList(String id) async {
    try {
      await _remoteDatasource.deleteTaskList(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar lista: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> shareTaskList(String id, List<String> memberIds) async {
    try {
      await _remoteDatasource.shareTaskList(id, memberIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao compartilhar lista: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> archiveTaskList(String id) async {
    try {
      await _remoteDatasource.archiveTaskList(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao arquivar lista: ${e.toString()}'));
    }
  }
}
